defmodule Seventeen do
  import Bitwise

  defmodule State do
    defstruct a: nil, b: nil, c: nil, p: nil, i: 0, out: []
  end

  def part_one(input) do
    input
    |> parse()
    |> run()
    |> Map.get(:out)
    |> Enum.join(",")
  end

  def part_two(input) do
    s = parse(input)
    # a = 35_184_372_000_000
    # a = 105_000_000_000_000
    # a = 105_550_000_000_000
    # a = 105_690_000_000_000
    # a = 105_690_550_000_000
    # a = 105_813_410_000_000
    # a = 105_819_404_000_000
    # a = 109_010_000_000_000
    # a = 109019849031000
    # a = 109019900000000
    a = 109019930300000
    IO.inspect(s.p)
    IO.inspect(run(%{s | a: a}).out)
    find(%{s | a: a})
  end

  defp parse(text) do
    text
    |> String.trim()
    |> then(fn str ->
      [a, b, c | program] =
        Regex.scan(~r/\d+/, str)
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)
      %State{a: a, b: b, c: c, p: program}
    end)
  end

  defp run(s) when s.i < 0 or s.i >= length(s.p), do: s
  defp run(s) do
    s
    |> op(Enum.at(s.p, s.i), Enum.at(s.p, s.i + 1))
    |> run()
  end

  defp op(s, 0, x), do: %{s| a: div(s.a, 2 ** combo(x, s)), i: s.i + 2}
  defp op(s, 1, x), do: %{s| b: bxor(s.b, x), i: s.i + 2}
  defp op(s, 2, x), do: %{s| b: rem(combo(x, s), 8), i: s.i + 2}
  defp op(%{a: 0} = s, 3, _), do: %{s | i: s.i + 2}
  defp op(s, 3, x), do: %{s | i: x}
  defp op(s, 4, _), do: %{s| b: bxor(s.b, s.c), i: s.i + 2}
  defp op(s, 5, x), do: %{s| out: s.out ++ [rem(combo(x, s), 8)], i: s.i + 2}
  defp op(s, 6, x), do: %{s| b: div(s.a, 2 ** combo(x, s)), i: s.i + 2}
  defp op(s, 7, x), do: %{s| c: div(s.a, 2 ** combo(x, s)), i: s.i + 2}

  defp combo(4, s), do: s.a
  defp combo(5, s), do: s.b
  defp combo(6, s), do: s.c
  defp combo(7, _), do: raise "oh no"
  defp combo(n, _), do: n

  defp find(s) do
    out = run(s).out
    # if rem(s.a, 10_000_000) == 0, do: IO.inspect({s.a, out})
    # if Enum.slice(out, -13..-1) == Enum.slice(s.p, -13..-1) do
    if run(s).out == s.p do
      s.a
    else
      # find(%{s | a: s.a + 100_000})
      find(%{s | a: s.a + 1})
    end
  end
end

input = File.read!("input/17.txt")

input |> Seventeen.part_one() |> IO.inspect(label: "part 1")
input |> Seventeen.part_two() |> IO.inspect(label: "part 2")
