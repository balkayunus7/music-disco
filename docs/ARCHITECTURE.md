# Music Disco architecture

Reference applications inspected: `../echo_learn_vocabulary` and, for the final folder/auth layout, `../daily-tarot-focus`. The shared package remains `../mobile-boilerplate`.

```text
lib/
  main.dart
  music_disco_app.dart
  config/
    bootstrap.dart
    env_config.dart
    setup_dependencies.dart
    app_router.dart
    app_routes.dart
  core/
    util/
      custom_app_colors.dart
      custom_app_sizes.dart
      text_style_helper.dart
      locale_keys.dart
      supabase_failure.dart
    widgets/
      app_status_view.dart
      fancy_button.dart
  features/
    auth/
      bloc/music_auth_cubit.dart
      data/
        impl_auth_service.dart
        impl_user_repository.dart
        secure_session_store.dart
      domain/
        models/
          music_user.dart
          music_user_properties.dart
        use_cases/i_session_store.dart
      presentation/pages/splash_page.dart
    core/home/
      home_page.dart
      widgets/guest_session_card.dart
supabase/
  config.toml
  migrations/
  functions/delete-account/
  tests/users_rls.sql
```

## Reference mapping

| Tarot reference | Music Disco |
| --- | --- |
| `config/setup_dependieces.dart` | `config/setup_dependencies.dart` |
| `features/auth/data/impl_auth_service.dart` | Same role and location; implements shared `IAuthService` |
| `features/auth/data/impl_user_repository.dart` | Same role and location; implements shared `IUserRepository` |
| `TarotUser extends User` | `MusicUser extends User` |
| `TarotUserProperties extends UserProperties` | `MusicUserProperties extends UserProperties` |
| Shared `AuthCubit` | Shared `AuthCubit` with a small `MusicAuthCubit` bootstrap adapter |
| `core/util`, feature `bloc`, `domain/models` | Same directory ownership |

## Authentication flow

1. Bootstrap validates compile-time configuration and registers dependencies using the shared `getIt`.
2. `AuthCubit.initialize()` restores the Supabase session from project-specific secure storage and fetches the application user.
3. Only `NotFoundFailure` from session lookup starts `signInAnonymously()`. Network, storage, rate-limit and user-fetch failures show a retry action.
4. An `auth.users` insert trigger creates `public.users`; the repository reads that row with the authenticated Supabase client.
5. The router opens `/home` only when both session and application user are available.
6. Auth refresh updates memory and secure storage; writes are serialized. The app starts/stops automatic refresh as its lifecycle changes. Invalidated sessions return to the splash/error route.

The adapter retains the latest token after user loading, guards concurrent initialization, and propagates auth stream errors. `startupFailure` reads both session and user failures independently, avoiding the shared state's nullable boolean short-circuit when only the user fetch fails.

## Backend and user ownership

Anonymous sign-ins must be enabled locally and on the hosted project. Anonymous users have the `authenticated` database role, so access is controlled by `auth.uid()` policies, as described in [Supabase anonymous sign-ins](https://supabase.com/docs/guides/auth/auth-anonymous).

`public.users` stores `user_id`, `name`, `firebase_token`, `revenuecat_id`, `premium_info` and timestamps. A client can select its own row and update only `name` and `firebase_token`. Subscription fields are server-owned. Account deletion validates the caller's JWT using `auth.getUser()` and deletes that caller via a server-only service role key; the foreign key cascades to its user record. No request-body user ID is trusted.

Tarot fetches users through Edge Functions. Music Disco's read/update repository currently uses Supabase's RLS-protected Data API; the shared repository and model contracts stay the same. The privileged deletion operation uses an Edge Function.

Purchases, Google/Apple identity linking, Firebase notifications and analytics are not configured. The package's auth methods for unavailable providers and subscription sync return an explicit failure. No placeholder purchase offerings or client-controlled premium grants are supplied. The shared theme bloc/cache, semantic colors, bundled Manrope/Archivo Black fonts and responsive sizing are connected independently of external service configuration.

## Presentation

UI follows the Step Tourist skill: semantic `context.colors`, `Sp` tokens, responsive dimensions, and immutable widgets. Typography follows `docs/TYPOGRAPHY.md`: Manrope for body and controls, Archivo Black at weight 400 for display text, and role helpers in `text_style_helper.dart`. Text uses logical units and preserves system scaling; headings derive their size from available content width. Page-specific visual fragments remain `part` files owned by their page. The base shell supports English/Turkish and uses a fixed dark appearance. MaterialApp is composed locally so startup does not depend on Firebase, analytics, purchases or network-time initialization.

All content pages use `core/widgets/app_page_bar.dart` through the required `BrandPageBody.appBar`. The bar stays above the scrollable content with one toolbar height, Manrope eyebrow style and a leading-aligned title. Root titles start at the content edge; nested titles follow the 48-unit back control with the same gap. An optional labeled icon action sits at the trailing edge. Header padding, safe-area handling and the gap before content are owned by `BrandPageBody`. Feature labels and large content headlines remain in their respective pages.

## Profile and settings

The third shell branch is `/settings`. Its presentation lives in `features/settings/presentation/`, with page-owned parts for the profile card, grouped rows and sheets. Profile name changes use the shared `AuthCubit.updateUser()` and `MusicUserProperties`; failures keep the editor open. Collection totals come from `CollectionState`.

The existing taste editor is reused under `/settings/taste`, keeping its nested genre/reference routes and back navigation in the settings branch. Song language updates the shared taste profile. Taste and collection snapshots are persisted locally through feature-owned store contracts and SharedPreferences adapters, scoped by the authenticated user ID. Writes report failures without replacing the previously saved state. This keeps data across restarts on the same installation; it does not provide cloud sync or recovery after reinstalling.

Appearance is fixed to dark through the shared theme bloc and the project cache adapter, including installations with an older saved light/system choice. Both palette contracts required by CoreApp use graphite colors. `SettingsCubit` persists the reduce-motion preference locally; the home shell combines it with the operating system preference through `MediaQuery.disableAnimations`. Shared transitions, disc effects and feature animations respect that value.

Support, Privacy Policy and Terms of Use rows read `MusicAppConfig`'s `mailToUrl`, `privacyPolicyUrl` and `termsOfServiceUrl`. These are currently empty; tapping an unconfigured link shows an unavailable message. Configured web/email links open externally. The Restore purchases row also reports that restoration is unavailable while store purchases and backend subscription sync remain unconfigured; it does not grant entitlements or report a successful restore.


## Discovery and library UX

The home screen puts the two discovery choices before its decorative discs. Mood and artist screens offer a pinned Continue action that opens the direction/distance customization step. Finding music then opens a separate loading route before the results; it follows the monochrome Ses izi design with five decorative waveform rows, and stays visible for at least five seconds while also waiting for the catalog request to finish. The waveform cycle never signals request completion. Reduced motion renders static traces; app backgrounding and inactive tickers pause animation. Archivo Black headings reuse the existing font; Manrope body text is bundled with its OFL license. The loading route is replaced by results, so back navigation returns to customization. Taste genre and artist editors are independent screens without numbered onboarding progress. App settings, support/legal links and restore-purchases entries remain available as before.

Production discovery currently uses `CuratedDiscoveryRepository`, a small local catalog with explicit genre, song language, energy and vocal metadata, including publisher-linked Turkish videos. Nearby results honor chosen genres and artist genres; song language is a strict filter. Aspect choices prioritize mood, vocals, energy or genres and are described accordingly; they do not claim audio embedding or voice similarity. Saved artists influence ranking. There are up to five results per round, and shorter or empty results are explained. Remote recommendation generation and a large catalog are not implemented.

Rejected songs are excluded for the lifetime of the discovery cubit. Replacement exhaustion and request failures have separate notices. In-flight replacement blocks track navigation, and unsuccessful preference changes keep the current round and settings. Finished rounds show total/saved counts and next actions and are not offered as resumable rounds.

Collection cards open the shared track player in a dismissible sheet. Their options menu assigns or clears a shelf, or removes the track with undo. The shared player supports mute/unmute, accessible seeking and retry after playback errors. Sheet disposal closes its player. `MotionSize` renders its child directly when reduced motion is active, avoiding zero-duration AnimatedSize layout invalidation.
