## 2026-09-01 - ruleset read-back

| Check | Command | Result | Status |
|---|---|---|---|
| Ruleset live | `gh api repos/NeoTech-Networks/postgres-mcp-railway-template/rules/branches/<default>` | ruleset NOT yet created | VERIFIED |
| Merge settings | `gh api repos/NeoTech-Networks/postgres-mcp-railway-template` | squash only, delete-on-merge true, auto-merge true | VERIFIED |
| PR #2 CI | wait_for.py ci --pr 2 | all 3 checks green | VERIFIED |
| Ruleset | rules/branches/main | none yet (deliberate) | UNVERIFIED |
