defmodule Graph.Testsetup do
  def getGraph do
    graph = Graph.new

    graph = Graph.add_edge(graph, :dp1, :dp2, 3)
    graph = Graph.add_edge(graph, :dp1, :dp5, 7)

    graph = Graph.add_edge(graph, :dp2, :dp3, 6)
    graph = Graph.add_edge(graph, :dp2, :shop, 5)

    graph = Graph.add_edge(graph, :dp3, :dp5, 3)
    graph = Graph.add_edge(graph, :dp3, :dp4, 5)
    graph = Graph.add_edge(graph, :dp3, :dp6, 7)

    graph = Graph.add_edge(graph, :dp4, :dp5, 4)
    graph = Graph.add_edge(graph, :dp4, :dp6, 5)

    graph = Graph.add_edge(graph, :dp5, :dp6, 6)

    graph = Graph.add_edge(graph, :dp6, :dp7, 5)

    graph = Graph.add_edge(graph, :dp7, :cust, 2)
    graph = Graph.add_edge(graph, :dp7, :dp8, 4)

    graph = Graph.add_edge(graph, :dp8, :dp9, 2)

    graph = Graph.add_edge(graph, :dp9, :dp10, 6)

    graph = Graph.add_edge(graph, :dp10, :shop, 7)

    graph
  end
end
