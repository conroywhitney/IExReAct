defmodule IExReAct.LoggerFilter do
  @moduledoc """
  Logger filter that redacts sensitive data like API keys from log messages.

  This filter intercepts log events and redacts patterns that match API keys
  before they reach the console, preventing accidental credential exposure
  in debug output.

  ## Usage

  Add to your config/runtime.exs:

      config :logger,
        filters: [redact_secrets: {IExReAct.LoggerFilter, :filter}]

  Or add at runtime:

      Logger.add_primary_filter(:redact_secrets, {IExReAct.LoggerFilter, :filter})

  """

  @doc """
  Logger filter function that redacts API keys from log messages.

  Returns :stop to drop the message entirely, or the modified event to continue.
  """
  @spec filter(:logger.log_event(), term()) :: :logger.log_event() | :stop
  def filter(%{msg: msg} = event, _extra) do
    redacted_msg = redact_message(msg)
    %{event | msg: redacted_msg}
  end

  def filter(event, _extra), do: event

  # Handle different message formats
  defp redact_message({:string, msg}) when is_binary(msg) do
    {:string, redact_string(msg)}
  end

  defp redact_message({:report, report}) when is_map(report) do
    {:report, redact_map(report)}
  end

  defp redact_message({format, args}) when is_list(args) do
    redacted_args = Enum.map(args, &redact_term/1)
    {format, redacted_args}
  end

  defp redact_message(msg) when is_binary(msg) do
    redact_string(msg)
  end

  defp redact_message(other), do: other

  # Redact sensitive patterns in strings
  defp redact_string(str) when is_binary(str) do
    str
    # Anthropic API keys: sk-ant-api03-...
    |> String.replace(~r/sk-ant-api\d+-[A-Za-z0-9_-]{40,}/, "[REDACTED_ANTHROPIC_KEY]")
    # OpenAI API keys: sk-...
    |> String.replace(~r/sk-[A-Za-z0-9]{32,}/, "[REDACTED_OPENAI_KEY]")
    # Generic API key patterns in inspect output: api_key: "..."
    |> String.replace(~r/api_key:\s*"[^"]+"/i, ~s(api_key: "[REDACTED]"))
    # Struct field format: api_key: "..."
    |> String.replace(~r/:api_key\s*=>\s*"[^"]+"/i, ~s(:api_key => "[REDACTED]"))
  end

  defp redact_string(other), do: other

  # Recursively redact maps
  defp redact_map(map) when is_map(map) do
    Map.new(map, fn
      {key, _value} when key in [:api_key, "api_key", :anthropic_api_key, "anthropic_api_key"] ->
        {key, "[REDACTED]"}

      {key, value} when is_map(value) ->
        {key, redact_map(value)}

      {key, value} when is_binary(value) ->
        {key, redact_string(value)}

      {key, value} ->
        {key, redact_term(value)}
    end)
  end

  # Redact terms (handles inspect output embedded in format args)
  defp redact_term(term) when is_binary(term), do: redact_string(term)
  defp redact_term(term) when is_map(term), do: redact_map(term)
  defp redact_term(term) when is_list(term), do: Enum.map(term, &redact_term/1)
  defp redact_term(term), do: term
end
