defmodule Calixir.SampleDates do
  @moduledoc """
  The main purpose of this module is to provide test data for functions
  written in Elixir or Erlang to convert dates from one calendar into the
  corresponding dates in another calendar.

  This module provides the following calendrica-4.0 dates as Elixir data:

  *Sample Dates*: they contain 33 dates from various years in seven files
  (see DR4, pp. 447 - 453):

  `dates1.csv`, `dates2.csv`, `dates3.csv`, `dates4.csv`,
  `dates3.csv`, `dates6.csv`, `dates7.csv`

  Both the year dates and the sample dates cover the same calendars.
  Thus they can be combined into a single large data table
  that contains 33 rows from the `dates*.csv` files and
  365/366 rows per year from the `201*.csv` files.

  One cell or entry of this table contains the date of one calendar 
  on a specific day.

  ## Date Structures
  
  There are a couple of nested data structures you need to understand
  in order to use the functions. From smallest to largest:
  
  ### `calendar`
  This is an atom, that represents the name of a calendar.

  ### `date`
  This is a number or a tuple.
  A `date` expresses a single date of some calendar.
  It is only useful if combined with a calendar.

  ### `caldate`
  This is a tuple, beginning with a calendar, followed by a date
  of that calendar:

  `caldate = {:calendar, {:calendar_field1, :calendar_field2, ...}}`, i.e.
  `caldate = {:gregorian, {2010, 1, 1}}`

  ### `caldate_row`
  This is a list of `caldate`s of a specific day across all the calendars
  discussed in DR4.

  `[caldate_1, caldate_2, caldate_3, ...]`, i.e.
  `[{:fixed, 2345678}, {:gregorian, {2010, 1, 1}}, ...]`

  ### `caldate_table`
  This is the table of all `caldate_row`s.
  It is the largest data structure that contains all the others.
  
  **NOTE:** All data in the `caldate_table` are **static**.

  The examples given only work with these data.
  They don't perfom date calculations or date conversions!

  The sample data have been precaculated by the functions of the
  original Lisp program `calendrica-4.0.cl` and provided in the
  files mentioned above.
  """

  import Calixir.SampleDatesTableMaker

  @sample_files    Enum.map(1..7, &("dates#{&1}.csv"))
  @sample_dict     sample_dict_from_files(@sample_files)
  @caldate_table   @sample_dict.dates
  @caldate_structs @sample_dict.caldate_structs
  @calendars       @sample_dict.calendars

  @doc """
  Returns a list of the date structures used in calendrica-4.0.

  Each `date_struct` is a list, beginning with a calendar and followed
  by one or more fields defining a date of that calendar.
  In other words: The `date_struct` defines a `caldate`:

  date_struct: `{:gregorian, {:gregorian_year, :gregorian_month, :gregorian_day}}`
  caldate:     `{:gregorian, {2010, 1, 1}}`

  date_struct: `{:fixed, :fixed}`
  caldate:     `{:fixed, 2345678}`

  The date structs are derived from the two header lines (calendars and fields)
  of the files containing the year dates and the sample dates.
  """
  def caldate_structs, do: @caldate_structs

  @doc """
  Returns the complete list of caldates.
  """
  def caldate_table, do: @caldate_table

  @doc """
  Returns a list of the calendars used in calendrica-4.0 in the order
  in which they appear in the sample files.

  **NOTE**: Not all results provided by this function are calendars proper.
  Some are just sub-structures (like `chinese_day_name`) or repeating data
  (like `weekday`), or astro data (like `solstice`).

  The calendars are derived from the first two header lines of the files
  containing the year dates and the sample dates.
  """
  def calendars, do: @calendars |> Enum.uniq

  @doc """
  Outputs a list of the calendars used in calendrica-4.0
  in the alphabetic order.
  ```
  akan_name
  arithmetic_french
  arithmetic_persian
  armenian
  astro_bahai
  astro_hindu_lunar
  astro_hindu_solar
  astronomical_easter
  aztec_tonalpohualli
  aztec_xihuitl
  babylonian
  bahai
  bali_pawukon
  chinese
  chinese_day_name
  coptic
  dawn
  easter
  egyptian
  ephem_corr
  eqn_of_time
  ethiopic
  fixed
  french
  gregorian
  hebrew
  hindu_lunar
  hindu_solar
  icelandic
  islamic
  iso
  jd
  julian
  lunar_alt
  lunar_lat
  lunar_long
  mayan_haab
  mayan_long_count
  mayan_tzolkin
  midday
  mjd
  moonrise
  moonset
  new_moon_after
  next_zhongqi
  observational_hebrew
  observational_islamic
  old_hindu_lunar
  old_hindu_solar
  olympiad
  orthodox_easter
  persian
  roman
  samaritan
  saudi_islamic
  set
  solar_long
  solstice
  tibetan
  unix
  weekday
  ```
  """
  def calendars_to_io() do
    calendars()
    |> Enum.sort
    |> Enum.map(&(IO.puts(&1)))
  end

  @doc """
  Returns all the calendar dates at fixed date`fixed`.
  """
  def caldates_at_fixed(fixed) do
    Enum.find(caldate_table(), &({:fixed, fixed} in &1))
  end

  @doc """
  Returns all the calendar dates at Gregorian date`{year, month, day}`.
  """
  def caldates_at_gregorian(year, month, day) do
    Enum.find(caldate_table(), &({:gregorian, {year, month, day}} in &1))
  end

  @doc """
  Returns all the calendar dates at Julian Day Number `jd`.
  """
  def caldates_at_jd(jd) do
    Enum.find(caldate_table(), &({:jd, jd} in &1))
  end

  @doc """
  Returns all caldates of `calendar`.
  """
  def caldates_of_calendar(calendar) do
    Enum.map(caldate_table(), &(caldate_in_row(calendar, &1)))
  end

  @doc """
  Returns the `calendar` part of the calendar date structurte `caldate`.
  """
  def calendar_of_caldate({calendar, _date} = _caldate), do: calendar

  @doc """
  Returns a list of pairs (= tuples) with a calendar date of `calendar1`
  and the corresponding calendar date of `calendar2`.

  Used to create date pairs for testing date-to-date conversions, i.e.:

  `calendar_to_calendar(:fixed, :gregorian)`
  `calendar_to_calendar(:gregorian, :hebrew)`
  """
  def calendar_to_calendar(calendar1, calendar2) do
    dates1 = dates_of_calendar(calendar1)
    dates2 = dates_of_calendar(calendar2)
    Enum.zip(dates1, dates2)
  end

  @doc """
  Returns the `date` part of the calendar date structure `caldate`.

  Single-value dates are returned as atoms.
  Multi-value dates are returned as tuples.
  """
  def date_of_caldate({_calendar, date} = _caldate), do: date

  @doc """
  Returns all the dates of `calendar`.
  """
  def dates_of_calendar(calendar) do
    Enum.map(caldate_table(), &(date_in_row(calendar, &1)))
  end

  @doc """
  Returns a list of pairs (= tuples) with a calendar date of a fixed date
  (aka Rata Die or R.D. of DR4) and the equivalent calendar date of `calendar`.
  Per default, the function returns the first 33 entries of the data table.
  These 33 rows are the data used in the Sample Data of DR4 445ff.

  This is a convenience function.
  """
  def fixed_with(calendar) do
    dates1 = dates_of_calendar(:fixed)
    dates2 = dates_of_calendar(calendar)
    Enum.zip(dates1, dates2) |> Enum.take(33)
  end

  @doc """
  Returns the `caldate` structure of `calendar` in the `caldate_row`.
  """
  def caldate_in_row(calendar, caldate_row) do
    Enum.find(caldate_row, &(elem(&1, 0) == calendar))
  end

  @doc """
  Returns the date of the `caldate` of `calendar` in the `caldate_row`.
  """
  def date_in_row(calendar, caldate_row) do
    calendar
    |> caldate_in_row(caldate_row)
    |> date_of_caldate
  end

  @doc """
  Returns a list of pairs (= tuples) with a calendar date of the Julian Day
  Number and the equivalent calendar date of `calendar`.

  This is a convenience function.
  """
  def jd_with(calendar) do
    dates1 = dates_of_calendar(:jd)
    dates2 = dates_of_calendar(calendar)
    Enum.zip(dates1, dates2)
  end

end