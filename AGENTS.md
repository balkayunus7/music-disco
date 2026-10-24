# Music Disco conventions

- Use the Tarot-style directory map in `docs/ARCHITECTURE.md`.
- App composition, environment, routing and dependency registration live in `lib/config/`.
- Shared UI lives in `lib/core/widgets/`; shared theme and utilities in `lib/core/util/`.
- A feature owns `bloc/`, `data/`, `domain/models/`, `domain/use_cases/` and `presentation/` as needed. Domain must not import data or UI.
- Reuse `mobile_boilerplate` from `../mobile-boilerplate`. Auth uses its `AuthCubit`, `IAuthService`, `IUserRepository`, `User` and `UserProperties` contracts. Do not modify the sibling package without authorization.
- Follow the `step-tourist-flutter-ui` skill for presentation work. Use `context.colors`, `Sp`, Montserrat helpers, small immutable widgets and page-owned part files. Keep calculations and business rules out of leaf widgets.
- Use `easy_localization`, update English and Turkish together, and regenerate `LocaleKeys` with the README command.
- Keep credentials, session tokens and server keys out of logs and tracked files. App configuration contains only the project URL and a publishable/anon key.
- Restore the existing guest session before creating a user. Network or profile errors must never trigger a new anonymous signup.
- Supabase project creation, remote configuration and deployment require the user's authorization. Never run database resets against hosted projects.
- Format changed Dart files, run `flutter analyze`, relevant `flutter test` tests and `git diff --check`. State any backend/platform checks not run.
