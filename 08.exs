defmodule Eight do
  def part_one(input) do
    {nodes_map, max_x, max_y} = parse(input)
    Enum.reduce(nodes_map, MapSet.new(), fn {_, coords}, acc ->
      MapSet.union(acc, antinodes(coords))
    end)
    |> Enum.reject(fn {x, y} -> x < 0 or x > max_x or y < 0 or y > max_y end)
    |> length()
  end

  def part_two(input) do
    {nodes_map, max_x, max_y} = parse(input)
    Enum.reduce(nodes_map, MapSet.new(), fn {_, coords}, acc ->
      MapSet.union(acc, resonants(coords, max_x, max_y))
    end)
    |> MapSet.size()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.with_index()
    |> Enum.reduce({%{}, 0, 0}, fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {".", x}, {line_acc, max_x, max_y} -> {line_acc, max(x, max_x), max(y, max_y)}
        {c, x}, {line_acc, max_x, max_y} -> {Map.update(line_acc, c, [{x, y}], fn nodes -> [{x, y} | nodes] end), max(x, max_x), max(y, max_y)}
      end)
    end)
  end

  defp antinodes(coords), do: antinodes(coords, MapSet.new())
  defp antinodes([_], antis), do: antis
  defp antinodes([{ax, ay} | rest], antis) do
    new_antis =
      Enum.reduce(rest, antis, fn {bx, by}, acc ->
        MapSet.put(acc, {bx - (ax - bx), by - (ay - by)})
        |> MapSet.put({ax - (bx - ax), ay - (by - ay)})
      end)
    antinodes(rest, new_antis)
  end

  defp resonants(coords, max_x, max_y), do: resonants(coords, max_x, max_y, MapSet.new())
  defp resonants([_], _, _, antis), do: antis
  defp resonants([{ax, ay} | rest], max_x, max_y, antis) do
    new_antis =
      Enum.reduce(rest, antis, fn {bx, by}, acc ->
        dx = ax - bx
        dy = ay - by

        side_1 =
          Stream.iterate(0, &(&1 + 1))
          |> Stream.map(fn n -> {ax + (n * dx), ay + (n * dy)} end)
          |> Enum.take_while(fn {x, y} -> not (x < 0 or x > max_x or y < 0 or y > max_y) end)
          |> MapSet.new()

        side_2 =
          Stream.iterate(0, &(&1 - 1))
          |> Stream.map(fn n -> {ax + (n * dx), ay + (n * dy)} end)
          |> Enum.take_while(fn {x, y} -> not (x < 0 or x > max_x or y < 0 or y > max_y) end)
          |> MapSet.new()

        MapSet.union(acc, side_1) |> MapSet.union(side_2)
      end)
    resonants(rest, max_x, max_y, new_antis)
  end
end

input = File.read!("input/08.txt")

input |> Eight.part_one() |> IO.inspect(label: "part 1")
input |> Eight.part_two() |> IO.inspect(label: "part 2")
