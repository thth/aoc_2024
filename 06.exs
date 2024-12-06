defmodule Six do
  defmodule State do
    defstruct obstacles: MapSet.new(), pos: nil, dir: nil, max_x: nil, max_y: nil, visited: MapSet.new(), pasts: MapSet.new()
  end

  def part_one(input) do
    input
    |> parse()
    |> run()
    |> Map.get(:visited)
    |> MapSet.size()
  end

  def part_two(input) do
    input
    |> parse()
    |> count_loops()
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
        {".", _}, state -> state
        {"#", x}, state -> %State{state | obstacles: MapSet.put(state.obstacles, {x, y})}
        {dir, x}, state -> %State{state | pos: {x, y}, dir: dir}
      end)
    end)
    |> then(fn state ->
      %State{state |
        max_x: Enum.max_by(state.obstacles, &elem(&1, 0)) |> elem(0),
        max_y: Enum.max_by(state.obstacles, &elem(&1, 1)) |> elem(1),
      }
    end)
  end

  defp run(%State{pos: {px, py}, max_x: mx, max_y: my} = state) when px < 0 or px > mx or py < 0 or py > my, do: state
  defp run(state) do
    {new_pos, new_dir} = next(state.pos, state.dir, state.obstacles)
    new_state = %State{state |
      pos: new_pos,
      dir: new_dir,
      visited: MapSet.put(state.visited, state.pos)
    }
    run(new_state)
  end

  defp next({x, y}, "^", obstacles), do: (if MapSet.member?(obstacles, {x, y - 1}), do: {{x, y}, ">"}, else: {{x, y - 1}, "^"})
  defp next({x, y}, "v", obstacles), do: (if MapSet.member?(obstacles, {x, y + 1}), do: {{x, y}, "<"}, else: {{x, y + 1}, "v"})
  defp next({x, y}, "<", obstacles), do: (if MapSet.member?(obstacles, {x - 1, y}), do: {{x, y}, "^"}, else: {{x - 1, y}, "<"})
  defp next({x, y}, ">", obstacles), do: (if MapSet.member?(obstacles, {x + 1, y}), do: {{x, y}, "v"}, else: {{x + 1, y}, ">"})

  defp count_loops(state) do
    run(state)
    |> Map.get(:visited)
    |> MapSet.delete(state.pos)
    |> Enum.count(&loops?(%State{state | obstacles: MapSet.put(state.obstacles, &1)}))
  end

  defp loops?(%State{pos: {px, py}, max_x: max_x, max_y: max_y}) when px < 0 or px > max_x or py < 0 or py > max_y, do: false
  defp loops?(state) do
    {new_pos, new_dir} = next(state.pos, state.dir, state.obstacles)
    if MapSet.member?(state.pasts, {new_pos, new_dir}) do
      true
    else
      new_state = %State{state |
        pos: new_pos,
        dir: new_dir,
        pasts: MapSet.put(state.pasts, {new_pos, new_dir})
      }
      loops?(new_state)
    end
  end
end

input = File.read!("input/06.txt")

input |> Six.part_one() |> IO.inspect(label: "part 1")
input |> Six.part_two() |> IO.inspect(label: "part 2")
