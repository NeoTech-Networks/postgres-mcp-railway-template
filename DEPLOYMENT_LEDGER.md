## 2026-09-01 - first CI-gated merge to main

| Commit | PR | Railway effect | Status |
|---|---|---|---|
| 3091fb3 | #2 docker-build workflow | 6 of 8 MCP/gateway services redeployed automatically at 19:37Z, all SUCCESS; Shared MCP and ABC MCP had dead triggers, reconnected and deployed (d78635b0, e99eb3fe) SUCCESS 19:40Z | VERIFIED |

Ruleset 22041154 created after the main run went green: required check `docker-build`, five rule types, admin bypass always.
