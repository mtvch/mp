defmodule Mp.Task4.Interpreter do
  @moduledoc """
  Выполнение AST дерева - вычисление его значения
  """
  alias Mp.Task4.AstNode
  alias Mp.Task4.Parser

  @doc """
  Выполняет AST дерево.

  `bindings` - мапа значений переменных. Ключ - название переменной, значение - ее значение
  """
  @spec run(binary() | AstNode.t(), map()) :: {:ok, any()} | {:error, atom()}
  def run(str_or_ast, bindings \\ %{})

  def run(str, bindings) when is_binary(str) do
    case Parser.parse(str) do
      {:ok, ast} ->
        run(ast, bindings)

      error ->
        error
    end
  end

  def run(ast, bindings) do
    case AstNode.eval(ast, bindings) do
      res when res in [0, 1] -> {:ok, res}
      error -> error
    end
  end
end
