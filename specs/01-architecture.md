# Architecture — First Version

## Applications

The project has three parts:

- Backend: Python with FastAPI (SQLAlchemy, pgAdmin, PostgreSQL)
- Web app: React
- Mobile app: Flutter in one package, using Clean Architecture, BLoC/Cubit, GoRouter, GetIt, Dio, and Material 3 (`material_ui`).
- The colors, fonts, and design should match the web and mobile apps.

## Backend structure

Build one FastAPI application with separate modules for:

- Authentication
- Farm settings
- Cows
- Poultry
- Crops
- Inventory
- Income and expenses

Keep business rules in the backend so that both the web and mobile apps follow the same rules.

## API

The web and mobile apps communicate with the backend through its API.

For each feature, document the API request fields, response fields, validation rules, and error behavior before connecting the screens.

## Mobile architecture

One Flutter package. Domain and data are folders inside `mobile/`, not separate pub packages.

- Infrastructure: GoRouter, GetIt, Material 3 theme, and English/Bangla localization.
- Presentation: screens and widgets. App-wide state uses Cubit (`SessionCubit`, `LocaleCubit`, `LoadingCubit`). Sign-in uses `SignInBloc`. Feature list, detail, and create pages call use cases from GetIt.
- Domain: pure Dart entities (`*Entity`), use cases under `domain/use_cases/`, and repository interfaces. Also `Failure` and `Result`. No Flutter, Dio, models, mappers, datasources, or repository implementations.
- Data: one Dio `ApiClient` (`data/network/`), JSON models (`*Model`), abstract datasources plus implementations, mappers, and repository implementations. `ApiClient` throws `Failure`. Auth repositories return `Result`; other domains let `Failure` propagate.
- Keep the same domain folders across entities, repositories, use cases, models, mappers, and datasources (`auth`, `cow`, `crop`, `poultry`, `inventory`, `ledger`, `dashboard`, `common`).
- Widgets come from `package:material_ui/material_ui.dart` and `package:cupertino_ui/cupertino_ui.dart`.

Folder and naming rules: `memory-bank/standards/coding-standards.md`. Package overview: `mobile/README.md`.

## Decisions to make before implementation

Choose and record:

- Database
- Authentication approach
- Where the backend will be hosted
- Where uploaded photos or files will be stored, if needed

Do not add complex infrastructure for the first version.
