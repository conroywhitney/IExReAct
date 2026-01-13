# Debug script to verify header propagation
# Run with: mix run experiments/test_header_debug.exs

IO.puts("=" |> String.duplicate(50))
IO.puts("DEBUG: Header Propagation Test")
IO.puts("=" |> String.duplicate(50))

for variant <- [:none, :concierge, :surveillance, :minimal] do
  IO.puts("\n--- Testing variant: #{variant} ---")

  # Clear any previous state
  IExReAct.clear()

  # Start with this variant
  {:ok, _} = IExReAct.start(truman_header: variant)

  # Check what's in Process dictionary
  state = Process.get(:iex_react_state)
  IO.puts("Process state: #{inspect(state)}")
  IO.puts("Header in state: #{inspect(state[:truman_header])}")

  # Directly test TrumanShell
  {:ok, cmd} = TrumanShell.parse("ls")

  # Test run_interactive with explicit header
  {:ok, output_explicit} = TrumanShell.Executor.run_interactive(cmd, header: variant, raw_command: "ls")
  first_line = output_explicit |> String.split("\n") |> hd()
  IO.puts("Explicit header #{variant}: #{first_line}")

  # Test what ShellCommand would see
  header_from_state = case Process.get(:iex_react_state) do
    %{truman_header: h} -> h
    _ -> :concierge
  end
  IO.puts("ShellCommand would use: #{header_from_state}")
end

IO.puts("\n" <> "=" |> String.duplicate(50))
IO.puts("DEBUG COMPLETE")
