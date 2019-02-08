defmodule CellularAtomaton.StateSet do
  alias CellularAtomaton.Cell
  alias CellularAtomaton.State

  @type t :: %{optional(Cell.t) => State.t}

end
