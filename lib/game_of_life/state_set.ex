defmodule GameOfLife.StateSet do
  alias CellularAtomaton.Cell
  alias GameOfLife.State

  @type t :: %{required(Cell.t) => State.t}

end
