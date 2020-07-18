defmodule SampleDates6Test do
  use ExUnit.Case

  import Calixir

  alias Calixir.SampleDates

  # === Sample Data - dates6.csv - DR4 452

  test "Ephemeris Correction - DR4 210 (14.15)" do
    for {fixed, ephem_corr} <- SampleDates.fixed_with(:ephem_corr) do
      value =
        fixed
        |> ephemeris_correction
        |> Kernel.*(1000000)
        |> trunc
        |> Kernel./(1000000)
      assert value == ephem_corr
    end
  end

  test "Equation of Time - DR4 215 (14.20)" do
    for {fixed, eqn_of_time} <- SampleDates.fixed_with(:eqn_of_time) do
      value =
        fixed
        |> equation_of_time
        |> Kernel.*(1000000)
        |> trunc
        |> Kernel./(1000000)
      assert value == eqn_of_time
    end
  end

  test "Solar Longitude at 12:00:00 U.T. - DR4 223 (14.33)" do
    # Due to rounding or trundcating errors,
    # there may be differences in the 6th+ decimal place
    # between the table values and the calculated values.
    # The table and calculated values are considered equal
    # if their difference is less than delta.
    for {fixed, solar_long} <- SampleDates.fixed_with(:solar_long) do
      delta = 0.0000011
      value =
        fixed + 0.5  # adjust for noon!
        |> solar_longitude
        |> Kernel.*(1000000)
        |> trunc
        |> Kernel./(1000000)
      assert solar_long - value < delta
    end
  end

  test "Next Solstice/Equinox (R.D.) - DR4 224 (14.36)" do
    # Due to rounding or trundcating errors,
    # there may be differences in the 3rd+ decimal place
    # between the table values and the calculated values.
    for {fixed, solstice} <- SampleDates.fixed_with(:solstice) do
      {year, _, _} = Calixir.gregorian_from_fixed(fixed)
      season =
        cond do
          fixed <= season_in_gregorian(0, year) -> 0
          fixed <= season_in_gregorian(90, year) -> 90
          fixed <= season_in_gregorian(180, year) -> 180
          fixed <= season_in_gregorian(270, year) -> 270
          true -> 0
        end
      value = solar_longitude_after(season, fixed)
      assert trunc(value * 100) == trunc(solstice * 100)
    end
  end

  test "Dawn in Paris - DR4 241 (14.72)" do
    for {fixed, {dawn, _, _, _} = _date} <- SampleDates.fixed_with(:dawn) do
      # DR4 244, Depression angle = 18° (Astronomical)
      dawn_paris = dawn(fixed, paris(), 18)
      if dawn == nil do
        assert dawn_paris == bogus()
      else
        s0 = seconds_from_moment(dawn)
        dawn_paris = mod(dawn_paris, 1)
        s1 = seconds_from_moment(dawn_paris)
        assert abs(s0 - s1) < 60
      end
    end
  end

  test "Midday in Tehran - DR4 218 (14.26)" do
    for {fixed, {midday, _, _, _}} <- SampleDates.fixed_with(:midday) do
      midday_tehran = midday(fixed, tehran())
      standard = standard_from_universal(midday_tehran, tehran())
      time = mod(standard, 1)
      assert trunc(time * 1000) == trunc(midday * 1000)
    end
  end

  test "Sunset in Jerusalem - DR4 242 (14.77)" do
    for {fixed, {set, _, _, _}} <- SampleDates.fixed_with(:set) do
      s0 = seconds_from_moment(set)
      sunset_jerusalem = sunset(fixed, jerusalem())
      time = mod(sunset_jerusalem, 1)
      s1 = seconds_from_moment(time)
      # The times from the Sample Data and the calculated times are
      # considered equal if they differ by less than 60 seconds.
      assert abs(s0 - s1) < 60
    end
  end

end

