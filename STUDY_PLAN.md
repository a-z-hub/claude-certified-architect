# Claude Certified Architect — Foundations: Study Plan

> Based on: official `exam_guide.pdf` (v0.1, Feb 2025), `guide_en.MD` community study guide,
> Anthropic Skilljar course catalog (June 2026), and Claude API docs.

---

## Quick Facts

| | |
|---|---|
| Format | Multiple choice, 1 correct of 4, no penalty for guessing |
| Pass score | 720 / 1000 |
| Scenarios | 4 drawn randomly from 6 official scenarios |
| Access | Partner network only (free for first 5,000 employees) |
| Access request | `https://anthropic.skilljar.com/claude-certified-architect-foundations-access-request` |

**Do this first:** Submit the access request before studying — approval can take days.

---

## Domain Weights (study time allocation)

| Domain | Weight | Hours to allocate |
|---|---|---|
| 1. Agentic Architecture & Orchestration | 27% | ~6 hrs |
| 3. Claude Code Configuration & Workflows | 20% | ~4.5 hrs |
| 4. Prompt Engineering & Structured Output | 20% | ~4.5 hrs |
| 2. Tool Design & MCP Integration | 18% | ~4 hrs |
| 5. Context Management & Reliability | 15% | ~3.5 hrs |

---

## Phase 0 — Access & Setup (Day 1)

- [ ] Submit access request at Skilljar (link above)
- [ ] Create account at `platform.claude.com` and get an API key
- [ ] Install Claude Code CLI: `npm install -g @anthropic-ai/claude-code`
- [ ] Verify: `claude --version`
- [ ] Clone or bookmark this repo — use `guide_en.MD` as primary reference
- [ ] Open `practical_test_en.html` in a browser — this is your practice exam

---

## Phase 1 — Courses (Week 1, ~10 hrs)

Take in this order. All are free on `anthropic.skilljar.com`.

### Priority 1 — Core exam coverage

- [ ] **Introduction to Subagents** (`/introduction-to-subagents`)
  - Directly covers Domain 1 (27%) — do this first
  - Topics: context passing, Task tool, coordinator patterns, parallel execution
- [ ] **Claude Code in Action** (`/claude-code-in-action`)
  - Covers Domain 3 (20%)
  - Topics: CLAUDE.md, slash commands, plan mode, CI/CD integration
- [ ] **Introduction to Agent Skills** (`/introduction-to-agent-skills`)
  - Covers Domain 3: skills frontmatter (`context: fork`, `allowed-tools`, `argument-hint`)
- [ ] **Claude Code 101** (`/claude-code-101`)
  - Daily workflow, built-in tools (Read/Write/Edit/Bash/Grep/Glob)
- [ ] **Building with the Claude API** (`/claude-with-the-anthropic-api`)
  - Covers Domain 2 and 4: tool_use, JSON schemas, tool_choice, Message Batches API
- [ ] **Introduction to Model Context Protocol** (`/introduction-to-model-context-protocol`)
  - Covers Domain 2: MCP servers, tools, resources, isError flag
- [ ] **Model Context Protocol: Advanced Topics** (`/model-context-protocol-advanced-topics`)
  - Structured error responses, advanced MCP patterns

### Priority 2 — Supplemental

- [ ] **Claude Platform 101** (`/claude-platform-101`) — Managed Agents overview
- [ ] **Claude 101** (`/claude-101`) — Quick background, skip if you use Claude daily

---

## Phase 2 — Theory Study by Domain (Week 2–3, ~22 hrs)

Work through `guide_en.MD` section by section. Read **Part II domain notes first** if time-pressed — they are the exam-focused distillation.

---

### Domain 1: Agentic Architecture & Orchestration (27%)

**Read:** `guide_en.MD` Chapters 3, 8, 9, 10 → then Part II Domain 1 notes (line 1570)

#### Task 1.1 — Agentic loops

- [ ] Know the full lifecycle: request → inspect `stop_reason` → execute tool → append result → next iteration
- [ ] `stop_reason: "tool_use"` → continue; `stop_reason: "end_turn"` → terminate
- [ ] Tool results must be appended to conversation history between iterations
- [ ] Anti-patterns: parsing natural language to determine loop end, arbitrary iteration caps, checking for assistant text content as completion signal

#### Task 1.2 — Coordinator–subagent patterns

- [ ] Hub-and-spoke: coordinator owns all inter-subagent communication, error handling, routing
- [ ] Subagents have **isolated context** — they do NOT inherit coordinator's conversation history
- [ ] Coordinator decomposes, delegates, aggregates, and routes dynamically
- [ ] Risk: overly narrow decomposition → coverage gaps (e.g., "AI in creative industries" decomposed as only visual arts)

#### Task 1.3 — Subagent invocation and context passing

- [ ] `Task` tool is the mechanism for spawning subagents
- [ ] Coordinator's `allowedTools` **must include "Task"** to spawn subagents
- [ ] All context must be **explicitly passed in the subagent's prompt** — no automatic inheritance
- [ ] `AgentDefinition`: descriptions, system prompts, tool restrictions per subagent type
- [ ] Parallel execution: emit **multiple Task calls in a single coordinator response** (not across turns)
- [ ] Pass structured data with source metadata (URL, doc name, page) to preserve attribution

#### Task 1.4 — Multi-step workflows and handoffs

- [ ] Programmatic enforcement (hooks, prerequisite gates) vs prompt-based guidance
- [ ] Prompt instructions alone have non-zero failure rate for critical sequences
- [ ] Use programmatic prerequisites: block `process_refund` until `get_customer` returns verified ID
- [ ] Structured handoff format: customer ID, root cause, refund amount, recommended action

#### Task 1.5 — Agent SDK hooks

- [ ] `PostToolUse` hook: intercepts tool results **before** model processes them — use for normalization
- [ ] Tool call interception hooks: block outgoing calls that violate policy (e.g., refunds > $500)
- [ ] Hooks = deterministic guarantees; prompts = probabilistic compliance
- [ ] Use hooks when business rules require guaranteed enforcement

#### Task 1.6 — Task decomposition strategies

- [ ] Fixed sequential pipeline (prompt chaining) → for predictable multi-aspect reviews
- [ ] Dynamic adaptive decomposition → for open-ended investigation tasks
- [ ] Large code review pattern: per-file local pass → separate cross-file integration pass
- [ ] Open-ended task pattern: map structure first → identify high-impact areas → prioritized plan

#### Task 1.7 — Session state, resumption, forking

- [ ] `--resume <session-name>` for named session continuation
- [ ] `fork_session` for independent branches from shared baseline (compare approaches)
- [ ] When resuming after file changes: **inform agent of specific changes** for targeted re-analysis
- [ ] Starting fresh with injected summary is more reliable than resuming with stale tool results

---

### Domain 2: Tool Design & MCP Integration (18%)

**Read:** `guide_en.MD` Chapters 2, 4 → then Part II Domain 2 notes (line 1676)

#### Task 2.1 — Tool interface design

- [ ] Tool descriptions are the **primary mechanism** LLMs use for tool selection
- [ ] Minimal descriptions → unreliable selection among similar tools
- [ ] Good description includes: purpose, input formats, example queries, edge cases, boundaries vs similar tools
- [ ] Ambiguous descriptions (e.g., `analyze_content` vs `analyze_document` with identical text) cause misrouting
- [ ] System prompt keywords can override well-written descriptions — audit for conflicts
- [ ] Fix: rename + rewrite description to eliminate overlap, or split generic tool into purpose-specific tools

#### Task 2.2 — Structured MCP error responses

- [ ] `isError: true` flag in MCP response — do NOT throw exception
- [ ] Error categories: `transient` (timeout, unavailable), `validation` (bad input), `business` (policy violation), `permission`
- [ ] Return: `errorCategory`, `isRetryable` boolean, human-readable description
- [ ] Local recovery in subagent for transient errors; propagate only unresolvable errors with partial results
- [ ] Distinguish **access failures** (timeout → retry decision) from **valid empty results** (no matches → not an error)

#### Task 2.3 — Tool distribution and `tool_choice`

- [ ] Too many tools (e.g., 18 instead of 4–5) degrades selection reliability
- [ ] Each agent gets only tools for its role — prevent cross-specialization misuse
- [ ] `tool_choice: "auto"` — model may skip tool and return text
- [ ] `tool_choice: "any"` — model **must** call a tool (choose which)
- [ ] `tool_choice: {"type": "tool", "name": "..."}` — model must call this specific tool
- [ ] Use forced selection to enforce ordering (e.g., `extract_metadata` before enrichment)
- [ ] Scoped cross-role tools for high-frequency needs (e.g., `verify_fact` for synthesis agent)

#### Task 2.4 — MCP server integration

- [ ] Project-level: `.mcp.json` in repo — shared via version control for team tooling
- [ ] User-level: `~/.claude.json` — personal/experimental servers
- [ ] Environment variable expansion in `.mcp.json`: `${GITHUB_TOKEN}` — never commit secrets
- [ ] All configured MCP servers discovered at connection time, available simultaneously
- [ ] MCP resources expose **content catalogs** (issue lists, doc hierarchies, schemas) to reduce exploratory calls
- [ ] Prefer existing community MCP servers for standard integrations (Jira, GitHub); build custom for team-specific needs
- [ ] Enhance MCP tool descriptions to prevent agent from preferring built-in tools (Grep) over better MCP tools

#### Task 2.5 — Built-in tools

- [ ] `Grep` → search **file contents** for patterns (function names, error messages, import statements)
- [ ] `Glob` → find files by **path pattern** (`**/*.test.tsx`)
- [ ] `Read`/`Write` → full file operations; `Edit` → targeted modification with unique text anchor
- [ ] When `Edit` fails (non-unique match) → fall back to `Read` + `Write`
- [ ] Investigation strategy: `Grep` to find entry points → `Read` to trace imports/flows (not all files upfront)

---

### Domain 3: Claude Code Configuration & Workflows (20%)

**Read:** `guide_en.MD` Chapters 5, 13 → then Part II Domain 3 notes (line 1757)

#### Task 3.1 — CLAUDE.md hierarchy

- [ ] Three levels: user (`~/.claude/CLAUDE.md`), project (root `CLAUDE.md`), directory (subdirectory `CLAUDE.md`)
- [ ] User-level instructions are **NOT shared** via version control
- [ ] `@import` syntax to reference external files (keep CLAUDE.md modular)
- [ ] `.claude/rules/` directory for topic-specific rule files (`testing.md`, `api-conventions.md`, `deployment.md`)
- [ ] `/memory` command to verify which files are loaded and diagnose session inconsistencies
- [ ] Common trap: instructions in user-level config → new team member doesn't receive them → move to project-level

#### Task 3.2 — Custom slash commands and skills

- [ ] Project-scoped commands: `.claude/commands/` — version-controlled, available to whole team
- [ ] User-scoped commands: `~/.claude/commands/` — personal only
- [ ] Skills: `.claude/skills/SKILL.md` with YAML frontmatter
  - `context: fork` — runs in isolated sub-agent, output doesn't pollute main session
  - `allowed-tools` — restricts tool access during skill execution
  - `argument-hint` — prompts user for parameters when invoked without args
- [ ] Skills vs CLAUDE.md: skills = on-demand invocation; CLAUDE.md = always-loaded
- [ ] Personal variants: create in `~/.claude/skills/` with different name to avoid affecting teammates

#### Task 3.3 — Path-specific rules

- [ ] `.claude/rules/` files with YAML frontmatter `paths:` field containing glob patterns
- [ ] Rules load **only** when editing matching files → reduces irrelevant context and tokens
- [ ] Example: `paths: ["terraform/**/*"]` → Terraform rules only when editing Terraform files
- [ ] `**/*.test.tsx` → test conventions for all test files regardless of directory
- [ ] Advantage over subdirectory CLAUDE.md: can apply to files spread across the codebase

#### Task 3.4 — Plan mode vs direct execution

- [ ] **Plan mode**: large-scale changes, multiple valid approaches, architectural decisions, multi-file modifications
- [ ] **Direct execution**: simple, well-scoped, single-file changes with clear path
- [ ] Plan mode enables safe exploration before committing — prevents costly rework
- [ ] `Explore` subagent for verbose discovery phases — returns summary, protects main context
- [ ] Pattern: use plan mode to investigate → direct execution for implementation
- [ ] Trap: switching to plan mode reactively when complexity emerges is too late for architectural decisions

#### Task 3.5 — Iterative refinement

- [ ] Concrete input/output examples beat prose descriptions for inconsistent transformations
- [ ] Test-driven iteration: write tests first → share failures → iterate until passing
- [ ] Interview pattern: Claude asks clarifying questions before implementing in unfamiliar domains
- [ ] Interacting issues → single message with all; independent issues → fix sequentially

#### Task 3.6 — CI/CD integration

- [ ] `-p` / `--print` flag for **non-interactive mode** (prevents CI hang) — this is the correct answer to "job hangs"
- [ ] `--output-format json` + `--json-schema` for machine-parseable structured CI output
- [ ] CLAUDE.md provides project context (testing standards, fixture conventions, review criteria) to CI-invoked runs
- [ ] Same session that generated code is **less effective** at reviewing it — use independent review instance
- [ ] Include prior review findings in context when re-running → report only new/unaddressed issues
- [ ] Provide existing test files so generation doesn't suggest already-covered scenarios

---

### Domain 4: Prompt Engineering & Structured Output (20%)

**Read:** `guide_en.MD` Chapters 6, 7 → then Part II Domain 4 notes (line 1855)

#### Task 4.1 — Explicit criteria vs vague instructions

- [ ] Specific categorical criteria beat "be conservative" or "only report high-confidence findings"
- [ ] Example good criterion: "flag comments only when claimed behavior contradicts actual code"
- [ ] False positives in one category undermine trust in all categories
- [ ] Fix: define which issue categories to report vs skip; add explicit severity definitions with code examples
- [ ] Temporarily disable high-false-positive categories while improving prompts for them

#### Task 4.2 — Few-shot prompting

- [ ] Most effective technique when detailed instructions produce inconsistent results
- [ ] 2–4 targeted examples for ambiguous scenarios — show reasoning for choice made
- [ ] Examples must demonstrate correct handling of edge cases, not just happy-path
- [ ] Include examples showing specific output format (location, issue, severity, suggested fix)
- [ ] Few-shot for extraction: demonstrate handling of varied document structures (inline citations vs bibliographies)
- [ ] Reduces hallucination: model returns null rather than fabricating missing values

#### Task 4.3 — Structured output via `tool_use`

- [ ] `tool_use` with JSON schema = most reliable method for schema-compliant output (eliminates syntax errors)
- [ ] Syntax errors eliminated by tool_use; **semantic errors are not** (line items don't sum, wrong field)
- [ ] `tool_choice: "any"` → must call a tool (use when multiple schemas exist, doc type unknown)
- [ ] Forced tool: `{"type": "tool", "name": "extract_metadata"}` → use before enrichment
- [ ] Schema: required vs optional; nullable fields prevent fabrication; `enum` + `"other"` + detail string
- [ ] `"unclear"` enum value for genuinely ambiguous cases

#### Task 4.4 — Validation, retry, feedback loops

- [ ] Retry-with-error-feedback: resend original doc + failed extraction + specific validation error
- [ ] Retries work for: format mismatches, structural output errors
- [ ] Retries do NOT work for: information simply absent from source document
- [ ] `detected_pattern` field in findings → enables systematic analysis of false positive dismissals
- [ ] Self-correction: extract `calculated_total` alongside `stated_total` → flag discrepancies
- [ ] `conflict_detected` boolean for inconsistent source data

#### Task 4.5 — Batch processing

- [ ] Message Batches API: 50% cost savings, up to 24-hour processing, no guaranteed latency SLA
- [ ] **Not suitable** for blocking workflows (pre-merge checks where developers wait)
- [ ] **Suitable** for: overnight reports, weekly audits, nightly test generation
- [ ] Batch API does NOT support multi-turn tool calling within a single request
- [ ] `custom_id` for correlating request/response pairs and resubmitting failed items
- [ ] Batch submission frequency: for 30-hr SLA with 24-hr batch window → submit every 4–6 hours
- [ ] Refine prompts on a sample set before batch-processing large volumes

#### Task 4.6 — Multi-instance and multi-pass review

- [ ] Self-review limitation: model retains reasoning context → less likely to question own decisions
- [ ] Independent review instance (no prior context) catches more subtle issues than self-review + extended thinking
- [ ] Multi-pass: per-file local analysis pass + separate cross-file integration pass
- [ ] Consensus requirement (e.g., flag only if 3/3 agree) **suppresses detection** — issues may only be caught intermittently

---

### Domain 5: Context Management & Reliability (15%)

**Read:** `guide_en.MD` Chapters 11, 12 → then Part II Domain 5 notes (line 1952)

#### Task 5.1 — Context preservation

- [ ] Progressive summarization risk: numbers, dates, amounts get condensed to vague text
- [ ] "Lost in the middle" effect: models process start and end reliably; middle sections get omitted
- [ ] Tool results accumulate and consume tokens (e.g., 40+ fields per order lookup, only 5 relevant)
- [ ] Extract transactional facts (amounts, dates, order numbers) into a persistent "case facts" block per prompt
- [ ] Trim verbose tool outputs to relevant fields before they accumulate (use `PostToolUse` hook)
- [ ] Place key findings at **beginning** of aggregated input; organize with explicit section headers

#### Task 5.2 — Escalation and ambiguity resolution

- [ ] Appropriate escalation triggers: customer explicitly requests human; policy exception/gap (not just complexity); unable to make progress
- [ ] Customer explicitly asks for human → escalate immediately, do not attempt to resolve first
- [ ] Sentiment-based escalation and self-reported confidence scores are **unreliable** proxies for complexity
- [ ] Multiple customer matches → ask for additional identifiers, do not heuristically select one
- [ ] Escalate when policy is silent on the specific case (not only when case is complex)

#### Task 5.3 — Error propagation in multi-agent systems

- [ ] Structured error context: failure type, attempted query, partial results, alternative approaches
- [ ] Generic "search unavailable" hides context → coordinator cannot make intelligent recovery decision
- [ ] Anti-patterns: silently return empty as success; terminate entire workflow on single subagent failure
- [ ] Subagents handle transient errors locally; propagate only unresolvable errors with what was attempted
- [ ] Coverage annotations in synthesis output: which topics well-supported vs which have gaps

#### Task 5.4 — Large codebase exploration

- [ ] Context degradation: extended sessions → agent starts citing "typical patterns" vs specific discovered classes
- [ ] Scratchpad files: persist key findings across context boundaries
- [ ] `Explore` subagent for verbose exploration — main agent preserves high-level coordination
- [ ] Crash recovery: each agent exports state to known location → coordinator loads manifest on resume
- [ ] `/compact` to reduce context usage during extended exploration sessions
- [ ] Summarize findings from one phase before spawning subagents for next phase

#### Task 5.5 — Human review workflows and confidence calibration

- [ ] Aggregate accuracy (e.g., 97% overall) can mask poor performance on specific document types/fields
- [ ] Stratified random sampling of high-confidence extractions → ongoing error rate measurement
- [ ] Field-level confidence scores calibrated with labeled validation sets for routing review attention
- [ ] Validate accuracy by document type and field **before** reducing human review
- [ ] Route low-confidence and contradictory-source extractions to human review

#### Task 5.6 — Information provenance

- [ ] Attribution lost during summarization when findings compressed without claim-source mappings
- [ ] Require subagents to output: claim + evidence excerpt + source URL/doc name + publication date
- [ ] Conflicting statistics from credible sources → annotate both with attribution, do NOT arbitrarily select one
- [ ] Temporal data: require publication/collection dates → prevent temporal gaps being misread as contradictions
- [ ] Render by content type: financial data as tables, news as prose, technical findings as structured lists

---

## Phase 3 — Hands-on Projects (Week 3–4, ~10 hrs)

These are the 4 official preparation exercises from the exam guide.

### Exercise 1: Multi-Tool Agent with Escalation Logic

**Domains:** 1, 2, 5

- [ ] Define 3–4 MCP tools with detailed descriptions; include ≥2 similar-purpose tools requiring careful differentiation
- [ ] Implement agentic loop: check `stop_reason`, handle `"tool_use"` and `"end_turn"` correctly
- [ ] Add structured error responses: `errorCategory`, `isRetryable`, human-readable description
- [ ] Test each error type: transient (retry), business (explain), permission (escalate)
- [ ] Implement `PostToolUse` hook that intercepts calls and blocks policy-violating operations
- [ ] Test with multi-concern message → verify agent decomposes, handles each, synthesizes unified response

### Exercise 2: Claude Code Team Development Configuration

**Domains:** 3, 2

- [ ] Create project-level `CLAUDE.md` with universal standards
- [ ] Create `.claude/rules/` files with YAML frontmatter glob patterns for ≥2 code areas
  - `paths: ["src/api/**/*"]` for API conventions
  - `paths: ["**/*.test.*"]` for testing conventions
  - Verify rules load only when editing matching files
- [ ] Create project-scoped skill in `.claude/skills/` with `context: fork` and `allowed-tools`
- [ ] Configure MCP server in `.mcp.json` with `${ENV_VAR}` expansion for credentials
- [ ] Add personal MCP server in `~/.claude.json`; verify both available simultaneously
- [ ] Test plan mode vs direct execution on: single-file bug fix, multi-file migration, new feature with options

### Exercise 3: Structured Data Extraction Pipeline

**Domains:** 4, 5

- [ ] Define extraction tool with JSON schema: required fields, optional/nullable fields, `enum` + `"other"` + detail string
- [ ] Process documents with absent fields → verify model returns `null` not fabricated values
- [ ] Implement validation-retry loop: resend doc + failed extraction + specific error message
- [ ] Distinguish resolvable errors (format mismatch) from unresolvable (info absent from source)
- [ ] Add 3–5 few-shot examples demonstrating extraction from varied document formats
- [ ] Batch: submit 100 documents via Message Batches API, handle failures by `custom_id`, resubmit with modifications
- [ ] Implement confidence scoring + human review routing

### Exercise 4: Multi-Agent Research Pipeline

**Domains:** 1, 2, 5

- [ ] Build coordinator with `allowedTools: ["Task", ...]`; ≥2 subagents (web search + document analysis)
- [ ] Each subagent receives its data **explicitly in prompt** — verify no implicit inheritance
- [ ] Emit multiple Task calls in single coordinator response → measure latency vs sequential
- [ ] Structured subagent output: claim + evidence excerpt + source URL + publication date
- [ ] Simulate subagent timeout → verify coordinator receives: failure type, attempted query, partial results
- [ ] Test coordinator can proceed with partial results and annotate output with coverage gaps
- [ ] Test with conflicting sources → verify synthesis preserves both with attribution, not arbitrarily selects one

---

## Phase 4 — Practice and Assessment (Week 4, ~4 hrs)

- [ ] Open `practical_test_en.html` — take the full 76-question practice test under timed conditions
- [ ] Review every incorrect answer against the relevant guide chapter/task statement
- [ ] Study the 12 annotated sample questions from `exam_guide.pdf` (pages 25–33)
- [ ] Do a second pass on the 2–3 domain areas with lowest practice scores
- [ ] Take the official Skilljar practice exam when access is approved

---

## Official API Docs Reading List

Read these alongside the relevant domain (not all upfront).

| Domain | Docs |
|---|---|
| D1 — Agent loops | `platform.claude.com/docs/en/managed-agents/sessions` |
| D1 — Managed Agents | `platform.claude.com/docs/en/managed-agents/agent-setup` |
| D1 — Hooks | `platform.claude.com/docs/en/agent-sdk/hooks` |
| D2 — Tool use | `platform.claude.com/docs/en/build-with-claude/tool-use` |
| D2 — MCP tools | `modelcontextprotocol.io/docs/concepts/tools` |
| D2 — MCP resources | `modelcontextprotocol.io/docs/concepts/resources` |
| D3 — CLAUDE.md | `code.claude.com/docs/en/memory` |
| D3 — Skills | `code.claude.com/docs/en/skills` |
| D3 — Hooks (Claude Code) | `code.claude.com/docs/en/hooks` |
| D3 — GitHub Actions | `code.claude.com/docs/en/github-actions` |
| D3 — Headless mode | `code.claude.com/docs/en/headless` |
| D4 — Prompt engineering | `platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview` |
| D4 — Message Batches | `platform.claude.com/docs/en/api/creating-message-batches` |
| D5 — Subagents | `code.claude.com/docs/en/sub-agents` |

---

## Exam Scenarios Quick Reference

The exam draws **4 of these 6 scenarios** at random. Prepare for all 6.

| Scenario | Primary Domains |
|---|---|
| 1. Customer Support Resolution Agent | D1, D2, D5 |
| 2. Code Generation with Claude Code | D3, D5 |
| 3. Multi-Agent Research System | D1, D2, D5 |
| 4. Developer Productivity with Claude | D2, D3, D1 |
| 5. Claude Code for Continuous Integration | D3, D4 |
| 6. Structured Data Extraction | D4, D5 |

> **Note:** The community `guide_en.MD` covers 8 scenarios (adds Conversational AI Architecture Patterns and Agentic AI Tools). These may reflect questions from exam candidates on newer versions. The official guide (v0.1, Feb 2025) specifies 6.

---

## Out-of-Scope — Do Not Study

These will NOT appear on the exam:

- Fine-tuning, model training, or model weights
- Claude API authentication mechanics, billing, rate limit calculations
- Deploying or hosting MCP server infrastructure (containers, networking)
- Extended thinking implementation details
- Streaming / server-sent events implementation
- Computer use, browser automation, vision/image analysis
- Constitutional AI, RLHF, safety training
- Vector databases, embedding models
- Specific cloud provider configs (AWS, GCP, Azure)
- Prompt caching implementation (beyond knowing it exists)
- Token counting algorithms or tokenization specifics
- OAuth, API key rotation

---

## Recommended 4-Week Timeline

| Week | Focus | Hours |
|---|---|---|
| 1 | Phase 0 (setup) + Phase 1 (all priority-1 courses) | ~12 |
| 2 | Phase 2: Domains 1 + 2 (theory chapters + domain notes) | ~10 |
| 3 | Phase 2: Domains 3 + 4 + 5 + start Phase 3 exercises | ~12 |
| 4 | Complete exercises + Phase 4 (all practice tests) | ~8 |

**Total: ~42 hours** over 4 weeks (~10 hrs/week).

If you have daily Claude Code experience already (which you do), cut Week 1 by 30% and focus the saved time on Domain 1 (Agent SDK / Managed Agents), which is the least familiar area for most Claude Code users.
