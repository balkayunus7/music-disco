create table public.users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  name text check (char_length(btrim(name)) between 1 and 80),
  firebase_token text,
  revenuecat_id text,
  premium_info jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.users enable row level security;

revoke all on public.users from anon, authenticated;
grant select on public.users to authenticated;
grant update (name, firebase_token) on public.users to authenticated;

create policy "Users can read their own profile"
on public.users for select to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can update their own profile"
on public.users for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.users (user_id) values (new.id);
  return new;
end;
$$;

revoke all on function public.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create function public.set_user_updated_at()
returns trigger language plpgsql set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

revoke all on function public.set_user_updated_at() from public, anon, authenticated;

create trigger on_user_updated
before update on public.users
for each row execute function public.set_user_updated_at();

insert into public.users (user_id)
select id from auth.users
on conflict (user_id) do nothing;
