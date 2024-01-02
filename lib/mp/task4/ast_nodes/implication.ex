defmodule Mp.Task4.AstNodes.Implication do
  @moduledoc """
  Логическая операция "Импликация" ("->")
  """
  defstruct [:a, :b]

  alias Mp.Task4.AstNode
  alias Mp.Task4.AstNodes.Implication

  defimpl AstNode, for: Implication do
    def priority(_node), do: 4

    def eval(%Implication{a: a, b: b}, bindings) do
      case {AstNode.eval(a, bindings), AstNode.eval(b, bindings)} do
        {1, 0} -> 0
        {{:error, _error} = error, _other} -> error
        {_other, {:error, _error} = error} -> error
        _other -> 1
      end
    end

    def to_str(%Implication{a: a, b: b} = _impl_op) do
      "#{AstNode.to_str(a)} -> #{AstNode.to_str(b)}"
    end
  end
end
