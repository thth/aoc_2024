defmodule Three do
  def part_one(input) do
    input
    |> parse()
    |> then(&Regex.scan(~r/mul\((\d+)\,(\d+)\)/, &1))
    |> Enum.map(fn [_, x, y] ->
      String.to_integer(x) * String.to_integer(y)
    end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> String.replace(~r/don't\(\).*?do\(\)/, "🐸")
    |> part_one()
  end

  defp parse(text) do
    text
    |> String.replace(~r/\R/, "")
  end
end

input = File.read!("input/03.txt")

input |> Three.part_one() |> IO.inspect(label: "part 1")
input |> Three.part_two() |> IO.inspect(label: "part 2")
