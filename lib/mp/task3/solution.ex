defmodule Mp.Task3.Solution do
  @moduledoc """
  Решение 3-го задания
  """

  @doc """
  Параллельный фильтр

  ## Примеры
  iex> parallel_filter([1, 2, 3, 4], & rem(&1, 2) == 0)
  [2, 4]
  iex> parallel_filter([1, 2, 3, 4], & rem(&1, 2) == 0, 3)
  [2, 4]
  """
  def parallel_filter(items, filter_f, chunks_number \\ nil)
      when is_list(items) and is_function(filter_f) do
    chunks_number = chunks_number || System.schedulers_online()

    items
    |> length()
    |> get_chunk_sizes(chunks_number)
    |> Enum.reduce({[], items}, fn chunk_size, {tasks, items} ->
      chunk_items = Enum.take(items, chunk_size)
      task = Task.async(fn -> Enum.filter(chunk_items, filter_f) end)
      {[task | tasks], Enum.drop(items, chunk_size)}
    end)
    # Берем tasks из acc
    |> elem(0)
    |> Enum.reverse()
    |> Task.await_many()
    |> List.flatten()
  end

  @doc """
  Параллельный фильтра для стрима: принимает на вход ленивую последовательность и возвращает ленивую последовательность.
  """
  def parallel_filter_stream(stream, filter_f, chunk_size \\ nil) do
    chunk_size = chunk_size || System.schedulers_online()

    stream
    |> Stream.chunk_every(chunk_size)
    |> Stream.map(fn chunk_items ->
      Enum.map(chunk_items, &Task.async(fn -> {&1, filter_f.(&1)} end))
    end)
    |> Stream.map(&Task.await_many/1)
    |> Stream.flat_map(fn items ->
      Enum.filter(items, fn {_item, filter_res} -> filter_res end)
    end)
    |> Stream.map(&elem(&1, 0))
  end

  @doc """
  Распределяет элементы в количестве items_count на chunks_number групп.
  Возвращает список, где каждый элемент - кол-во элементов в соответственной группе.

  ## Примеры
  iex> get_chunk_sizes(8, 2)
  [4, 4]
  iex> get_chunk_sizes(6, 4)
  [2, 2, 1, 1]
  iex> get_chunk_sizes(2, 5)
  [1, 1, 0, 0, 0]
  iex> get_chunk_sizes(1, 1)
  [1]
  iex> get_chunk_sizes(0, 1)
  [0]
  """
  def get_chunk_sizes(items_count, chunks_number) do
    chunk_size = div(items_count, chunks_number)
    reminder = rem(items_count, chunks_number)

    1..chunks_number
    |> Enum.reduce({[], reminder}, fn _n, {chunks_sizes, reminder} ->
      if reminder > 0 do
        {[chunk_size + 1 | chunks_sizes], reminder - 1}
      else
        {[chunk_size | chunks_sizes], reminder}
      end
    end)
    # Берем chunk_sizes из acc
    |> elem(0)
    |> Enum.reverse()
  end
end
