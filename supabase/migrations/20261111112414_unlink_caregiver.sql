-- Either participant may end an existing caregiver link.
create function public.unlink_caregiver(target_caregiver_id uuid)
returns void language plpgsql security definer set search_path = '' as $$
declare caller uuid := (select auth.uid());
begin
  if caller is null or target_caregiver_id is null then
    raise exception 'Sessão ou cuidador inválido.';
  end if;
  delete from public.care_links
    where caregiver_id = target_caregiver_id
      and (caregiver_id = caller or assisted_id = caller);
  if not found then
    raise exception 'Vínculo não encontrado.';
  end if;
end;
$$;
revoke all on function public.unlink_caregiver(uuid) from public, anon;
grant execute on function public.unlink_caregiver(uuid) to authenticated;
