-- NIM: 2415051039 | Nama: Agus Prasetya
-- Tahap 3: tabel profiles, RLS, dan trigger pembuat profile otomatis

-- 1. Tabel profiles: satu baris untuk setiap akun di auth.users
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  name text,
  role text not null default 'seeker'
    check (role in ('seeker', 'owner', 'admin')),
  created_at timestamptz not null default now()
);

-- 2. RLS: pengguna hanya bisa membaca profile miliknya sendiri.
--    Tidak ada policy UPDATE, jadi role tidak bisa diubah dari aplikasi.
alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles for select
to authenticated
using (auth.uid() = id);

grant select on public.profiles to authenticated;

-- 3. Trigger: profile dibuat otomatis setiap ada akun baru.
--    Role dari aplikasi hanya diterima kalau 'seeker' atau 'owner'.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'name', ''),
    case
      when new.raw_user_meta_data->>'role' in ('seeker', 'owner')
        then new.raw_user_meta_data->>'role'
      else 'seeker'
    end
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- 4. Profile untuk akun lama yang dibuat sebelum trigger ada
insert into public.profiles (id, email, name, role)
select id, email, '', 'seeker' from auth.users
on conflict (id) do nothing;