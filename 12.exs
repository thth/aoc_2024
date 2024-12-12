defmodule Twelve do
  def part_one(input) do
    input
    |> parse()
    |> list_regions()
    |> Enum.map(&(perimeter(&1) * length(&1)))
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> list_regions()
    |> Enum.map(&(sides(&1) * length(&1)))
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, x}, line_acc -> Map.put(line_acc, {x, y}, c) end)
    end)
  end

  defp list_regions(map), do: list_regions(Map.keys(map), [], map)
  defp list_regions([], regions, _), do: regions
  defp list_regions([plot | _] = plots, regions, map) do
    region = traverse(plot, map)
    list_regions(plots -- region, [region | regions], map)
  end

  defp traverse(plot, map), do: traverse([plot], map[plot], [plot], [], map)
  defp traverse([], _, _, region, _), do: region
  defp traverse([plot | rest], plant, seen, region, map) do
    nexts =
      adj(plot)
      |> Enum.map(&({&1, map[&1]}))
      |> Enum.reduce([], fn
        {pos, ^plant}, acc -> [pos | acc]
        _, acc -> acc
      end)
    traverse((nexts -- seen) ++ rest, plant, adj(plot) ++ seen, [plot | region], map)
  end

  defp adj({x, y}), do: [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]

  defp perimeter(region) do
    Enum.reduce(region, 0, fn plot, acc ->
      acc + Enum.count(adj(plot), &(&1 in region == false))
    end)
  end

  defp sides(region) do
    region
    |> Enum.reduce([], fn plot, acc ->
      adj(plot)
      |> Enum.reject(&(&1 in region))
      |> Enum.map(&{plot, &1})
      |> Kernel.++(acc)
    end)
    |> count_sides()
  end

  defp count_sides(pairs), do: count_horizontal(pairs) + count_vertical(pairs)
  defp count_horizontal(pairs) do
    pairs
    |> Enum.filter(fn {{ax, _}, {bx, _}} -> ax == bx end)
    |> Enum.sort_by(fn {{x, _}, _} -> x end)
    |> count_horizontal([])
  end
  defp count_horizontal([], groups), do: length(groups)
  defp count_horizontal([{{x, ay}, {x, by}} | _] = pairs, groups) do
    side =
      Stream.iterate(0, &(&1 + 1))
      |> Stream.map(&{{x + &1, ay}, {x + &1, by}})
      |> Enum.take_while(&(&1 in pairs))
    count_horizontal(pairs -- side, [side | groups])
  end

  defp count_vertical(pairs) do
    pairs
    |> Enum.filter(fn {{_, ay}, {_, by}} -> ay == by end)
    |> Enum.sort_by(fn {{_, y}, _} -> y end)
    |> count_vertical([])
  end
  defp count_vertical([], groups), do: length(groups)
  defp count_vertical([{{ax, y}, {bx, y}} | _] = pairs, groups) do
    side =
      Stream.iterate(0, &(&1 + 1))
      |> Stream.map(&{{ax, y + &1}, {bx, y + &1}})
      |> Enum.take_while(&(&1 in pairs))
    count_vertical(pairs -- side, [side | groups])
  end
end

input = File.read!("input/12.txt")

input |> Twelve.part_one() |> IO.inspect(label: "part 1")
input |> Twelve.part_two() |> IO.inspect(label: "part 2")
