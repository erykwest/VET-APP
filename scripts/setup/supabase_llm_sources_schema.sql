-- LLM trusted sources catalog and retrieval schema.
-- Note: the vector size is set to 1536 for an embedding model in that range.
-- If you choose a different embedding model, adjust the vector dimensions
-- before ingesting any real chunks.

create extension if not exists vector with schema extensions;
create extension if not exists pgcrypto with schema extensions;

create schema if not exists ai;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

create table if not exists ai.trusted_source_domains (
    id uuid primary key default extensions.gen_random_uuid(),
    host text not null unique,
    display_name text not null,
    base_url text not null,
    source_kind text not null check (
        source_kind in (
            'journal',
            'guideline_body',
            'publisher',
            'government',
            'university',
            'association',
            'knowledge_base',
            'other'
        )
    ),
    allow_subdomains boolean not null default true,
    is_active boolean not null default true,
    authority_score numeric(4,3) not null default 0.500 check (
        authority_score >= 0 and authority_score <= 1
    ),
    veterinary_relevance_score numeric(4,3) not null default 0.500 check (
        veterinary_relevance_score >= 0 and veterinary_relevance_score <= 1
    ),
    evidence_policy text not null default 'curated_only' check (
        evidence_policy in ('curated_only', 'allow_manual_docs', 'allow_auto_ingest')
    ),
    notes text,
    metadata jsonb not null default '{}'::jsonb,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ai.source_documents (
    id uuid primary key default extensions.gen_random_uuid(),
    domain_id uuid not null references ai.trusted_source_domains(id) on delete restrict,
    canonical_url text not null,
    url_host text not null,
    title text not null,
    document_kind text not null default 'other' check (
        document_kind in (
            'guideline',
            'consensus',
            'systematic_review',
            'meta_analysis',
            'review',
            'trial',
            'cohort',
            'case_series',
            'reference_page',
            'abstract',
            'other'
        )
    ),
    journal_name text,
    publisher text,
    doi text,
    pmid text,
    pmcid text,
    publication_date date,
    publication_year integer,
    language_code text not null default 'en',
    species_tags text[] not null default '{}'::text[],
    clinical_domain text[] not null default '{}'::text[],
    reliability_tier text not null default 'D' check (
        reliability_tier in ('A', 'B', 'C', 'D')
    ),
    trust_score numeric(4,3) not null default 0.500 check (
        trust_score >= 0 and trust_score <= 1
    ),
    peer_reviewed boolean not null default true,
    is_preprint boolean not null default false,
    is_retracted boolean not null default false,
    eligible_for_rag boolean not null default false,
    ingestion_status text not null default 'pending' check (
        ingestion_status in ('pending', 'ingested', 'blocked', 'archived', 'error')
    ),
    summary text,
    source_text text,
    source_text_sha256 text,
    metadata jsonb not null default '{}'::jsonb,
    last_verified_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create unique index if not exists idx_source_documents_canonical_url
    on ai.source_documents (lower(canonical_url));

create index if not exists idx_source_documents_domain_id
    on ai.source_documents (domain_id);

create index if not exists idx_source_documents_species_tags
    on ai.source_documents using gin (species_tags);

create index if not exists idx_source_documents_clinical_domain
    on ai.source_documents using gin (clinical_domain);

create index if not exists idx_source_documents_rag
    on ai.source_documents (eligible_for_rag, reliability_tier);

create table if not exists ai.source_document_chunks (
    id uuid primary key default extensions.gen_random_uuid(),
    document_id uuid not null references ai.source_documents(id) on delete cascade,
    chunk_index integer not null,
    section_label text,
    content text not null,
    token_count integer,
    embedding_model text,
    embedding extensions.vector(1536),
    metadata jsonb not null default '{}'::jsonb,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (document_id, chunk_index)
);

create index if not exists idx_source_document_chunks_document_id
    on ai.source_document_chunks (document_id);

create index if not exists idx_source_document_chunks_embedding
    on ai.source_document_chunks
    using hnsw (embedding extensions.vector_cosine_ops);

create table if not exists ai.answer_audits (
    id uuid primary key default extensions.gen_random_uuid(),
    app_conversation_id text,
    user_query text not null,
    species_filter text,
    clinical_domain_filter text,
    provider_name text not null,
    provider_model text not null,
    selected_document_ids uuid[] not null default '{}'::uuid[],
    selected_chunk_ids uuid[] not null default '{}'::uuid[],
    response_confidence text,
    prompt_snapshot text,
    created_at timestamptz not null default now()
);

drop trigger if exists trg_trusted_source_domains_set_updated_at on ai.trusted_source_domains;
create trigger trg_trusted_source_domains_set_updated_at
before update on ai.trusted_source_domains
for each row
execute function public.set_updated_at();

drop trigger if exists trg_source_documents_set_updated_at on ai.source_documents;
create trigger trg_source_documents_set_updated_at
before update on ai.source_documents
for each row
execute function public.set_updated_at();

drop trigger if exists trg_source_document_chunks_set_updated_at on ai.source_document_chunks;
create trigger trg_source_document_chunks_set_updated_at
before update on ai.source_document_chunks
for each row
execute function public.set_updated_at();

alter table ai.trusted_source_domains enable row level security;
alter table ai.source_documents enable row level security;
alter table ai.source_document_chunks enable row level security;
alter table ai.answer_audits enable row level security;

drop policy if exists trusted_source_domains_read_backend on ai.trusted_source_domains;
create policy trusted_source_domains_read_backend
on ai.trusted_source_domains
for select
to authenticated
using (false);

drop policy if exists source_documents_read_backend on ai.source_documents;
create policy source_documents_read_backend
on ai.source_documents
for select
to authenticated
using (false);

drop policy if exists source_document_chunks_read_backend on ai.source_document_chunks;
create policy source_document_chunks_read_backend
on ai.source_document_chunks
for select
to authenticated
using (false);

drop policy if exists answer_audits_write_backend on ai.answer_audits;
create policy answer_audits_write_backend
on ai.answer_audits
for insert
to authenticated
with check (false);

create or replace function ai.tier_rank(tier text)
returns integer
language sql
immutable
as $$
    select case upper(coalesce(tier, 'D'))
        when 'A' then 4
        when 'B' then 3
        when 'C' then 2
        else 1
    end;
$$;

create or replace function ai.match_source_chunks(
    query_embedding extensions.vector(1536),
    match_count integer default 8,
    species_filter text default null,
    domain_filter text default null,
    min_tier text default 'C'
)
returns table (
    chunk_id uuid,
    document_id uuid,
    title text,
    canonical_url text,
    document_kind text,
    reliability_tier text,
    trust_score numeric,
    section_label text,
    content text,
    similarity double precision
)
language sql
stable
as $$
    select
        c.id as chunk_id,
        d.id as document_id,
        d.title,
        d.canonical_url,
        d.document_kind,
        d.reliability_tier,
        d.trust_score,
        c.section_label,
        c.content,
        1 - (c.embedding <=> query_embedding) as similarity
    from ai.source_document_chunks c
    join ai.source_documents d on d.id = c.document_id
    where d.eligible_for_rag = true
      and d.is_retracted = false
      and ai.tier_rank(d.reliability_tier) >= ai.tier_rank(min_tier)
      and (
          species_filter is null
          or species_filter = any(d.species_tags)
          or 'other' = any(d.species_tags)
      )
      and (
          domain_filter is null
          or domain_filter = any(d.clinical_domain)
      )
    order by
        c.embedding <=> query_embedding,
        d.trust_score desc
    limit greatest(match_count, 1);
$$;

insert into ai.trusted_source_domains (
    host,
    display_name,
    base_url,
    source_kind,
    authority_score,
    veterinary_relevance_score,
    evidence_policy,
    notes
)
values
    (
        'pubmed.ncbi.nlm.nih.gov',
        'PubMed',
        'https://pubmed.ncbi.nlm.nih.gov',
        'knowledge_base',
        0.980,
        0.850,
        'allow_auto_ingest',
        'Indicizzazione primaria per abstract e metadata biomedici.'
    ),
    (
        'pmc.ncbi.nlm.nih.gov',
        'PubMed Central',
        'https://pmc.ncbi.nlm.nih.gov',
        'knowledge_base',
        0.990,
        0.850,
        'allow_auto_ingest',
        'Preferibile per full text open access.'
    ),
    (
        'wsava.org',
        'WSAVA',
        'https://wsava.org',
        'association',
        0.950,
        0.980,
        'allow_manual_docs',
        'Guideline e position statement di alto valore pratico.'
    ),
    (
        'aaha.org',
        'AAHA',
        'https://www.aaha.org',
        'association',
        0.930,
        0.960,
        'allow_manual_docs',
        'Fonte utile per guideline e standard clinici companion animals.'
    ),
    (
        'merckvetmanual.com',
        'Merck Veterinary Manual',
        'https://www.merckvetmanual.com',
        'knowledge_base',
        0.900,
        0.970,
        'allow_manual_docs',
        'Knowledge base secondaria, non sostituisce guideline o review.'
    )
on conflict (host) do update
set
    display_name = excluded.display_name,
    base_url = excluded.base_url,
    source_kind = excluded.source_kind,
    authority_score = excluded.authority_score,
    veterinary_relevance_score = excluded.veterinary_relevance_score,
    evidence_policy = excluded.evidence_policy,
    notes = excluded.notes,
    updated_at = now();
