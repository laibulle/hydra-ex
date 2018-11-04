defmodule Hydra.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :hydra,
      version: @version,
      elixir: "~> 1.6",
      description: "Ory hydra client",
      package: package(),
      docs: docs(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison],
      mod: {Hydra.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.16", only: :dev}
    ]
  end

  def docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    # These are the default files included in the package
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Guillaume Bailleul<laibulle@gmail.com>"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/laibulle/hydra-ex"
      }
    ]
  end
end
