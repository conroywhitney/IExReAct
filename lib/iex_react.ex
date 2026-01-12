defmodule IExReAct do
  @moduledoc """
  A minimal ReAct agent for IEx demonstrating safe tool use.
  """

  alias Jido.AI.Model
  alias Jido.AI.Prompt

  @default_model "claude-opus-4-5-20251101"
  @default_timeout 30_000

  @base_prompt """
  You are a helpful assistant with access to safe file and URL tools.
  You can read, write, and list files within the vault directory.
  You can fetch content from allowlisted URLs (github.com, hexdocs.pm, etc.).
  """

  def start(opts \\ []) do
    model_name = Keyword.get(opts, :model, @default_model)

    case Model.from({:anthropic, model: model_name}) do
      {:ok, model} ->
        state = %{
          model: model,
          tools: IExReAct.Actions.all(),
          history: []
        }

        Process.put(:iex_react_state, state)
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

        params = %{
          model: state.model,
          prompt: prompt,
          tools: state.tools,
          verbose: Keyword.get(opts, :verbose, false)
        }

        # Call the action directly with our timeout
        case Jido.Exec.run(
               Jido.AI.Actions.Langchain.ToolResponse,
               params,
               %{},
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
