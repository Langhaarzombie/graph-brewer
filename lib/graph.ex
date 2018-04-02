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

  @type node_id   :: atom
  @type costs     :: non_neg_integer
  @type label     :: term
  @type edge_info :: %{node_id => costs}
  @type node_info :: %{label: label, costs: costs}
  @type t         :: %__MODULE__{
    nodes: %{node_id => node_info},
    edges: %{node_id => edge_info}
  }

  @doc"""
  Creates a new undirected Graph.
  """
  @spec new :: t
  def new, do: %__MODULE__{}

  @doc~S"""
  Adds an edge to the given graph from a to b & b to a and assigns the according costs. If the nodes a and / or b do not exist they are created (costs and label of these nodes is set to nil).
  If there are no costs set, the default value of 1 will be assigned.

  ## Example

    iex> g = Graph.new |> Graph.add_edge(:a, :b, 5) |> Graph.add_edge(:b, :c, 3)
    %Graph{
      edges: %{a: %{b: 5}, b: %{a: 5, c: 3}, c: %{b: 3}},
      nodes: %{
        a: %{costs: 0, label: nil},
        b: %{costs: 0, label: nil},
        c: %{costs: 0, label: nil}
      }
    }
    iex> Graph.add_edge(g, :b, :c, 9)
    %Graph{
      edges: %{a: %{b: 5}, b: %{a: 5, c: 9}, c: %{b: 9}},
      nodes: %{
        a: %{costs: 0, label: nil},
        b: %{costs: 0, label: nil},
        c: %{costs: 0, label: nil}
      }
    }
  """
  @spec add_edge(t, node_id, node_id, costs) :: t
  def add_edge(%__MODULE__{edges: e} = g, from, to, costs \\ 1) when is_atom(from) and is_atom(to) do
    g = g |> add_node(from) |> add_node(to)
    e = e |> update_edge(from, to, costs) |> update_edge(to, from, costs)
    %{g | edges: e}
  end
  defp update_edge(e, from, to, costs) do
    fe = e[from]
    cond do
      fe == nil ->
        Map.put_new(e, from, %{to => costs})
      Map.has_key?(fe, to) ->
        %{e | from => %{fe | to => costs}}
      true ->
        Map.put_new(fe, to, costs) |> (&%{e | from => &1}).()
    end
  end

  @doc~S"""
  Gets you the edge connecting two nodes.

  ## Example

      iex> g = Graph.new |> Graph.add_edge(:a, :b, 3)
      %Graph{
        edges: %{a: %{b: 3}, b: %{a: 3}},
        nodes: %{a: %{costs: 0, label: nil}, b: %{costs: 0, label: nil}}
      }
      iex> Graph.get_edge(g, :a, :b)
      {:a, :b, 3}
      iex> Graph.get_edge(g, :a, :s)
      nil
  """
  @spec get_edge(t, node_id, node_id) :: {node_id, node_id, costs}
  def get_edge(%__MODULE__{edges: e}, from, to) do
    case e[from] do
      nil -> nil
      edges ->
        for {^to, costs} <- Map.to_list(edges) do
          {from, to, costs}
        end |> Enum.at(0)
    end
  end

  defp has_edge?(%__MODULE__{} = g, from, to) do
    get_edge(g, from, to) != nil || get_edge(g, to, from) != nil
  end

  @doc~S"""
  Deletes an the edge that goes from a to b. The edge is only deleted if it really exists. Isolated nodes are of course not deleted.

  ## Example

      iex> g = Graph.new |> Graph.add_edge(:a, :b, 5) |> Graph.add_edge(:b, :c, 5)
      %Graph{
        edges: %{a: %{b: 5}, b: %{a: 5, c: 5}, c: %{b: 5}},
        nodes: %{
          a: %{costs: 0, label: nil},
          b: %{costs: 0, label: nil},
          c: %{costs: 0, label: nil}
        }
      }
      iex> Graph.delete_edge(g, :b, :c)
      %Graph{
        edges: %{a: %{b: 5}, b: %{a: 5}},
        nodes: %{
          a: %{costs: 0, label: nil},
          b: %{costs: 0, label: nil},
          c: %{costs: 0, label: nil}
        }
      }
  """
  @spec delete_edge(t, node_id, node_id) :: t
  def delete_edge(%__MODULE__{} = g, from, to) do
    g = if has_edge?(g, from, to), do: delete_edge!(g, from, to)
    g = if has_edge?(g, to, from), do: delete_edge!(g, to, from)
    g
  end
  def delete_edge!(%__MODULE__{edges: e} = g, from, to) do
    e = %{e | from => Map.delete(e[from], to)}
    if e[from] == %{}, do: e = Map.delete(e, from)
    %__MODULE__{g | edges: e}
  end

  @doc~S"""
  Adds a node to the graph with the specified information.

  ## Example

      iex> g = Graph.new |> Graph.add_node(:a, label: "This is a", costs: 2)
      %Graph{edges: %{}, nodes: %{a: %{costs: 2, label: "This is a"}}}
      iex> Graph.add_node(g, :a, costs: 5)
      %Graph{edges: %{}, nodes: %{a: %{costs: 5, label: "This is a"}}}
  """
  @spec add_node(t, node_id, node_info) :: t
  def add_node(%__MODULE__{nodes: n} = g, node, opts \\ []) when is_atom(node) do
    label = Keyword.get(opts, :label, n[node][:label])
    costs = case Keyword.get(opts, :costs) do
      nil -> 0
      value -> value
    end
    %__MODULE__{g | nodes: Map.put(n, node, %{label: label, costs: costs})}
  end

  @doc~S"""
  Gets node info for the ID.

  ## Example
  
      iex> g = Graph.new |> Graph.add_node(:a, label: "This is a", costs: 4)
      %Graph{edges: %{}, nodes: %{a: %{costs: 4, label: "This is a"}}}
      iex> Graph.get_node(g, :a)
      %{costs: 4, label: "This is a"}
  """
  @spec get_node(t, node_id) :: node_info
  def get_node(%__MODULE__{nodes: n}, id), do: n[id]

  @doc~S"""
  Gets the list of all nodes that have an edge towards or from the given node.

  ## Example

      iex> Graph.new |> Graph.add_edge(:a, :b, 5) |> Graph.add_edge(:b, :c, 5) |> Graph.get_neighbors(:b)
      [:a, :c]
  """
  @spec get_neighbors(t, node_id) :: []
  def get_neighbors(%__MODULE__{nodes: n} = g, id) do
    for to <- Map.keys(n), has_edge?(g, id, to), do: to
  end

  @doc"""
  Deletes a given node plus the edges it is involved in.

  ## Example

      iex> g = Graph.new |> Graph.add_node(:a) |> Graph.add_node(:b) |> Graph.add_edge(:a, :b)
      %Graph{
        edges: %{a: %{b: 1}, b: %{a: 1}},
        nodes: %{a: %{costs: 0, label: nil}, b: %{costs: 0, label: nil}}
      }
      iex> Graph.delete_node(g, :b)
      %Graph{edges: %{}, nodes: %{a: %{costs: 0, label: nil}}}
  """
  @spec delete_node(t, node_id) :: t
  def delete_node(%__MODULE__{nodes: n} = g, node) do
    g = get_neighbors(g, node) |> delete_relations(g, node)
    %__MODULE__{g | nodes: Map.delete(n, node)}
  end
  defp delete_relations([], %__MODULE__{} = g, _node), do: g
  defp delete_relations([h | t], %__MODULE__{} = g, node) do
    delete_relations(t, g, node) |> delete_edge(node, h)
  end

  @doc"""
  Gets the total costs for a path (considering edge weights).

  ## Example

      iex> g = Graph.new |>
      ...> Graph.add_edge(:s, :a, 3)  |>
      ...> Graph.add_edge(:a, :b, 5)  |>
      ...> Graph.add_edge(:b, :c, 10) |>
      ...> Graph.add_edge(:c, :d, 3)  |>
      ...> Graph.add_edge(:d, :e, 4)  |>
      ...> Graph.add_edge(:b, :e, 5)
      %Graph{
        edges: %{
          a: %{b: 5, s: 3},
          b: %{a: 5, c: 10, e: 5},
          c: %{b: 10, d: 3},
          d: %{c: 3, e: 4},
          e: %{b: 5, d: 4},
          s: %{a: 3}
        },
        nodes: %{
          a: %{costs: 0, label: nil},
          b: %{costs: 0, label: nil},
          c: %{costs: 0, label: nil},
          d: %{costs: 0, label: nil},
          e: %{costs: 0, label: nil},
          s: %{costs: 0, label: nil}
        }
      }
      iex> Graph.shortest_path(g, :s, :e) |>
      ...> Graph.path_costs(g)
      13
  """
  @spec path_costs(t, []) :: costs
  def path_costs(%__MODULE__{} = g, path), do: do_path_costs(g, path)
  def path_costs(path, %__MODULE__{} = g), do: path_costs(g, path)
  def do_path_costs(_g, path) when length(path) == 1, do: 0
  def do_path_costs(%__MODULE__{} = g, [f | [t | _] = n]) do
    case do_path_costs(g, n) do
      nil -> nil
      c ->
        cond do
          has_edge?(g, f, t) ->
            edge_costs(g, f, t) + c
          true -> nil
        end
    end
  end

  @doc~S"""
  Returns the costs for the edge from node A to node B. Returns nil if there is no connection.

  ## Example
  
      iex> g = Graph.new |>
      ...> Graph.add_edge(:s, :a, 3)  |>
      ...> Graph.add_edge(:a, :b, 5)  |>
      ...> Graph.add_edge(:b, :c, 10) |>
      ...> Graph.add_edge(:c, :d, 3)  |>
      ...> Graph.add_edge(:d, :e, 4)  |>
      ...> Graph.add_edge(:b, :e, 5)
      iex> Graph.edge_costs(g, :s, :a)
      3

  """
  @spec edge_costs(t, node_id, node_id) :: costs
  def edge_costs(%__MODULE__{} = g, from, to) do
    case get_edge(g, from, to) do
      nil -> nil
      e -> elem(e, 2)
    end
  end

  @doc~S"""
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
    pq = Priorityqueue.new
         |> Priorityqueue.push(from, %{costs_to: 0, costs_hop: 0, costs_heur: 0, from: nil})
    do_shortest_path(g, from, to, pq, %{})
  end
  defp do_shortest_path(%__MODULE__{} = g, from, to, pq, processed) do
    pq = case Priorityqueue.pop(pq) do
      {_, ^to, data} ->
        Map.put(processed, to, data) |> construct_path(from, to)
      {pq, id, data} ->
        processed = Map.put(processed, id, data)
        neighbors = Enum.filter(get_neighbors(g, id),
                                fn(x) -> !(Enum.member?(Map.keys(processed), x)) end)
        insert_pq(g, pq, neighbors, Map.merge(%{key: id}, data))
      nil -> []
    end
    if is_list(pq) do
      Enum.reverse(pq)
    else
      do_shortest_path(g, from, to, pq, processed)
    end
  end
  defp insert_pq(_g, pq, [], _previous), do: pq
  defp insert_pq(%__MODULE__{} = g, pq, [h | t], previous) do
    insert_pq(g, pq, t, previous) |> Priorityqueue.push(h, calculate_costs(g, h, previous))
  end
  defp calculate_costs(g, to, from) do
    {_, _, costs_hop} = get_edge(g, from[:key], to)
    costs_heur = get_node(g, to)[:costs]
    costs_to = from[:costs_to] + costs_hop
    %{costs_to: costs_to, costs_hop: costs_hop, costs_heur: costs_heur, from: from[:key]}
  end
  defp construct_path(_processed, from, from), do: [from]
  defp construct_path(processed, from, to) do
      [to] ++ construct_path(processed, from, processed[to][:from])
  end
 end

