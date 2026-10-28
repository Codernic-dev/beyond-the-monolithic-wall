---
name: coc-check
description: Inspect and verify Codernic Managed Package (COC) dependencies, registry health, and standalone fallback.
---
<?xml version="1.0" encoding="UTF-8"?>
<codernic_skill id="coc-check" kind="workflow" version="1.0">
  <mental_model>
    Codernic Managed Packages (COC) provide cryptographically sealed dependency management. Dependencies must be validated against BLAKE3 checksums, registry synchronization maintained, and boundary rules enforced: packages in .codernic/packages/@codernic/* must never be modified directly; changes belong to upstream source repositories.
  </mental_model>
  <workflow>
    <step n="1" name="Package Integrity Validation">
      <action>Validate installed packages against cryptographic BLAKE3 hashes using coc-pm CLI.</action>
      <command>coc-pm verify --json</command>
    </step>
    <step n="2" name="Registry Health Check">
      <action>Run system health check across local sovereign dependencies and registries.</action>
      <command>coc-pm health --json</command>
    </step>
    <step n="3" name="Package Boundary Inspection">
      <action>Inspect package boundaries in .codernic/packages/@codernic/* and ensure upstream source edits only.</action>
      <command>coc-pm check-boundaries --json</command>
    </step>
    <step n="4" name="Standalone Fallback Verification">
      <action>When COC environment is absent or unconfigured, confirm standalone native tooling operates cleanly without failure.</action>
      <command>cargo check --workspace</command>
    </step>
  </workflow>
  <invariants>
    <invariant id="INV-ZERO-MCP">Zero MCP calls; invoke coc-pm CLI with --json output only.</invariant>
    <invariant id="INV-UPSTREAM-BOUND">Never mutate .codernic/packages/ directly; modify upstream source repositories.</invariant>
    <invariant id="INV-HASH-SEAL">All package manifests must match registered BLAKE3 hashes.</invariant>
  </invariants>
  <anti_patterns>
    <avoid>Never edit files inside .codernic/packages/@codernic/* directly.</avoid>
    <avoid>Never bypass coc-pm cryptographic validation by manually tampering with lockfiles.</avoid>
    <avoid>Never introduce workspace-escaping parent relative paths (..) in manifests.</avoid>
  </anti_patterns>
  <verification>
    <check>Verify coc-pm verify --json returns ok: true.</check>
    <check>Verify coc-pm health --json reports no registry inconsistencies.</check>
  </verification>
</codernic_skill>