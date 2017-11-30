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
        else
          pq
        end
    end
  end

  def pop(%__MODULE__{entries: e} = pq) do
    {skey, _} = find_smallest(pq, Map.keys(e), %{key: nil, value: 2092013})
    pq = %__MODULE__{pq | entries: Map.delete(e, skey)}
    {pq, skey, Map.get(e, skey)}
  end

  defp find_smallest(%__MODULE__{}, [], smallest) do
    {Map.get(smallest, :key), Map.get(smallest, :value)}
  end
  defp find_smallest(%__MODULE__{entries: e} = pq, [h | t], smallest) do
    with entry <- Map.get(e, h) do
      ct = Map.get(entry, :costs_to)
      ch = Map.get(entry, :costs_heur)
      total = ct + ch
      if total < Map.get(smallest, :value) do
        find_smallest(pq, t, %{key: h, value: total})
      else
        find_smallest(pq, t, smallest)
      end
    end
  end

end
