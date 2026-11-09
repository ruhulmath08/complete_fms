# Farm Management System — Product and Technical Specification

## 1. Purpose

Build a simple farm management system that helps one farm owner keep track of livestock, crops, supplies, income, and expenses.

The system has three parts:

- Backend: Python with FastAPI, SQLAlchemy, and PostgreSQL. pgAdmin may be used to administer the PostgreSQL database.
- Web app: React.
- Mobile app: Flutter using Clean Architecture, BLoC, GoRouter, GetIt, and Material 3.

The web and mobile apps should use a consistent visual style, including colors and fonts.

## 2. First-version scope

The first version supports one farm and one owner account. It includes:

- Sign up, sign in, and sign out
- Basic owner profile and farm settings
- Cow records for milk, meat, or both, including milk production and feeding records
- Poultry groups for broilers, ducks, layers, and local birds, including feeding and egg production where applicable
- Crop names, crop cycles, crop expenses, harvest records, and simple crop summaries
- Inventory records and stock updates
- Simple general income and expense entries

The system is for basic record keeping. It is not a full accounting or farm forecasting system.

## 3. Users and access

The first version has one user: the farm owner. The owner manages all records for the single farm. There are no staff accounts or role management in this release.

Private farm data must only be available to the signed-in owner.

## 4. Out of scope

The first version does not include:

- Multiple farms
- Multiple owner accounts or staff roles
- Advanced accounting
- Forecasting
- Complex reporting

## 5. Authentication and owner profile

### Sign up

The owner creates an account with all of these required fields:

- Profile image
- Full name
- Email address
- Phone number
- Address
- Location (latitude and longitude)
- Password
- Confirm password

The system must validate email format and enforce agreed password requirements. It must reject duplicate email addresses and duplicate phone numbers. Password and confirm password must match; the confirmation value is not stored as a separate credential.

### Sign in and sign out

The owner signs in using email address and password and can sign out. A signed-out user cannot access private farm data.

### Profile and farm settings

The owner can view and update:

- Profile image
- Full name
- Email address
- Phone number
- Address
- Location (latitude and longitude)

## 6. Cows

The owner can add, view, edit, and archive cow records.

Each cow can include:

- Tag number
- Name, if known
- Breed, if known
- Date of birth, if known
- Purpose: milk, meat, or both
- Gender
- Color, if known
- Weight, if known
- Age, if known
- Acquired by: purchased or born on farm
- Purchase date, if purchased and known
- Purchase price, if purchased and known
- Notes

Purchase date and purchase price apply only to cows marked as purchased.

### Milk production

For cows kept for milk, the owner can record:

- Date and time of production
- Quantity of milk
- Unit of measurement
- Price per unit
- Optional note

The owner can review a cow's milk production entries. A cow kept only for meat does not require milk records.

### Feeding

For any cow, the owner can record:

- Date and time of feeding
- Feed type or name
- Quantity
- Unit of measurement
- Optional note

The owner can review a cow's feeding entries.

## 7. Poultry

The owner can add, view, edit, and archive poultry groups.

Each group includes:

- Type: broiler, duck, layer, or local
- Group name or identifier
- Number of birds
- Date acquired, if known
- Acquired by: purchased or born on farm
- Purchase date, if purchased and known
- Purchase price, if purchased and known
- Notes

The owner can update bird counts when birds are added or removed. Purchase date and purchase price apply only when the group was purchased.

### Feeding

For any poultry group, the owner can record date and time, feed type or name, quantity, unit of measurement, and an optional note. The owner can review feeding entries.

### Egg production

For layer, duck, or local groups, the owner can record date and time, quantity of eggs, unit of measurement, price per unit, and an optional note. The owner can review egg production entries. Broiler groups do not require egg production records.

## 8. Crops

### Crop names

Crop names are managed separately from crop cycles. The owner can add, view, edit, and archive crop names. A crop cycle must select a name from this list; crop name is not free text on the cycle.

### Crop cycles

The owner can add, view, edit, and archive crop cycles. Each cycle can include:

- Crop name selected from the crop names list
- Field or plot name
- Area, if known
- Location (latitude and longitude), if known
- Planting date
- Expected harvest date, if known
- Notes

### Crop expenses

The owner can add and review expenses linked to a crop cycle. Each expense includes date, category, amount, and optional note.

Expense categories:

- Labour
- Fertilizers
- Pesticides and chemicals
- Seeds
- Irrigation
- Equipment
- Other

### Harvest records

The owner can record harvest date, quantity harvested, unit of measurement, optional sale amount, and optional note.

### Crop summary

For each crop cycle, show total recorded expenses, recorded sale income (if entered), and the simple result: recorded crop income minus recorded crop expenses. This is a basic summary of entered records, not full accounting.

## 9. Inventory

The owner can add, view, edit, and archive inventory items. Each item can include:

- Item name
- Category
- Quantity
- Unit of measurement
- Price per unit
- Total price
- Optional note

The owner can record stock being added or used. Each stock update includes date, quantity added or used, and reason or note. The displayed quantity should reflect the recorded stock updates. A stock update must not reduce quantity below zero.

## 10. General income and expenses

The owner can add, view, edit, and archive general farm income and expense entries. Each entry includes:

- Type: income or expense
- Date
- Category
- Amount
- Unit of measurement
- Total price
- Optional note

Entries can be viewed by date. The owner can see simple total income and total expenses for a selected period. Crop expenses belong in the Crops module and must not be counted a second time as general expenses.

## 11. Architecture and implementation constraints

### Backend

Build one FastAPI application, separated into modules for:

- Authentication and owner profile/farm settings
- Cows
- Poultry
- Crops
- Inventory
- Income and expenses

Use SQLAlchemy for database access and PostgreSQL for persistence. Keep business rules in the backend so the web and mobile apps follow the same rules. Use database migrations and document API request fields, response fields, validation, and error behavior for each feature before connecting client screens.

### Web

Build the web app with React. It communicates with the backend API and follows the same product behavior and visual design as mobile where practical.

### Mobile

Build the mobile app with Flutter, Clean Architecture, BLoC, GoRouter, GetIt, and Material 3. Support Bangla and English localization.

Organize mobile code into:

- Infrastructure: GoRouter, GetIt, Material 3, theme, localization, and supporting infrastructure
- Presentation: screens, widgets, and BLoCs
- Domain: pure Dart entities, business rules, use cases, repository interfaces, logger, and utilities
- Data: API calls, data models, data sources, mappers between data models and domain entities, and repository implementations

Keep data and domain as separate projects within the mobile app project. The domain layer must remain pure Dart: no API calls, data models, data sources, mappers, or repository implementations.

### Shared API behavior

The FastAPI API is the shared contract for React and Flutter. Document each feature's request fields, response fields, validation rules, and errors before building dependent client screens.

## 12. Decisions to settle before implementation

Choose and record:

- PostgreSQL database setup and migration tool
- Authentication/session or token approach
- Backend hosting
- Storage for profile images and any future uploaded files
- Minimum password requirements
- Supported units and currency behavior

Keep infrastructure simple for the first version.

## 13. First-release acceptance checklist

- [ ] The app supports one farm and one owner account.
- [ ] Advanced accounting and complex reporting are excluded.
- [ ] Sign up, sign in, and sign out work.
- [ ] The owner can manage profile and farm settings.
- [ ] Cow records, milk production, and feeding records work.
- [ ] Poultry groups and bird-count updates work.
- [ ] Poultry feeding and applicable egg production records work.
- [ ] Crop names, crop cycles, crop expenses, harvests, and simple summaries work.
- [ ] Inventory items and stock updates work, including the no-negative-stock rule.
- [ ] General income and expense entries and simple period totals work.
- [ ] The web app can complete the main workflows.
- [ ] The mobile app can complete the main workflows.
- [ ] Both apps use the same backend rules and API.
- [ ] The owner can only access their own farm data.
- [ ] Setup instructions explain how to run the backend, web app, and mobile app.
