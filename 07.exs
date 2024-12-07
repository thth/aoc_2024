defmodule Seven do
  def part_one(input) do
    input
    |> parse()
    |> Enum.filter(fn line -> valid?(line, [&Kernel.+/2, &Kernel.*/2]) end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.filter(fn line -> valid?(line, [&Kernel.+/2, &Kernel.*/2, &concat/2]) end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      Regex.scan(~r/\d+/, line)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.map(fn [result | nums] -> {result, nums} end)
  end

  defp valid?({result, nums}, fns), do: valid?(result, [nums], fns)
  defp valid?(_, [],  _), do: false
  defp valid?(result, [[result] | _], _), do: true
  defp valid?(result, [[_] | rest], fns), do: valid?(result, rest, fns)
  defp valid?(result, [[a, b | n_rest] | rest], fns) do
    nexts =
      fns
      |> Enum.map(&apply(&1, [a, b]))
      |> Enum.reject(&(&1 > result))
      |> Enum.map(&([&1 | n_rest]))
    valid?(result, nexts ++ rest, fns)
  end

  defp concat(a, b) do
    String.to_integer(Integer.to_string(a) <> Integer.to_string(b))
  end
end

input = File.read!("input/07.txt")

input |> Seven.part_one() |> IO.inspect(label: "part 1")
input |> Seven.part_two() |> IO.inspect(label: "part 2")
