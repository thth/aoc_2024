File.mkdir_p!("input")
File.touch("README.md")
File.touch("input/_test.txt")
File.write(".gitignore", ".gitignore\ninput/_test.txt\nerl_crash.dump", [:exclusive])

~w[
  One Two Three Four Five Six Seven Eight Nine Ten Eleven Twelve
  Thirteen Fourteen Fifteen Sixteen Seventeen Eighteen Nineteen
  Twenty TwentyOne TwentyTwo TwentyThree TwentyFour TwentyFive
]
|> Enum.with_index(1)
|> Enum.each(fn {word, i} ->
  day_n = i |> Integer.to_string() |> String.pad_leading(2, "0")
  part_two =
    """

      def part_two(input) do
        input
        |> parse()
      end
    """
  content =
    """
    defmodule #{word} do
      def part_one(input) do
        input
        |> parse()
      end
      #{if day_n == "25", do: "", else: """

        def part_two(input) do
          input
          |> parse()
        end
      """}
      defp parse(text) do
        text
        |> String.trim()
        # |> String.split(~r/\\R/)
        # |> Enum.map(fn line ->
        #   line
        # end)
      end
    end

    input = File.read!("input/#{day_n}.txt")
    # input = File.read!("input/_test.txt")

    input |> #{word}.part_one() |> IO.inspect(label: "part 1")
    """
    <> (if day_n == "25", do: "", else: "# input |> #{word}.part_two() |> IO.inspect(label: \"part 2\")\n")

  File.touch("input/#{day_n}.txt")

  # [:exclusive] so does not overwrite if existing
  File.write("#{day_n}.exs", content, [:exclusive])
end)
