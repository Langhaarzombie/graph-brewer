defmodule Priorityqueue do
  @moduledoc"""
  The prioriy queue is used by the shortest path algorithm of the `Graph` module. It keeps all the nodes that are to be evaluated and determines which node is to evaluated next.
  As the name suggests it works as a queue. So the main methods are `push` for adding an entry and `pop` for getting the next one.
  """
  defstruct entries: %{}

  @type key             :: atom
  @type node_id         :: atom
  @type path_costs      :: non_neg_integer
  @type heuristic_costs :: non_neg_integer
  @type to_costs        :: non_neg_integer
  @type t               :: %__MODULE__{
    entries: %{key => %{pcosts: path_costs, hcosts: heuristic_costs, tcosts: to_costs, from: node_id}}
  }

  @doc"""
  Returns a new struct of `PriorityQueue` with zero entries.

  ## Example

      iex(15)> Priorityqueue.new
      %Priorityqueue {entries: %{}}
  """
  @spec new :: t
  def new, do: %__MODULE__{}

  @doc"""
  Adds a new entry to an existing priority queue. The entry must contain the path costs to the node, the costs of the latest hop to the node, the heuristic costs of the node and the node from which the added one is reached (needed for reconstructing the path later on).

  ## Example

      iex> pq = Priorityqueue.new |> Priorityqueue.push(:a, %{costs_to: 15, costs_hop: 3, costs_heur: 4, from: :s})
      %Priorityqueue {entries: %{a: %{costs_heur: 4, costs_hop: 3, costs_to: 15, from: :s}}}
  """
  @spec push(t, key, %{costs_to: path_costs, costs_hop: path_costs, costs_heur: heuristic_costs, from: key}) :: t
  def push(%__MODULE__{entries: e} = pq, node, %{costs_to: cto, costs_hop: _, costs_heur: _, from: _} = prop) do
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

  @doc"""
  Returns the next item in the queue. As the shortest path algorithm uses the principle of the a star algorithm, the queue returns the element with the lowest costs. In detail, the function returns the updated priority queue, the key (the node) of the element to be evaluated next and the data of that element.

  ## Example

      iex> Priorityqueue.new |> Priorityqueue.push(:a, %{costs_to: 15, costs_hop: 3, costs_heur: 4, from: :s}) |> Priorityqueue.push(:b, %{costs_to: 10, costs_hop: 4, costs_heur: 3, from: :s}) |>
      ...> Priorityqueue.pop
      {%Priorityqueue {entries: %{a: %{costs_heur: 4, costs_hop: 3, costs_to: 15, from: :s}}}, :b, %{costs_heur: 3, costs_hop: 4, costs_to: 10, from: :s}}
  """
  @spec pop(t) :: {t, key, %{costs_heur: heuristic_costs, costs_hop: path_costs, costs_to: path_costs, from: key}}
  def pop(%__MODULE__{entries: e} = pq) do
    {skey, _} = Map.to_list(e) |> Enum.min_by(fn(x) -> elem(x, 1)[:costs_to] + elem(x, 1)[:costs_heur] end)
    pq = %__MODULE__{pq | entries: Map.delete(e, skey)}
    {pq, skey, Map.get(e, skey)}
  end
end

