defmodule Mp.Task4.Transform do
  @moduledoc """
  Функции для эквивалентных преобразований АСТ дерева
  """
  alias Mp.Task4.AstNode
  alias Mp.Task4.AstNodes.And
  alias Mp.Task4.AstNodes.Const
  alias Mp.Task4.AstNodes.Implication
  alias Mp.Task4.AstNodes.Not
  alias Mp.Task4.AstNodes.Or
  alias Mp.Task4.AstNodes.Var

  @doc """
  Пребразует АСТ дерево логического выражения в АСТ дерево его ДНФ
  """
  @spec to_dnf(AstNode.t()) :: AstNode.t()
  def to_dnf(ast) do
    ast
    |> remove_non_core_ops()
    |> move_not_to_vars()
    |> apply_distributive_law()
    |> normalize_conjunctions()
  end

  defp remove_non_core_ops(%Not{} = node) do
    %{node | x: remove_non_core_ops(node.x)}
  end

  defp remove_non_core_ops(%And{} = node) do
    %{node | a: remove_non_core_ops(node.a), b: remove_non_core_ops(node.b)}
  end

  defp remove_non_core_ops(%Or{} = node) do
    %{node | a: remove_non_core_ops(node.a), b: remove_non_core_ops(node.b)}
  end

  defp remove_non_core_ops(%Implication{} = node) do
    %Or{a: %Not{x: remove_non_core_ops(node.a)}, b: remove_non_core_ops(node.b)}
  end

  defp remove_non_core_ops(node), do: node

  defp move_not_to_vars(%Not{} = node) do
    case node.x do
      %And{a: a, b: b} -> %Or{a: move_not_to_vars(%Not{x: a}), b: move_not_to_vars(%Not{x: b})}
      %Or{a: a, b: b} -> %And{a: move_not_to_vars(%Not{x: a}), b: move_not_to_vars(%Not{x: b})}
      # remove duplicate nots
      %Not{x: x} -> move_not_to_vars(x)
      _var_or_const -> node
    end
  end

  defp move_not_to_vars(%{a: a, b: b} = node) do
    %{node | a: move_not_to_vars(a), b: move_not_to_vars(b)}
  end

  defp move_not_to_vars(node), do: node

  # defp remove_duplicate_nots(%Not{} = node) do
  #   case node.x do
  #     %Not{x: x} -> remove_duplicate_nots(x)
  #     x -> %{node | x: remove_duplicate_nots(x)}
  #   end
  # end

  # defp remove_duplicate_nots(%{a: a, b: b} = node) do
  #   %{node | a: remove_duplicate_nots(a), b: remove_duplicate_nots(b)}
  # end
  # defp remove_duplicate_nots(node), do: node

  defp apply_distributive_law(%And{a: a, b: b}) do
    case {a, b} do
      {%Or{a: a_1, b: b_1}, %Or{a: a_2, b: b_2}} ->
        %Or{
          a: %Or{
            a: apply_distributive_law(%And{a: a_1, b: a_2}),
            b: apply_distributive_law(%And{a: a_1, b: b_2})
          },
          b: %Or{
            a: apply_distributive_law(%And{a: a_2, b: b_1}),
            b: apply_distributive_law(%And{a: a_2, b: b_2})
          }
        }

      {%Or{a: a, b: b}, node} ->
        %Or{
          a: apply_distributive_law(%And{a: a, b: node}),
          b: apply_distributive_law(%And{a: b, b: node})
        }

      {node, %Or{a: a, b: b}} ->
        %Or{
          a: apply_distributive_law(%And{a: node, b: a}),
          b: apply_distributive_law(%And{a: node, b: b})
        }

      {a, b} ->
        %And{a: a, b: b}
    end
  end

  defp apply_distributive_law(%Or{a: a, b: b}) do
    %Or{a: apply_distributive_law(a), b: apply_distributive_law(b)}
  end

  defp apply_distributive_law(node), do: node

  defp normalize_conjunctions(node) do
    node
    # get list of lists. outer list - conjunctions, inner - list - elements
    |> get_conjunctions([])
    |> Enum.map(fn conjunction_elements ->
      conjunction_elements
      |> eval_consts()
      |> remove_duplicate_elements()
      |> remove_trues()
      |> case do
        [] ->
          [%Const{value: 1}]

        elements ->
          if has_false?(elements) or has_contradicts?(elements) do
            nil
          else
            order_vars_by_name(elements)
          end
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> remove_duplicate_conjunctions()
    |> conjunctions_to_ast()
  end

  # Or - collect list of lists - conjunctions
  defp get_conjunctions(%Or{a: a, b: b}, conjunctions) do
    conjunctions = get_conjunctions(a, conjunctions)
    get_conjunctions(b, conjunctions)
  end

  defp get_conjunctions(node, conjunctions) do
    [get_conjunction_elements(node, []) | conjunctions]
  end

  # And - collect list of conjunction elements
  defp get_conjunction_elements(%And{a: a, b: b}, conjunction_elements) do
    conjunction_elements = get_conjunction_elements(a, conjunction_elements)
    get_conjunction_elements(b, conjunction_elements)
  end

  # Not, Var, Const
  defp get_conjunction_elements(elem, conjunction_elements) do
    [elem | conjunction_elements]
  end

  defp eval_consts(conjunction_elements) do
    Enum.map(conjunction_elements, fn
      %Not{x: %Const{value: 0}} -> %Const{value: 1}
      %Not{x: %Const{value: 1}} -> %Const{value: 0}
      elem -> elem
    end)
  end

  defp remove_duplicate_elements(conjunction_elements) do
    # Пока не содержат мета информации - можно так
    Enum.uniq(conjunction_elements)
  end

  defp remove_trues(conjunction_elements) do
    Enum.filter(conjunction_elements, fn
      %Const{value: 1} -> false
      _elem -> true
    end)
  end

  defp has_false?(conjunction_elements) do
    if Enum.find(conjunction_elements, fn
         %Const{value: 0} -> true
         _elem -> false
       end) do
      true
    else
      false
    end
  end

  # На этом этапе уже нет констант
  defp has_contradicts?(conjunction_elements) do
    {positive_elements, negative_elements} =
      Enum.split_with(conjunction_elements, fn
        %Not{} -> false
        _elem -> true
      end)

    if Enum.find(positive_elements, fn %Var{name: name} ->
         Enum.find(negative_elements, fn %Not{x: var} -> var.name == name end)
       end) do
      true
    else
      false
    end
  end

  defp order_vars_by_name(conjunction_elements) do
    Enum.sort_by(conjunction_elements, fn
      %Not{x: var} -> var.name
      var -> var.name
    end)
  end

  defp remove_duplicate_conjunctions(conjunctions) do
    Enum.uniq(conjunctions)
  end

  defp conjunctions_to_ast([]), do: %Const{value: 0}

  defp conjunctions_to_ast([[elem]]) do
    elem
  end

  defp conjunctions_to_ast([[elem | conjunction_elements]]) do
    %And{a: elem, b: conjunction_elements_to_ast(conjunction_elements)}
  end

  defp conjunctions_to_ast([conjunction_elements | conjunctions]) do
    %Or{
      a: conjunction_elements_to_ast(conjunction_elements),
      b: conjunctions_to_ast(conjunctions)
    }
  end

  defp conjunction_elements_to_ast([conjunction_element]) do
    conjunction_element
  end

  defp conjunction_elements_to_ast([conjunction_element | elements]) do
    %And{a: conjunction_element, b: conjunction_elements_to_ast(elements)}
  end
end
