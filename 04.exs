defmodule Four do
  def part_one(input) do
    map = parse(input)
    {max_x, _} = Map.keys(map) |> Enum.max_by(fn {x, _} -> x end)
    {_, max_y} = Map.keys(map) |> Enum.max_by(fn {_, y} -> y end)
    for x <- 0..max_x,
        y <- 0..max_y do
      xmas({x, y}, map)
    end
    |> Enum.sum()
  end

  def part_two(input) do
    map = parse(input)
    {max_x, _} = Map.keys(map) |> Enum.max_by(fn {x, _} -> x end)
    {_, max_y} = Map.keys(map) |> Enum.max_by(fn {_, y} -> y end)
    for x <- 0..max_x,
        y <- 0..max_y do
      x_mas({x, y}, map)
    end
    |> Enum.count(&(&1))
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
      |> Enum.reduce(acc, fn {c, x}, line_acc ->
        Map.put(line_acc, {x, y}, c)
      end)
    end)
  end

  defp xmas({x, y}, map) do
    [:hf?, :hb?, :vf?, :vb?, :uf?, :ub?, :df?, :db?]
    |> Enum.map(fn f -> apply(__MODULE__, f, [{x, y}, map]) end)
    |> Enum.count(&(&1))
  end

  def hf?({x, y}, m), do: m[{x, y}] == "X" and m[{x + 1, y}] == "M" and m[{x + 2, y}] == "A" and m[{x + 3, y}] == "S"
  def hb?({x, y}, m), do: m[{x, y}] == "X" and m[{x - 1, y}] == "M" and m[{x - 2, y}] == "A" and m[{x - 3, y}] == "S"
  def vf?({x, y}, m), do: m[{x, y}] == "X" and m[{x, y + 1}] == "M" and m[{x, y + 2}] == "A" and m[{x, y + 3}] == "S"
  def vb?({x, y}, m), do: m[{x, y}] == "X" and m[{x, y - 1}] == "M" and m[{x, y - 2}] == "A" and m[{x, y - 3}] == "S"
  def uf?({x, y}, m), do: m[{x, y}] == "X" and m[{x + 1, y - 1}] == "M" and m[{x + 2, y - 2}] == "A" and m[{x + 3, y - 3}] == "S"
  def ub?({x, y}, m), do: m[{x, y}] == "X" and m[{x - 1, y + 1}] == "M" and m[{x - 2, y + 2}] == "A" and m[{x - 3, y + 3}] == "S"
  def df?({x, y}, m), do: m[{x, y}] == "X" and m[{x + 1, y + 1}] == "M" and m[{x + 2, y + 2}] == "A" and m[{x + 3, y + 3}] == "S"
  def db?({x, y}, m), do: m[{x, y}] == "X" and m[{x - 1, y - 1}] == "M" and m[{x - 2, y - 2}] == "A" and m[{x - 3, y - 3}] == "S"

  defp x_mas({x, y}, map) do
    [:u?, :d?, :l?, :r?]
    |> Enum.map(fn f -> apply(__MODULE__, f, [{x, y}, map]) end)
    |> Enum.any?(&(&1))
  end

  def u?({x, y}, m), do: m[{x, y}] == "A" and m[{x - 1, y - 1}] == "M" and m[{x + 1, y - 1}] == "M" and m[{x - 1, y + 1}] == "S" and m[{x + 1, y + 1}] == "S"
  def d?({x, y}, m), do: m[{x, y}] == "A" and m[{x - 1, y - 1}] == "S" and m[{x + 1, y - 1}] == "S" and m[{x - 1, y + 1}] == "M" and m[{x + 1, y + 1}] == "M"
  def l?({x, y}, m), do: m[{x, y}] == "A" and m[{x - 1, y - 1}] == "M" and m[{x + 1, y - 1}] == "S" and m[{x - 1, y + 1}] == "M" and m[{x + 1, y + 1}] == "S"
  def r?({x, y}, m), do: m[{x, y}] == "A" and m[{x - 1, y - 1}] == "S" and m[{x + 1, y - 1}] == "M" and m[{x - 1, y + 1}] == "S" and m[{x + 1, y + 1}] == "M"
end

input = File.read!("input/04.txt")

input |> Four.part_one() |> IO.inspect(label: "part 1")
input |> Four.part_two() |> IO.inspect(label: "part 2")
