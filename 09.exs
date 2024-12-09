defmodule Nine do
  def part_one(input) do
    input
    |> parse()
    |> encode()
    |> run()
    |> checksum()
  end

  def part_two(input) do
    input
    |> parse()
    |> encode()
    |> run_two()
    |> Enum.sort()
    |> checksum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  defp encode(list), do: file(list, {[], []}, 0, 0)
  defp file([], disk, _, _), do: disk
  defp file([0 | rest], disk, i, id), do: free(rest, disk, i, id + 1)
  defp file([n | rest], {files, frees}, i, id), do: file([n - 1 | rest], {[{i, id} | files], frees}, i + 1, id)

  defp free([], disk, _, _), do: disk
  defp free([0 | rest], disk, i, id), do: file(rest, disk, i, id)
  defp free([n | rest], {files, frees}, i, id), do: free([n - 1 | rest], {files, [i | frees]}, i + 1, id)

  defp run({files, frees}), do: run(files, Enum.reverse(frees), [])
  defp run([{i_file, _} | _] = frees, [i_free | _], past) when i_file < i_free, do: frees ++ past
  defp run([{_i_file, id} | files_rest], [i_free | frees_rest], past) do
    run(files_rest, frees_rest, [{i_free, id}| past])
  end

  defp checksum(disk) do
    disk
    |> Enum.map(fn {i, id} -> i * id end)
    |> Enum.sum()
  end

  defp run_two({files, frees}) do
    files =
      Enum.chunk_by(files, &elem(&1, 1))
      |> Enum.map(&Enum.reverse/1)

    frees =
      Enum.reverse(frees)
      |> Enum.chunk_while({-1, []}, fn
        i, {prev, acc} when prev + 1 == i -> {:cont, {i, [i | acc]}}
        i, {_prev, acc} -> {:cont, Enum.reverse(acc), {i, [i]}}
      end, fn
        {_, []} -> {:cont, []}
        {_, acc} -> {:cont, Enum.reverse(acc), []}
      end)
      |> Enum.reject(&(&1 == []))

    run_two(files, frees, [])
  end

  defp run_two([], _, past), do: List.flatten(past)
  defp run_two([[{file_i, _} | _] = file | files_rest], frees, past) do
    if i_free_chunk = Enum.find_index(frees, fn
      [] -> false
      [fc_i | _] = free_chunk -> (length(free_chunk) >= length(file)) and file_i > fc_i
    end) do
      free_chunk = Enum.at(frees, i_free_chunk)

      new_file =
        Enum.zip(file, free_chunk)
        |> Enum.map(fn {{_, id}, i_free} -> {i_free, id} end)

      new_frees =
        frees
        |> List.update_at(i_free_chunk, &Enum.slice(&1, length(file)..-1//1))

      run_two(files_rest, new_frees, [new_file | past])
    else
      run_two(files_rest, frees, file ++ past)
    end
  end
end

input = File.read!("input/09.txt")

input |> Nine.part_one() |> IO.inspect(label: "part 1")
input |> Nine.part_two() |> IO.inspect(label: "part 2")
