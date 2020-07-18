defmodule Calixir.HolidaysTableMaker do
  @moduledoc """
  This module generates Elixir data from the Calixir-4.0 holidays data.
  """

  @doc """
  Returns the list of holiday lists.
  """
  def holiday_dates_from_file(file) do
    file
    |> check_path
    |> File.read!
    |> String.trim
    |> String.split("\n")
    |> tl # ignore the header line
    |> Enum.map(&(holiday_date_from_csv(&1)))
  end

  defp holiday_date_from_csv(csv_string) do
    # Transform a csv_string with holiday data into a line of Elixir data.
    [holiday_name, csv_function | csv_values] = holiday_line_from_csv(csv_string)
    holiday_function = holiday_function_from_csv(csv_function)
    holiday_data = holiday_values_from_csv(csv_values)
    [holiday_function, holiday_name] ++ holiday_data
  end

  defp holiday_line_from_csv(csv_line) do
    csv_line
    |> String.split(",")
    |> Enum.map(&(String.trim(&1)))
  end

  defp holiday_function_from_csv(csv_function) do
    csv_function
    |> String.replace("-", "_")
    |> String.to_atom
  end

  defp holiday_values_from_csv(csv_values) do
    csv_values
    |> Enum.map(&(value_from_csv(&1)))
    |> Enum.chunk_every(2)
    |> Enum.zip(2000..2103)
    |> Enum.map(&(holiday_value_from_chunk(&1)))
  end

  defp holiday_value_from_chunk({[nil, nil], year}) do
    {year, 0, 0}
  end

  defp holiday_value_from_chunk({[month, day], year}) do
    {year, month, day}
  end

  defp value_from_csv(csv_value) do
    # Transforms a single csv value into an Elxir value.
    s = String.trim(csv_value)
    cond do
      String.match?(s, ~r/^[0-9+-]+$/) -> String.to_integer(s)
      String.match?(s, ~r/^[0-9.+-]+$/) -> String.to_float(s)
      s == "f" -> false
      s == "t" -> true
      s == "none" -> nil
      s == "" -> nil
      s == "bogus" -> "bogus"
      true -> s |> String.downcase |> String.to_atom
    end
  end

  defp check_path(files) when is_list(files) do
    # Checks if all the files in the list exist.
    # Aborts on error, else returns a list with the full paths.
    Enum.map(files, &(check_path(&1)))
  end

  defp check_path(file) do
    # Checks if the file exists.
    # Aborts on error, else returns the path.
    path = Path.expand("./assets/#{file}")
    if not File.exists?(path) do
      raise "error: file <#{path}> does not exist"
    end
    path
  end

end
