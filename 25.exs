defmodule TwentyFive do
  def part_one(input) do
    {locks, keys} = parse(input)

    (for lock <- locks, key <- keys, do: {lock, key})
    |> Enum.count(fn {lock, key} ->
      Enum.zip(lock, key)
      |> Enum.all?(fn {a, b} -> a + b < 8 end)
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> Enum.reduce({[], []}, fn block, {locks, keys} ->
      block
      |> String.split(~r/\R/)
      |> Enum.map(&String.to_charlist/1)
      |> Enum.zip()
      |> Enum.map(&Tuple.to_list/1)
      |> then(fn
        [[?. | _] | _] = lines ->
          lock =
            lines
            |> Enum.map(&Enum.reverse/1)
            |> Enum.map(fn line -> Enum.chunk_by(line, &(&1)) |> hd() |> length() end)
          {[lock | locks], keys}
        lines ->
          key =
            lines
            |> Enum.map(fn line -> Enum.chunk_by(line, &(&1)) |> hd() |> length() end)
          {locks, [key | keys]}
      end)
    end)
  end
end

input = File.read!("input/25.txt")

input |> TwentyFive.part_one() |> IO.inspect(label: "part 1")
