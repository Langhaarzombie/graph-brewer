defmodule Graph do
  @moduledoc"""
  This module serves as a graph library that enables to handle undirected graphs (directed is in the works) in memory.
  It features simple operations as stated below and also includes a shortest path calculation.

  Supported features:

  - `Nodes` with an optional heuristic `costs` (for the shortest path algorithm) and and optional `label`
  - `Edges` from and to nodes with certain `costs`
  - Adding and deleting `nodes`
  - Adding and deleting `edges`

  The `Graph` module is strucutred like so:

  - `nodes` is a `Map` that has the node_id (atom) as a key and another `Map` as value. This `Map` conatins `label` and `costs` as keys that refer to the corresponding value.
  - `edges` is a `Map` that has the node_id (atom) as a key and a `MapSet` as value. The `MapSet` contains `Maps` which store the information of the `edge`. The key `to` points to the `node` the adge is connecting and the key `costs` points to the assigned costs of the edge.
  """

  require Logger

  defstruct nodes: %{}, edges: %{}

  @type node_id :: atom
  @type costs :: non_neg_integer
  @type label :: term
  @type edge_info :: %{to: node_id, costs: costs}
  @type t :: %__MODULE__{
    nodes: %{node_id => %{label: label, costs: costs}},
    edges: %{node_id => MapSet.t(edge_info)}
  }

  def new, do: %__MODULE__{}

  def add_edge(%__MODULE__{nodes: n, edges: e} = g, from, to, costs) when is_atom(from) and is_atom(to) do
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

  def delete_edge(%__MODULE__{edges: e} = g, from, to) do
    with  fe <- Map.get(e, from),
          te <- Map.get(e, to) do
          #g = %__MODULE__{g | edges: %{from => MapSet.delete(ef, do_delete_edge(MapSet.to_list(ef), to))}}
          #%__MODULE__{g | edges: MapSet.delete(tf, do_delete_edge(MapSet.to_list(tf), from))}}
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
  defp find_edge([], to) do
    nil
  end
  defp find_edge([h | t], to) do
    if Map.get(h, :to) == to do
      h
    else
      find_edge(t, to)
    end
  end
  # TODO maybe delete below
  defp out_edges(%__MODULE__{edges: e}, node) do
    edges = MapSet.to_list(Map.get(e, node))
    extract_nodes(edges)
  end
  defp extract_nodes([h | []]) do
    [Map.get(h, :to)]
  end
  defp extract_nodes([h | t]) do
    [Map.get(h, :to)] ++ extract_nodes(t)
  end

  def add_node(%__MODULE__{nodes: n} = g, node) when is_atom(node) do
    case Map.get(n, node) do
      nil ->
        add_node(g, node, %{label: nil, costs: 0})
      _ ->
        add_node(g, node, Map.get(n, node))
    end
  end

  def add_node(%__MODULE__{nodes: n} = g, node, opts) when is_atom(node) and is_map(opts) do
    %__MODULE__{g | nodes: Map.put(n, node, %{label: Map.get(opts, :label), costs: Map.get(opts, :costs)})}
  end

  def delete_node(%__MODULE__{nodes: n} = g, node) when is_atom(node) do
    %__MODULE__{g | nodes: Map.delete(n, node)}
  end

  def shortest_path(%__MODULE__{nodes: n, edges: e} = g, from, to) when is_atom(from) and is_atom(to) do
    processed = %{}
    pq = Graph.Priorityqueue.new
      |> Graph.Priorityqueue.push(from, %{costs_to: 0, costs_hop: 0, costs_heur: 0, from: nil})
    do_shortest_path(g, from, to, pq, processed)
  end

  defp do_shortest_path(%__MODULE__{nodes: n, edges: e} = g, from, to, pq, processed) do
    pq = case Graph.Priorityqueue.pop(pq) do
      {pq, ^to, data} ->
        processed = Map.put(processed, to, data)
        construct_path(processed, from, to)
      {pq, id, data} ->
        IO.puts "Evaluating: From #{id}"
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
        FunctionClauseError -> Logger.error "Could not find path from #{from} to #{to}!!"
      end
    end
  end

  # n ... neighbors, p ... processed, there must not be any nodes on neighbors which are also in processed
  defp filter(n, p) do
    pkeys = Map.keys(p)
    Enum.filter(n, fn x -> !(Enum.member?(pkeys, Map.get(x, :to))) end)
  end

  defp insert_pq(%__MODULE__{edges: e, nodes: n} = g, pq, [], previous) do
    pq
  end
  defp insert_pq(%__MODULE__{edges: e, nodes: n} = g, pq, [h | []], previous) do
    with id   <- Map.get(h, :to),
         node <- Map.get(n, id) do
      costs_hop = Map.get(h, :costs)
      costs_heur = Map.get(node, :costs)
      costs_to = Map.get(previous, :costs_to) + costs_hop
      Graph.Priorityqueue.push(pq, id, %{costs_to: costs_to, costs_hop: costs_hop, costs_heur: costs_heur, from: Map.get(previous, :key)})
    end
  end
  defp insert_pq(%__MODULE__{edges: e, nodes: n} = g, pq, [h | t], previous) do
    with  id    <- Map.get(h, :to),
          node  <- Map.get(n, id) do
      costs_hop = Map.get(h, :costs)
      costs_heur = Map.get(node, :costs)
      costs_to = Map.get(previous, :costs_to) + costs_hop
      Graph.Priorityqueue.push(insert_pq(g, pq, t, previous), id, %{costs_to: costs_to, costs_hop: costs_hop, costs_heur: costs_heur, from: Map.get(previous, :key)})
    end
  end

  # from is the initial target and to is where we started
  defp construct_path(processed, from, to) do
    if from == to do
      [to]
    else
      [to] ++ construct_path(processed, from, Map.get(Map.get(processed, to), :from))
    end
  end
 end
