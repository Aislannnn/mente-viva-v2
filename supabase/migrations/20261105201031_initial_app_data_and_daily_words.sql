-- Mente Viva v2: dados privados por Pessoa Assistida e palavras do jogo.
-- Aplicado no projeto hdgxxdaedzidkpfmsvra como migration initial_app_data_and_daily_words.

create schema if not exists app_private;
revoke all on schema app_private from public, anon, authenticated;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text check (role in ('assistida', 'cuidador')),
  created_at timestamptz not null default now()
);

create table public.care_links (
  caregiver_id uuid primary key references public.profiles(id) on delete cascade,
  assisted_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint different_accounts check (caregiver_id <> assisted_id)
);
create index care_links_assisted_id_idx on public.care_links(assisted_id);

create table app_private.care_invites (
  id uuid primary key default gen_random_uuid(),
  assisted_id uuid not null references public.profiles(id) on delete cascade,
  code_hash bytea not null unique,
  expires_at timestamptz not null,
  redeemed_at timestamptz,
  created_at timestamptz not null default now()
);
create index care_invites_assisted_id_idx on app_private.care_invites(assisted_id);

create table public.app_records (
  assisted_id uuid primary key references public.profiles(id) on delete cascade,
  data jsonb not null default '{}'::jsonb check (jsonb_typeof(data) = 'object'),
  version bigint not null default 0 check (version >= 0),
  updated_at timestamptz not null default now()
);

create table public.word_bank (
  id bigint generated always as identity primary key,
  hint text not null check (char_length(trim(hint)) between 3 and 120),
  answer text not null check (answer ~ '^[A-Z]{3,10}$'),
  active boolean not null default true,
  unique(answer)
);

alter table public.profiles enable row level security;
alter table public.care_links enable row level security;
alter table app_private.care_invites enable row level security;
alter table public.app_records enable row level security;
alter table public.word_bank enable row level security;

grant select on public.profiles to authenticated;
grant select on public.care_links to authenticated;
grant select, insert, update on public.app_records to authenticated;
grant select on public.word_bank to authenticated;

create policy "Read own profile" on public.profiles
  for select to authenticated using (id = (select auth.uid()));

create policy "Read own care links" on public.care_links
  for select to authenticated
  using (caregiver_id = (select auth.uid()) or assisted_id = (select auth.uid()));

create policy "Read linked records" on public.app_records
  for select to authenticated
  using (
    assisted_id = (select auth.uid())
    or exists (
      select 1 from public.care_links cl
      where cl.assisted_id = app_records.assisted_id
        and cl.caregiver_id = (select auth.uid())
    )
  );

create policy "Create own records" on public.app_records
  for insert to authenticated
  with check (
    assisted_id = (select auth.uid())
    and exists (
      select 1 from public.profiles p
      where p.id = (select auth.uid()) and p.role = 'assistida'
    )
  );

create policy "Update linked records" on public.app_records
  for update to authenticated
  using (
    assisted_id = (select auth.uid())
    or exists (
      select 1 from public.care_links cl
      where cl.assisted_id = app_records.assisted_id
        and cl.caregiver_id = (select auth.uid())
    )
  )
  with check (
    assisted_id = (select auth.uid())
    or exists (
      select 1 from public.care_links cl
      where cl.assisted_id = app_records.assisted_id
        and cl.caregiver_id = (select auth.uid())
    )
  );

create policy "Read active words when signed in" on public.word_bank
  for select to authenticated using (active);

create function app_private.handle_new_user()
returns trigger language plpgsql security definer set search_path = '' as $$
declare chosen_role text;
begin
  chosen_role := new.raw_user_meta_data->>'display_role';
  if chosen_role not in ('assistida', 'cuidador') then
    chosen_role := null;
  end if;
  insert into public.profiles(id, role) values (new.id, chosen_role);
  if chosen_role = 'assistida' then
    insert into public.app_records(assisted_id) values (new.id);
  end if;
  return new;
end;
$$;

create trigger on_auth_user_created_mente_viva
  after insert on auth.users
  for each row execute function app_private.handle_new_user();

insert into public.profiles(id, role)
select id,
  case when raw_user_meta_data->>'display_role' in ('assistida', 'cuidador')
    then raw_user_meta_data->>'display_role' else null end
from auth.users
on conflict (id) do nothing;

insert into public.app_records(assisted_id)
select id from public.profiles where role = 'assistida'
on conflict (assisted_id) do nothing;

create function public.create_care_invite()
returns text language plpgsql security definer set search_path = '' as $$
declare caller uuid := (select auth.uid());
declare code text;
begin
  if caller is null or not exists (
    select 1 from public.profiles where id = caller and role = 'assistida'
  ) then
    raise exception 'Somente a Pessoa Assistida pode gerar um convite.';
  end if;
  update app_private.care_invites
    set expires_at = now()
    where assisted_id = caller and redeemed_at is null;
  code := upper(encode(extensions.gen_random_bytes(8), 'hex'));
  insert into app_private.care_invites(assisted_id, code_hash, expires_at)
    values (caller, extensions.digest(code, 'sha256'), now() + interval '24 hours');
  return code;
end;
$$;

create function public.redeem_care_invite(code text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare caller uuid := (select auth.uid());
declare invite app_private.care_invites%rowtype;
begin
  if caller is null or not exists (
    select 1 from public.profiles where id = caller and role = 'cuidador'
  ) then
    raise exception 'Somente um cuidador pode aceitar um convite.';
  end if;
  if exists (select 1 from public.care_links where caregiver_id = caller) then
    raise exception 'Esta conta já está vinculada.';
  end if;
  select * into invite from app_private.care_invites
    where code_hash = extensions.digest(upper(trim(code)), 'sha256')
      and expires_at > now() and redeemed_at is null
    for update;
  if not found then
    raise exception 'Código inválido ou vencido.';
  end if;
  insert into public.care_links(caregiver_id, assisted_id)
    values (caller, invite.assisted_id);
  update app_private.care_invites set redeemed_at = now() where id = invite.id;
  return invite.assisted_id;
end;
$$;

revoke all on function public.create_care_invite() from public, anon;
revoke all on function public.redeem_care_invite(text) from public, anon;
grant execute on function public.create_care_invite() to authenticated;
grant execute on function public.redeem_care_invite(text) to authenticated;

insert into public.word_bank(hint, answer) values
  ('Lugar onde moramos', 'CASA'),
  ('Planta com pétalas', 'FLOR'),
  ('Objeto para ler', 'LIVRO'),
  ('Estrela que ilumina o dia', 'SOL'),
  ('Animal que mia', 'GATO'),
  ('Bebida feita com grãos torrados', 'CAFE'),
  ('Cai do céu e molha a rua', 'CHUVA'),
  ('Fruta amarela e comprida', 'BANANA'),
  ('Lugar com muitas árvores', 'BOSQUE'),
  ('Animal que late', 'CACHORRO'),
  ('Serve para abrir uma porta', 'CHAVE'),
  ('Mostra as horas', 'RELOGIO'),
  ('Onde guardamos roupas', 'ARMARIO'),
  ('Usado para escrever', 'LAPIS'),
  ('Voa no céu e tem penas', 'PASSARO'),
  ('Fruta vermelha pequena', 'MORANGO'),
  ('Veículo com duas rodas e pedais', 'BICICLETA'),
  ('Usado para sentar', 'CADEIRA');
