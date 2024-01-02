defmodule Mp.Task4.AstNodes.Not do
  @moduledoc """
  Логическая операция "Отрицание" ("!")
  """
  defstruct [:x]

  alias Mp.Task4.AstNode
  alias Mp.Task4.AstNodes.Not

  defimpl AstNode, for: Not do
    def priority(_node), do: 1

    def eval(%Not{x: x}, bindings) do
      case AstNode.eval(x, bindings) do
        0 -> 1
        1 -> 0
        error -> error
      end
    end

    def to_str(%Not{x: x} = not_op) do
      if AstNode.priority(x) > priority(not_op) do
        "!(#{AstNode.to_str(x)})"
      else
        "!" <> AstNode.to_str(x)
      end
    end
  end
end
