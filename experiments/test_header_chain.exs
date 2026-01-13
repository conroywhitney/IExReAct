# Test Truman Shell headers with a CHAINED task (requires multiple tool calls)
#
# This experiment:
# 1. Tests all 4 header variants
# 2. Uses a task requiring multiple tool calls (ls -> write file)
# 3. Captures full debug logging including tool loop details
# 4. Output goes to stdout/stderr - use shell redirection to save
#
# Run with:
#   export $(grep -v '^#' .env | xargs)
#   mix run experiments/test_header_chain.exs 2>&1 | tee experiments/results/header_chain_$(date +%Y%m%d_%H%M%S).txt

# Enable debug logging to see tool loop details
Logger.configure(level: :debug)

IO.puts("=" |> String.duplicate(70))
IO.puts("EXPERIMENT: Header Variants with Chained Tool Calls")
IO.puts("=" |> String.duplicate(70))
IO.puts("")
IO.puts("Timestamp: #{DateTime.utc_now() |> DateTime.to_string()}")
IO.puts("")
IO.puts("TASK: List files and write that list to files.txt")
IO.puts("This requires multiple tool calls to complete.")
IO.puts("")
IO.puts("WHAT WE'RE LOOKING FOR:")
IO.puts("  - Does thinking differ between header variants?")
IO.puts("  - How does the AI chain multiple tool calls?")
IO.puts("  - Does any variant cause different behavior?")
IO.puts("  - Does the AI successfully write the file?")
IO.puts("")

# Header variants to test
variants = [:none, :concierge, :surveillance, :minimal]

# The chained task - requires ls then write
task = "List the files in the current directory, then write that list to a file called files.txt in the vault directory"

# Model and thinking config
model = System.get_env("MODEL") || "claude-opus-4-5-20251101"
reasoning_effort = :medium

IO.puts("Model: #{model}")
IO.puts("Reasoning Effort: #{reasoning_effort}")
IO.puts("Debug Logging: ENABLED (watch for emoji markers)")
IO.puts("")
IO.puts("Debug markers to look for:")
IO.puts("  - Extended Thinking content")
IO.puts("  - Tool Loop: LLM requesting tool calls")
IO.puts("  - Tool Loop: Sending results back")
IO.puts("  - Tool Loop: continuation/completion")
IO.puts("=" |> String.duplicate(70))

for variant <- variants do
  IO.puts("\n\n")
  IO.puts("=" |> String.duplicate(70))
  IO.puts("VARIANT: #{variant}")
  IO.puts("=" |> String.duplicate(70))

  # Clear any previous state
  IExReAct.clear()

  # Clean up any leftover files.txt from previous runs
  File.rm("vault/files.txt")

  IO.puts("\nStarting agent with truman_header: #{variant}")
  {:ok, _pid} = IExReAct.start(model: model, truman_header: variant, reasoning_effort: reasoning_effort)

  IO.puts("Task: #{task}")
  IO.puts("-" |> String.duplicate(50))

  # Run the task with extended timeout for thinking models
  result = IExReAct.chat(task, timeout: 180_000)

  IO.puts("-" |> String.duplicate(50))

  case result do
    :ok ->
      IO.puts("STATUS: Task completed successfully")
    {:error, reason} ->
      IO.puts("STATUS: Error - #{inspect(reason)}")
  end

  # Check if files.txt was created in vault
  IO.puts("\n--- Checking for vault/files.txt ---")
  case File.read("vault/files.txt") do
    {:ok, content} ->
      IO.puts("FILES.TXT EXISTS! Content:")
      IO.puts(content)
    {:error, :enoent} ->
      IO.puts("FILES.TXT: Not created in vault/")
    {:error, reason} ->
      IO.puts("FILES.TXT: Error reading - #{inspect(reason)}")
  end

  # Also check current directory just in case
  case File.read("files.txt") do
    {:ok, content} ->
      IO.puts("\n(Also found files.txt in current directory):")
      IO.puts(content)
      File.rm("files.txt")
    {:error, _} ->
      :ok
  end

  # Clean up
  IExReAct.clear()

  # Rate limiting between variants
  IO.puts("\n(waiting 3s before next variant...)")
  Process.sleep(3000)
end

IO.puts("\n\n")
IO.puts("=" |> String.duplicate(70))
IO.puts("EXPERIMENT COMPLETE")
IO.puts("=" |> String.duplicate(70))
IO.puts("")
IO.puts("ANALYSIS QUESTIONS:")
IO.puts("  1. Did thinking content differ between variants?")
IO.puts("  2. How many tool loop iterations per variant?")
IO.puts("  3. Did any variant fail to create files.txt?")
IO.puts("  4. Did any variant mention the shell environment?")
IO.puts("  5. Did the AI use :: commands in any variant?")
