-- Mente Viva v2: caregiver-generated invites accepted by the assisted person.
create table app_private.caregiver_invites (
  id uuid primary key default gen_random_uuid(),
  caregiver_id uuid not null references public.profiles(id) on delete cascade,
  code_hash bytea not null unique,
  expires_at timestamptz not null,
  redeemed_at timestamptz,
  created_at timestamptz not null default now()
);
create index caregiver_invites_caregiver_id_idx
  on app_private.caregiver_invites(caregiver_id);
alter table app_private.caregiver_invites enable row level security;
revoke all on app_private.caregiver_invites from public, anon, authenticated;

create function public.create_caregiver_invite()
returns text language plpgsql security definer set search_path = '' as $$
declare caller uuid := (select auth.uid());
declare code text;
begin
  if caller is null or not exists (
    select 1 from public.profiles where id = caller and role = 'cuidador'
  ) then
    raise exception 'Somente um cuidador pode gerar o convite.';
  end if;
  if exists (select 1 from public.care_links where caregiver_id = caller) then
    raise exception 'Este cuidador já está vinculado.';
  end if;
  update app_private.caregiver_invites set expires_at = now()
    where caregiver_id = caller and redeemed_at is null;
  code := upper(encode(extensions.gen_random_bytes(8), 'hex'));
  insert into app_private.caregiver_invites(caregiver_id, code_hash, expires_at)
    values (caller, extensions.digest(code, 'sha256'), now() + interval '24 hours');
  return code;
end;
$$;

create function public.accept_caregiver_invite(code text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare caller uuid := (select auth.uid());
declare invitation app_private.caregiver_invites%rowtype;
begin
  if caller is null or not exists (
    select 1 from public.profiles where id = caller and role = 'assistida'
  ) then
    raise exception 'Somente a Pessoa Assistida pode aceitar o convite.';
  end if;
  select * into invitation from app_private.caregiver_invites
    where code_hash = extensions.digest(upper(trim(code)), 'sha256')
      and expires_at > now() and redeemed_at is null
    for update;
  if not found then
    raise exception 'Convite inválido ou vencido.';
  end if;
  if exists (select 1 from public.care_links
             where caregiver_id = invitation.caregiver_id) then
    raise exception 'Este cuidador já está vinculado.';
  end if;
  insert into public.care_links(caregiver_id, assisted_id)
    values (invitation.caregiver_id, caller);
  update app_private.caregiver_invites set redeemed_at = now()
    where id = invitation.id;
  return invitation.caregiver_id;
end;
$$;

revoke all on function public.create_caregiver_invite() from public, anon;
revoke all on function public.accept_caregiver_invite(text) from public, anon;
grant execute on function public.create_caregiver_invite() to authenticated;
grant execute on function public.accept_caregiver_invite(text) to authenticated;
