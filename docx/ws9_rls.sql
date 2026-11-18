-- NIM: 2415051039 | Nama: Agus Prasetya
-- Tahap 5: Row Level Security untuk tabel courses

-- 0. Semua course wajib punya pemilik
update public.courses
set owner_id = (
  select id from public.profiles
  where role = 'owner' order by created_at limit 1
)
where owner_id is null;
alter table public.courses alter column owner_id set not null;

-- 1. Hapus policy longgar dari Pertemuan 7 dan dari Tahap 4
drop policy if exists "lab: anon boleh baca dan tulis courses" on public.courses;
drop policy if exists "lab: authenticated boleh baca dan tulis courses" on public.courses;

-- Pengguna yang belum login tidak punya akses sama sekali
revoke all on public.courses from anon;
revoke all on sequence public.courses_id_seq from anon;

-- 2. Pastikan RLS aktif
alter table public.courses enable row level security;

-- 3. SELECT: semua pengguna yang sudah login boleh membaca
drop policy if exists "courses_select_authenticated" on public.courses;
create policy "courses_select_authenticated"
on public.courses for select
to authenticated
using (true);

-- 4. INSERT: pemilik harus dirinya sendiri, dan role-nya Pengajar atau Admin
drop policy if exists "courses_insert_owner" on public.courses;
create policy "courses_insert_owner"
on public.courses for insert
to authenticated
with check (
  auth.uid() = owner_id
  and exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role in ('owner', 'admin')
  )
);

-- 5. UPDATE: hanya pemilik course
drop policy if exists "courses_update_own" on public.courses;
create policy "courses_update_own"
on public.courses for update
to authenticated
using (auth.uid() = owner_id)
with check (auth.uid() = owner_id);

-- 6. DELETE: hanya pemilik course
drop policy if exists "courses_delete_own" on public.courses;
create policy "courses_delete_own"
on public.courses for delete
to authenticated
using (auth.uid() = owner_id);

-- 7. Admin boleh semua operasi
create or replace function public.is_admin()
returns boolean
language sql stable
security definer set search_path = public
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
$$;

drop policy if exists "courses_admin_all" on public.courses;
create policy "courses_admin_all"
on public.courses for all
to authenticated
using (public.is_admin())
with check (public.is_admin());
