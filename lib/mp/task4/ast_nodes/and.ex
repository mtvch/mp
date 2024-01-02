defmodule Mp.Task4.AstNodes.And do
  @moduledoc """
  Логическая операция "И" ("&")
  """
  defstruct [:a, :b]

  alias Mp.Task4.AstNode
  alias Mp.Task4.AstNodes.And

  defimpl AstNode, for: And do
    def priority(_node), do: 2

    def eval(%And{a: a, b: b}, bindings) do
      case {AstNode.eval(a, bindings), AstNode.eval(b, bindings)} do
        {1, 1} -> 1
        {{:error, _error} = error, _other} -> error
        {_other, {:error, _error} = error} -> error
        _other -> 0
      end
    end

    def to_str(%And{a: a, b: b} = and_op) do
      "#{do_to_str(a, and_op)} & #{do_to_str(b, and_op)}"
    end

    defp do_to_str(arg, and_op) do
      if AstNode.priority(arg) > priority(and_op) do
        "(#{AstNode.to_str(arg)})"
      else
        AstNode.to_str(arg)
      end
    end
  end
end
