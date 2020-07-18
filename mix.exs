defmodule Calixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :calixir,
      version: "0.1.0",
      elixir: "~> 1.9",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Calixir",
      source_url: "https://github.com/rengel-de/calixir"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp description() do
    """
    Calixir is a port of the Lisp calendar software calendrica-4.0.cl
    by Nachum Dershowitz and Edward M. Reingold to Elixir.
    """
  end

  defp package() do
    [
      name: "calixir",
      # These are the default files included in the package
      files: ~w(.formatter.exs mix.exs README.md COPYRIGHT*
                 .gitignore assets lib test),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/rengel-de/calixir"}
    ]
  end

end
