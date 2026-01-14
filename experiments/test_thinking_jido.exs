# Test if extended thinking works through Jido with LangChain 0.4.1
# Run with: export $(grep -v '^#' .env | xargs) && mix run experiments/test_thinking_jido.exs

IO.puts("Testing extended thinking through Jido/LangChain 0.4.1...")

# Check if LangChain supports thinking
IO.puts("LangChain version: #{Application.spec(:langchain, :vsn)}")

# Start IExReAct with surveillance header
IExReAct.clear()
{:ok, _} = IExReAct.start(model: "claude-sonnet-4-20250514", truman_header: :surveillance)

IO.puts("\nSending task with surveillance header...")
IO.puts("=" |> String.duplicate(50))

# This should trigger shell tool and we want to see if thinking is captured
result = IExReAct.chat("Run: ls", timeout: 60_000)

IO.puts("=" |> String.duplicate(50))
IO.puts("Result: #{inspect(result)}")
