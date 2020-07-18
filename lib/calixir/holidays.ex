defmodule Calixir.Holidays do
  @moduledoc """
  This module provides the holiday data contained in the sample
  data file `holiday-list.csv` of calendrica-4.0 as Elixir data.

  The data consist of a list of holiday lists with the holiday dates
  ranging from 2000 to 2103.

  Each holiday list has the following structure:

  `[:holiday_function, holiday_name, date_2000, ..., date_2103]`

  `:holiday_function` is the name of the function to calculate the dates.
  `holiday_name` is a string, giving the common name of the holiday.
  `date_nnnn` is the Gregorian date `{year, month, day}` of the holiday
  or `{year, 0, 0}` if no such holiday exists in that year.
  """

  import Calixir.HolidaysTableMaker

  @holiday_file   "holiday-list.csv"
  @holiday_dates  holiday_dates_from_file(@holiday_file)

  @doc """
  Returns the complete list of holiday lists.
  Each holiday list starts with the atom used for the holiday and
  its common name. Then follow the Gregorian dates of the holiday
  for the years 2000 to 2103.

  ```
  [
    [
      :advent,
      "Advent Sunday",
      {2000, 12, 3},
      {2001, 12, 2},
      {2002, 12, 1},
      ...
    ],
    [
      :bahai_new_year,
      "Baha'i New Year",
      {2000, 3, 21},
      {2001, 3, 21},
      {2002, 3, 21},
      ...
    ],
    ...
  ]
  ```
  """
  def holiday_dates, do: @holiday_dates

  @doc """
  Returns a list of the holiday functions used to calculate holidays.
  """
  def holiday_functions() do
    holiday_dates()
    |> Enum.map(&(Enum.at(&1, 0)))
    |> Enum.sort
  end

  @doc """
  Outputs a list of the holiday functions used to calculate holidays.
  ```
  advent
  astronomical_easter
  bahai_new_year
  birkath_ha_hama
  birth_of_the_bab
  chinese_new_year
  christmas
  classical_passover_eve
  coptic_christmas
  daylight_saving_end
  daylight_saving_start
  diwali
  dragon_festival
  easter
  eastern_orthodox_christmas
  election_day
  epiphany
  feast_of_ridvan
  hanukkah
  hindu_lunar_new_year
  icelandic_summer
  icelandic_winter
  independence_day
  kajeng_keliwon
  labor_day
  mawlid
  memorial_day
  mesha_samkranti
  naw_ruz
  nowruz
  observational_hebrew_first_of_nisan
  orthodox_easter
  passover
  pentecost
  purim
  qing_ming
  rama
  sacred_wednesdays
  sh_ela
  shiva
  ta_anit_esther
  tibetan_new_year
  tishah_be_av
  tumpek
  unlucky_fridays
  yom_ha_zikkaron
  yom_kippur
  ```
  """
  def holiday_functions_to_io do
    holiday_functions()
    |> Enum.join("\n")
    |> IO.puts
  end

  @doc """
  Returns a list of the common names of the holidays.
  """
  def holiday_names do
    holiday_dates()
    |> Enum.map(&(Enum.at(&1, 1)))
    |> Enum.sort
  end

  @doc """
  Outputs a list of the common names of the holidays.
  ```
  Advent Sunday
  Baha'i New Year
  Birkath ha-Hama
  Birth of the Bab
  Birthday of Rama
  Chinese New Year
  Christmas
  Christmas (Coptic)
  Christmas (Orthodox)
  Diwali
  Dragon Festival
  Easter
  Easter (Astronomical)
  Easter (Orthodox)
  Epiphany
  Feast of Naw-Ruz
  Feast of Ridvan
  Friday the 13th (first)
  Great Night of Shiva
  Hanukkah (first day)
  Hindu Lunar New Year
  Icelandic Summer
  Icelandic Winter
  Kajeng Keliwon (first)
  Losar
  Mawlid
  Mesha Samkranti (date)
  Nowruz
  Observ. Hebrew 1 Nisan
  Passover
  Passover Eve (Classical)
  Pentecost
  Purim
  Qingming
  Sacred Wednesday (first)
  Sh'ela
  Ta'anit Esther
  Tishah be-Av
  Tumpek (first)
  U.S. Daylight Savings End
  U.S. Daylight Savings Start
  U.S. Election Day
  U.S. Independence Day
  U.S. Labor Day
  U.S. Memorial Day
  Yom Kippur
  Yom ha-Zikkaron
  ```
  """
  def holiday_names_to_io do
    holiday_names()
    |> Enum.join("\n")
    |> IO.puts
  end

  @doc """
  Returns the list with the dates of the holiday given by the function `holiday`.
  """
  def dates_of_holiday(holiday) do
    holiday_dates()
    |> Enum.filter(&(Enum.at(&1, 0) == holiday))
    |> Enum.at(0)
    |> Enum.drop(2)
  end

end