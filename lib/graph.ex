defmodule Graph do

  defstruct nodes: %{}, edges: %{}

  @type node_id :: atom
  @type edge_id :: {node_id, node_id}
  @type costs :: non_neg_integer
  @type label :: term
  @type t :: %__MODULE__{
    nodes: %{node_id => %{label: label, costs: costs}},
    edges: %{{node_id, node_id} => costs}
  }

  # NOTE This module only serves as a library for undirected graphs!
  # Nodes is defined as %{key(atom) => %{label => "string", hcosts => int}}
  # Edges is defined as %{{from(atom), to(atom)} => costs(int)}

  def new do
    %__MODULE__{}
  end

  def add_edge(%__MODULE__{nodes: n, edges: e} = g, from, to, costs) when is_atom(from) and is_atom(to) do
    case Map.get(e, {from, to}) do
      nil ->
        g = g
          |> add_node(from)
          |> add_node(to)
        %__MODULE__{g | edges: Map.put(e, {from, to}, costs)}
    end
  end

  def add_node(%__MODULE__{nodes: n} = g, node) when is_atom(node) do
    case Map.get(n, node) do
      nil ->
        add_node(g, node, %{label: nil, costs: nil})
      _ ->
        add_node(g, node, Map.get(n, node))
    end
  end

  def add_node(%__MODULE__{nodes: n} = g, node, opts) when is_atom(node) and is_map(opts) do
    case Map.get(n, node) do
      nil ->
        %__MODULE__{g | nodes: Map.put(n, node, %{label: Map.get(opts, :label), costs: Map.get(opts, :costs)})}
      _ ->
        g |> delete_node(node)
          |> add_node(node, opts)
    end
  end

  def delete_node(%__MODULE__{nodes: n} = g, node) when is_atom(node) do
    %__MODULE__{g | nodes: Map.delete(n, node)}
  end

  def shortes_path(%__MODULE__{nodes: n, edges: e} = g, from, to) when is_atom(from) and is_atom(to) do
  end

end
