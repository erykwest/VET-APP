alter table public.pet_profiles add column if not exists birth_date text;
alter table public.pet_profiles add column if not exists weight_kg double precision;
alter table public.pet_profiles add column if not exists microchip_code text;
alter table public.pet_profiles add column if not exists neutered boolean;

create table if not exists public.clinical_documents (
    id text primary key,
    owner_id text not null,
    pet_id text not null references public.pet_profiles(id) on delete cascade,
    title text not null,
    document_type text not null,
    document_date date not null,
    summary text,
    source text,
    file_path text,
    original_filename text,
    extracted_text_summary text,
    status text not null default 'uploaded',
    verified_by_user boolean not null default false,
    created_at timestamptz not null default now()
);

create table if not exists public.clinical_events (
    id text primary key,
    owner_id text not null,
    pet_id text not null references public.pet_profiles(id) on delete cascade,
    event_type text not null,
    title text not null,
    event_date date not null,
    summary text,
    severity text,
    source text,
    linked_document_id text references public.clinical_documents(id) on delete set null,
    created_at timestamptz not null default now()
);

create index if not exists idx_clinical_documents_owner_id on public.clinical_documents(owner_id);
create index if not exists idx_clinical_documents_pet_id on public.clinical_documents(pet_id);
create index if not exists idx_clinical_documents_pet_date on public.clinical_documents(pet_id, document_date desc);
create index if not exists idx_clinical_events_owner_id on public.clinical_events(owner_id);
create index if not exists idx_clinical_events_pet_id on public.clinical_events(pet_id);
create index if not exists idx_clinical_events_pet_date on public.clinical_events(pet_id, event_date desc);

alter table public.clinical_documents enable row level security;
alter table public.clinical_events enable row level security;

insert into storage.buckets (id, name, public)
values ('clinical-documents', 'clinical-documents', false)
on conflict (id) do nothing;

drop policy if exists clinical_documents_select_own on public.clinical_documents;
create policy clinical_documents_select_own
on public.clinical_documents
for select
using (owner_id = auth.uid()::text);

drop policy if exists clinical_documents_insert_own on public.clinical_documents;
create policy clinical_documents_insert_own
on public.clinical_documents
for insert
with check (
    owner_id = auth.uid()::text
    and exists (
        select 1
        from public.pet_profiles
        where public.pet_profiles.id = public.clinical_documents.pet_id
          and public.pet_profiles.owner_id = auth.uid()::text
    )
);

drop policy if exists clinical_documents_update_own on public.clinical_documents;
create policy clinical_documents_update_own
on public.clinical_documents
for update
using (owner_id = auth.uid()::text)
with check (
    owner_id = auth.uid()::text
    and exists (
        select 1
        from public.pet_profiles
        where public.pet_profiles.id = public.clinical_documents.pet_id
          and public.pet_profiles.owner_id = auth.uid()::text
    )
);

drop policy if exists clinical_documents_delete_own on public.clinical_documents;
create policy clinical_documents_delete_own
on public.clinical_documents
for delete
using (owner_id = auth.uid()::text);

drop policy if exists clinical_events_select_own on public.clinical_events;
create policy clinical_events_select_own
on public.clinical_events
for select
using (owner_id = auth.uid()::text);

drop policy if exists clinical_events_insert_own on public.clinical_events;
create policy clinical_events_insert_own
on public.clinical_events
for insert
with check (
    owner_id = auth.uid()::text
    and exists (
        select 1
        from public.pet_profiles
        where public.pet_profiles.id = public.clinical_events.pet_id
          and public.pet_profiles.owner_id = auth.uid()::text
    )
);

drop policy if exists clinical_events_update_own on public.clinical_events;
create policy clinical_events_update_own
on public.clinical_events
for update
using (owner_id = auth.uid()::text)
with check (
    owner_id = auth.uid()::text
    and exists (
        select 1
        from public.pet_profiles
        where public.pet_profiles.id = public.clinical_events.pet_id
          and public.pet_profiles.owner_id = auth.uid()::text
    )
);

drop policy if exists clinical_events_delete_own on public.clinical_events;
create policy clinical_events_delete_own
on public.clinical_events
for delete
using (owner_id = auth.uid()::text);
