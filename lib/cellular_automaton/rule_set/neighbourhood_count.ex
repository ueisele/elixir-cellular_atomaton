defmodule CellularAtomaton.RuleSet.NeighbourhoodCount do
  alias CellularAtomaton.Cell
  alias CellularAtomaton.StateSet
  alias CellularAtomaton.State

  @type t :: {
    %{
      optional(State.t) => [
        {%{optional(State.t) => non_neg_integer()}, State.t}
      ]
    },
    default: State.t
  }

  @type t_neighbours_by_state ::  %{optional(State.t) => non_neg_integer()}

  @spec create_state_transition_function(t | (State.t, t_neighbours_by_state -> State.t)) :: ({Cell.t, State.t}, StateSet.t -> {Cell.t, State.t})
  def create_state_transition_function({%{} = transfer_table_by_state, default: default_state}) do
    create_state_transition_function(fn (state, neighbours_by_state) -> next_state(transfer_table_by_state[state] || [], neighbours_by_state, default_state) end)
  end
  def create_state_transition_function(neighbours_transfer_function) do
    fn
      ({cell, state}, neighbourhood) -> {cell, neighbours_transfer_function.(state, neighbours_by_state(neighbourhood))}
    end
  end

  @spec next_state(
    [{%{optional(State.t) => non_neg_integer()}, State.t}],
    %{optional(State.t) => non_neg_integer()},
    State.t) :: State.t
  defp next_state([], _, default_state), do: default_state
  defp next_state([{condition, state} | tail], neighbours_by_state, default_state) do
    case MapSet.subset?(MapSet.new(condition), MapSet.new(neighbours_by_state)) do
      true -> state
      false -> next_state(tail, neighbours_by_state, default_state)
    end
  end

  @spec create_state_transition_module(
          atom() | binary(),
          atom() | binary(),
          t
        ) :: module()
  def create_state_transition_module(ns \\ __ENV__.module, name, {%{} = transfer_table_by_state, default: default_state}) do
    module_head =
      quote do
        alias CellularAtomaton.RuleSet.NeighbourhoodCount
        @behaviour CellularAtomaton.StateTransition
        def transfer({cell, state}, neighbourhood), do: {cell, transfer(state, NeighbourhoodCount.neighbours_by_state(neighbourhood))}
      end
    module_body = for {state, transitions} <- transfer_table_by_state do
      for {condition, next_state} <- transitions do
        quote do
          def transfer(unquote(state), unquote(Macro.escape(condition))), do: unquote(next_state)
        end
      end
    end
    module_food =
      quote do
        def transfer(_, _), do: unquote(default_state)
      end
    {:module, created_module, _, _} = Module.create(Module.concat(ns, name), [module_head] ++ List.flatten(module_body) ++ [module_food], Macro.Env.location(__ENV__))
    created_module
  end

  @spec neighbours_by_state(StateSet.t) :: %{optional(State.t) => non_neg_integer()}
  def neighbours_by_state(neighbourhood) do
    count_by_entry(Map.values(neighbourhood))
  end

  @spec count_by_entry([any()]) :: %{optional(any()) => non_neg_integer()}
  def count_by_entry(list), do: count_by_entry(list, %{})
  @spec count_by_entry([any()], %{optional(any()) => non_neg_integer()}) :: %{optional(any()) => non_neg_integer()}
  def count_by_entry([], result_map), do: result_map
  def count_by_entry([entry | tail], result_map) do
    count_by_entry(tail, Map.update(result_map, entry, 1, fn acc -> acc + 1 end))
  end

  @spec neighbours_with_state(StateSet.t, State.t) :: non_neg_integer()
  def neighbours_with_state(neighbourhood, state) do
    count_entries_with_value(Map.values(neighbourhood), state)
  end

  @spec count_entries_with_value([any()], any()) :: non_neg_integer()
  def count_entries_with_value(list, entry_to_count) do
    Enum.count(list, fn
      ^entry_to_count -> true
      _ -> false
    end)
  end

end
