defmodule IExReAct do
  @moduledoc """
  A minimal ReAct agent for IEx demonstrating safe tool use.

  ## Options

    * `:model` - Model to use (default: "claude-opus-4-5-20251101")
    * `:truman_header` - Truman Shell header variant:
      * `:concierge` - Friendly "bash concierge" framing (default)
      * `:surveillance` - Original "sandboxed environment" framing
      * `:minimal` - Just the :: commands
      * `:none` - No header
    * `:reasoning_effort` - Extended thinking level:
      * `:low` - 1,024 tokens
      * `:medium` - 2,048 tokens
      * `:high` - 4,096 tokens

  ## Example

      iex> IExReAct.start(truman_header: :surveillance, reasoning_effort: :medium)
      {:ok, #PID<...>}

  """

  alias Jido.AI.Model
  alias Jido.AI.Prompt

  @default_model "claude-opus-4-5-20251101"
  @default_timeout 120_000  # Extended for thinking models

  @base_prompt """
  You are a helpful assistant with access to safe file, URL, and shell tools.
  You can read, write, and list files within the vault directory.
  You can fetch content from allowlisted URLs (github.com, hexdocs.pm, etc.).
  You can execute shell commands (ls, cat, grep, etc.) in a sandboxed environment.
  """

  def start(opts \\ []) do
    model_name = Keyword.get(opts, :model, @default_model)
    truman_header = Keyword.get(opts, :truman_header, :concierge)
    reasoning_effort = Keyword.get(opts, :reasoning_effort)

    case Model.from({:anthropic, model: model_name}) do
      {:ok, model} ->
        state = %{
          model: model,
          tools: [IExReAct.Actions.ShellCommand],
          history: [],
          truman_header: truman_header,
          reasoning_effort: reasoning_effort
        }

        # Store in Process dict (for local access)
        Process.put(:iex_react_state, state)

        # Also store truman_header in Application env (for cross-process access)
        # Jido spawns tool calls in separate processes, so Process dict won't work
        Application.put_env(:iex_react, :truman_header, truman_header)

        if reasoning_effort do
          IO.puts("🧠 Extended thinking enabled: #{reasoning_effort}")
        end

        {:ok, self()}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def chat(message, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, @default_timeout)

    case Process.get(:iex_react_state) do
      nil ->
        {:error, :not_started}

      state ->
        prompt =
          Prompt.new(:user, @base_prompt <> "\n\n" <> message)

        params =
          %{
            model: state.model,
            prompt: prompt,
            tools: state.tools,
            verbose: Keyword.get(opts, :verbose, false)
          }
          |> maybe_put(:reasoning_effort, state.reasoning_effort)

        # Context carries truman_header to ShellCommand action
        context = %{truman_header: state.truman_header}

        # Call the ReqLLM-based action with our timeout
        case Jido.Exec.run(
               Jido.AI.Actions.ReqLlm.ToolResponse,
               params,
               context,
               timeout: timeout
             ) do
          {:ok, %{result: result}} ->
            IO.puts(format_response(result))
            :ok

          {:ok, result} ->
            IO.puts(format_response(result))
            :ok

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  def history do
    case Process.get(:iex_react_state) do
      nil -> {:error, :not_started}
      state -> {:ok, state.history}
    end
  end

  def clear do
    case Process.get(:iex_react_state) do
      nil ->
        {:error, :not_started}

      _state ->
        Process.delete(:iex_react_state)
        :ok
    end
  end

  defp format_response(response) when is_binary(response), do: response
  defp format_response(response), do: inspect(response, pretty: true)
end
