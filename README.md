# IExReAct

A minimal ReAct (Reason/Act) AI agent for Interactive Elixir, demonstrating safe tool use with [Jido AI](https://github.com/agentjido/jido_ai).

## What is this?

IExReAct gives you a conversational AI agent in your IEx session that can:
- Execute shell commands via **TrumanShell** (sandboxed simulation)
- Read/write/list files (safely confined to `vault/` directory)
- Fetch URLs (restricted to allowlisted domains)

It demonstrates "security by omission" - the agent operates in a controlled environment where dangerous operations are either sandboxed or simply don't exist.

## Setup

```bash
# 1. Install dependencies
mix deps.get

# 2. Configure your API key
cp .env.example .env
# Edit .env and add your ANTHROPIC_API_KEY

# 3. Run tests (optional but satisfying)
mix test
```

## Usage

```elixir
# Start IEx with the project
iex -S mix

# Start the agent
IExReAct.start()
# => {:ok, #PID<0.xxx.0>}

# Chat with it
IExReAct.chat("What files are in the vault?")
# Agent uses list_files tool, responds with results

IExReAct.chat("Create a file called notes/ideas.md with some project ideas")
# Agent uses write_file tool

IExReAct.chat("Read notes/ideas.md")
# Agent uses read_file tool

# Use a different model
IExReAct.start(model: "claude-sonnet-4-20250514")

# Clear conversation and stop agent
IExReAct.clear()
```

## Available Tools

| Tool | Description |
|------|-------------|
| `shell` | Execute shell commands via TrumanShell sandbox |
| `read_file` | Read files from `vault/` directory |
| `write_file` | Write files to `vault/` directory (creates parent dirs) |
| `list_files` | List files matching glob pattern in `vault/` |
| `fetch_url` | Fetch content from allowlisted domains |

### Allowlisted Domains

- `github.com`
- `raw.githubusercontent.com`
- `hexdocs.pm`
- `elixirforum.com`

## Security Model

**"BEAM is the Sandbox"** - Security through API design, not containment:

- No `System.cmd` or shell access
- No `Code.eval_*` or dynamic code execution
- File operations confined to `vault/` directory
- Path traversal (`../`) and absolute paths blocked
- URL fetching restricted to allowlist

The agent literally cannot do dangerous things because those functions don't exist in its toolset.

## Project Structure

```
lib/
  iex_react.ex              # Main module (start, chat, clear, history)
  iex_react/
    safe_tools_skill.ex     # Core safety functions (safe_path!, etc.)
    actions.ex              # Jido.Action wrappers for tools
vault/                      # Safe zone for agent file operations
```

## Troubleshooting

### Jaxon NIF Warning

If you see repeated warnings like:
```
[warning] The on_load function for module Elixir.Jaxon.Parsers.NifParser returned: {:error, {:load_failed, ...}}
```

This happens when the precompiled NIF binary doesn't match your architecture. Fix it by recompiling:

```bash
# Clean and recompile Jaxon
rm -rf deps/jaxon/_build deps/jaxon/priv/*.so _build/dev/lib/jaxon
mix deps.compile jaxon --force
```

This recompiles the native JSON parser for your system. The warning is harmless (Jaxon falls back to pure Elixir), but noisy.

## License

MIT
