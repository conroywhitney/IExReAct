# Change: Add IExReAct Agent

## Why

Current AI coding tools (Claude Code, Cursor, etc.) are optimized for the ~1% of knowledge work that is coding. The other 99% — collecting thoughts, connecting ideas, creating artifacts, closing loops (the "4 Cs") — doesn't need bash, arbitrary file access, or code execution.

This change introduces a minimal IEx-based ReAct agent that demonstrates:
1. Jido AI's agent capabilities in a real-world scenario
2. The "BEAM is the Sandbox" philosophy — security by omission, not containment
3. A bounded tool approach where dangerous operations simply don't exist

## What Changes

- Add `IExReAct` main module (~50 lines) providing `start/1`, `chat/1`, `history/0`, `clear/0`
- Add `IExReAct.SafeToolsSkill` (~50 lines) with bounded tools:
  - `read_file/1` — reads only from `vault/`
  - `write_file/2` — writes only to `vault/`
  - `list_files/1` — lists only `vault/` contents
  - `fetch_url/1` — fetches only from allowlisted domains
- Add Mix project structure with Jido/Jido AI dependencies
- Add `vault/` directory as the safe write zone
- Add comprehensive tests for security boundaries

## Impact

- **New capability**: `iex-react-agent` — first spec in this project
- **Affected code**: Creates new project structure from scratch
- **Dependencies**: `jido ~> 1.2.0`, `jido_ai ~> 0.5.2`
- **Security model**: No external sandboxing required (no Docker, FUSE, fanotify)

## Success Criteria

1. Basic conversation works in IEx
2. Agent can read/write files within `vault/` only
3. Path traversal attacks are blocked
4. Non-allowlisted URLs are rejected
5. Total implementation is ~100 lines (excluding tests)
6. `mix test` passes all security boundary tests
