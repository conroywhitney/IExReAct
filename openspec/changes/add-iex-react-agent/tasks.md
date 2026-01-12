# Tasks: Add IExReAct Agent

## 1. Project Setup

- [ ] 1.1 Initialize Mix project with `mix new iex_react`
- [ ] 1.2 Configure `mix.exs` with dependencies (`jido ~> 1.2.0`, `jido_ai ~> 0.5.2`)
- [ ] 1.3 Create `config/config.exs` with Jido AI keyring configuration
- [ ] 1.4 Create `.env.example` with `ANTHROPIC_API_KEY=your-key-here`
- [ ] 1.5 Add `dotenvy` dependency for .env file loading
- [ ] 1.6 Create `vault/` directory with `.gitkeep`
- [ ] 1.7 Update `.gitignore` to exclude `.env` and `vault/*` contents

## 2. Core Implementation

- [ ] 2.1 Create `lib/iex_react.ex` main module
  - `start/1` — Start supervised agent with optional model config
  - `chat/1` — Send message and print response
  - `history/0` — Get conversation history
  - `clear/0` — Reset conversation state
  - `vault_path/0` — Return vault path for tool use
  - `system_prompt/0` — Define agent persona and capabilities

- [ ] 2.2 Create `lib/iex_react/safe_tools_skill.ex`
  - `tools/0` — Define tool schemas for LLM
  - `read_file/1` — Read from vault only
  - `write_file/2` — Write to vault only
  - `list_files/1` — List vault contents
  - `fetch_url/1` — Fetch from allowlisted domains
  - `safe_path!/1` — Path validation helper

## 3. Security Boundary Tests

- [ ] 3.1 Test `safe_path!/1` blocks `../` traversal
- [ ] 3.2 Test `safe_path!/1` blocks absolute paths outside vault
- [ ] 3.3 Test `safe_path!/1` handles edge cases (empty, `.`, `//`)
- [ ] 3.4 Test `fetch_url/1` blocks non-allowlisted domains
- [ ] 3.5 Test `fetch_url/1` allows allowlisted domains
- [ ] 3.6 Test `write_file/2` creates files in vault
- [ ] 3.7 Test `write_file/2` blocks writes outside vault

## 4. Integration Tests

- [ ] 4.1 Test agent starts successfully
- [ ] 4.2 Test basic conversation flow
- [ ] 4.3 Test tool invocation via chat (e.g., "list my files")
- [ ] 4.4 Test agent refuses dangerous operations gracefully

## 5. Documentation

- [ ] 5.1 Add `@moduledoc` to `IExReAct`
- [ ] 5.2 Add `@moduledoc` to `IExReAct.SafeToolsSkill`
- [ ] 5.3 Add `@doc` to all public functions
- [ ] 5.4 Update project README with usage examples

## 6. Validation

- [ ] 6.1 Run `mix test` — all tests pass
- [ ] 6.2 Run `mix format` — code is formatted
- [ ] 6.3 Run `mix credo` — no warnings (if available)
- [ ] 6.4 Manual IEx testing of happy path scenarios
- [ ] 6.5 Verify implementation is ~100 lines (excluding tests)

## Dependencies

- Task 2.x depends on 1.x (project must be set up first)
- Task 3.x depends on 2.2 (need SafeToolsSkill implemented)
- Task 4.x depends on 2.1 and 2.2 (need both modules)
- Task 5.x can run in parallel with 3.x and 4.x
- Task 6.x depends on all other tasks

## Parallelization

Tasks 3.1-3.7 can run in parallel after 2.2 is complete.
Tasks 5.1-5.4 can run in parallel with testing tasks.
