defmodule Thirteen do
  def part_one(input) do
    input
    |> parse()
    |> Enum.map(&solve/1)
    |> Enum.filter(&(&1))
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(fn {a, b, {x, y}} -> {a, b, {x + 10_000_000_000_000, y + 10_000_000_000_000}} end)
    |> Enum.map(&solve/1)
    |> Enum.filter(&(&1))
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> Enum.map(fn machine ->
      Regex.scan(~r/\d+/, machine)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(fn [ax, ay, bx, by, x, y] -> {{ax, ay}, {bx, by}, {x, y}} end)
  end

  defp solve({{ax, ay}, {bx, by}, {x, y}}) do
    na = ((y * bx) - (x * by)) / ((ay * bx) - (ax * by))
    nb = ((y * ax) - (x * ay)) / ((by * ax) - (bx * ay))
    if int?(na) and int?(nb) do
      trunc(na) * 3 + trunc(nb)
    else
      nil
    end
  end

  defp int?(float), do: float == (trunc(float) * 1.0)
end

input = File.read!("input/13.txt")

input |> Thirteen.part_one() |> IO.inspect(label: "part 1")
input |> Thirteen.part_two() |> IO.inspect(label: "part 2")
