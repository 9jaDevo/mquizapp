# Agent Registry

## Planning Agent

Purpose:
- Convert product goals into implementable phases.
- Define sequencing, dependencies, and acceptance criteria.

Responsibilities:
- Maintain phase plan and checklist integrity.
- Enforce mandatory gates (audit, scaffolding, phase completion).

## Explore Agent

Purpose:
- Perform read-only analysis before implementation.

Responsibilities:
- Inspect existing code and identify reusable patterns.
- Produce delta map: reuse, modify, create, do-not-touch.

## Implementation Agent

Purpose:
- Implement scoped changes phase-by-phase.

Responsibilities:
- Follow conventions from `copilot-instructions.md`.
- Make minimal, targeted edits.
- Do not proceed to next phase without checklist ticks.

## Review Agent

Purpose:
- Validate quality, regressions, and completion.

Responsibilities:
- Verify acceptance criteria and test coverage for each phase.
- Confirm no unrelated regressions introduced.

## Handoff Rules

- Planning -> Explore: include scope and target paths.
- Explore -> Implementation: include delta map and risks.
- Implementation -> Review: include changed files and validation evidence.

## Tool Boundaries

- Prefer read-only discovery before edits.
- Do not use destructive repository commands.
- Avoid editing unrelated files.
