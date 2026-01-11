defmodule IExReAct do
  @moduledoc """
  A minimal ReAct agent for IEx demonstrating safe tool use.
  """

  alias Jido.AI.Agent

  @default_model "claude-opus-4-5-20251101"
  @default_timeout 30_000
  @agent_key :iex_react_agent

  @prompt """
  You are a helpful assistant with access to safe file and URL tools.
  You can read, write, and list files within the vault directory.
  You can fetch content from allowlisted URLs (github.com, hexdocs.pm, etc.).

  <%= @message %>
  """

  def start(opts \\ []) do
    model = Keyword.get(opts, :model, @default_model)

    result =
      Agent.start_link(
        ai: [
          model: {:anthropic, model: model},
          prompt: @prompt,
          tools: IExReAct.Actions.all()
        ]
      )

    case result do
      {:ok, pid} ->
        Process.put(@agent_key, pid)
        {:ok, pid}

      error ->
        error
    end
  end

  def chat(message, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, @default_timeout)

    case Process.get(@agent_key) do
      nil ->
        {:error, :not_started}

      pid ->
        {:ok, signal} = Jido.Signal.new(%{
          type: "jido.ai.tool.response",
          data: %{message: message}
        })

        case Jido.Agent.Server.call(pid, signal, timeout) do
          {:ok, response} ->
            IO.puts(format_response(response))
            :ok

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  def history do
    case Process.get(@agent_key) do
      nil -> {:error, :not_started}
      _pid -> {:ok, []}  # TODO: implement history retrieval
    end
  end

  def clear do
    case Process.get(@agent_key) do
      nil ->
        {:error, :not_started}

      pid ->
        Process.delete(@agent_key)
        Process.exit(pid, :normal)
        :ok
    end
  end

  defp format_response(response) when is_binary(response), do: response
  defp format_response(response), do: inspect(response, pretty: true)
end
