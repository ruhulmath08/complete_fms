---
unit: 001-design-api
bolt: 019-design-api
stage: model
status: complete
updated: 2026-11-11T18:11:36Z
---

# Static Model - Design API (Cows contract extensions)

## Bounded Context

**Design API** extends the existing **Cows** bounded context (and list-paging conventions) so refreshed clients can:

1. Rely on **system-generated tag numbers**
2. Attach an optional **cow image**
3. Load **milk** and **feeding** history in pages of **10**

Owner-only scoping and soft-archive rules from the first-release cows model remain in force. This unit does not own poultry, crops, inventory, income/expenses, or a notification domain.

## Domain Entities

| Entity | Properties | Business Rules |
|--------|------------|----------------|
| Cow | Existing profile fields **plus** `image_path?` / image reference; `tag_number` (system-generated); `name` and `breed` **required on create** for tag generation; weight remains optional numeric/text with kg semantics at the UI | Tag is **not** supplied by the owner on create. On create, system sets `tag_number = name + breed + 6 random digits` (no separators unless later decided). Name and breed required for create. Generated tag must be unique among **active** cows for the owner; on collision, regenerate/retry until unique (bounded retries). Image optional on create/update. Soft-archive and purchase-field rules unchanged. |
| MilkProduction | Unchanged fields: id, cow_id, owner_id, produced_at, quantity, unit, price_per_unit, note?, timestamps | Eligibility unchanged (`milk` \| `both`). **Listing** must support paging with default page size **10**. Clients may compute **total** as `quantity × price_per_unit`. |
| CowFeeding | Unchanged fields: id, cow_id, owner_id, fed_at, feed_name, quantity, unit, note?, timestamps | Allowed for any non-archived cow. **Listing** must support paging with default page size **10**. |

## Value Objects

| Value Object | Properties | Constraints |
|--------------|------------|-------------|
| GeneratedTagNumber | value (string) | Format: concatenation of `name` + `breed` + exactly six ASCII digits `0-9`. Not blank. Unique among active cows per owner. Owner cannot invent an alternate tag on create. |
| TagDigitSuffix | six_digits | Exactly 6 digits; cryptographically or securely random enough for farm-scale uniqueness |
| CowImageRef | storage_path or public_url_path | Points to local upload storage outside Git; empty/null means no image |
| PageRequest | limit, offset (or page/page_size) | Default `limit=10` for milk and feeding lists; enforce max limit (design stage) |
| PageMeta | total?, limit, offset (or page, page_size, total_pages?) | Enough for clients to paginate without loading full history |
| MoneyAmount | amount | Non-negative; used for `price_per_unit` / totals |
| Quantity | amount, unit | amount > 0; unit non-empty |

## Aggregates

| Aggregate Root | Members | Invariants |
|----------------|---------|------------|
| Cow | Cow profile including generated tag and optional image; child MilkProduction and CowFeeding | Owner ownership immutable. Tag generated only when name+breed present. Unique active tag per owner. Purchase fields only when purchased. Milk writes only if purpose milk/both. Block new milk/feeding on archived cows; history readable. Image is part of cow profile consistency (same owner auth). |

## Domain Events

| Event | Trigger | Payload |
|-------|---------|---------|
| CowTagGenerated | Cow created with system tag | cow_id, owner_id, tag_number |
| CowRegistered | Cow created (extends prior event) | cow_id, owner_id, tag_number, purpose, has_image |
| CowImageAttached | Image set/replaced on cow | cow_id, owner_id, image_path |
| CowImageCleared | Image removed (if supported) | cow_id, owner_id |
| MilkProductionListed | N/A (query) — no persistent event required | — |
| CowUpdated | Profile fields changed (not tag invent by client) | cow_id, changed_fields |

## Domain Services

| Service | Operations | Dependencies |
|---------|------------|--------------|
| TagNumberGenerator | generate(name, breed) → GeneratedTagNumber; ensure_unique(owner_id, candidate) | CowRepository (uniqueness check) |
| CowService | create (calls generator; optional image), get, list_active, update (tag not client-invented on create path), archive; attach_image / clear_image | CowRepository, TagNumberGenerator, ImageStoragePort, AuthorizationPolicy |
| MilkProductionService | add; list_by_cow(owner_id, cow_id, PageRequest) → page | CowRepository, MilkProductionRepository |
| CowFeedingService | add; list_by_cow(owner_id, cow_id, PageRequest) → page | CowRepository, CowFeedingRepository |

## Repository Interfaces

| Repository | Entity | Methods |
|------------|--------|---------|
| CowRepository | Cow | save; get_by_id(owner_id, id); list_active(owner_id, paging?); update; archive; exists_active_tag(owner_id, tag_number) |
| MilkProductionRepository | MilkProduction | save; list_by_cow(owner_id, cow_id, PageRequest) → (items, PageMeta) |
| CowFeedingRepository | CowFeeding | save; list_by_cow(owner_id, cow_id, PageRequest) → (items, PageMeta) |
| ImageStoragePort | CowImageRef | store(owner_id, cow_id, bytes/content_type) → CowImageRef; delete?(ref) |

All queries filter by `owner_id`. Private images must not be readable without owner authorization.

## Ubiquitous Language

| Term | Definition |
|------|------------|
| Generated tag number | System-created cow identifier: name + breed + 6 random digits |
| Cow image | Optional photo associated with a cow, stored on local disk outside Git |
| Page size 10 | Default number of milk or feeding rows returned per list request for refreshed tables |
| Total (milk) | Derived display amount: quantity × unit price (price_per_unit) |
| Active cow | Non-archived cow for the signed-in owner |
| Tag collision | Generated tag already used by another active cow of the same owner |

## Story Coverage

| Story | Domain coverage |
|-------|-----------------|
| 001-api-auto-tag-number | GeneratedTagNumber, TagNumberGenerator, name/breed required on create, uniqueness + retry |
| 002-api-cow-image | CowImageRef, ImageStoragePort, Cow.image, auth on private media |
| 003-api-milk-feeding-pagination | PageRequest/PageMeta default limit 10 on milk and feeding list_by_cow |

## Changes vs First-Release Cows Model

| Topic | First release (004-cows) | This bolt |
|-------|-------------------------|-----------|
| Tag number | Owner-supplied; unique among active | System-generated; owner does not invent on create |
| Name / breed | Optional | Required on create (for tag generation) |
| Cow image | Not modeled | Optional image ref on Cow |
| Milk/feeding list default page size | Documented as 20 default / max 100 | Default **10** for refreshed UI tables; max still capped in design |

## Open Questions Deferred to Technical Design

- Exact max retry count on tag collision
- Whether tag can be regenerated on update if name/breed change (default: **no** — tag stable after create)
- Image required vs optional on create (domain: **optional**; product may tighten later)
- Max upload size / allowed content types
- Whether `total` is returned by API or computed only by clients (recommend: client-computed or optional response field — decide in design)
- Page meta shape (`offset/limit` vs `page/page_size`) — align with existing `/api/v1` list conventions in design
