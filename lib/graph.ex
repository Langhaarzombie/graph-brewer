defmodule Graph do
  @moduledoc"""
  This module serves as a graph library that enables to handle undirected weighted graphs (directed is in the works) in memory.
  It features simple operations such as adding and removing `nodes` and `edges` and finding the shortest path between nodes.

  Supported features:

  - `Nodes` with an optional heuristic `costs` (for the shortest path algorithm) and and optional `label`
  - `Edges` from and to nodes with certain `costs`
  - Adding and deleting `nodes`
  - Adding and deleting `edges`

  The `Graph` module is strucutred like so:

  - `nodes` is a `Map` that has the node_id (atom) as a key and another `Map` as value. This `Map` conatins `label` and `costs` as keys that refer to the corresponding value.
  - `edges` is a `Map` that has the node_id (atom) as a key and a `MapSet` as value. The `MapSet` contains `Maps` which store the information of the `edge`. The key `to` points to the `node` the adge is connecting and the key `costs` points to the assigned costs of the edge.
  """

  defstruct nodes: %{}, edges: %{}

  @type node_id :: atom
  @type costs :: non_neg_integer
  @type label :: term
  @type edge_info :: %{to: node_id, costs: costs}
  @type node_info :: %{label: label, costs: costs}
  @type t :: %__MODULE__{
    nodes: %{node_id => node_info},
    edges: %{node_id => MapSet.t(edge_info)}
  }

  @doc"""
  Creates a new undirected Graph.
  """
  @spec new :: t
  def new, do: %__MODULE__{}

  @doc"""
  Adds an edge to the given graph from a to b & b to a and assigns the according costs. If the nodes a and / or b do not exist they are created (costs and label of these nodes is set to nil).
  If there are no costs set, the default value of 1 will be assigned.

  ## Example

      iex> g = Graph.new |> Graph.add_edge(:a, :b, 5)
      %Graph {
        edges: %{a: %MapSet<[%{costs: 5, to: :b}]>, b: %MapSet<[%{costs: 5, to: :a}]>},
        nodes: %{a: %{costs: 0, label: nil}, b: %{costs: 0, label: nil}}
      }
  """
  @spec add_edge(t, node_id, node_id, costs) :: t
  def add_edge(%__MODULE__{edges: e} = g, from, to, costs \\ 1) when is_atom(from) and is_atom(to) do
    g = g
      |> add_node(from)
      |> add_node(to)

    g = case Map.get(e, from) do
      nil ->
        %__MODULE__{g | edges: Map.put(e, from, MapSet.put(MapSet.new, %{to: to, costs: costs}))}
      _ ->
        %__MODULE__{g | edges: Map.put(e, from, MapSet.put(Map.get(e, from), %{to: to, costs: costs}))}
    end

    e = g.edges
    case Map.get(e, to) do
      nil ->
        %__MODULE__{g | edges: Map.put(e, to, MapSet.put(MapSet.new, %{to: from, costs: costs}))}
      _ ->
        %__MODULE__{g | edges: Map.put(e, to, MapSet.put(Map.get(e, to), %{to: from, costs: costs}))}
    end
  end

  @doc"""
  Deletes an the edge that goes from a to b. The edge is only deleted if it really exists. Isolated nodes are of course not deleted.

  ## Example

      iex> g = Graph.new |> Graph.add_edge(:a, :b, 5) |> Graph.add_edge(:b, :c, 5)
      %Graph {
        edges: %{a: #MapSet<[%{costs: 5, to: :b}]>, b: #MapSet<[%{costs: 5, to: :a}, %{costs: 5, to: :c}]>, c: #MapSet<[%{costs: 5, to: :b}]>},
        nodes: %{a: %{costs: 0, label: nil}, b: %{costs: 0, label: nil}, c: %{costs: 0, label: nil}}
      }
      iex> g = Graph.delete_edge(g, :b, :c)
      %Graph {
        edges: %{a: #MapSet<[%{costs: 5, to: :b}]>, b: #MapSet<[%{costs: 5, to: :a}]>, c: #MapSet<[]>},
        nodes: %{a: %{costs: 0, label: nil}, b: %{costs: 0, label: nil}, c: %{costs: 0, label: nil}}
      }
  """
  @spec delete_edge(t, node_id, node_id) :: t
  def delete_edge(%__MODULE__{edges: e} = g, from, to) do
    with fe <- Map.get(e, from),
         te <- Map.get(e, to) do
      fe_new = MapSet.delete(fe, find_edge(MapSet.to_list(fe), to))
      te_new = MapSet.delete(te, find_edge(MapSet.to_list(te), from))

      e = e
        |> Map.delete(from)
        |> Map.delete(to)
        |> Map.put(from, fe_new)
        |> Map.put(to, te_new)

      %__MODULE__{g | edges: e}
    end
  end
  defp find_edge([], _) do
    nil
  end
  defp find_edge([h | t], to) do
    if Map.get(h, :to) == to do
      h
    else
      find_edge(t, to)
    end
  end

  @doc"""
  Adds a node to the graph without any further info.

  ## Example

      iex> g = Graph.new |> Graph.add_node(:a)
      %Graph {edges: %{}, nodes: %{a: %{costs: 0, label: nil}}}
  """
  @spec add_node(t, node_id) :: t
  def add_node(%__MODULE__{nodes: n} = g, node) when is_atom(node) do
    case Map.get(n, node) do
      nil ->
        add_node(g, node, %{label: nil, costs: 0})
      _ ->
        add_node(g, node, Map.get(n, node))
    end
  end

  @doc"""
  Adds a node to the graph with the specified information.

  ## Example

      iex> g = Graph.new |> Graph.add_node(:a, %{label: "This is a", costs: 2})
      %Graph {edges: %{}, nodes: %{a: %{costs: 2, label: "This is a"}}}
  """
  @spec add_node(t, node_id, node_info) :: t
  def add_node(%__MODULE__{nodes: n} = g, node, opts) when is_atom(node) and is_map(opts) do
    %__MODULE__{g | nodes: Map.put(n, node, %{label: Map.get(opts, :label), costs: Map.get(opts, :costs)})}
  end

  @doc"""
  Deletes a given node plus the edges it is involved in.

  ## Example

      iex> g = Graph.new |> Graph.add_node(:a) |> Graph.add_node(:b) |> Graph.add_edge(:a, :b)
      %Graph {
        edges: %{a: #MapSet<[%{costs: 1, to: :b}]>, b: #MapSet<[%{costs: 1, to: :a}]>},
        nodes: %{a: %{costs: 0, label: nil}, b: %{costs: 0, label: nil}}
      }
      iex> g = Graph.delete_node(g, :b)
      %Graph{edges: %{a: #MapSet<[]>}, nodes: %{a: %{costs: 0, label: nil}}}

  """
  @spec delete_node(t, node_id) :: t
  def delete_node(%__MODULE__{} = g, node) when is_atom(node) do
    res = delete_from_neighbors(g, node)
    %__MODULE__{res | nodes: Map.delete(res.nodes, node), edges: Map.delete(res.edges, node)}
  end
  def delete_from_neighbors(%__MODULE__{edges: e} = g, node) do
    do_delete_from_neigbors(g, node, MapSet.to_list(Map.get(e, node)))
  end
  def do_delete_from_neigbors(g, from, [to | []]) do
    delete_edge(g, from, Map.get(to, :to))
  end
  def do_delete_from_neigbors(g, from, [to | next]) do
    g = delete_edge(g, from, Map.get(to, :to))
    do_delete_from_neigbors(g, from, next)
  end

  @doc"""
  Gets you the total costs of a path (edge + weight). If you enter a path is not complete (there is a hole) the method will return a negative value.

  ## Example

      iex> Graph.new |>
      ...> Graph.add_edge(:s, :a, 3)  |>
      ...> Graph.add_edge(:a, :b, 5)  |>
      ...> Graph.add_edge(:b, :c, 10) |>
      ...> Graph.add_edge(:c, :d, 3)  |>
      ...> Graph.add_edge(:d, :e, 4)  |>
      ...> Graph.add_edge(:b, :e, 5)  |>
      ...> Graph.shortest_path(:s, :e) |>
      ...> Graph.path_costs
      13
  """
  @spec path_costs(t, []) :: costs
  def path_costs(%__MODULE__{nodes: n, edges: e}, path) do
    do_path_costs(n, e, path)
  end
  defp do_path_costs(n, _, [target | []]) do
    Map.get(Map.get(n, target), :costs)
  end
  defp do_path_costs(n, e, [from | [to | _] = next]) do 
    nodecosts = Map.get(Map.get(n, from), :costs)
    edgecosts = get_edge_costs(e, from, to)
    (nodecosts + edgecosts) + do_path_costs(n, e, next)
  end
  defp get_edge_costs(e, from, to) do
    neig = MapSet.to_list(Map.get(e, from))
    Map.get(check_neighbors(neig, to), :costs)
  end
  defp check_neighbors([], to) do
    raise "The path provided is not actually a complete one. There are holes in it."
  end
  defp check_neighbors([h | t], to) do
    if Map.get(h, :to) != to do
      check_neighbors(t, to)
    else
      h
    end
  end

  @doc"""
  Returns the costs of the hop from node A to node B. Basically uses `path_costs` but with a path with just two nodes.
  Same as `path_costs` it raises an exception if there is no connection.

  ## Example
  
      iex> g = Graph.new |>
      ...> Graph.add_edge(:s, :a, 3)  |>
      ...> Graph.add_edge(:a, :b, 5)  |>
      ...> Graph.add_edge(:b, :c, 10) |>
      ...> Graph.add_edge(:c, :d, 3)  |>
      ...> Graph.add_edge(:d, :e, 4)  |>
      ...> Graph.add_edge(:b, :e, 5)
      iex> Graph.hop_costs(g, :s, :a)
      3

  """
  @spec hop_costs(t, node_id, node_id) :: costs
  def hop_costs(%__MODULE__{} = g, from, to) do
    path_costs(g, [from, to])
  end

  @doc"""
  Find the shortest path from a to b in the given graph.

  ## Example

      iex> Graph.new |>
      ...> Graph.add_edge(:s, :a, 3)  |>
      ...> Graph.add_edge(:a, :b, 5)  |>
      ...> Graph.add_edge(:b, :c, 10) |>
      ...> Graph.add_edge(:c, :d, 3)  |>
      ...> Graph.add_edge(:d, :e, 4)  |>
      ...> Graph.add_edge(:b, :e, 5)  |>
      ...> Graph.shortest_path(:s, :e)
      [:s, :a, :b, :e]
  """
  @spec shortest_path(t, node_id, node_id) :: [node_id, ...]
  def shortest_path(%__MODULE__{} = g, from, to) when is_atom(from) and is_atom(to) do
    processed = %{}
    pq = Priorityqueue.new
      |> Priorityqueue.push(from, %{costs_to: 0, costs_hop: 0, costs_heur: 0, from: nil})
    do_shortest_path(g, from, to, pq, processed)
  end
  defp do_shortest_path(%__MODULE__{edges: e} = g, from, to, pq, processed) do
    pq = case Priorityqueue.pop(pq) do
      {_, ^to, data} ->
        processed = Map.put(processed, to, data)
        construct_path(processed, from, to)
      {pq, id, data} ->
        processed = Map.put(processed, id, data)
        neighbors = filter(MapSet.to_list(Map.get(e, id)), processed)
        insert_pq(g, pq, neighbors, Map.merge(%{key: id}, data))
    end
    if is_list(pq) do
      Enum.reverse(pq) # because for some reason the path is constructed is the other way around
    else
      try do
        do_shortest_path(g, from, to, pq, processed)
      rescue
        []
      end
    end
  end
  defp filter(n, p) do
    pkeys = Map.keys(p)
    Enum.filter(n, fn x -> !(Enum.member?(pkeys, Map.get(x, :to))) end)
  end
  defp insert_pq(_, pq, [], _) do
    pq
  end
  defp insert_pq(%__MODULE__{nodes: n}, pq, [h | []], previous) do
    with id   <- Map.get(h, :to),
         node <- Map.get(n, id) do
      costs_hop = Map.get(h, :costs)
      costs_heur = Map.get(node, :costs)
      costs_to = Map.get(previous, :costs_to) + costs_hop
      Priorityqueue.push(pq, id, %{costs_to: costs_to, costs_hop: costs_hop, costs_heur: costs_heur, from: Map.get(previous, :key)})
    end
  end
  defp insert_pq(%__MODULE__{nodes: n} = g, pq, [h | t], previous) do
    with  id    <- Map.get(h, :to),
          node  <- Map.get(n, id) do
      costs_hop = Map.get(h, :costs)
      costs_heur = Map.get(node, :costs)
      costs_to = Map.get(previous, :costs_to) + costs_hop
      Priorityqueue.push(insert_pq(g, pq, t, previous), id, %{costs_to: costs_to, costs_hop: costs_hop, costs_heur: costs_heur, from: Map.get(previous, :key)})
    end
  end
  defp construct_path(processed, from, to) do
    if from == to do
      [to]
    else
      [to] ++ construct_path(processed, from, Map.get(Map.get(processed, to), :from))
    end
  end
 end

