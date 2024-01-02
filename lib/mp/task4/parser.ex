defmodule Mp.Task4.Parser do
  @moduledoc """
  Парсинг строки логического выражения в AST дерево
  """
  alias Mp.Task4.AstNode
  alias Mp.Task4.Parser.Grammar
  @peg Grammar.peg()

  @spec parse(binary()) :: {:ok, AstNode.t()} | {:error, :parsing_error}
  def parse(str) when is_binary(str) do
    case Xpeg.match(@peg, str) do
      %{result: :ok, captures: [ast]} -> {:ok, ast}
      %{result: :error} -> {:error, :parsing_error}
    end
  end
end
