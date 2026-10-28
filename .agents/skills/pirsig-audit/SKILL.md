---
name: pirsig-audit
description: Audit source files against Pirsig AST invariants (<=200 lines/file, <=40 lines/fn, zero any/stubs, zero warnings).
---
<?xml version="1.0" encoding="UTF-8"?>
<codernic_skill id="pirsig-audit" kind="workflow" version="1.0">
  <mental_model>
    The Pirsig Sovereign AST Quality model guarantees non-negotiable structural and architectural excellence across all codebases. Structural complexity is bounded by tight physical AST invariants, static typing purity, complete production implementation with zero stubs, and absolute warning-free compilation.
  </mental_model>
  <workflow>
    <step n="1" name="Source File Bounds Verification">
      <action>Audit physical line counts across all created or modified source files to guarantee strict adherence to file length limits.</action>
      <rule>Maximum 200 lines per file (target &lt;= 190 lines). Split modules into cohesion-bounded submodules when approaching 190 lines.</rule>
    </step>
    <step n="2" name="Function and Method Complexity Audit">
      <action>Inspect function, method, and closure implementations to verify strict complexity ceilings.</action>
      <rule>Maximum 40 lines per function or method (target &lt;= 38 lines). Extract helper functions for complex branching or transformations.</rule>
    </step>
    <step n="3" name="Zero-Stub and Strict Typing Inspection">
      <action>Perform recursive AST scan to detect prohibited placeholders, unfinished branches, or dynamic type escapes.</action>
      <rule>Absolute ban on todo!(), unimplemented!(), any, dummy placeholders, mock responses, and synthetic fallbacks.</rule>
    </step>
    <step n="4" name="Zero-Warning Compiler and Linter Enforcement">
      <action>Execute strict workspace compiler and linter passes with warnings treated as fatal compilation errors.</action>
      <command>cargo clippy --workspace --all-targets --all-features -- -D warnings</command>
      <command>tsc --noEmit</command>
    </step>
  </workflow>
  <invariants>
    <invariant id="INV-PIRSIG-FILE-LINES">Source files must never exceed 200 lines under any circumstance.</invariant>
    <invariant id="INV-PIRSIG-FN-LINES">Functions and methods must never exceed 40 lines under any circumstance.</invariant>
    <invariant id="INV-ZERO-STUBS">All types, functions, and interfaces must be 100% production-implemented with zero stubs.</invariant>
    <invariant id="INV-ZERO-WARNINGS">Zero compiler, linter, or typechecker warnings tolerated across all build targets.</invariant>
  </invariants>
  <anti_patterns>
    <avoid>Never insert todo!() or unimplemented!() macros to defer implementation.</avoid>
    <avoid>Never bypass type safety using any, dynamic casting, or untyped dictionary escapes.</avoid>
    <avoid>Never leave dead code or unused imports generating compiler warnings.</avoid>
    <avoid>Never bundle unrelated logic into mega-files exceeding 190 lines.</avoid>
  </anti_patterns>
  <verification>
    <check>Verify file line counts across touched files remain &lt;= 200 lines.</check>
    <check>Verify all function declarations remain &lt;= 40 lines.</check>
    <check>Verify cargo clippy -- -D warnings and tsc --noEmit pass with exit code 0.</check>
  </verification>
</codernic_skill>