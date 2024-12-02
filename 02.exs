defmodule Two do
  def part_one(input) do
    input
    |> parse()
    |> Enum.filter(&only_up_or_down?/1)
    |> Enum.filter(&gradual?/1)
    |> Enum.count()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(fn report ->
      0..(length(report) - 1)
      |> Enum.map(fn n -> List.delete_at(report, n) end)
    end)
    |> Enum.count(fn reports ->
      Enum.any?(reports, fn r -> only_up_or_down?(r) and gradual?(r) end)
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp only_up_or_down?(report) do
    (report == Enum.sort(report)) or (report == Enum.sort(report, :desc))
  end

  defp gradual?(report) do
    report
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [x, y] -> abs(x - y) end)
    |> Enum.min_max()
    |> then(fn {min, max} -> min > 0 and max <= 3 end)
  end
end

input = File.read!("input/02.txt")

input |> Two.part_one() |> IO.inspect(label: "part 1")
input |> Two.part_two() |> IO.inspect(label: "part 2")
