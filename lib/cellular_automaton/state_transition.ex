defmodule CellularAtomaton.StateTransition do
  alias CellularAtomaton.Cell
  alias CellularAtomaton.StateSet
  alias CellularAtomaton.State

  @type t_neighbourhood :: StateSet.t

  @callback transfer({Cell.t, State.t}, t_neighbourhood) :: {Cell.t, State.t}

end
