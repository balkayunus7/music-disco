begin;

create extension if not exists pgtap with schema extensions;
select plan(6);

insert into public.artists (id, name, genres, popularity) values
  ('00000000-0000-4000-8000-000000000001', 'Duman', '{rock,alternative}', 500),
  ('00000000-0000-4000-8000-000000000002', 'Şebnem Ferah', '{rock}', 300),
  ('00000000-0000-4000-8000-000000000003', 'Bonobo', '{electronic}', 900);

select is(
  (select search_name from public.artists where name = 'Şebnem Ferah'),
  'sebnem ferah', 'Search keys fold Turkish characters'
);

set local role anon;
select throws_ok($$select * from public.artists$$, '42501', null, 'Anonymous role cannot read the catalog');
reset role;

set local role authenticated;
select is((select name from public.search_artists('sebnem') limit 1), 'Şebnem Ferah', 'ASCII query finds Turkish names');
select is((select name from public.search_artists('bonbo') limit 1), 'Bonobo', 'Typos still match');
select is(
  (select array_agg(name) from public.search_artists('', '{rock}')),
  array['Duman', 'Şebnem Ferah'], 'Empty query lists popular artists in the genre'
);
select throws_ok(
  $$insert into public.artists (id, name) values ('00000000-0000-4000-8000-000000000009', 'X')$$,
  '42501', null, 'Clients cannot write to the catalog'
);

select * from finish();
rollback;
