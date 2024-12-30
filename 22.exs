defmodule TwentyTwo do
  import Bitwise

  def part_one(input) do
    input
    |> parse()
    |> Enum.map(fn n ->
      Stream.iterate(n, &step/1)
      |> Enum.at(2000)
    end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(fn n ->
      Stream.iterate(n, &step/1)
      |> Enum.take(2000)
      |> Enum.map(&rem(&1, 10))
      |> Enum.chunk_every(5, 1, :discard)
      |> Enum.map(fn sequence ->
        key =
          sequence
          |> Enum.chunk_every(2, 1, :discard)
          |> Enum.map(fn [a, b] -> b - a end)
        {key, List.last(sequence)}
      end)
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        Map.put_new(acc, k, v)
      end)
    end)
    |> Enum.reduce(%{}, fn m, acc ->
      Map.merge(acc, m, fn _, v1, v2 -> v1 + v2 end)
    end)
    |> Enum.max_by(&elem(&1, 1))
    |> elem(1)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(&String.to_integer/1)
  end

  defp step(n) do
    n
    |> then(fn s ->
      s
      |> Kernel.*(64)
      |> mix(s)
      |> prune()
    end)
    |> then(fn s ->
      s
      |> div(32)
      |> mix(s)
      |> prune()
    end)
    |> then(fn s ->
      s
      |> Kernel.*(2048)
      |> mix(s)
      |> prune()
    end)
  end

  defp mix(a, b), do: bxor(a, b)
  defp prune(a), do: rem(a, 16777216)
end

input = File.read!("input/22.txt")

input |> TwentyTwo.part_one() |> IO.inspect(label: "part 1")
input |> TwentyTwo.part_two() |> IO.inspect(label: "part 2")
