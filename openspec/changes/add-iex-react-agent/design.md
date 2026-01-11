# Design: IExReAct Agent Architecture

## Context

We're building a minimal ReAct agent that runs in IEx to demonstrate Jido AI's capabilities. The key insight is that the BEAM's process model provides natural isolation — we don't need Docker, FUSE, or fanotify for security. Instead, we achieve security by omission: dangerous operations simply don't exist in the API.

**Stakeholders**:
- Developers exploring Jido AI
- Knowledge workers who want AI assistance without code execution risks
- Teams evaluating AI agent security models

**Constraints**:
- Must be ~100 lines total (excluding tests)
- Must use Jido AI framework
- Must demonstrate ReAct loop with tool use
- Must be secure without external sandboxing

## Goals / Non-Goals

### Goals
- Demonstrate Jido AI's agent and skill system
- Provide a working example for the "4 Cs" of knowledge work
- Prove that bounded tools eliminate the need for elaborate containment
- Create a foundation for future tool expansion

### Non-Goals
- General-purpose coding assistant (intentionally limited)
- Shell command execution (explicitly excluded)
- Arbitrary file system access (vault-only by design)
- Code evaluation capabilities (no `Code.eval_*`)
- Network servers or sockets (no attack surface)

## Decisions

### Decision 1: IEx as Primary Interface

**What**: Users interact via standard IEx session, not a custom CLI.

**Why**:
- Zero additional tooling required
- Familiar to Elixir developers
- Leverages IEx's existing features (history, completion)
- Demonstrates seamless BEAM integration

**Alternatives considered**:
- Custom CLI (escript): More distribution complexity, less Elixir-native feel
- Phoenix LiveView: Overkill for a demo, adds web dependency
- Mix task: Less interactive, harder to maintain conversation state

### Decision 2: Vault-Only File Access

**What**: All file operations restricted to `./vault/` directory.

**Why**:
- Simple mental model: "vault is the sandbox"
- Easy to audit: grep for `@vault_path` shows all access points
- Path traversal protection via `safe_path!/1` validation
- No need for OS-level sandboxing

**Implementation**:
```elixir
defp safe_path!(relative_path) do
  full_path = relative_path
    |> Path.expand(@vault_path)
    |> Path.expand()

  unless String.starts_with?(full_path, @vault_path) do
    raise ArgumentError, "Path escape attempt: #{relative_path}"
  end

  full_path
end
```

### Decision 3: Domain Allowlist for URL Fetching

**What**: `fetch_url/1` only permits specific domains.

**Why**:
- Prevents SSRF attacks
- No need for URL parsing complexity
- Easy to extend for specific use cases
- Fails closed (unknown domain = blocked)

**Allowed domains**:
- `github.com` — Jido AI repos, examples
- `raw.githubusercontent.com` — Raw file access
- `hexdocs.pm` — Elixir documentation
- `elixirforum.com` — Community knowledge

### Decision 4: Jido.AI.Agent for State Management

**What**: Use Jido's built-in Agent GenServer for conversation state.

**Why**:
- Handles message history automatically
- Manages tool invocation lifecycle
- Provides `reset/1` for conversation clearing
- Integrates with Jido.Skill for tool definitions

**Alternative considered**:
- Custom GenServer: More boilerplate, reinvents wheel
- Agent-less (stateless): Loses conversation context

### Decision 5: :httpc for HTTP (No Extra Dependencies)

**What**: Use Erlang's built-in `:httpc` module for URL fetching.

**Why**:
- Zero additional dependencies
- Sufficient for simple GET requests
- Already part of OTP (`:inets` application)
- Keeps the project minimal

**Alternative considered**:
- Req/Finch: Better ergonomics but adds dependencies
- HTTPoison: Popular but unnecessary for this scope

## Component Architecture

```
┌─────────────────────────────────────────────────────┐
│                    IEx Session                       │
├─────────────────────────────────────────────────────┤
│  IExReAct.start()     → Starts supervised agent     │
│  IExReAct.chat(msg)   → Send message, get response  │
│  IExReAct.history()   → View conversation history   │
│  IExReAct.clear()     → Reset conversation          │
└─────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────┐
│              Jido.AI.Agent (GenServer)              │
├─────────────────────────────────────────────────────┤
│  - Model: {:anthropic, "claude-3-haiku-20240307"}   │
│  - Prompt: System prompt with persona + tools       │
│  - Skills: [IExReAct.SafeToolsSkill]               │
└─────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────┐
│           IExReAct.SafeToolsSkill                   │
├─────────────────────────────────────────────────────┤
│  read_file(path)    → Only vault/** paths          │
│  write_file(path, content) → Only vault/** paths   │
│  fetch_url(url)     → Only allowlisted domains     │
│  list_files(glob)   → Only vault/** patterns       │
└─────────────────────────────────────────────────────┘
```

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Path traversal bypasses `safe_path!/1` | Comprehensive tests for edge cases (`..`, symlinks, encoded paths) |
| Jido AI API changes break implementation | Pin to specific versions in mix.exs |
| User expects more capabilities | Clear documentation of intentional limitations |
| Anthropic API key exposure | Use environment variables via Jido.AI.Keyring |

## Migration Plan

Not applicable — this is a greenfield implementation with no existing code to migrate.

## Open Questions

1. **Model selection**: Should we support model switching at runtime, or is Haiku-only sufficient for MVP?
   - Current decision: Accept model as option to `start/1`, default to Haiku

2. **Vault location**: Should vault be configurable, or always `./vault`?
   - Current decision: Hardcoded for simplicity, can add config later

3. **Rate limiting**: Should we add any protection against API abuse?
   - Current decision: Out of scope for MVP (user's API key, their problem)
