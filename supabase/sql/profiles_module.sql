-- ==========================================================
-- Script SQL: module profil utilisateur pour CashOut
-- ==========================================================

alter table if exists public.profiles
  add column if not exists address text,
  add column if not exists department text,
  add column if not exists job_title text,
  add column if not exists birth_date date,
  add column if not exists hire_date date,
  add column if not exists notifications_enabled boolean default true,
  add column if not exists language text default 'fr',
  add column if not exists font_scale numeric default 1.0,
  add column if not exists last_login_at timestamptz;

create table if not exists public.user_login_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  logged_at timestamptz not null default now(),
  ip_address text,
  user_agent text
);

alter table public.user_login_history enable row level security;

drop policy if exists "Users read own login history" on public.user_login_history;
create policy "Users read own login history"
  on public.user_login_history
  for select
  using (auth.uid() = user_id);

drop policy if exists "Users manage own profile" on public.profiles;
create policy "Users manage own profile"
  on public.profiles
  for all
  using (auth.uid() = id)
  with check (auth.uid() = id);

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists "Avatar read public" on storage.objects;
create policy "Avatar read public"
on storage.objects
for select
using (bucket_id = 'avatars');

drop policy if exists "Avatar write own folder" on storage.objects;
create policy "Avatar write own folder"
on storage.objects
for all
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);
