defmodule Sixteen do
  defmodule State do
    defstruct pos: nil, dir: {1, 0}, dest: nil, walls: MapSet.new()
  end
  def part_one(input) do
    input
    |> parse()
    |> lowest()
  end

  def part_two(input) do
    state = parse(input)
    lowest_score = lowest(state)
    path(state, lowest_score)
    |> Enum.reduce(MapSet.new(), fn p, acc -> p |> MapSet.new() |> MapSet.union(acc) end)
    |> MapSet.size()
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
        {"#", x}, line_acc -> %{line_acc | walls: MapSet.put(line_acc.walls, {x, y})}
        {"S", x}, line_acc -> %{line_acc | pos: {x, y}}
        {"E", x}, line_acc -> %{line_acc | dest: {x, y}}
      end)
    end)
  end

  defp lowest(state), do: lowest([{0, [state.pos], state.dir}], MapSet.new([{state.pos, state.dir}]), state.dest, state.walls)
  defp lowest([curr | rest], memo, dest, walls) do
    new_nexts =
      nexts(curr, walls)
      |> Enum.reject(fn {_, [pos | _], dir} -> MapSet.member?(memo, {pos, dir}) end)
    new_memo =
      new_nexts
      |> Enum.map(fn {_, [pos | _], dir} -> {pos, dir} end)
      |> MapSet.new()
      |> MapSet.union(memo)
    case Enum.find(new_nexts, fn {_, [pos | _], _} -> pos == dest end) do
      {score, _, _} -> score
      _ ->
        lowest(Enum.sort(new_nexts ++ rest), new_memo, dest, walls)
    end
  end

  defp nexts({score, [{x, y} | _] = p, {dx, dy}}, walls) do
    forward = if MapSet.member?(walls, {x + dx, y + dy}), do: [], else: [{score + 1, [{x + dx, y + dy} | p], {dx, dy}}]
    {{ldx, ldy}, {rdx, rdy}} =
      case {dx, dy} do
        {1, 0} -> {{0, -1}, {0, 1}}
        {-1, 0} -> {{0, 1}, {0, -1}}
        {0, 1} -> {{-1, 0}, {1, 0}}
        {0, -1} -> {{1, 0}, {-1, 0}}
      end
    left = if MapSet.member?(walls, {x + ldx, y + ldy}), do: [], else: [{score + 1001, [{x + ldx, y + ldy} | p], {ldx, ldy}}]
    right = if MapSet.member?(walls, {x + rdx, y + rdy}), do: [], else: [{score + 1001, [{x + rdx, y + rdy} | p], {rdx, rdy}}]
    forward ++ left ++ right
  end

  defp path(state, low), do: path([{0, [state.pos], state.dir}], %{{state.pos, state.dir} => 0}, MapSet.new(), low, state.dest, state.walls)
  defp path([], _memo, paths, _low, _dest, _walls), do: paths
  defp path([{score, _, _} | rest], memo, paths, low, dest, walls) when score > low, do: path(rest, memo, paths, low, dest, walls)
  defp path([curr | rest], memo, paths, low, dest, walls) do
    new_nexts =
      nexts(curr, walls)
      |> Enum.reject(fn {s, [pos | p_rest], d} ->
        (Map.has_key?(memo, {pos, d}) and memo[{pos, d}] < s) or (pos in p_rest)
      end)
    new_memo =
      new_nexts
      |> Enum.reduce(memo, fn {s, [pos | _], d}, acc ->
        Map.update(acc, {pos, d}, s, &(min(&1, s)))
      end)
    case Enum.find(new_nexts, fn {_, [pos | _], _} -> pos == dest end) do
      {^low, p, _} -> path(rest, new_memo, MapSet.put(paths, p), low, dest, walls)
      _ -> path(Enum.sort(new_nexts ++ rest), new_memo, paths, low, dest, walls)
    end
  end
end

input = File.read!("input/16.txt")

input |> Sixteen.part_one() |> IO.inspect(label: "part 1")
input |> Sixteen.part_two() |> IO.inspect(label: "part 2")
