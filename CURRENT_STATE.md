# CURRENT_STATE

## 2026-09-01 - ruleset live

- Ruleset 22041154 active on main with required check `docker-build` (created after the workflow's first green main run 3091fb3). All 8 consumer services deployed from 3091fb3.
## 2026-09-01 - main ruleset and merge settings landed (github-gates plan, session 3f7cfc15)

- Ruleset `main-protection-trunk-and-promote` is ACTIVE on this repo's default branch as of 2026-09-01: pull_request, required_linear_history, non_fast_forward, deletion (required_status_checks [`docker-build`] to be added after PR #2 lands and runs green on main). Bypass: RepositoryRole admin, mode `always` (same shape as the four Railway repos). VERIFIED by `gh api repos/NeoTech-Networks/postgres-mcp-railway-template/rules/branches/<branch>`.
- Merge settings PATCHed to squash-only, delete_branch_on_merge=true, allow_auto_merge=true. VERIFIED by read-back.
- Known limit, decided at plan time and to be revisited by Steve: with bypass `always`, an admin direct push or API merge is ACCEPTED with a "Bypassed rule violations" notice (proved on make-scenario-contracts 2026-09-01); only non-admin actors are refused.
- PR #2 adds `.github/workflows/docker-build.yml` (buildx both images, gate job `docker-build`). CI green on the PR (3 checks). Merge HELD for the promote phrase: eight production MCP/gateway services build from main of this repo.
- Ruleset is created only after the workflow's first green run on main, so a required check that has never reported cannot lock the branch.
