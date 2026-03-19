# League Implementation Checklist

Use this file as the phase gate tracker. Do not start the next phase until all items in the current phase are checked.

## Phase -1: Existing Codebase Audit

- [x] Reviewed backend contest flow and reusable API patterns
- [x] Reviewed Flutter contest flow and reusable UI/state patterns
- [x] Created delta map: reuse, modify, create, do-not-touch
- [x] Logged risks and conflict points
- [x] Audit approved

## Phase 0: Copilot Scaffolding

- [x] Created/updated root instruction entrypoint
- [x] Created/updated agent registry
- [x] Created scoped instruction files with applyTo
- [x] Created league skills (planning, api, ui, notifications-ads)
- [x] Scaffolding validation gate passed

## Phase 1: Database

- [x] League migration file created
- [x] Migration executed in test db
- [x] Indices and constraints verified
- [x] Rollback notes captured

## Phase 2: Backend APIs

- [x] League list/details endpoints implemented
- [x] Opt-in/join flows implemented
- [x] Daily quiz retrieval and daily limit rule implemented
- [x] Submission and leaderboard logic implemented
- [ ] Endpoint tests completed

Note: Endpoint runtime tests are currently blocked in local env due to PHP runtime mismatch (required >= 8.4, current 8.2.12).

## Phase 3: Flutter Frontend

- [x] League models implemented
- [x] League cubits and states implemented
- [x] League screens implemented
- [x] Navigation integrated with quiz hub
- [ ] Device/emulator flow test completed

## Phase 4: Admin Backend

- [x] League CRUD/admin pages implemented
- [x] Daily quiz assignment workflow implemented
- [x] Admin validation/permissions verified
- [ ] Admin smoke tests completed

## Phase 5: Prize Distribution

- [x] Prize setup table/logic finalized
- [ ] Duplicate payout protection verified
- [ ] Payout run tested and logged

## Phase 6: Push Notifications

- [x] T-24h job implemented
- [x] Start-day job implemented
- [x] Notification preferences respected
- [ ] Logging and retry handling verified
- [ ] Real-device delivery tests completed

Note: Runtime verification is blocked in local env due to PHP runtime mismatch (required >= 8.4, current 8.2.12).

## Phase 7: Ads Integration

- [ ] AdMob interstitial integrated for first daily play
- [ ] One-ad-per-day enforcement verified
- [ ] Analytics/impression logging verified
- [ ] UX regression checks passed

## Final Release Gate

- [ ] All phase checklists completed
- [ ] Contest and league coexistence regression test passed
- [ ] Performance and stability checks passed
- [ ] Rollout approval completed
