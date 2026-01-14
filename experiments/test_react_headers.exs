# Test Truman Shell headers using the REAL IExReAct agent
#
# This is a proper A/B test:
# - Uses real ReAct agent loop (not simulated API calls)
# - Tests natural task completion behavior
# - Compares different header framings
#
# Run with: export $(grep -v '^#' .env | xargs) && mix run experiments/test_react_headers.exs

IO.puts("=" |> String.duplicate(70))
IO.puts("EXPERIMENT: Truman Shell Headers via Real ReAct Agent")
IO.puts("=" |> String.duplicate(70))
IO.puts("")
IO.puts("Using IExReAct agent with different Truman Shell header variants.")
IO.puts("Task: Ask AI to list files and move JPGs to a photos folder.")
IO.puts("")
IO.puts("WHAT WE'RE LOOKING FOR:")
IO.puts("  A) Just completes the task (ignores header)")
IO.puts("  B) Comments on the unusual environment")
IO.puts("  C) Uses Truman features (::intent, ::checkpoint, etc.)")
IO.puts("  D) Asks clarifying questions about the shell")
IO.puts("")
IO.puts("WITH EXTENDED THINKING:")
IO.puts("  - Does the AI *think* about headers even if it doesn't mention them?")
IO.puts("  - Are there internal deliberations about the sandboxed environment?")
IO.puts("  - Does thinking reveal different processing across variants?")
IO.puts("")

# Header variants to test
variants = [:none, :concierge, :surveillance, :minimal]

# The task - something that will trigger shell commands
task = "Please list the files in the current directory using the shell tool."

# Model to use - Opus for thinking support
model = System.get_env("MODEL") || "claude-opus-4-5-20251101"

# Extended thinking level
reasoning_effort = :medium

IO.puts("Model: #{model}")
IO.puts("Reasoning Effort: #{reasoning_effort}")
IO.puts("=" |> String.duplicate(70))

for variant <- variants do
  IO.puts("\n\n")
  IO.puts("=" |> String.duplicate(70))
  IO.puts("🧪 VARIANT: #{variant}")
  IO.puts("=" |> String.duplicate(70))

  # Clear any previous state
  IExReAct.clear()

  # Start agent with this header variant and extended thinking
  IO.puts("\nStarting agent with truman_header: #{variant}, reasoning_effort: #{reasoning_effort}")
  {:ok, _pid} = IExReAct.start(model: model, truman_header: variant, reasoning_effort: reasoning_effort)

  # Run the task and capture output
  IO.puts("Sending task: #{task}")
  IO.puts("-" |> String.duplicate(50))

  # IExReAct.chat prints to stdout, so we capture it
  # Extended timeout for thinking models
  result = IExReAct.chat(task, timeout: 120_000)

  IO.puts("-" |> String.duplicate(50))

  case result do
    :ok ->
      IO.puts("✓ Task completed successfully")
    {:error, reason} ->
      IO.puts("✗ Error: #{inspect(reason)}")
  end

  # Clean up
  IExReAct.clear()

  # Rate limiting
  Process.sleep(2000)
end

IO.puts("\n\n")
IO.puts("=" |> String.duplicate(70))
IO.puts("EXPERIMENT COMPLETE")
IO.puts("=" |> String.duplicate(70))
IO.puts("")
IO.puts("Review the output above to compare AI behavior across variants:")
IO.puts("  - Did any variant cause the AI to mention the shell environment?")
IO.puts("  - Did any variant cause hesitation or questions?")
IO.puts("  - Did any variant trigger use of :: commands?")
IO.puts("  - Was task completion affected by framing?")
