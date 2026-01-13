# Quick single variant test with debug output
# Run with: export $(grep -v '^#' .env | xargs) && mix run experiments/test_single_variant.exs

model = System.get_env("MODEL") || "claude-sonnet-4-20250514"
variant = :surveillance

IO.puts("Testing with variant: #{variant}")
IO.puts("Main process: #{inspect(self())}")

IExReAct.clear()
{:ok, _} = IExReAct.start(model: model, truman_header: variant)

state = Process.get(:iex_react_state)
IO.puts("Main process state header: #{inspect(state[:truman_header])}")

IO.puts("\n--- Calling chat ---")
IExReAct.chat("Run the command: ls", timeout: 60_000)
