defmodule TwentyThree do
  def part_one(input) do
    input
    |> parse()
    |> Enum.reduce(%{}, fn {a, b}, acc ->
      acc
      |> Map.update(a, MapSet.new([b]), &MapSet.put(&1, b))
      |> Map.update(b, MapSet.new([a]), &MapSet.put(&1, a))
    end)
    |> triples()
    |> Enum.count(&Enum.any?(&1, fn x -> String.first(x) == "t" end))
  end

  def part_two(input) do
    conn_map =
      input
      |> parse()
      |> Enum.reduce(%{}, fn {a, b}, acc ->
        acc
        |> Map.update(a, MapSet.new([b]), &MapSet.put(&1, b))
        |> Map.update(b, MapSet.new([a]), &MapSet.put(&1, a))
      end)

    conn_map
    |> triples()
    |> Stream.iterate(fn set ->
      next = wumbo(set, conn_map)
      IO.inspect(MapSet.size(next))
      next
    end)
    |> Enum.find(&MapSet.size(&1) == 1)
    |> Enum.sort()
    |> Enum.join(",")
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      String.split(line, "-")
      |> List.to_tuple()
    end)
  end

  defp triples(map), do: triples(Enum.to_list(map), MapSet.new())
  defp triples([_], acc), do: acc
  defp triples([{x, x_conns} | rest], acc) do
    new_acc =
      Enum.reduce(x_conns, acc, fn y, acc2 ->
        case Enum.find(rest, fn {k, _} -> k == y end) do
          nil -> acc2
          {^y, y_conns} ->
            MapSet.intersection(x_conns, y_conns)
            |> Enum.map(&MapSet.new([x, y, &1]))
            |> Enum.reduce(acc2, fn triple, acc3 -> MapSet.put(acc3, triple) end)
        end
      end)
    triples(rest, new_acc)
  end

  defp wumbo(groups, conns), do: wumbo(Enum.to_list(groups), conns, MapSet.new())
  defp wumbo([_], _, acc), do: acc
  defp wumbo([g1 | rest], conns, acc) do
    new_acc =
      Enum.reduce(rest, acc, fn g2, acc2 ->
        with gu <- MapSet.union(g1, g2),
             true <- MapSet.size(gu) == MapSet.size(g1) + 1,
             c1 <- MapSet.difference(gu, g2) |> Enum.at(0),
             c2 <- MapSet.difference(gu, g1) |> Enum.at(0),
             true <- conns[c1] |> MapSet.member?(c2) do
          MapSet.put(acc2, gu)
        else
          false -> acc2
        end
      end)
    wumbo(rest, conns, new_acc)
  end
end

input = File.read!("input/23.txt")

input |> TwentyThree.part_one() |> IO.inspect(label: "part 1")
input |> TwentyThree.part_two() |> IO.inspect(label: "part 2")
