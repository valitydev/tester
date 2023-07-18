defmodule Tester.MixProject do
  use Mix.Project

  def project do
    [
      app: :tester,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      escript: escript(),
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  def application do
    [
      mod: {Tester.Application, []},
      extra_applications: [:logger]
    ]
  end

  def escript do
    [
      main_module: Tester.Cli
    ]
  end

  defp deps do
    [
      {:tesla, "~> 1.4"},
      {:poison, ">= 1.0.0"},
      {:ink, "~> 1.0"},
      {:retry, "~> 0.14"},
      # Tesla.Adapter.Gun dependency
      {:gun, "~> 1.3"},
      # Tesla.Adapter.Gun dependency
      {:idna, "~> 6.0"},
      # Tesla.Adapter.Gun dependency
      {:castore, "~> 0.1"},
      # Only dev
      {:dialyxir, "~> 1.0.0", only: [:dev], runtime: false}
    ]
  end

  defp dialyzer do
    [flags: ["-Wunmatched_returns", :error_handling, :race_conditions, :unknown]]
  end
end
