defmodule IExReAct.Application do
  @moduledoc """
  Application callback module for IExReAct.

  Registers the Logger filter on startup to redact API keys from debug output.
  """

  use Application
  require Logger

  @impl true
  def start(_type, _args) do
    # Register the API key redaction filter before any other work
    # Uses Erlang's :logger directly as Elixir Logger doesn't expose this API yet
    :logger.add_primary_filter(:redact_secrets, {&IExReAct.LoggerFilter.filter/2, []})
    Logger.debug("[IExReAct] Logger filter registered for API key redaction")

    children = []

    opts = [strategy: :one_for_one, name: IExReAct.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
