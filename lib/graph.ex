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

  # Nodes is defined as %{key(atom) => %{label => "string", hcosts => int}}
  # Edges is defined as %{{from(atom), to(atom)} => costs(int)}

  def add_edge(%__MODULE__{nodes: n, edges: e} = g, from, to, weight) when is_atom(from) and is_atom(to) do
  end

  def add_node(%__MODULE__{nodes: n} = g, from, to, opts) when is_atom(from) and is_atom(to) and is_map(opts) do
  end

  def shortes_path(%__MODULE__{nodes: n, edges: e} = g, from, to) when is_atom(from) and is_atom(to) do
  end

end
