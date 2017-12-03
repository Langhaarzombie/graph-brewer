defmodule Graph.Mixfile do
  use Mix.Project

  def project do
    [
      app: :graphbrewer,
      version: "0.1.1",
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  def application, do: [extra_applications: []]

  defp deps do
    [{:ex_doc, "~> 0.16", only: :dev}]
  end

  defp description, do: "A (working) graph library for Elixir"
  defp package do
    [file: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["Maximilian Meyer-Mölleringhof"],
     licenses: ["MIT"],
     links: %{GitHub: "https://github.com/Langhaarzombie/graph-brewer"}]
  end

end
