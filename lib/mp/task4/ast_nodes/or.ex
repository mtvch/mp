defmodule Mp.Task4.AstNodes.Or do
  @moduledoc """
  Логическая операция "Или" ("|")
  """
  defstruct [:a, :b]

  alias Mp.Task4.AstNode
  alias Mp.Task4.AstNodes.Or

  defimpl AstNode, for: Or do
    def priority(_node), do: 3

    def eval(%Or{a: a, b: b}, bindings) do
      case {AstNode.eval(a, bindings), AstNode.eval(b, bindings)} do
        {0, 0} -> 0
        {{:error, _error} = error, _other} -> error
        {_other, {:error, _error} = error} -> error
        _other -> 1
      end
    end

    def to_str(%Or{a: a, b: b} = or_op) do
      "#{do_to_str(a, or_op)} | #{do_to_str(b, or_op)}"
    end

    defp do_to_str(arg, or_op) do
      if AstNode.priority(arg) > priority(or_op) do
        "(#{AstNode.to_str(arg)})"
      else
        AstNode.to_str(arg)
      end
    end
  end
end
