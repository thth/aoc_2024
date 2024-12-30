defmodule Nineteen do
  def part_one(input) do
    {towels, patterns} = parse(input)
    Enum.count(patterns, &(find([&1], towels)))
  end

  def part_two(input) do
    {towels, patterns} = parse(input)

    Agent.start_link(fn -> %{} end, name: Memo)
    Enum.reduce(patterns, 0, &(&2 + combos(&1, towels)))
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> then(fn [t, p] ->
      towels = t |> String.split(", ", trim: true) |> Enum.map(&String.to_charlist/1)
      patterns = p |> String.split(~r/\R/) |> Enum.map(&String.to_charlist/1)
      {towels, patterns}
    end)
  end

  defp find([], _), do: nil
  defp find([[] | _], _), do: true
  defp find([pattern | rest], towels) do
    nexts =
      towels
      |> Enum.filter(&List.starts_with?(pattern, &1))
      |> Enum.map(&(pattern -- &1))
    find(nexts ++ rest, towels)
  end

  defp combos(pattern, towels) do
    case Agent.get(Memo, &Map.get(&1, pattern)) do
      nil ->
        count =
          towels
          |> Enum.filter(fn towel -> Enum.take(pattern, length(towel)) == towel end)
          |> Enum.reduce(0, fn towel, acc ->
            if pattern == towel do
              acc + 1
            else
              acc + combos(Enum.drop(pattern, length(towel)), towels)
            end
          end)
        Agent.update(Memo, &Map.put(&1, pattern, count))
        count
      n -> n
    end
  end
end

input = File.read!("input/19.txt")

input |> Nineteen.part_one() |> IO.inspect(label: "part 1")
input |> Nineteen.part_two() |> IO.inspect(label: "part 2")
