defmodule Eleven do
  def part_one(input) do
    input
    |> parse()
    |> Enum.frequencies()
    |> run(25)
    |> Map.values()
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.frequencies()
    |> run(75)
    |> Map.values()
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  defp run(stones, 0), do: stones
  defp run(stones, n) do
    blink(stones)
    |> run(n - 1)
  end

  defp blink(stones) do
    Enum.reduce(stones, %{}, fn
      {0, n}, acc ->
        Map.update(acc, 1, n, &(&1 + n))
      {stone, n}, acc ->
        digits = trunc(:math.log10(stone)) + 1
        if (rem(digits, 2)) == 0 do
          half = div(digits, 2)
          divisor = :math.pow(10, half) |> round()

          acc
          |> Map.update(rem(stone, divisor), n, &(&1 + n))
          |> Map.update(div(stone, divisor), n, &(&1 + n))
        else
          Map.update(acc, stone * 2024, n, &(&1 + n))
        end
    end)
  end
end

input = File.read!("input/11.txt")

input |> Eleven.part_one() |> IO.inspect(label: "part 1")
input |> Eleven.part_two() |> IO.inspect(label: "part 2")
