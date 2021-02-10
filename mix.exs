defmodule Samly.Mixfile do
  use Mix.Project

  @version "1.2.0"
  @description "SAML SP SSO made easy - Decisiv fork"
  @source_url "https://github.com/Decisiv/samly"

  def project() do
    [
      app: :samly,
      version: @version,
      description: @description,
      docs: docs(),
      package: package(),
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application() do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps() do
    [
      {:plug, "~> 1.6"},
      {:esaml, "~> 4.2"},
      {:sweet_xml, "~> 0.6.6"},
      {:ex_doc, "~> 0.19.0", only: :dev, runtime: false},
      {:inch_ex, "~> 1.0", only: [:dev, :test]},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp docs() do
    [
      extras: ["README.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp package() do
    [
      maintainers: ["handnot2"],
      files: ["config", "lib", "LICENSE", "mix.exs", "README.md"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
