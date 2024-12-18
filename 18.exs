defmodule Eighteen do
  @max 70

  def part_one(input) do
    input
    |> parse()
    |> Enum.take(1024)
    |> path()
  end

  def part_two(input) do
    input
    |> parse()
    |> Stream.transform([], fn x, acc -> {[[x | acc]], [x | acc]} end)
    |> Enum.find(&(path(&1) == :oh_no))
    |> then(fn [{x, y} | _] -> "#{x},#{y}" end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp path(obs), do: path(MapSet.new(obs), [{0, 0}], [], 0)
  defp path(_, [], [],  _), do: :oh_no
  defp path(obs, [], next, n), do: path(obs, next, [], n + 1)
  defp path(_, [{@max, @max} | _], _, n), do: n
  defp path(obs, [{x, y} | rest], next, n) do
    new_nexts =
      [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
      |> Enum.reject(fn {a, b} ->
        a < 0 or a > @max or b < 0 or b > @max or MapSet.member?(obs, {a, b})
      end)
    path(new_nexts |> MapSet.new() |> MapSet.union(obs), rest, new_nexts ++ next, n)
  end
end

input = File.read!("input/18.txt")

input |> Eighteen.part_one() |> IO.inspect(label: "part 1")
input |> Eighteen.part_two() |> IO.inspect(label: "part 2")
