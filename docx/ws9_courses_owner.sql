-- NIM: 2415051039 | Nama: Agus Prasetya
-- Tahap 4: kepemilikan course (owner_id)

alter table public.courses
  add column if not exists owner_id uuid
  references auth.users(id) on delete cascade
  default auth.uid();

update public.courses
set owner_id = (
  select id from public.profiles
  where role = 'owner'
  order by created_at
  limit 1
)
where owner_id is null;

drop policy if exists "lab: authenticated boleh baca dan tulis courses" on public.courses;
create policy "lab: authenticated boleh baca dan tulis courses"
on public.courses for all
to authenticated
using (true) with check (true);

grant select, insert, update, delete on public.courses to authenticated;
grant usage, select on sequence public.courses_id_seq to authenticated;