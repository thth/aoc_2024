defmodule TwentyFive do
  def part_one(input) do
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

input = File.read!("input/25.txt")
# input = File.read!("input/_test.txt")

input |> TwentyFive.part_one() |> IO.inspect(label: "part 1")
