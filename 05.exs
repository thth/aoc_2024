defmodule Five do
  def part_one(input) do
    {rules, updates} = parse(input)
    updates
    |> Enum.filter(&valid?(&1, rules))
    |> Enum.map(&Enum.at(&1, div(length(&1), 2)))
    |> Enum.sum()
  end

  def part_two(input) do
    {rules, updates} = parse(input)
    updates
    |> Enum.reject(&valid?(&1, rules))
    |> Enum.map(&fix(&1, rules))
    |> Enum.map(&Enum.at(&1, div(length(&1), 2)))
    |> Enum.sum()
  end

  defp parse(text) do
    [rules_text, updates_text] =
      text
      |> String.trim()
      |> String.split(~r/\R\R/)
    rules =
      rules_text
      |> String.split(~r/\R/)
      |> Enum.reduce(%{}, fn str, acc ->
        [a, b] = String.split(str, "|") |> Enum.map(&String.to_integer/1)
        Map.update(acc, a, [b], &([b | &1]))
      end)
    updates =
      updates_text
      |> String.split(~r/\R/)
      |> Enum.map(fn str ->
        String.split(str, ",")
        |> Enum.map(&String.to_integer/1)
      end)
    {rules, updates}
  end

  defp valid?([_], _), do: true
  defp valid?([a | rest], rules) do
    if Enum.any?(rest, &(a in (rules[&1] || []))) do
      false
    else
      valid?(rest, rules)
    end
  end

  defp fix(update, rules), do: fix(update, [], [], rules)
  defp fix([last], [], acc, _), do: Enum.reverse([last | acc])
  defp fix([a | rest], past, acc, rules) do
    if Enum.any?(rest, &(a in (rules[&1] || []))) do
      fix(rest, [a | past], acc, rules)
    else
      fix(rest ++ past, [], [a | acc], rules)
    end
  end
end

input = File.read!("input/05.txt")

input |> Five.part_one() |> IO.inspect(label: "part 1")
input |> Five.part_two() |> IO.inspect(label: "part 2")
