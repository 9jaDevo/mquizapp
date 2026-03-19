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
- [ ] Migration executed in test db
- [ ] Indices and constraints verified
- [ ] Rollback notes captured

## Phase 2: Backend APIs

- [ ] League list/details endpoints implemented
- [ ] Opt-in/join flows implemented
- [ ] Daily quiz retrieval and daily limit rule implemented
- [ ] Submission and leaderboard logic implemented
- [ ] Endpoint tests completed

## Phase 3: Flutter Frontend

- [ ] League models implemented
- [ ] League cubits and states implemented
- [ ] League screens implemented
- [ ] Navigation integrated with quiz hub
- [ ] Device/emulator flow test completed

## Phase 4: Admin Backend

- [ ] League CRUD/admin pages implemented
- [ ] Daily quiz assignment workflow implemented
- [ ] Admin validation/permissions verified
- [ ] Admin smoke tests completed

## Phase 5: Prize Distribution

- [ ] Prize setup table/logic finalized
- [ ] Duplicate payout protection verified
- [ ] Payout run tested and logged

## Phase 6: Push Notifications

- [ ] T-24h job implemented
- [ ] Start-day job implemented
- [ ] Notification preferences respected
- [ ] Logging and retry handling verified
- [ ] Real-device delivery tests completed

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
