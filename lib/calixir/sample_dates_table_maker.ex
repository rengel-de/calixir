defmodule Calixir.SampleDatesTableMaker do
  @moduledoc """
  This module generates Elixir data from the Calixir-4.0 sample data.
  """

  @doc """
  Transforms the sample files into one set with sample dates.
  """
  def sample_dict_from_files(files) do
    files
    |> check_path
    |> datasets_from_files
    |> sample_set_from_datasets
    |> caldates_from_dataset
  end

  defp sample_set_from_datasets([head | tail] = _datasets) do
    # Combines all sample datasets into a one `sample_set`.
    Enum.reduce(tail, head, fn set, acc -> join_lines([], acc, set) end)
  end

  defp join_lines(acc, [], []), do: acc
  defp join_lines(acc, [h1 | t1] = _set1, [[_ | th2] | t2] = _set2) do
    join_lines(acc ++ [h1 ++ th2], t1, t2)
  end

  # === year_dates ===================================================

  @doc """
  Transforms the year files into one set with year dates.
  """
  def year_dict_from_files(files) do
    files
    |> check_path
    |> datasets_from_files
    |> year_set_from_datasets
    |> caldates_from_dataset
  end

  defp year_set_from_datasets([head | _] = datasets) do
    # Combines all year datasets into a single dataset.
    # The dataset has two headers, calendars and fields,
    # followed by 365/366 data lines per year.
    Enum.reduce(datasets, head, fn [_, _ | data], acc -> acc ++ data end)
  end

  defp datasets_from_files(files) do
    # Creates a list of lists (= a list of datasets).
    # Each element list contains the data of one file,
    files
    |> Enum.map(&(csv_from_file(&1)))
    |> Enum.map(&(dataset_from_csv(&1)))
    |> Enum.map(&(check_dataset(&1)))
  end

  defp csv_from_file(path) do
    # Reads the csv file and splits it into lines
    # and returns a list of csv_strings.
    path
    |> File.read!
    |> String.trim
    |> String.split("\n")
  end

  defp dataset_from_csv([csv_calendars, csv_fields | csv_values] = _csv) do
    # Transforms csv table data into an equivalent Elixir data structure.
    calendars = calendars_from_csv(csv_calendars)
    fields = fields_from_csv(csv_fields)
    data = Enum.map(csv_values, &(values_from_csv(&1)))
    [calendars, fields] ++ data
  end

  defp calendars_from_csv(csv_calendars) do
    # Transforms the first csv header string into Elixir data.
    csv_calendars
    |> String.trim_trailing
    |> String.downcase
    |> String.replace(~r/^rd,/, "fixed,")
    |> String.replace(~r/mid day,/, "midday,")
    |> String.replace(~r/ day,/, " weekday,")
    |> String.split(~r/, */)
    |> fill([])
    |> Enum.map(&(String.replace(&1, " ", "_")))
  end

  # fill-in empty placeholders after calendars, i.e.:
  # "..., Unix, Gregorian, , , Julian, , , Roman, , , , , Olympiad, ..."
  defp fill([""   | []],   acc), do: acc ++ [List.last(acc)]
  defp fill([head | []],   acc), do: acc ++ [head]
  defp fill([""   | tail], acc), do: fill(tail, acc ++ [List.last(acc)])
  defp fill([head | tail], acc), do: fill(tail, acc ++ [head])

  defp fields_from_csv(csv_fields) do
    # Transforms the second csv header string into Elixir data.
    # In some calendars 'leap' isn't used uniquely, so there is a special fix. 
    csv_fields
    |> String.trim_trailing
    |> String.downcase
    |> String.replace("month, leap, day, leap", "month, leap_month, day, leap_day")
    |> String.split(",")
    |> Enum.map(&(String.trim(&1)))
    |> Enum.map(&(String.replace(&1, " ", "_")))
  end

  defp values_from_csv(csv_values) do
    # Transforms csv values into Elixir values.
    csv_values
    |> String.trim_trailing
    |> String.trim_trailing(",")
    |> String.split(~r/, */)
    |> Enum.map(&(value_from_csv(&1)))
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

  defp check_dataset([calendars, fields | data] = dataset) do
    # Checks dataset for consistent line lengths.
    # Aborts on error, else returns the dataset.
    len = length(calendars)
    b = Enum.reduce(dataset, true, fn l, acc -> acc and length(l) == len end)
    if b == false do
      IO.inspect(calendars,         label: "calendars        ")
      IO.inspect(length(calendars), label: "length(calendars)")
      IO.inspect(fields,            label: "fields           ")
      IO.inspect(length(fields),    label: "length(fields)   ")
      IO.inspect(length(hd(data)),  label: "length(data)     ")
      IO.inspect(dataset)
      raise "error: different line lengths in dataset"
    end
    dataset
  end

  defp check_path(files) when is_list(files) do
    # Checks if all the files in the list exist.
    # Aborts on error, else return a list with the full paths.
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

  defp caldates_from_dataset([calendars, fields | data] = _dataset) do
    headers = headers_from_calendars_and_fields(calendars, fields)
    calendars = Enum.map(calendars, &(String.to_atom(&1)))
    caldate_structs = caldate_structs_from_calendars_and_headers(calendars, headers)
    data = Enum.map(data, &(Enum.zip(headers, &1)))
    dates = Enum.map(data, &(caldates_from_data(&1, caldate_structs)))
    %{calendars: calendars, caldate_structs: caldate_structs, dates: dates}
  end

  # === headers ======================================================

  defp headers_from_calendars_and_fields(calendars, fields) do
    # Returns a list of headers (= atoms) that combine calendar and fields:
    # calendars  [..., "unix", "gregorian", "gregorian", "gregorian",...]
    # + fields   [..., "", "year", "month", "day",...]
    # -> headers [..., :unix, :gregorian_year, :gregorian_month, :gregorian_day,...] 
    calendars
    |> Enum.zip(fields)
    |> Enum.map(&(header_from_calendar_and_field(&1)))
    |> Enum.map(&(String.to_atom(&1)))
  end

  # Headers of empty fields get the name of the calendar.
  defp header_from_calendar_and_field({calendar, ""}), do: calendar
  # Combines calendar and field into a single header.
  defp header_from_calendar_and_field({calendar, field}), do: "#{calendar}_#{field}"

  # === caldate_structs =================================================

  defp caldate_structs_from_calendars_and_headers(calendars, headers) do
    # Returns a list of caldate_structs. A caldate_struct is a list of the form:
    # {:calendar, {:header1, :header2, :header3, ...}}
    # Its first element is the calendar, the other elements its fields.
    # Two examples for caldate_structs:
    # {:fixed, :fixed}
    # {:gregorian, {:gregorian_year, :gregorian_month, :gregorian_day}}
    calendars
    |> Enum.zip(headers)
    |> Enum.chunk_by(&(elem(&1, 0)))
    |> Enum.map(&(caldate_struct_from_chunk(&1)))
  end

  defp caldate_struct_from_chunk(chunk) do
    # Reduces a chunk (= list of tuples) to a single tuple:
    # [
    #   {:calendar, :header1},
    #   {:calendar, :header2}, -> {:calendar, {:header1, :header2, :header3, ...}}
    #   {:calendar, :header3},
    #   ...
    # ]
    calendar = chunk |> hd |> elem(0)
    fields = Enum.map(chunk, fn {_, header} -> header end) |> List.to_tuple
    if tuple_size(fields) == 1 do
      {calendar, elem(fields, 0)}
    else
       {calendar, fields}
    end
  end

  # === dates ========================================================

  defp caldates_from_data(data, caldate_structs) do
    # Returns a list of caldates of the form
    # {:calendar, {field_value1, field_value2, field_value3, ...}}
    Enum.map(caldate_structs, fn {calendar, fields} ->
      {calendar, date_from_data(fields, data)}
    end)
  end

  defp date_from_data(fields, data) when is_tuple(fields) do
    fields
    |> Tuple.to_list
    |> Enum.map(&(Keyword.get(data, &1)))
    |> List.to_tuple
  end

  defp date_from_data(fields, data) do
    Keyword.get(data, fields)
  end

end
