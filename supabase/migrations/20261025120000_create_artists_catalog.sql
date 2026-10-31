create extension if not exists pg_trgm with schema extensions;
create extension if not exists unaccent with schema extensions;

create function public.artist_search_key(value text)
returns text language sql immutable parallel safe set search_path = ''
as $$
  select lower(extensions.unaccent('extensions.unaccent'::regdictionary, translate(coalesce(value, ''), 'ıİ', 'iI')));
$$;

create table public.artists (
  id uuid primary key,
  name text not null check (char_length(btrim(name)) between 1 and 200),
  search_name text generated always as (public.artist_search_key(name)) stored,
  genres text[] not null default '{}' check (
    genres <@ array['alternative', 'pop', 'electronic', 'rock', 'hip_hop', 'rnb_soul', 'jazz', 'classical']
  ),
  image_url text,
  image_license text,
  image_author text,
  image_source_url text,
  popularity bigint not null default 0 check (popularity >= 0),
  updated_at timestamptz not null default now()
);

create index artists_search_name_trgm on public.artists using gin (search_name extensions.gin_trgm_ops);
create index artists_genres on public.artists using gin (genres);
create index artists_popularity on public.artists (popularity desc);

alter table public.artists enable row level security;

revoke all on public.artists from anon, authenticated;
grant select on public.artists to authenticated;

create policy "Signed-in users can read the artist catalog"
on public.artists for select to authenticated
using (true);

create function public.search_artists(
  query text default '',
  genre_filter text[] default null,
  result_limit integer default 12
)
returns setof public.artists
language sql stable security invoker set search_path = ''
as $$
  with input as (
    select
      public.artist_search_key(query) as key,
      least(greatest(coalesce(result_limit, 12), 1), 50) as lim
  )
  select a.*
  from public.artists a, input
  where (
      input.key = ''
      or starts_with(a.search_name, input.key)
      or input.key operator(extensions.<%) a.search_name
    )
    and (coalesce(cardinality(genre_filter), 0) = 0 or a.genres && genre_filter)
  order by
    case
      when input.key = '' then 0
      when starts_with(a.search_name, input.key) then 1
      else extensions.word_similarity(input.key, a.search_name)
    end desc,
    a.popularity desc
  limit (select lim from input);
$$;

revoke all on function public.search_artists(text, text[], integer) from public, anon;
grant execute on function public.search_artists(text, text[], integer) to authenticated;
revoke all on function public.artist_search_key(text) from anon;
