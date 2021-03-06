defmodule Graph.Mixfile do
  use Mix.Project

  def project do
    [
      app: :graphbrewer,
      version: "0.1.8",
      elixir: "~> 1.6.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  def application, do: [extra_applications: []]

  defp deps do
    [{:ex_doc, "~> 0.18.3", only: :dev}]
  end

  defp description, do: "A (working) graph library for Elixir"
  defp package do
    [file: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Langhaarzombie"],
     licenses: ["MIT"],
     links: %{GitHub: "https://github.com/Langhaarzombie/graph-brewer"}]
  end

end
