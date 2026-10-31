import { createClient } from 'npm:@supabase/supabase-js@2'

const USER_AGENT = 'music-disco-artist-catalog/1.0 (Supabase Edge Function)'
const SPARQL_URL = 'https://query.wikidata.org/sparql'
const POPULARITY_URL = 'https://api.listenbrainz.org/1/popularity/artist'
const MAX_SLICE = 1000
const POPULARITY_BATCH = 1000
const MIN_GLOBAL_SITELINKS = 15
const SEGMENT_SIZE = { global: 10000, turkish: 3000 } as const

type Segment = keyof typeof SEGMENT_SIZE

const CANDIDATE_QUERIES: Record<Segment, string> = {
  global: `SELECT DISTINCT ?a ?mbid WHERE {
    ?a wdt:P434 ?mbid ; wikibase:sitelinks ?links . FILTER(?links >= ${MIN_GLOBAL_SITELINKS})
  }`,
  turkish: `SELECT DISTINCT ?a ?mbid WHERE {
    ?a wdt:P434 ?mbid .
    { ?a wdt:P27 wd:Q43 } UNION { ?a wdt:P495 wd:Q43 } UNION { ?a wdt:P740 ?place . ?place wdt:P17 wd:Q43 }
  }`,
}

const TURKISH_MUSICIANS_QUERY = `SELECT ?a (MAX(?links) AS ?sitelinks) WHERE {
  { ?a wdt:P27 wd:Q43 ; wdt:P106 ?o . ?o wdt:P279* wd:Q639669 }
  UNION { ?a wdt:P31/wdt:P279* wd:Q215380 ; wdt:P495 wd:Q43 }
  ?a wikibase:sitelinks ?links .
} GROUP BY ?a`

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

function json(body: Record<string, unknown>, status: number) {
  return new Response(JSON.stringify(body), { status, headers: { 'Content-Type': 'application/json' } })
}

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

async function fetchJson(url: string, init: RequestInit = {}, attempts = 3): Promise<any> {
  for (let attempt = 1; ; attempt++) {
    const response = await fetch(url, { ...init, headers: { 'User-Agent': USER_AGENT, ...init.headers } })
    if (response.ok) return response.json()
    if (attempt >= attempts || ![429, 500, 502, 503, 504].includes(response.status)) {
      throw new Error(`${new URL(url).host} responded ${response.status}`)
    }
    await sleep(attempt * 2000)
  }
}

async function sparql(query: string): Promise<any[]> {
  const body = await fetchJson(SPARQL_URL, {
    method: 'POST',
    headers: { 'Accept': 'application/sparql-results+json', 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ query }),
  })
  return body.results.bindings
}

function qidOf(uri: string): string {
  return uri.slice(uri.lastIndexOf('/') + 1)
}

async function candidates(segment: Segment): Promise<Map<string, string>> {
  const entities = new Map<string, string>()
  for (const row of await sparql(CANDIDATE_QUERIES[segment])) {
    const id = String(row.mbid.value).toLowerCase()
    if (UUID.test(id) && !entities.has(id)) entities.set(id, qidOf(row.a.value))
  }
  return entities
}

async function listenCounts(ids: string[]): Promise<Map<string, number>> {
  const counts = new Map<string, number>()
  for (let start = 0; start < ids.length; start += POPULARITY_BATCH) {
    const rows = await fetchJson(POPULARITY_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ artist_mbids: ids.slice(start, start + POPULARITY_BATCH) }),
    })
    for (const row of rows) counts.set(row.artist_mbid, Number(row.total_listen_count) || 0)
  }
  return counts
}

async function artistNames(qids: string[], segment: Segment): Promise<Map<string, string>> {
  const languages = segment === 'turkish' ? ['tr', 'mul', 'en'] : ['en', 'mul', 'tr']
  const rows = await sparql(`SELECT ?a ?label (LANG(?label) AS ?lang) WHERE {
    VALUES ?a { ${qids.map((qid) => `wd:${qid}`).join(' ')} }
    ?a rdfs:label ?label . FILTER(LANG(?label) IN (${languages.map((lang) => `"${lang}"`).join(', ')}))
  }`)
  const best = new Map<string, { rank: number; name: string }>()
  for (const row of rows) {
    const qid = qidOf(row.a.value)
    const rank = languages.indexOf(row.lang.value)
    const current = best.get(qid)
    if (!current || rank < current.rank) best.set(qid, { rank, name: String(row.label.value).trim() })
  }
  return new Map([...best].map(([qid, { name }]) => [qid, name]))
}

async function uuidFor(qid: string): Promise<string> {
  const digest = new Uint8Array(await crypto.subtle.digest('SHA-1', new TextEncoder().encode(`wikidata:${qid}`)))
  const bytes = digest.slice(0, 16)
  bytes[6] = (bytes[6] & 0x0f) | 0x50
  bytes[8] = (bytes[8] & 0x3f) | 0x80
  const hex = [...bytes].map((b) => b.toString(16).padStart(2, '0')).join('')
  return `${hex.slice(0, 8)}-${hex.slice(8, 12)}-${hex.slice(12, 16)}-${hex.slice(16, 20)}-${hex.slice(20)}`
}

type RankedArtist = { id: string; qid: string; popularity: number }

async function rankArtists(segment: Segment): Promise<RankedArtist[]> {
  const entities = await candidates(segment)
  const counts = await listenCounts([...entities.keys()])
  const listened = [...entities]
    .filter(([id]) => (counts.get(id) ?? 0) > 0)
    .sort(([a], [b]) => counts.get(b)! - counts.get(a)! || a.localeCompare(b))
    .map(([id, qid]) => ({ id, qid, popularity: counts.get(id)! }))
    .filter((artist, index, all) => all.findIndex((other) => other.qid === artist.qid) === index)
  if (segment !== 'turkish') return listened

  const known = new Set(entities.values())
  const others = (await sparql(TURKISH_MUSICIANS_QUERY))
    .map((row) => ({ qid: qidOf(row.a.value), sitelinks: Number(row.sitelinks.value) }))
    .filter(({ qid }) => !known.has(qid))
    .sort((a, b) => b.sitelinks - a.sitelinks || a.qid.localeCompare(b.qid))
  const filled = await Promise.all(
    others.map(async ({ qid }) => ({ id: await uuidFor(qid), qid, popularity: 0 })),
  )
  return [...listened, ...filled]
}

function secretMatches(given: string | null, expected: string): boolean {
  if (!given || given.length !== expected.length) return false
  let diff = 0
  for (let i = 0; i < expected.length; i++) diff |= given.charCodeAt(i) ^ expected.charCodeAt(i)
  return diff === 0
}

function adminClient() {
  return createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, {
    auth: { persistSession: false, autoRefreshToken: false },
  })
}

Deno.serve(async (request: Request) => {
  if (request.method !== 'POST') return json({ error: 'Method not allowed' }, 405)
  const secret = Deno.env.get('ARTIST_REFRESH_SECRET')
  if (!secret || !secretMatches(request.headers.get('x-refresh-secret'), secret)) {
    return json({ error: 'Unauthorized' }, 401)
  }

  const body = await request.json().catch(() => ({}))

  try {
    if (body.action === 'prune') {
      const before = new Date(body.before)
      if (Number.isNaN(before.getTime())) return json({ error: 'A valid "before" timestamp is required' }, 400)
      const { count, error } = await adminClient()
        .from('artists')
        .delete({ count: 'exact' })
        .lt('updated_at', before.toISOString())
      if (error) throw new Error(error.message)
      return json({ action: 'prune', deleted: count ?? 0 }, 200)
    }

    const segment: Segment = body.segment === 'turkish' ? 'turkish' : 'global'
    const offset = Math.max(0, Number(body.offset) || 0)
    const end = Math.min(SEGMENT_SIZE[segment], offset + MAX_SLICE)
    if (offset >= end) return json({ segment, offset, upserted: 0, done: true }, 200)

    const ranked = await rankArtists(segment)
    const slice = ranked.slice(offset, end)
    const names = await artistNames(slice.map((artist) => artist.qid), segment)
    const updatedAt = new Date().toISOString()
    const rows = slice
      .filter((artist) => names.get(artist.qid))
      .map((artist) => ({
        id: artist.id,
        name: names.get(artist.qid)!.slice(0, 200),
        genres: [],
        image_url: null,
        image_license: null,
        image_author: null,
        image_source_url: null,
        popularity: artist.popularity,
        updated_at: updatedAt,
      }))

    const { error } = await adminClient().from('artists').upsert(rows, { onConflict: 'id' })
    if (error) throw new Error(error.message)

    return json({
      segment,
      offset,
      ranked: ranked.length,
      upserted: rows.length,
      done: end >= Math.min(SEGMENT_SIZE[segment], ranked.length),
    }, 200)
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : 'Refresh failed' }, 502)
  }
})
