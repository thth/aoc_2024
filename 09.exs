defmodule Nine do
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

input = File.read!("input/09.txt")
# input = File.read!("input/_test.txt")

input |> Nine.part_one() |> IO.inspect(label: "part 1")
# input |> Nine.part_two() |> IO.inspect(label: "part 2")
