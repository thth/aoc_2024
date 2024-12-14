defmodule Fourteen do
  @width 101
  @length 103

  def part_one(input) do
    input
    |> parse()
    |> Stream.iterate(&step/1)
    |> Enum.at(100)
    |> safety_factor()
  end

  def part_two(input) do
    starting_robots = parse(input)

    period =
      Stream.iterate({starting_robots, MapSet.new()}, fn {robots, seen} -> {step(robots), MapSet.put(seen, robots)} end)
      |> Enum.find_index(fn {robots, seen} -> MapSet.member?(seen, robots) end)

    starting_robots
    |> Stream.iterate(&step/1)
    |> Enum.take(period)
    |> Enum.with_index()
    |> Enum.max_by(fn {robots, _} -> count_has_neighbors(robots) end)
    |> then(fn {robots, i} ->
      IO.puts(draw(robots))
      i
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      Regex.scan(~r/[\d\-]+/, line)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(fn [x, y, dx, dy] -> {{x, y}, {dx, dy}} end)
  end

  defp step(robots), do: step(robots, [])
  defp step([], new), do: new
  defp step([{{x, y}, {dx, dy}} | rest], new) do
    new_x = if rem(x + dx, @width) < 0, do: @width + rem(x + dx, @width), else: rem(x + dx, @width)
    new_y = if rem(y + dy, @length) < 0, do: @length + rem(y + dy, @length), else: rem(y + dy, @length)
    step(rest, [{{new_x, new_y}, {dx, dy}} | new])
  end

  defp safety_factor(robots) do
    x_mid = div(@width, 2)
    y_mid = div(@length, 2)
    Enum.reduce(robots, [0, 0, 0, 0], fn
      {{x, y}, _}, [a, b, c, d] when x < x_mid and y < y_mid -> [a + 1, b, c, d]
      {{x, y}, _}, [a, b, c, d] when x < x_mid and y > y_mid -> [a, b + 1, c, d]
      {{x, y}, _}, [a, b, c, d] when x > x_mid and y < y_mid -> [a, b, c + 1, d]
      {{x, y}, _}, [a, b, c, d] when x > x_mid and y > y_mid -> [a, b, c, d + 1]
      _, acc -> acc
    end)
    |> Enum.product()
  end

  defp count_has_neighbors(robots) do
    positions = Enum.map(robots, &elem(&1, 0)) |> MapSet.new()
    Enum.count(positions, fn pos ->
      neighbors(pos)
      |> Enum.any?(&MapSet.member?(positions, &1))
    end)
  end

  defp neighbors({x, y}) do
    [{x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1}, {x - 1, y}, {x + 1, y}, {x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}]
  end

  defp draw(robots) do
    positions = Enum.map(robots, fn {pos, _} -> pos end)
    Enum.reduce(0..@length, "", fn y, acc ->
      Enum.reduce(0..@width, acc, fn x, line_acc ->
        if {x, y} in positions, do: line_acc <> "@", else: line_acc <> "."
      end) <> "\n"
    end)
  end
end

input = File.read!("input/14.txt")

input |> Fourteen.part_one() |> IO.inspect(label: "part 1")
input |> Fourteen.part_two() |> IO.inspect(label: "part 2")
