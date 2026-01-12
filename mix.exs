defmodule IExReAct.MixProject do
  use Mix.Project

  def project do
    [
      app: :iex_react,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {IExReAct.Application, []},
      extra_applications: [:logger, :inets, :ssl]
    ]
  end

  defp deps do
    [
      {:jido_ai, "~> 0.5.2"},
      {:truman_shell, path: "../truman-shell"}
    ]
  end
end
