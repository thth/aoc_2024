defmodule TwentyFour do
  def part_one(input) do
    input
    |> parse()
    |> run()
    |> Enum.filter(fn {w, _} -> String.starts_with?(w, "z") end)
    |> Enum.sort(:desc)
    |> Enum.map(fn
      {_, {true, _}} -> "1"
      {_, {false, _}} -> "0"
    end)
    |> Enum.join()
    |> String.to_integer(2)
  end

  def part_two(input) do
    {_state, ins} = parse(input)

    ins =
      ins
      |> swap("fgc", "z12")
      |> swap("mtj", "z29")
      |> swap("dgr", "vvm")
      |> swap("dtv", "z37")

    s1 =
      0..44
      |> Enum.reduce(%{}, fn n, acc ->
        n_str = n |> Integer.to_string() |> String.pad_leading(2, "0")
        acc
        |> Map.put("x" <> n_str, {true, ["x" <> n_str]})
        |> Map.put("y" <> n_str, {false, ["y" <> n_str]})
      end)

    s2 =
      0..44
      |> Enum.reduce(%{}, fn n, acc ->
        n_str = n |> Integer.to_string() |> String.pad_leading(2, "0")
        acc
        |> Map.put("x" <> n_str, {false, ["x" <> n_str]})
        |> Map.put("y" <> n_str, {false, ["y" <> n_str]})
      end)
      |> Map.put("x36", {true, ["x36"]})
      |> Map.put("y36", {true, ["y36"]})

    sets = fn s, t ->
      run({s, t})
      |> Enum.filter(fn {w, _} -> String.starts_with?(w, "z") end)
      |> Enum.sort()
      |> Enum.map(fn {_, {_, l}} -> MapSet.new(l) end)
      |> then(fn l ->
        l
        |> Enum.with_index()
        |> Enum.map(fn {q, i} -> {i, MapSet.difference(q, Enum.at(l, i - 1) || MapSet.new())} end)
      end)
    end

    run({s1, ins})
    |> Enum.filter(fn {w, _} -> String.starts_with?(w, "z") end)
    |> Enum.sort()
    |> Enum.map(fn
      {_, {true, _}} -> "1"
      {_, {false, _}} -> "0"
    end)
    # |> Enum.with_index()
    # |> Enum.chunk_by(&(&1))
    # |> List.last()
    # |> length()

    # target = ["0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0",
    # "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "0",
    # "0", "0", "0", "0", "0", "1", "0", "0", "0", "0", "0", "0", "0", "0"]

    # for a1 <- ins,
    #     a2 <- ins -- [a1] do
    #   {a1, a2}
    # end
    # |> Enum.map(fn {{a1_0, a1_1, a1_2, a1_3} = a1, {a2_0, a2_1, a2_2, a2_3} = a2} ->
    #   {{a1_3, a2_3}, [{a1_0, a1_1, a1_2, a2_3}, {a2_0, a2_1, a2_2, a1_3}] ++ (ins -- [a1, a2])}
    # end)
    # |> then(fn x ->
    #   x
    # end)
    # |> Enum.filter(fn {pair, swapped_ins} ->
    #   case attempt(s2, swapped_ins) do
    #     :help -> false
    #     hlep ->
    #       hlep == target
    #   end
    # end)
    # |> Enum.map(fn {pair, ins} ->
    #   # {pair, attempt(s1, ins) |> Enum.chunk_by(&(&1))}
    #   {pair, sets.(s1, ins)}
    # end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> then(fn [a, b] ->
      state =
        String.trim(a)
        |> String.split(~r/\R/)
        |> Enum.map(fn
          <<w::binary-size(3)>> <> ": 1" -> {w, {true, [w]}}
          <<w::binary-size(3)>> <> ": 0" -> {w, {false, [w]}}
        end)
        |> Enum.into(%{})
      ins =
        String.trim(b)
        |> String.split(~r/\R/)
        |> Enum.map(fn
          <<w1::binary-size(3)>> <> " AND " <> <<w2::binary-size(3)>> <> " -> " <> <<w3::binary-size(3)>> ->
            {:and, w1, w2, w3}
          <<w1::binary-size(3)>> <> " OR "  <> <<w2::binary-size(3)>> <> " -> " <> <<w3::binary-size(3)>> ->
            {:or, w1, w2, w3}
          <<w1::binary-size(3)>> <> " XOR " <> <<w2::binary-size(3)>> <> " -> " <> <<w3::binary-size(3)>> ->
            {:xor, w1, w2, w3}
        end)
      {state, ins}
    end)
  end

  defp run({state, ins}), do: run(ins, [], nil, state)
  defp run([], [], _, state), do: state
  defp run([], past, pastpast, _state) when length(past) == pastpast, do: :help
  defp run([], past, _, state), do: run(Enum.reverse(past), [], length(past), state)
  defp run([{o, w1, w2, w3} = ins | rest], past, pastpast, state) do
    case {state[w1], state[w2]} do
      {a, b} when a != nil and b != nil ->
        run(rest, past, pastpast, Map.put(state, w3, op(o, a, b, w3)))
      _ ->
        run(rest, [ins | past], pastpast, state)
    end
  end

  defp op(:and, {a, aa}, {b, bb}, w), do: {a and b, [w] ++ aa ++ bb}
  defp op(:or,{a, aa}, {b, bb}, w), do: {a or b, [w] ++ aa ++ bb}
  defp op(:xor, {a, aa}, {b, bb}, w), do: {(a and not b) or (b and not a), [w] ++ aa ++ bb}

  defp attempt(state, ins) do
    case run({state, ins}) do
      :help -> :help
      result ->
        result
        |> Enum.filter(fn {w, _} -> String.starts_with?(w, "z") end)
        |> Enum.sort()
        |> Enum.map(fn
          {_, {true, _}} -> "1"
          {_, {false, _}} -> "0"
        end)
        # |> Enum.chunk_by(&(&1))
        # |> List.last()
        # |> length()
    end
  end

  defp swap(ins, a, b) do
    Enum.map(ins, fn
      {w0, w1, w2, ^a} -> {w0, w1, w2, b}
      {w0, w1, w2, ^b} -> {w0, w1, w2, a}
      x -> x
    end)
  end
end

input = File.read!("input/24.txt")
# input = File.read!("input/_test.txt")

# input |> TwentyFour.part_one() |> IO.inspect(label: "part 1")
input |> TwentyFour.part_two() |> IO.inspect(label: "part 2", limit: :infinity)
