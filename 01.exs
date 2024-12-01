defmodule One do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(&Enum.sort/1)
    |> Enum.zip()
    |> Enum.map(fn {x, y} -> abs(x - y) end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> then(fn [left, right] ->
      Enum.reduce(left, 0, fn x, acc ->
        x * Enum.count(right, &(&1 == x)) + acc
      end)
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end
end

input = File.read!("input/01.txt")

input |> One.part_one() |> IO.inspect(label: "part 1")
input |> One.part_two() |> IO.inspect(label: "part 2")
