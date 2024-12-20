defmodule Twenty do
  defmodule State do
    defstruct s: nil, e: nil, walls: []
  end

  # can also do same thing as part 2 with manhattan distance <= 2
  def part_one(input) do
    %{s: s, e: e, walls: walls} = parse(input)
    memo = path(s, e, walls)
    {max_x, _} = Enum.max_by(walls, fn {x, _} -> x end)
    {_, max_y} = Enum.max_by(walls, fn {_, y} -> y end)
    walls
    |> Enum.reject(fn {x, y} -> x == 0 or y == 0 or x == max_x or y == max_y end)
    |> Enum.map(fn wall ->
      case adj(wall) |> Enum.map(&(memo[&1])) |> Enum.filter(&(&1)) do
        [] -> 0
        list -> max(Enum.max(list) - Enum.min(list) - 2, 0)
      end
    end)
    # |> Enum.frequencies()
    |> Enum.count(&(&1 >= 100))
  end

  def part_two(input) do
    %{s: s, e: e, walls: walls} = parse(input)
    memo = path(s, e, walls)
    memo
    |> Enum.sort_by(&elem(&1, 1), :desc)
    |> Enum.map(fn {pos, t} ->
      memo
      |> Enum.filter(fn {k, _} -> manhattan(pos, k) <= 20 end)
      |> Enum.map(fn {k, v} -> v - t - manhattan(pos, k) end)
      |> Enum.count(&(&1 >= 100))
    end)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.with_index()
    |> Enum.reduce(%State{}, fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {".", _}, line_acc -> line_acc
        {"#", x}, line_acc -> %{line_acc | walls: [{x, y} | line_acc.walls]}
        {"S", x}, line_acc -> %{line_acc | s: {x, y}}
        {"E", x}, line_acc -> %{line_acc | e: {x, y}}
      end)
    end)
  end

  defp path(s, e, walls), do: path(s, e, walls, %{s => 0}, 0)
  defp path(e, e, _, memo, _), do: memo
  defp path(p, e, walls, memo, t) do
    [next] = adj(p) |> Enum.reject(&(&1 in walls))
    path(next, e, [p | walls], Map.put(memo, next, t + 1), t + 1)
  end

  defp adj({x, y}), do: [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]

  defp manhattan({x, y}, {a, b}), do: abs(x - a) + abs(y - b)
end

input = File.read!("input/20.txt")

input |> Twenty.part_one() |> IO.inspect(label: "part 1")
input |> Twenty.part_two() |> IO.inspect(label: "part 2")
