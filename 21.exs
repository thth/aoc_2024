defmodule TwentyOne do
  def part_one(input) do
    input
    |> parse()
  end
  
  def part_two(input) do
    input
    |> parse()
  end

  defp parse(text) do
    text
    |> String.trim()
    # |> String.split(~r/\R/)
    # |> Enum.map(fn line ->
    #   line
    # end)
  end
end

input = File.read!("input/21.txt")
# input = File.read!("input/_test.txt")

input |> TwentyOne.part_one() |> IO.inspect(label: "part 1")
# input |> TwentyOne.part_two() |> IO.inspect(label: "part 2")
