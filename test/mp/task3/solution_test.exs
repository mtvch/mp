defmodule Mp.Task3.SolutionTest do
  use ExUnit.Case
  alias Mp.Task3.Solution
  doctest Solution, import: true

  test "Сравнение скорости работы реализаций" do
    f = fn x ->
      :timer.sleep(100)
      rem(x, 2) == 0
    end

    items = 1..50 |> Enum.to_list()

    {t1, _res} = :timer.tc(fn -> Solution.parallel_filter(items, f) end, :second)
    IO.puts("Parallel impl time: #{t1} seconds")

    {t2, _res} =
      :timer.tc(fn -> Solution.parallel_filter_stream(1..50, f) |> Enum.take(50) end, :second)

    IO.puts("Parallel stream impl time: #{t2} seconds")

    {t3, _res} = :timer.tc(fn -> Enum.filter(items, f) end, :second)
    IO.puts("Default impl time: #{t3} seconds")

    assert t1 < t3 and t2 < t3

    # Вот результаты на моем пк

    # Parallel impl time: 0 seconds
    # Parallel stream impl time: 0 seconds
    # Default impl time: 5 seconds
  end

  test "Parallel stream impl" do
    stream = Stream.iterate(1, &(&1 + 1))
    assert %Stream{} = stream = Solution.parallel_filter_stream(stream, &(rem(&1, 2) == 0))
    assert [2, 4, 6, 8, 10, 12, 14, 16, 18, 20] == Enum.take(stream, 10)
  end
end
