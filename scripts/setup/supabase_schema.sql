create table if not exists public.pet_profiles (
    id text primary key,
    owner_id text not null,
    name text not null,
    species text not null,
    breed text,
    age_years integer,
    notes text,
    birth_date_label text,
    sex text,
    weight_label text,
    health_badge text,
    next_visit_label text,
    avatar_key text,
    profile_image_data_url text,
    gallery_provider text
);

alter table public.pet_profiles add column if not exists birth_date text;
alter table public.pet_profiles add column if not exists weight_kg double precision;
alter table public.pet_profiles add column if not exists microchip_code text;
alter table public.pet_profiles add column if not exists neutered boolean;

create table if not exists public.conversations (
    id text primary key,
    owner_id text not null,
    pet_id text not null references public.pet_profiles(id) on delete cascade,
    title text not null,
    messages jsonb not null default '[]'::jsonb
);

create table if not exists public.reminders (
    id text primary key,
    owner_id text not null,
    pet_id text not null references public.pet_profiles(id) on delete cascade,
    title text not null,
    due_date date not null,
    notes text
);

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

create index if not exists idx_pet_profiles_owner_id on public.pet_profiles(owner_id);
create index if not exists idx_conversations_owner_id on public.conversations(owner_id);
create index if not exists idx_conversations_pet_id on public.conversations(pet_id);
create index if not exists idx_reminders_owner_id on public.reminders(owner_id);
create index if not exists idx_reminders_pet_id on public.reminders(pet_id);
create index if not exists idx_clinical_documents_owner_id on public.clinical_documents(owner_id);
create index if not exists idx_clinical_documents_pet_id on public.clinical_documents(pet_id);
create index if not exists idx_clinical_documents_pet_date on public.clinical_documents(pet_id, document_date desc);

alter table public.pet_profiles enable row level security;
alter table public.conversations enable row level security;
alter table public.reminders enable row level security;
alter table public.clinical_documents enable row level security;

drop policy if exists pet_profiles_select_own on public.pet_profiles;
create policy pet_profiles_select_own
on public.pet_profiles
for select
using (owner_id = auth.uid()::text);

drop policy if exists pet_profiles_insert_own on public.pet_profiles;
create policy pet_profiles_insert_own
on public.pet_profiles
for insert
with check (owner_id = auth.uid()::text);

drop policy if exists pet_profiles_update_own on public.pet_profiles;
create policy pet_profiles_update_own
on public.pet_profiles
for update
using (owner_id = auth.uid()::text)
with check (owner_id = auth.uid()::text);

drop policy if exists pet_profiles_delete_own on public.pet_profiles;
create policy pet_profiles_delete_own
on public.pet_profiles
for delete
using (owner_id = auth.uid()::text);

drop policy if exists conversations_select_own on public.conversations;
create policy conversations_select_own
on public.conversations
for select
using (owner_id = auth.uid()::text);

drop policy if exists conversations_insert_own on public.conversations;
create policy conversations_insert_own
on public.conversations
for insert
with check (
    owner_id = auth.uid()::text
    and exists (
        select 1
        from public.pet_profiles
        where public.pet_profiles.id = public.conversations.pet_id
          and public.pet_profiles.owner_id = auth.uid()::text
    )
);

drop policy if exists conversations_update_own on public.conversations;
create policy conversations_update_own
on public.conversations
for update
using (owner_id = auth.uid()::text)
with check (
    owner_id = auth.uid()::text
    and exists (
        select 1
        from public.pet_profiles
        where public.pet_profiles.id = public.conversations.pet_id
          and public.pet_profiles.owner_id = auth.uid()::text
    )
);

drop policy if exists conversations_delete_own on public.conversations;
create policy conversations_delete_own
on public.conversations
for delete
using (owner_id = auth.uid()::text);

drop policy if exists reminders_select_own on public.reminders;
create policy reminders_select_own
on public.reminders
for select
using (owner_id = auth.uid()::text);

drop policy if exists reminders_insert_own on public.reminders;
create policy reminders_insert_own
on public.reminders
for insert
with check (
    owner_id = auth.uid()::text
    and exists (
        select 1
        from public.pet_profiles
        where public.pet_profiles.id = public.reminders.pet_id
          and public.pet_profiles.owner_id = auth.uid()::text
    )
);

drop policy if exists reminders_update_own on public.reminders;
create policy reminders_update_own
on public.reminders
for update
using (owner_id = auth.uid()::text)
with check (
    owner_id = auth.uid()::text
    and exists (
        select 1
        from public.pet_profiles
        where public.pet_profiles.id = public.reminders.pet_id
          and public.pet_profiles.owner_id = auth.uid()::text
    )
);

drop policy if exists reminders_delete_own on public.reminders;
create policy reminders_delete_own
on public.reminders
for delete
using (owner_id = auth.uid()::text);

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
