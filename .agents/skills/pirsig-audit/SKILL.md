---
name: pirsig-audit
description: Audit source files against Pirsig AST invariants (max 200 lines per file, max 40 lines per function, zero any types, zero placeholders).
---

# Pirsig AST Audit Skill

Audit source files against Codernic Pirsig sovereign AST quality invariants.

## Invariant Checks
1. File size limit: maximum 200 lines per file.
2. Function size limit: maximum 40 lines per function or method.
3. Strict typing: zero any types; all types must be explicitly declared.
4. Complete implementation: zero placeholder comments, dummy values, or unfinished logic.
5. Zero warnings: compiler and linter passes must be clean.

## Verification Workflow
When reviewing changes across the project:
1. Verify line counts for every touched file (<= 200 lines).
2. Inspect function definitions to ensure bounded scope (<= 40 lines).
3. Confirm zero occurrences of disallowed type escapes (no any, no stubs).
4. Run compiler and linter checks to ensure zero warnings.
