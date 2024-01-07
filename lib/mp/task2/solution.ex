defmodule Mp.Task2.Solution do
  @moduledoc """
  Решение 2-го задания
  """
  alias Mp.Task2.CachingStream
  # Нижняя граница
  @default_step 0.1
  @epsilon 0.01
  @precision 2

  use Memoize

  @doc """
  Оператор интегрирования.
  Принимает аргументом функцию `f` от одной переменной и
  возвращают функцию одной переменной, вычисляющую (численно) выражение:
  Интеграл от 0 до x f(t)dt
  """
  def integration_op(f) do
    fn x when x > 0 ->
      integrate(f, x)
    end
  end

  @doc """
  Оператор интегрирования с мемоизацией.

  При вызове полученной функции многократно, внутренняя функция будет вызываться только один раз в каждой точке
  """
  def memoized_integration_op(f) do
    fn x when x > 0 ->
      f = memoize(f)
      integrate(f, x)
    end
  end

  @doc """
  Оператор интегрирования с оптимизацией бесконечной последовательности частичных решений.

  При вызове полученной функции многократно, внутренняя функция будет вызываться только один раз в каждой точке
  """
  def stream_integration_op(f) do
    fn x ->
      stream_integrate(f, x)
    end
  end

  @doc """
  Считает интеграл от `нуля` до `x` для функции `f` с использованием бесконечной последовательности
  частичных решений

  ## Примеры
  iex> stream_integrate(fn x -> x * x end, 1, 0.1)
  0.33
  iex> stream_integrate(fn x -> x * x end, 2, 0.1)
  2.67
  iex> stream_integrate(fn x -> x * x end, 0, 0.01)
  0.0
  """
  def stream_integrate(f, x, step \\ @default_step) do
    n = round(x / step)

    if n == 0 do
      0.0
    else
      s = get_cached_stream(f) || integration_stream(f, step)
      {s, {_point, res}} = CachingStream.nth(s, n)
      cache_stream(f, s)
      Float.round(res, @precision)
    end
  end

  defp integration_stream(f, step) do
    CachingStream.iterate({0, 0}, fn {point, sum} ->
      {point + step, sum + step * (f.(point) + f.(point + step)) / 2}
    end)
  end

  @doc """
  Считает интеграл от `нуля` до `x` для функции `f`

  ## Примеры
  iex> integrate(fn x -> x * x end, 1, 0.1)
  0.33
  iex> integrate(fn x -> x * x end, 2, 0.1)
  2.67
  iex> integrate(fn x -> x * x end, 0, 0.01)
  0.0
  """
  def integrate(f, x, step \\ @default_step) when x >= 0 do
    res = step * do_integrate(f, step, step, x, f.(0) / 2)
    Float.round(res, @precision)
  end

  # Последнее слагаемое
  defp do_integrate(f, point, _step, x, sum) when point > x - @epsilon do
    sum + f.(point) / 2
  end

  # Основные слагаемые
  defp do_integrate(f, point, step, x, sum) do
    do_integrate(f, point + step, step, x, sum + f.(point))
  end

  defp memoize(f) do
    fn x ->
      memoize_apply(f, x)
    end
  end

  defmemop memoize_apply(f, x) do
    f.(x)
  end

  # Самая простая реализация кэширования - в памяти процесса
  defp cache_stream(fun, stream) do
    Process.put(fun, stream)
  end

  defp get_cached_stream(fun) do
    Process.get(fun)
  end
end
