defmodule Ten do
  def part_one(input) do
    map = parse(input)

    map
    |> Enum.filter(fn {_, h} -> h == 0 end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&score(&1, map))
    |> Enum.sum()
  end

  def part_two(input) do
    map = parse(input)

    map
    |> Enum.filter(fn {_, h} -> h == 0 end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&rating(&1, map))
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
      |> Enum.reduce(acc, fn {h, x}, line_acc -> Map.put(line_acc, {x, y}, String.to_integer(h)) end)
    end)
  end

  defp score(pos, map), do: score([pos], map, MapSet.new())
  defp score([], _, peaks), do: MapSet.size(peaks)
  defp score([pos | rest], map, peaks) do
    case map[pos] do
      8 ->
        new_peaks =
          adj(pos)
          |> Enum.map(fn p -> {p, map[p]} end)
          |> Enum.filter(fn
            {_, nil} -> false
            {_, 9} -> true
            _ -> false
          end)
          |> Enum.map(&elem(&1, 0))
          |> MapSet.new()

        score(rest, map, MapSet.union(peaks, new_peaks))
      pos_h ->
        next_coords =
          adj(pos)
          |> Enum.map(fn p -> {p, map[p]} end)
          |> Enum.filter(fn
            {_, nil} -> false
            {_, h} when pos_h + 1 == h -> true
            _ -> false
          end)
          |> Enum.map(&elem(&1, 0))

        score(next_coords ++ rest, map, peaks)
    end
  end

  defp adj({x, y}), do: [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]

  defp rating(pos, map), do: rating([pos], map, 0)
  defp rating([], _, n_trails), do: n_trails
  defp rating([pos | rest], map, n_trails) do
    case map[pos] do
      8 ->
        n_new =
          adj(pos)
          |> Enum.map(fn p -> {p, map[p]} end)
          |> Enum.filter(fn
            {_, nil} -> false
            {_, 9} -> true
            _ -> false
          end)
          |> Enum.map(&elem(&1, 0))
          |> length()

        rating(rest, map, n_trails + n_new)
      pos_h ->
        next_coords =
          adj(pos)
          |> Enum.map(fn p -> {p, map[p]} end)
          |> Enum.filter(fn
            {_, nil} -> false
            {_, h} when pos_h + 1 == h -> true
            _ -> false
          end)
          |> Enum.map(&elem(&1, 0))

        rating(next_coords ++ rest, map, n_trails)
    end
  end
end

input = File.read!("input/10.txt")

input |> Ten.part_one() |> IO.inspect(label: "part 1")
input |> Ten.part_two() |> IO.inspect(label: "part 2")
