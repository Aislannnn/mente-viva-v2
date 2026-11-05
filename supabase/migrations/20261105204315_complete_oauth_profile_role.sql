-- OAuth providers do not know the Mente Viva role on first sign-in.
-- A signed-in user may choose a role once; existing roles cannot be changed.
create function public.complete_profile_role(requested_role text)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  caller uuid := (select auth.uid());
  existing_role text;
begin
  if caller is null or requested_role not in ('assistida', 'cuidador') then
    raise exception 'Perfil inválido ou sessão expirada.';
  end if;

  select role into existing_role
    from public.profiles where id = caller for update;
  if not found then
    raise exception 'Perfil da conta não encontrado.';
  end if;
  if existing_role is not null and existing_role <> requested_role then
    raise exception 'Esta conta já pertence ao outro perfil.';
  end if;
  if existing_role is null then
    update public.profiles set role = requested_role where id = caller;
    if requested_role = 'assistida' then
      insert into public.app_records(assisted_id) values (caller)
        on conflict (assisted_id) do nothing;
    end if;
  end if;
  return requested_role;
end;
$$;

revoke all on function public.complete_profile_role(text) from public, anon;
grant execute on function public.complete_profile_role(text) to authenticated;
