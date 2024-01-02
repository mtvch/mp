defmodule Mp.Task4.Solution do
  @moduledoc """
  Решение задачи 4
  """
  alias Mp.Task4.AstNode
  alias Mp.Task4.Interpreter
  alias Mp.Task4.Parser
  alias Mp.Task4.Transform

  @doc """
  Вычисляет значение логического выражения и возвращает его представление в ДНФ

  ## Параметры:
  `expression` - строка, логическое выражение
  `bindings` - Мапа, ключи - название переменных, значения - значения переменных
  """
  @spec run(binary(), map()) :: {:ok, %{result: integer(), dnf: binary()}} | {:error, atom()}
  def run(expression, bindings) do
    with {:ok, ast} <- Parser.parse(expression),
         {:ok, res} <- Interpreter.run(ast, bindings) do
      {:ok, %{result: res, dnf: ast |> Transform.to_dnf() |> AstNode.to_str()}}
    end
  end
end
