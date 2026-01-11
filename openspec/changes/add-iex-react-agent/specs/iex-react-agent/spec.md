# Capability: IEx ReAct Agent

A minimal ReAct agent for IEx demonstrating safe tool use with Jido AI.

## ADDED Requirements

### Requirement: Agent Lifecycle Management

The system SHALL provide functions to start, manage, and reset the ReAct agent within an IEx session.

#### Scenario: Starting the agent

- **GIVEN** an IEx session with the project loaded
- **WHEN** the user calls `IExReAct.start()`
- **THEN** a supervised agent process starts
- **AND** the function returns `{:ok, pid}`

#### Scenario: Starting with custom model

- **GIVEN** an IEx session with the project loaded
- **WHEN** the user calls `IExReAct.start(model: "claude-3-5-sonnet-20241022")`
- **THEN** the agent starts with the specified model
- **AND** the function returns `{:ok, pid}`

#### Scenario: Clearing conversation

- **GIVEN** an agent with existing conversation history
- **WHEN** the user calls `IExReAct.clear()`
- **THEN** the conversation history is reset
- **AND** the agent is ready for new conversations

### Requirement: Conversational Interface

The system SHALL provide a simple interface for sending messages and receiving responses.

#### Scenario: Basic conversation

- **GIVEN** a started agent
- **WHEN** the user calls `IExReAct.chat("Hello, who are you?")`
- **THEN** the agent responds with a friendly message explaining its capabilities
- **AND** the response is printed to stdout
- **AND** the function returns `:ok`

#### Scenario: Viewing conversation history

- **GIVEN** an agent with previous messages
- **WHEN** the user calls `IExReAct.history()`
- **THEN** the full conversation history is returned

### Requirement: Vault-Only File Reading

The system SHALL provide a tool to read files, restricted to the vault directory.

#### Scenario: Reading a file in vault

- **GIVEN** a file exists at `vault/notes/idea.md`
- **WHEN** the agent invokes `read_file` with path `notes/idea.md`
- **THEN** the file contents are returned

#### Scenario: Blocking path traversal

- **GIVEN** an attempt to read `../etc/passwd`
- **WHEN** the agent invokes `read_file` with path `../etc/passwd`
- **THEN** an `ArgumentError` is raised with message containing "Path escape"
- **AND** no file outside vault is accessed

#### Scenario: Blocking absolute paths

- **GIVEN** an attempt to read `/etc/passwd`
- **WHEN** the agent invokes `read_file` with path `/etc/passwd`
- **THEN** an `ArgumentError` is raised with message containing "Path escape"
- **AND** no file outside vault is accessed

### Requirement: Vault-Only File Writing

The system SHALL provide a tool to write files, restricted to the vault directory.

#### Scenario: Writing a file to vault

- **GIVEN** the vault directory exists
- **WHEN** the agent invokes `write_file` with path `notes/new.md` and content `Hello`
- **THEN** the file is created at `vault/notes/new.md`
- **AND** parent directories are created if needed
- **AND** a success message is returned

#### Scenario: Blocking writes outside vault

- **GIVEN** an attempt to write to `../outside.txt`
- **WHEN** the agent invokes `write_file` with path `../outside.txt`
- **THEN** an `ArgumentError` is raised
- **AND** no file outside vault is modified

### Requirement: Vault File Listing

The system SHALL provide a tool to list files within the vault directory.

#### Scenario: Listing all files

- **GIVEN** files exist in the vault
- **WHEN** the agent invokes `list_files` with pattern `**/*`
- **THEN** all regular files in vault are returned as relative paths

#### Scenario: Listing with glob pattern

- **GIVEN** markdown files exist in `vault/notes/`
- **WHEN** the agent invokes `list_files` with pattern `notes/*.md`
- **THEN** only matching files are returned

### Requirement: Allowlisted URL Fetching

The system SHALL provide a tool to fetch URLs, restricted to an allowlist of domains.

#### Scenario: Fetching allowed URL

- **GIVEN** the domain `raw.githubusercontent.com` is allowlisted
- **WHEN** the agent invokes `fetch_url` with URL `https://raw.githubusercontent.com/agentjido/jido_ai/main/README.md`
- **THEN** the content is fetched and returned

#### Scenario: Blocking non-allowlisted domain

- **GIVEN** the domain `evil.com` is not allowlisted
- **WHEN** the agent invokes `fetch_url` with URL `https://evil.com/malware`
- **THEN** an error is returned with message "Domain not allowed"
- **AND** no HTTP request is made to the blocked domain

#### Scenario: Default allowlisted domains

- **GIVEN** the system is configured
- **THEN** the following domains SHALL be allowlisted:
  - `github.com`
  - `raw.githubusercontent.com`
  - `hexdocs.pm`
  - `elixirforum.com`

### Requirement: Security by Omission

The system SHALL NOT provide any dangerous operations, ensuring security through API design rather than containment.

#### Scenario: No shell access

- **GIVEN** the agent receives a request to execute shell commands
- **WHEN** the agent attempts to fulfill the request
- **THEN** no `System.cmd` or equivalent function is available
- **AND** the agent explains it cannot perform that action

#### Scenario: No code execution

- **GIVEN** the agent receives a request to evaluate Elixir code
- **WHEN** the agent attempts to fulfill the request
- **THEN** no `Code.eval_*` or equivalent function is available
- **AND** the agent explains it cannot perform that action

#### Scenario: No arbitrary file access

- **GIVEN** the agent receives a request to access files outside vault
- **WHEN** the agent attempts to use file tools with paths outside vault
- **THEN** the operation is blocked at the tool level
- **AND** the agent explains the limitation
