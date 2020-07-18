defmodule SampleDates1Test do
  use ExUnit.Case

  import Calixir

  alias Calixir.SampleDates

  # === Sample Data - dates1.csv - DR4 447

  test "Weekday - DR4 33 (1.60)" do
    days = [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
    for {fixed, date} <- SampleDates.fixed_with(:weekday) do
      day = day_of_week_from_fixed(fixed)
      assert Enum.at(days, day) == date
    end
  end

  test "Julian day - DR4 18 (1.5)" do
    for {fixed, date} <- SampleDates.fixed_with(:jd) do
      assert jd_from_fixed(fixed) == date
      assert fixed_from_jd(date) == fixed
    end
  end

  test "Modified Julian day - DR4 19 (1.8)" do
    for {fixed, date} <- SampleDates.fixed_with(:mjd) do
      assert mjd_from_fixed(fixed) == date
      assert fixed_from_mjd(date) == fixed
    end
  end

  test "Unix - DR4 19 (1.11)" do
    for {fixed, date} <- SampleDates.fixed_with(:unix) do
      assert unix_from_fixed(fixed) == date
      assert fixed_from_unix(date) == fixed
    end
  end

  test "Gregorian - DR4 62 (2.23)" do
    for {fixed, date} <- SampleDates.fixed_with(:gregorian) do
      assert gregorian_from_fixed(fixed) == date
      assert fixed_from_gregorian(date) == fixed
    end
  end

  test "Julian - Date - DR4 76 (3.4)" do
    for {fixed, date} <- SampleDates.fixed_with(:julian) do
      assert julian_from_fixed(fixed) == date
      assert fixed_from_julian(date) == fixed
    end
  end

  test "Julian - Roman name - DR4 80 (3.11)" do
    for {fixed, date} <- SampleDates.fixed_with(:roman) do
      assert roman_from_fixed(fixed) == date
      assert fixed_from_roman(date) == fixed
    end
  end

  test "Julian - Olympiad - DR4 82 (3.17)" do
    for {fixed, olympiad} <- SampleDates.fixed_with(:olympiad) do
      {year, _, _} = julian_from_fixed(fixed)
      assert olympiad_from_julian_year(year) == olympiad
      assert julian_year_from_olympiad(olympiad) == year
    end
  end

  test "Egyptian - DR4 31 (1.49)" do
    for {fixed, date} <- SampleDates.fixed_with(:egyptian) do
      assert egyptian_from_fixed(fixed) == date
      assert fixed_from_egyptian(date) == fixed      # DR4 30 (1.47)
      assert alt_fixed_from_egyptian(date) == fixed  # DR4 31 (1.48)
    end
  end

  test "Armenian - DR4 31 (1.52)" do
    for {fixed, date} <- SampleDates.fixed_with(:armenian) do
      assert armenian_from_fixed(fixed) == date
      assert fixed_from_armenian(date) == fixed
    end
  end

end

