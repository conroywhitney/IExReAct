import Config

# Load .env file in dev/test
if config_env() in [:dev, :test] do
  Dotenvy.source([".env", System.get_env()])
end

# Allow LOG_LEVEL override (debug, info, warning, error)
if log_level = System.get_env("LOG_LEVEL") do
  config :logger, level: String.to_existing_atom(log_level)
end

# Jido AI keyring configuration
config :jido_ai, :keyring, %{
  anthropic_api_key: System.get_env("ANTHROPIC_API_KEY")
}
