# Farm Management Project

This project is a farm management system that helps farmers keep track of their livestock, crops, supplies, income, and expenses.

## Features

- Cow records for meat and milk, including milk production
- Poultry groups for broilers, ducks, layers, and local birds
- Crop cycles and harvest records
- Crop costs, including labour, fertilizers, pesticides and chemicals, seeds, irrigation, equipment, and other costs
- Inventory records and stock updates
- Simple income and expense entries
- Basic farm settings

## Technologies

- Backend: Python with FastAPI (SQLAlchemy, pgAdmin, PostgreSQL)
- Web app: React
- Mobile app: Flutter using Clean Architecture, BLoC, GoRouter, GetIt, Material 3.
- The colors, fonts, and design should match the web and mobile apps.

## Architecture

The project has three parts:

- Backend: Python with FastAPI (SQLAlchemy, pgAdmin, PostgreSQL)
- Infrastructure: GoRouter, GetIt, Material 3, Theme, Localizations (bangla and english), and other infrastructure code.
- Presentation: screens, widgets, and BLoCs
- Domain: business rules, entities, use cases, and repository interfaces, Logger, and Utils.
- Data: API calls, data models, data sources, mappers to convert between data models and entities, and repository implementations
- The domain layer is pure Dart code. No API calls, no data models, no data sources, no mappers, no repository implementations.
- Data and domain layers are saperate projects. They inside the mobile app project.

## The details document is in the docs folder. Please follow the following links

- 1 [Install Spaces](docs/01-install-spaces.md)
