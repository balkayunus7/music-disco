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

Purchases, Google/Apple identity linking, Firebase notifications and analytics are not configured. The package's auth methods for unavailable providers and subscription sync return an explicit failure. No placeholder purchase offerings or client-controlled premium grants are supplied. The shared theme bloc/cache, semantic colors, Montserrat fonts and responsive sizing are connected independently of external service configuration.

## Presentation

UI follows the Step Tourist skill: semantic `context.colors`, `Sp` tokens, responsive dimensions, Montserrat helpers, and immutable widgets. Page-specific visual fragments remain `part` files owned by their page. The base shell supports English/Turkish and system light/dark mode. MaterialApp is composed locally so startup does not depend on Firebase, analytics, purchases or network-time initialization.
