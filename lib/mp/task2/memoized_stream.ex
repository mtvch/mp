defmodule Mp.Task2.MemoizedStream do
  @moduledoc false
  # В Elixir есть Stream для ленивых вычислений, но в них отсутствует оптимизация с запоминанием результата
  # Поэтому я добавил свою простую реализацию стрима на этот случай
  # Релизованы только возможности ленивых потоков, необходимые для выполнения задания.
  defstruct [:start_value, :next_f, :last_result, results: [], results_count: 0]

  @type t() :: %__MODULE__{
          start_value: any(),
          next_f: function(),
          # Результаты вычисления последовательности, чтобы при повторном обращении не производить вычисления
          results: [any()],
          # Для оптимизации, чтобы каждый раз не ходить в конец списка результатов
          last_result: any(),
          # Оптимизация, чтобы не вычислять каждый раз длину списка
          results_count: non_neg_integer()
        }

  @spec iterate(any(), function()) :: t()
  def iterate(start_value, next_f) when is_function(next_f) do
    %__MODULE__{start_value: start_value, next_f: next_f}
  end

  @spec nth(t(), non_neg_integer()) :: {t(), res :: any()}
  def nth(%__MODULE__{} = stream, n) when is_integer(n) and n > 0 do
    if stream.results_count < n do
      results =
        Enum.reduce((stream.results_count + 1)..n, [], fn _i, results ->
          last_result =
            cond do
              results == [] and stream.results == [] -> stream.start_value
              results == [] -> stream.last_result
              true -> hd(results)
            end

          [stream.next_f.(last_result) | results]
        end)

      last_result = hd(results)
      results = Enum.reverse(results)

      {%{stream | results: stream.results ++ results, results_count: n, last_result: last_result},
       last_result}
    else
      {stream, Enum.at(stream.results, n - 1)}
    end
  end
end
