defmodule ReviewScraper.MixProject do
  use Mix.Project

  def project do
    [
      app: :review_scraper,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [
        "test.watch": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Test helper
      {:mix_test_watch, "~> 1.1", only: [:dev, :test], runtime: false},

      # HTTP
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.18"},

      # HTML Parser
      {:floki, "~> 0.32.0"},

      # JSON encoder/decoder
      {:jason, "~> 1.2"}
    ]
  end
end
