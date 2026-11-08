# Architecture — First Version

## Applications

The project has three parts:

- Backend: Python with FastAPI (SQLAlchemy, pgAdmin, PostgreSQL)
- Web app: React
- Mobile app: Flutter using Clean Architecture, BLoC, GoRouter, GetIt, Material 3.
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

Organize Flutter code into:

- Infrastructure: GoRouter, GetIt, Material 3, Theme, Localizations (bangla and english), and other infrastructure code.
- Presentation: screens, widgets, and BLoCs
- Domain: business rules, entities, use cases, and repository interfaces, Logger, and Utils.
- Data: API calls, data models, data sources, mappers to convert between data models and entities, and repository implementations
- The domain layer is pure Dart code. No API calls, no data models, no data sources, no mappers, no repository implementations.
- Data and domain layers are saperate projects. They inside the mobile app project.

## Decisions to make before implementation

Choose and record:

- Database
- Authentication approach
- Where the backend will be hosted
- Where uploaded photos or files will be stored, if needed

Do not add complex infrastructure for the first version.
