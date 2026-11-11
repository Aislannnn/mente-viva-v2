-- Appearance and accessibility settings belong to the signed-in account,
-- while routine data remains shared by the assisted person and caregiver.
create table public.user_preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  dark boolean not null default false,
  font_scale numeric(3,1) not null default 1.0 check (font_scale between 0.8 and 1.5),
  font_family text not null default 'Padrão' check (font_family in ('Padrão', 'Serif', 'Mono')),
  updated_at timestamptz not null default now()
);
alter table public.user_preferences enable row level security;
revoke all on public.user_preferences from public, anon;
grant select, insert, update on public.user_preferences to authenticated;
create policy "Read own preferences" on public.user_preferences
  for select to authenticated using (user_id = (select auth.uid()));
create policy "Create own preferences" on public.user_preferences
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy "Update own preferences" on public.user_preferences
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- Keep each existing account's current appearance as its starting point.
insert into public.user_preferences(user_id, dark, font_scale, font_family)
select p.id,
       coalesce((r.data #>> '{preferences,dark}')::boolean, false),
       least(greatest(coalesce((r.data #>> '{preferences,font_scale}')::numeric, 1.0), 0.8), 1.5),
       case when r.data #>> '{preferences,font_family}' in ('Padrão', 'Serif', 'Mono')
            then r.data #>> '{preferences,font_family}' else 'Padrão' end
from public.profiles p
left join public.care_links cl on cl.caregiver_id = p.id
left join public.app_records r on r.assisted_id = coalesce(cl.assisted_id, p.id)
on conflict (user_id) do nothing;
