defmodule Mp.Task2.Solution do
  # Нижняя граница
  @default_step 0.01
  @precision 2

  # def integration_op(f) do
  #   fn x when x > @a ->
  #     b = find_next_grid_point(@a, @step, x)
  #     @step * (f.(b) / 2) + calc(f, Float.round(b - @step, @precision))
  #   end
  # end

  @doc """
  Считает интеграл от `нуля` до `x` для функции `f`

  ## Примеры
  iex> integration_sum(fn x -> x * x end, 1)
  0.33
  iex> integration_sum(fn x -> x * x end, 0)
  0.0
  """
  def integration_sum(f, x, step \\ @default_step) when x >= 0 do
    res = step * do_integration_sum(f, step, step, x, f.(0) / 2)
    Float.round(res, @precision)
  end

  defp do_integration_sum(f, point, _step, x, sum) when point >= x do
    sum + f.(point) / 2
  end

  defp do_integration_sum(f, point, step, x, sum) do
    do_integration_sum(f, point + step, step, x, sum + f.(point))
  end
end
