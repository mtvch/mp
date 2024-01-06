defmodule Mp.Task2.SolutionTest do
  use ExUnit.Case
  alias Mp.Task2.Solution
  doctest Solution, import: true

  test "All impls have same result" do
    f = fn x -> :math.exp(x) end

    memoized_int_op = Solution.memoized_integration_op(f)
    streamed_int_op = Solution.stream_integration_op(f)
    int_op = Solution.integration_op(f)

    Enum.each(1..5, fn i ->
      res_1 = int_op.(i)
      res_2 = memoized_int_op.(i)
      res_3 = streamed_int_op.(i)
      assert res_1 == res_2 and res_1 == res_3
    end)
  end

  test "compare memozied and default impl" do
    f = fn _x ->
      :timer.sleep(50)
      1
    end

    memoized_int_op = Solution.memoized_integration_op(f)
    streamed_int_op = Solution.stream_integration_op(f)
    int_op = Solution.integration_op(f)

    {t1, _res} = :timer.tc(fn -> Enum.each(1..5, fn i -> memoized_int_op.(i) end) end, :second)
    IO.puts("Memoization impl time: #{t1} seconds")

    {t2, _res} = :timer.tc(fn -> Enum.each(1..5, fn i -> streamed_int_op.(i) end) end, :second)
    IO.puts("Streamed impl time: #{t2} seconds")

    {t3, _res} = :timer.tc(fn -> Enum.each(1..5, fn i -> int_op.(i) end) end, :second)
    IO.puts("Default impl time: #{t3} seconds")

    assert t1 < t3 and t2 < t3

    # Вот результаты на моем пк

    # Memoization impl time: 2 seconds
    # Streamed impl time: 5 seconds
    # Default impl time: 8 seconds

    # Потоки работают медленнее мемоизации из-за использования списков.
    # Возможно, использование массивов сравняло бы ситуацию, но они не поддерживаются нативно
  end
end
