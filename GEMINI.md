<antigravity_rules>

<ruleset name="Rust Code Quality & Architecture">
    <rule>**Zero Warnings Policy:** Run `cargo clippy --workspace --all-targets --all-features -- -D warnings`. You must resolve ALL lints before finishing the task.</rule>
    <rule>**Workspace Dependency Enforcement:** Do not add inline `path = "..."` dependencies inside nested `Cargo.toml` files. All internal and common external dependencies MUST be declared in the root `Cargo.toml` under `[workspace.dependencies]` and referenced in sub-crates using `{ workspace = true }`.</rule>
    <rule>**Strict Boundaries:** Ensure no dependency path escapes the workspace root (e.g., no `path = "../../../other_repo"`).</rule>
    <rule>**Dependency Inversion (Engine Purity):** High-level orchestration crates (e.g. `codernic`, `galileus`, `pirsig`) may depend on engines. Low-level engine crates MUST NEVER depend on high-level business logic or integration bridges.</rule>
</ruleset>

<ruleset name="Antigravity Session Defaults">
    <rule>**Strict Mode & Temperature:** Strict mode is ON. Temperature is effectively 0. Antigravity must behave as deterministically and strictly as possible.</rule>
    <rule>**Language Policy:** All communication and explanations must strictly be written in English.</rule>
</ruleset>

<ruleset name="Architectural & Code Quality Best Practices">
    <rule>**No Monolithic Implementations:** Never create monolithic implementations.</rule>
    <rule>**No God Functions/Components:** Never create god functions or components. Always break down large functions into smaller ones. Always break down huge components into smaller reusable components.</rule>
    <rule>**UI & Organization Patterns:** Always use Atomic Design principles for UI components. Always use Feature-Sliced Design (FSD) patterns for file organization.</rule>
    <rule>**Design Patterns:** Always use recognized design patterns whenever suitable.</rule>
    <rule>**Documentation:** Always document features (update existing or create new) in the `private_docs` folder.</rule>
</ruleset>

<ruleset name="TypeScript & React Rules">
    <rule>**Strict TypeScript:** Never use `any` or stub types in TypeScript.</rule>
    <rule>**React Components:** Never use `React.FC` for components. Always declare an interface for props and destructure all props directly in the component signature.</rule>
</ruleset>

<ruleset name="Agent Behavior & Verification Rules">
    <rule>**No Guessing:** Never guess. ALWAYS verify your assumptions before affirming something.</rule>
    <rule>**Strict Testing Policy:** Never claim something is fixed if you haven't explicitly tested it.</rule>
    <rule>**Propose Tests:** Always propose creating suitable tests for new or modified features.</rule>
</ruleset>

<ruleset name="UI Component Reuse & Atomic Design">
    <rule>**Codernic-UI Component Reuse:** When working on `codernic-ui` and adding UI elements (atoms, molecules, organisms), you MUST reuse components already built in the `~/packages/ui` library. Do not recreate existing or shared elements.</rule>
    <rule>**Component Analysis Workflow:** The best practice is to: 1. Analyze and list all needed components. 2. Check their availability in the shared library (`packages/ui`) or the shared folder in `codernic-ui`. 3. If they don't exist, evaluate if they are good candidates to be shared. 4. Only if the component is too specific should it be created locally.</rule>
</ruleset>

<ruleset name="Agent Coordination & Subagents">
    <rule>**Supervisor Role:** As the main supervisor agent, you must hire the best specialized agent for the task you are performing.</rule>
    <rule>**Context Delegation:** Make sure the hired agent has enough context to comply with its duties, strictly following the best practices defined here.</rule>
    <rule>**Agent Registry:** All specialized agent definitions are located in the `.gemini/agents/` directory. Use them as reference or instructions when invoking subagents.</rule>
    <rule>**Skills Registry:** Specialized agents must use the appropriate skill files located in `.gemini/skills/` to ensure absolute best practices for the targeted technology.</rule>
</ruleset>

<ruleset name="Architecture Principles & Reference">
    <rule>**Architecture Principles Guide:** You must adhere to the concepts described in `private_docs/architecture_principles.md`. This file contains the definitive guidelines for Design Patterns, SOLID Principles, Clean Code, Clean Architecture, Atomic Design, Feature-Sliced Design (FSD), and other engineering standards applicable to this project.</rule>
</ruleset>

<ruleset name="Sovereign Productivity Gateway: Ragtime 2 & Galileus DAG Suspension">
    <rule>**DAG & RAG Obligation Lifted (Suspended Pending SOTA Finalization):** By explicit user mandate, all obligations to use Galileus DAG V2 and RagTime 2 are SUSPENDED. They are NOT to be imposed on agents or workflows until their architectures are fully refactored, benchmarked, and finalized. Antigravity MUST use native tools (`replace_file_content`, `write_to_file`, `run_command`, `grep_search`, `find_by_name`, `cargo`, `git`) for all code modifications, refactorings, and searches without restriction.</rule>
</ruleset>

</antigravity_rules>
