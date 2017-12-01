defmodule Graph.Testsetup do
  def getSmallGraph do
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

  def getGraph do
    # Costs are measured in 10m -> 250m == costs 25
    state = Graph.new
            |> Graph.add_node(:dp0, %{costs: 0, label: "Spengergasse"})
            |> Graph.add_node(:dp1, %{costs: 0, label: "Hofburg"})
            |> Graph.add_node(:dp2, %{costs: 0, label: "Stephansplatz"})
            |> Graph.add_node(:dp3, %{costs: 0, label: "Flex Cafe"})
            |> Graph.add_node(:dp4, %{costs: 0, label: "Hard Rock Cafe"})
            |> Graph.add_node(:dp5, %{costs: 0, label: "MAK"})
            |> Graph.add_node(:dp6, %{costs: 0, label: "Karlsplatz"})
            |> Graph.add_node(:dp7, %{costs: 0, label: "Cineplex Apollo Kino"})
            |> Graph.add_node(:dp8, %{costs: 0, label: "Krankenhaus"})
            |> Graph.add_node(:dp9, %{costs: 0, label: "Westbahnhof"})
            |> Graph.add_node(:dp10, %{costs: 0, label: "Stadthalle"})
            |> Graph.add_node(:dp11, %{costs: 0, label: "Rathaus"})
            |> Graph.add_node(:dp12, %{costs: 0, label: "Votivkirche"})
            |> Graph.add_node(:dp13, %{costs: 0, label: "AKH"})
            |> Graph.add_node(:dp14, %{costs: 0, label: "Uni Campus"})
            |> Graph.add_node(:dp15, %{costs: 0, label: "Bruno Bettelheim Haus"})
            |> Graph.add_node(:dp16, %{costs: 0, label: "Museum"})
            |> Graph.add_node(:dp17, %{costs: 0, label: "Schäffergasse"})
            |> Graph.add_node(:dp18, %{costs: 0, label: "Matzleinsdorferplatz"})
            |> Graph.add_node(:dp19, %{costs: 0, label: "Hauptbahnhof"})
            |> Graph.add_node(:dp20, %{costs: 0, label: "Belvedere"})
            |> Graph.add_node(:dp21, %{costs: 0, label: "Universität Musik/Kunst"})
            |> Graph.add_node(:dp22, %{costs: 0, label: "Hundertwasserhaus"})

    state = state
            |> Graph.add_edge(:dp0, :dp18,  75)
            |> Graph.add_edge(:dp0, :dp19,  170)
            |> Graph.add_edge(:dp0, :dp17,  260)
            |> Graph.add_edge(:dp0, :dp8,   120)
            |> Graph.add_edge(:dp0, :dp7,   150)

    state = state
            |> Graph.add_edge(:dp1, :dp6,   110)
            |> Graph.add_edge(:dp1, :dp11,  85)
            |> Graph.add_edge(:dp1, :dp12,  130)
            |> Graph.add_edge(:dp1, :dp2,   75)
            |> Graph.add_edge(:dp1, :dp16,  200)
            |> Graph.add_edge(:dp1, :dp3,   160)
            |> Graph.add_edge(:dp1, :dp4,   100)

    state = state
            |> Graph.add_edge(:dp2, :dp11,  160)
            |> Graph.add_edge(:dp2, :dp12,  150)
            |> Graph.add_edge(:dp2, :dp3,   130)
            |> Graph.add_edge(:dp2, :dp5,   80)
            |> Graph.add_edge(:dp2, :dp6,   120)
            |> Graph.add_edge(:dp2, :dp4,   100)

    state = state
            |> Graph.add_edge(:dp3, :dp12,  110)
            |> Graph.add_edge(:dp3, :dp11,  150)
            |> Graph.add_edge(:dp3, :dp4,   100)

    state = state
            |> Graph.add_edge(:dp4, :dp5,   80)
            |> Graph.add_edge(:dp4, :dp22,  170)

    state = state
            |> Graph.add_edge(:dp5, :dp22,  110)
            |> Graph.add_edge(:dp5, :dp6,   130)
            |> Graph.add_edge(:dp5, :dp21,  85)

    state = state
            |> Graph.add_edge(:dp6, :dp20,  150)
            |> Graph.add_edge(:dp6, :dp17,  120)
            |> Graph.add_edge(:dp6, :dp21,  140)

    state = state
            |> Graph.add_edge(:dp7, :dp16,  70)
            |> Graph.add_edge(:dp7, :dp9,   130)
            |> Graph.add_edge(:dp7, :dp8,   85)
            |> Graph.add_edge(:dp7, :dp17,  110)
            |> Graph.add_edge(:dp7, :dp15,  100)

    state = state
            |> Graph.add_edge(:dp8, :dp9,   75)
            |> Graph.add_edge(:dp8, :dp17,  170)
            |> Graph.add_edge(:dp8, :dp16,  95)

    state = state
            |> Graph.add_edge(:dp9, :dp16,  90)
            |> Graph.add_edge(:dp9, :dp10,  90)

    state = state
            |> Graph.add_edge(:dp10, :dp16, 150)
            |> Graph.add_edge(:dp10, :dp15, 140)

    state = state
            |> Graph.add_edge(:dp11, :dp12, 60)
            |> Graph.add_edge(:dp11, :dp15, 140)
            |> Graph.add_edge(:dp11, :dp13, 190)

    state = state
            |> Graph.add_edge(:dp12, :dp15, 190)
            |> Graph.add_edge(:dp12, :dp13, 170)
            |> Graph.add_edge(:dp12, :dp14, 70)

    state = state
            |> Graph.add_edge(:dp13, :dp14, 100)

    state = state
            |> Graph.add_edge(:dp15, :dp16, 70)

    state = state
            |> Graph.add_edge(:dp17, :dp20, 130)

    state = state
            |> Graph.add_edge(:dp18, :dp19, 120)

    state = state
            |> Graph.add_edge(:dp19, :dp20, 120)

    state = state
            |> Graph.add_edge(:dp20, :dp21, 45)

    state = state
            |> Graph.add_edge(:dp21, :dp22, 200)
    state
  end
end

