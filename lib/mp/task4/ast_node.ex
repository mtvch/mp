defprotocol Mp.Task4.AstNode do
  @moduledoc """
  Протокол, который должны реализовать элементы AST дерева выражения
  """
  alias Mp.Task4.AstNode

  @doc """
  Вычисление значения элемента
  """
  @spec eval(AstNode.t(), map()) :: {:ok, any()} | {:error, atom()}
  def eval(node, bindings)

  @doc """
  Преобразование данных в строку
  """
  @spec to_str(AstNode.t()) :: binary()
  def to_str(node)

  @doc """
  Приоритет операции. Чем меньше значение, тем выше приоритет
  """
  @spec priority(AstNode.t()) :: integer()
  def priority(node)
end
