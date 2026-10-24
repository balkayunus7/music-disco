begin;

create extension if not exists pgtap with schema extensions;
select plan(7);

insert into auth.users (id, is_anonymous)
values ('11111111-1111-4111-8111-111111111111', true),
       ('22222222-2222-4222-8222-222222222222', true);

select is(
  (select count(*) from public.users where user_id in (
    '11111111-1111-4111-8111-111111111111',
    '22222222-2222-4222-8222-222222222222'
  )), 2::bigint, 'Auth signup trigger creates user records'
);

set local role authenticated;
select set_config('request.jwt.claim.sub', '11111111-1111-4111-8111-111111111111', true);

select is((select count(*) from public.users), 1::bigint, 'A user sees only their own record');
select lives_ok(
  $$update public.users set name = 'Music Guest' where user_id = '11111111-1111-4111-8111-111111111111'$$,
  'A user can edit their own name'
);
select is((select name from public.users), 'Music Guest', 'Name update persists');
select is(
  (select count(*) from public.users where user_id = '22222222-2222-4222-8222-222222222222'),
  0::bigint, 'Other user records remain private'
);
select throws_ok(
  $$update public.users set premium_info = '{}'::jsonb$$,
  '42501', 'permission denied for table users', 'Clients cannot change subscription entitlements'
);
select throws_ok(
  $$insert into public.users (user_id) values ('33333333-3333-4333-8333-333333333333')$$,
  '42501', 'permission denied for table users', 'Clients cannot create user records directly'
);

select * from finish();
rollback;
