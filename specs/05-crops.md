# Crops

## Purpose

Let the farm owner track crop cycles, crop costs, harvests, and related income.

## Crop names

Crop names are stored in a separate table. The owner adds and manages the list of crop names.

The owner can:

- Add a crop name
- View crop names
- Edit a crop name
- Archive a crop name

A crop cycle must select its crop name from this list. Crop name is not free text on the crop cycle.

## Crop cycle

Each crop cycle can include:

- Crop name (selected from the crop names table)
- Field or plot name
- Area, if known
- Location (latitude and longitude), if known
- Planting date
- Expected harvest date, if known
- Notes

## Crop expenses

The owner can add expenses to a crop cycle. Each expense includes:

- Date
- Category
- Amount
- Optional note

Expense categories:

- Labour
- Fertilizers
- Pesticides and chemicals
- Seeds
- Irrigation
- Equipment
- Other

## Harvest

The owner can record:

- Harvest date
- Quantity harvested
- Unit of measurement
- Optional sale amount
- Optional note

## Crop summary

For each crop cycle, show:

- Total recorded expenses
- Recorded sale income, if entered
- Simple result: recorded crop income minus recorded crop expenses

This is a basic summary of entered records, not full accounting.

## Acceptance criteria

- The owner can add, view, edit, and archive crop names in a separate table.
- A crop cycle must use a crop name from that table.
- The owner can add, view, edit, and archive a crop cycle.
- The owner can record and review expenses for a crop cycle.
- The owner can record harvest details and optional sale income.
- The crop summary uses the expenses and income recorded for that crop cycle.
