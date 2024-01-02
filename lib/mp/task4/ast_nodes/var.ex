defmodule Mp.Task4.AstNodes.Var do
  @moduledoc """
  Переменная
  """
  defstruct [:name]

  alias Mp.Task4.AstNode
  alias Mp.Task4.AstNodes.Var

  defimpl AstNode, for: Var do
    def priority(_node), do: 0

    def eval(%Var{name: name}, bindings) when is_binary(name) do
      case bindings do
        %{^name => val} when val in [0, 1] -> val
        _other -> {:error, {:var_not_defined, name}}
      end
    end

    def to_str(%Var{name: name}) when is_binary(name), do: name
  end
end
