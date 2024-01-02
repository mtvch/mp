defmodule Mp.Task4.AstNodes.Const do
  @moduledoc """
  Константа: 0 или 1
  """
  defstruct [:value]

  alias Mp.Task4.AstNode
  alias Mp.Task4.AstNodes.Const

  defimpl AstNode, for: Const do
    def priority(_node), do: 0
    def eval(%Const{value: value}, _bindings) when value in [0, 1], do: value
    def to_str(%Const{value: value}) when value in [0, 1], do: to_string(value)
  end
end
