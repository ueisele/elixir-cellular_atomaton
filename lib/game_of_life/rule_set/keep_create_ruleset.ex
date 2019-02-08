defmodule GameOfLife.RuleSet.KeepCreateRuleSet do
  alias CellularAtomaton.Cell
  alias GameOfLife.StateSet
  alias GameOfLife.State

  

  @spec ruleset() ::
          {%{alive: [{any(), any()}, ...], dead: [{any(), any()}, ...]}, [{:default, :dead}, ...]}
  def ruleset() do
    {%{:alive => [
        {%{:alive => 2}, :alive},
        {%{:alive => 3}, :alive}
      ],
      :dead => [
        {%{:alive => 3}, :alive}
      ]
    },
    default: :dead}
  end

end
