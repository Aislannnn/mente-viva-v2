-- Publish only the shared workspace table. Existing SELECT RLS still limits
-- which account can receive its changes.
alter publication supabase_realtime add table public.app_records;
