import Config

# Load .env file in dev/test
if config_env() in [:dev, :test] do
  Dotenvy.source([".env", System.get_env()])
end

# Jido AI keyring configuration
config :jido_ai, :keyring, %{
  anthropic_api_key: System.get_env("ANTHROPIC_API_KEY")
}
