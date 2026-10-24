# Music Disco

Flutter foundation based on the Tarot app folder/auth conventions and the Step Tourist presentation skill.

## Run

The sibling package must be present at `../mobile-boilerplate`.

```sh
flutter pub get
cp .env.example.json .env.local.json
# Fill in this project's URL and publishable/anon key in .env.local.json.
flutter run --dart-define-from-file=.env.local.json
```

Configuration is read via Dart defines. `.env.local.json` is ignored by Git. Never put a service-role key, Supabase management token or database password into the app config. Without configuration, the app shows a startup error and prints a diagnostic to the development console.

## Backend setup

The CLI is initialized locally. Hosted project creation and deployment require approval.

```sh
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
supabase functions deploy delete-account
```

Enable anonymous sign-ins on the hosted project before running the app. Local config already enables anonymous auth. Review the configuration diff before using `supabase config push`; it manages more than the anonymous-auth switch.

## Checks

```sh
dart format lib test
flutter analyze
flutter test
git diff --check
```

For a running local Supabase stack:

```sh
supabase start
supabase test db
```

The SQL tests use a transaction and roll back their fixtures. They verify automatic user creation, row isolation, permitted profile updates, and rejection of client premium writes.

Regenerate localization keys after updating both `assets/translations/en.json` and `tr.json`:

```sh
dart run easy_localization:generate -S assets/translations -s en.json -f keys -o locale_keys.dart -O lib/core/util
```

See [architecture and reference mapping](docs/ARCHITECTURE.md) for the folder layout, authentication flow, backend ownership and currently configured services.
