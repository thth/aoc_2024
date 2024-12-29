defmodule TwentyOne do
  @n %{
    ?A => [{?0, ?<}, {?3, ?^}],
    ?0 => [{?A, ?>}, {?2, ?^}],
    ?1 => [{?4, ?^}, {?2, ?>}],
    ?2 => [{?0, ?v}, {?1, ?<}, {?5, ?^}, {?3, ?>}],
    ?3 => [{?A, ?v}, {?2, ?<}, {?6, ?^}],
    ?4 => [{?1, ?v}, {?5, ?>}, {?7, ?^}],
    ?5 => [{?2, ?v}, {?4, ?<}, {?6, ?>}, {?8, ?^}],
    ?6 => [{?3, ?v}, {?5, ?<}, {?9, ?^}],
    ?7 => [{?4, ?v}, {?8, ?>}],
    ?8 => [{?7, ?<}, {?5, ?v}, {?9, ?>}],
    ?9 => [{?8, ?<}, {?6, ?v}]
  }

  @a %{
    ?A => [{?^, ?<}, {?>, ?v}],
    ?^ => [{?A, ?>}, {?v, ?v}],
    ?v => [{?^, ?^}, {?<, ?<}, {?>, ?>}],
    ?< => [{?v, ?>}],
    ?> => [{?A, ?^}, {?v, ?<}]
  }

  @a_pad %{
    60 => %{
      60 => [~c"A"],
      62 => [~c">>A"],
      65 => [~c">>^A"],
      94 => [~c">^A"],
      118 => [~c">A"]
    },
    62 => %{
      60 => [~c"<<A"],
      62 => [~c"A"],
      65 => [~c"^A"],
      94 => [~c"<^A"],
      118 => [~c"<A"]
    },
    65 => %{
      60 => [~c"v<<A"],
      62 => [~c"vA"],
      65 => [~c"A"],
      94 => [~c"<A"],
      118 => [~c"<vA"]
    },
    94 => %{
      60 => [~c"v<A"],
      62 => [~c"v>A"],
      65 => [~c">A"],
      94 => [~c"A"],
      118 => [~c"vA"]
    },
    118 => %{
      60 => [~c"<A"],
      62 => [~c">A"],
      65 => [~c"^>A"],
      94 => [~c"^A"],
      118 => [~c"A"]
    }
  }

  def part_one(input) do
    input
    |> parse()
    |> Enum.map(fn {n, seq} ->
      n * shortest(seq, 2)
    end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.map(fn {n, seq} ->
      n * shortest(seq, 25)
    end)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      n = Regex.run(~r/\d+/, line) |> hd() |> String.replace_leading("0", "") |> String.to_integer()
      {n, String.to_charlist(line)}
    end)
  end

  defp abstract(code, pad) do
    [?A | code]
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> pad[a][b] end)
  end

  defp shortest(sequence, n) do
    Agent.start_link(fn -> %{} end, name: Memo)
    n_pad = gen_pad(@n)
    # a_pad = gen_pad(@a)
    a_pad = @a_pad

    sequence
    |> abstract(n_pad)
    |> Enum.map(fn codes ->
      deep(codes, a_pad, n)
    end)
    |> Enum.sum()
  end

  defp deep([code], _pad, 0), do: length(code)
  defp deep(codes, pad, n) do
    case Agent.get(Memo, &Map.get(&1, {codes, pad, n})) do
      nil ->
        v =
          codes
          |> Enum.map(fn code ->
            code
            |> abstract(pad)
            |> Enum.map(fn cs ->
              deep(cs, pad, n - 1)
            end)
            |> Enum.sum()
          end)
          |> Enum.min()
        Agent.update(Memo, &Map.put(&1, {codes, pad, n}, v))
        v
      val -> val
    end
  end

  def gen_pad(keys) do
    keys
    |> Map.keys()
    |> Enum.map(fn origin ->
      v =
        (Map.keys(keys) -- [origin])
        |> Enum.map(fn target -> {target, find(origin, target, keys)} end)
        |> Enum.into(%{})
        |> Map.put(origin, [~c"A"])
      {origin, v}
    end)
    |> Enum.into(%{})
  end

  defp find(a, b, keys), do: find([{a, [], [a]}], [], b, keys, [])
  defp find([], [], _, _, out) do
      out
    |> Enum.reject(fn list -> length(Enum.uniq(list)) > 2 end)
    |> Enum.map(fn list -> list ++ [?A] end)
  end
  defp find([], next, b, keys, out), do: find(next, [], b, keys, out)
  defp find([{b, path, _} | rest], next, b, keys, out), do: find(rest, next, b, keys, [path | out])
  defp find([{c, path, been} | rest], next, b, keys, out) do
    nexts =
      keys[c]
      |> Enum.reject(fn {key, _} -> key in been end)
      |> Enum.map(fn {key, dir} -> {key, path ++ [dir], [key | been]} end)
    find(rest, nexts ++ next, b, keys, out)
  end

end

input = File.read!("input/21.txt")

input |> TwentyOne.part_one() |> IO.inspect(label: "part 1")
input |> TwentyOne.part_two() |> IO.inspect(label: "part 2")
