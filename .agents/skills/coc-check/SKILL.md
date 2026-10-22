---
name: coc-check
description: Inspect and verify Codernic Sovereign Package Manager dependencies and registry health.
---

# COC Package Verification Skill

Verify package integrity, dependency DAGs, and registry synchronization using COC.

## Verification Workflow
1. Validate installed packages against cryptographic hashes:
   `coc-pm verify`
2. Run system health check across local sovereign dependencies:
   `coc-pm health`
3. Query sovereign packages in `.codernic/packages/@codernic/*`:
   - Always modify upstream sources in the workspace, never mutate package caches directly.
