---
intent: 004-poultry-history-actions-and-table-polish
env: local
version: v0.4.0-e2cd75e
status: ready
updated: "2026-11-12T10:23:28Z"
---

# Local Deployment — Intent 004

## Status

| Environment         | Status                          |
| ------------------- | ------------------------------- |
| Local (dev machine) | ✅ Build verified; ready to run |
| Staging             | ⏭ Skipped (local-only)         |
| Production          | ⏭ Skipped (local-only)         |

## Smoke checklist (manual)

- [ ] Sign in on web; open a poultry group (layer/duck/local)
- [ ] Add egg → Edit → Delete (confirm); list refreshes
- [ ] Add feeding → Edit → Delete (confirm)
- [ ] Confirm **No.** headers; Edit primary / Delete danger
- [ ] Archived group: Action hidden/disabled
- [ ] Same flows on Flutter poultry detail (BN + EN)
- [ ] Cow milk/feeding Action colors still primary/danger

## Rollback

Revert to prior commit on `main` if local smoke fails; no remote host to roll back.
