defmodule Graph.Priorityqueue do

  defstruct entries: %{}

  @type key :: atom
  @type path_costs :: non_neg_integer
  @type heuristic_costs :: non_neg_integer
  @type total_costs :: non_neg_integer
  @type t :: %__MODULE__{
    entries: %{key => %{pcosts: path_costs, hcosts: heuristic_costs, tcosts: total_costs}}
  }

  def new, do: %__MODULE__{}

  def push(%__MODULE__{entries: e} = pq, node, %{costs_to: cto, costs_hop: chop, costs_heur: cheu, from: from} = prop) when is_atom(node) and is_atom(from) do
    case Map.get(e, node) do
      nil ->
        %__MODULE__{pq | entries: Map.put(e, node, prop)}
      entry ->
        if Map.get(entry, :costs_to) > cto do
          %__MODULE__{pq | entries: Map.put(e, node, prop)}
        end
    end
  end

  def pop(pq) do
  end

end
