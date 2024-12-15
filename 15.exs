defmodule Fifteen do
  defmodule State do
    defstruct walls: MapSet.new(), boxes: nil, robot: nil
  end
  def part_one(input) do
    {state, dirs} = parse(input)
    run(state, dirs)
    |> gps()
  end

  def part_two(input) do
    {state, dirs} = parse_two(input)
    run_two(state, dirs)
    |> gps_two()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> then(fn [s, d] ->
      state =
        s
        |> String.split(~r/\R/)
        |> Enum.with_index()
        |> Enum.reduce(%State{boxes: MapSet.new()}, fn {line, y}, acc ->
          line
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.reduce(acc, fn
            {".", _}, line_acc -> line_acc
            {"#", x}, line_acc -> %{line_acc | walls: MapSet.put(line_acc.walls, {x, y})}
            {"O", x}, line_acc -> %{line_acc | boxes: MapSet.put(line_acc.boxes, {x, y})}
            {"@", x}, line_acc -> %{line_acc | robot: {x, y}}
          end)
        end)
      dirs = String.graphemes(d) |> Enum.reject(&(&1 =~ ~r/\R/))
      {state, dirs}
    end)
  end

  defp run(state, []), do: state
  defp run(state, ["^" | rest]), do: run(run_dir(state, {0, -1}), rest)
  defp run(state, ["v" | rest]), do: run(run_dir(state, {0, 1}), rest)
  defp run(state, ["<" | rest]), do: run(run_dir(state, {-1, 0}), rest)
  defp run(state, [">" | rest]), do: run(run_dir(state, {1, 0}), rest)

  defp run_dir(%{robot: r} = state, dir) do
    cond do
      MapSet.member?(state.walls, d(r, dir)) -> state
      MapSet.member?(state.boxes, d(r, dir)) ->
        Stream.iterate(1, &(&1 + 1))
        |> Enum.find_value(fn n ->
          cond do
            MapSet.member?(state.walls, d(r, dir, n)) -> state
            MapSet.member?(state.boxes, d(r, dir, n)) -> nil
            true -> %{state | robot: d(r, dir), boxes: state.boxes |> MapSet.delete(d(r, dir)) |> MapSet.put(d(r, dir, n))}
          end
        end)
      true -> %{state | robot: d(r, dir)}
    end
  end

  defp d({x, y}, {dx, dy}, n \\ 1), do: {x + (dx * n), y + (dy * n)}

  defp gps(%{boxes: boxes}) do
    boxes
    |> Enum.map(fn {x, y} -> x + (y * 100) end)
    |> Enum.sum()
  end

  defp parse_two(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> then(fn [s, d] ->
      state =
        s
        |> String.split(~r/\R/)
        |> Enum.with_index()
        |> Enum.reduce(%State{boxes: %{}}, fn {line, y}, acc ->
          line
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.reduce(acc, fn
            {".", _}, line_acc -> line_acc
            {"#", x}, line_acc -> %{line_acc | walls: line_acc.walls |> MapSet.put({x * 2, y}) |> MapSet.put({x * 2 + 1, y})}
            {"O", x}, line_acc -> %{line_acc | boxes: line_acc.boxes |> Map.put({x * 2, y}, {x * 2, y}) |> Map.put({x * 2 + 1, y}, {x * 2, y})}
            {"@", x}, line_acc -> %{line_acc | robot: {x * 2, y}}
          end)
        end)
      dirs = String.graphemes(d) |> Enum.reject(&(&1 =~ ~r/\R/))
      {state, dirs}
    end)
  end

  defp run_two(state, []), do: state
  defp run_two(state, ["^" | rest]), do: run_two(dir_two(state, {0, -1}), rest)
  defp run_two(state, ["v" | rest]), do: run_two(dir_two(state, {0, 1}), rest)
  defp run_two(state, ["<" | rest]), do: run_two(dir_two(state, {-1, 0}), rest)
  defp run_two(state, [">" | rest]), do: run_two(dir_two(state, {1, 0}), rest)

  defp dir_two(%{robot: r} = state, dir) do
    cond do
      MapSet.member?(state.walls, d(r, dir)) ->
        state
      box_id = state.boxes[d(r, dir)] ->
        [{b1, _}, {b2, _}] = Enum.filter(state.boxes, &(elem(&1, 1) == box_id))
        Stream.iterate([b1, b2], &next_boxes_pos(&1, dir, state))
        |> Enum.reduce_while(MapSet.new([box_id]), fn bps, acc ->
          cond do
            Enum.any?(bps, fn bp -> MapSet.member?(state.walls, d(bp, dir)) end) -> {:halt, state}
            Enum.all?(bps, fn bp -> state.boxes[d(bp, dir)] == nil or MapSet.member?(acc, state.boxes[d(bp, dir)]) end) ->
              ids =
                bps
                |> Enum.map(&(state.boxes[&1]))
                |> MapSet.new()
                |> MapSet.union(acc)
              {:halt, %{state |
                robot: d(r, dir),
                boxes: Enum.map(state.boxes, fn {pos, id} ->
                  (if MapSet.member?(ids, id), do: {d(pos, dir), id}, else: {pos, id})
                end) |> Enum.into(%{})
              }}
            true ->
              {:cont, Enum.map(bps, &(state.boxes[&1])) |> MapSet.new() |> MapSet.union(acc)}
          end
        end)
      true -> %{state | robot: d(r, dir)}
    end
  end

  defp next_boxes_pos(bps, dir, state) do
    next_ids =
      bps
      |> Enum.map(fn bp -> state.boxes[d(bp, dir)] end)
      |> Enum.filter(&(&1))
      |> Enum.uniq()
    state.boxes
    |> Enum.filter(&(elem(&1, 1) in next_ids))
    |> Enum.map(fn {p, _} -> p end)
  end

  defp gps_two(%{boxes: map}) do
    map
    |> Enum.group_by(fn {_, id} -> id end)
    |> Enum.map(fn {_id, dps} -> dps |> Enum.sort() |> List.first() |> elem(0) end)
    |> Enum.map(fn {x, y} -> x + (y * 100) end)
    |> Enum.sum()
  end
end

input = File.read!("input/15.txt")

input |> Fifteen.part_one() |> IO.inspect(label: "part 1")
input |> Fifteen.part_two() |> IO.inspect(label: "part 2")
