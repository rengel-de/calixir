defmodule SampleDates7Test do
  use ExUnit.Case

  import Calixir

  alias Calixir.SampleDates

  # === Sample Data - dates7.csv - DR4 453

  test "Lunar Position at 00:00:00 U.T. - Longitude - DR4 212 (14.48)" do
    for {fixed, lunar_long} <- SampleDates.fixed_with(:lunar_long) do
      value = lunar_longitude(fixed)
      assert trunc(value * 1000) == trunc(lunar_long * 1000)
    end
  end

  test "Lunar Position at 00:00:00 U.T. - Latitude - DR4 236 (14.63)" do
    for {fixed, lunar_lat} <- SampleDates.fixed_with(:lunar_lat) do
      value = lunar_latitude(fixed)
      assert trunc(value * 1000) == trunc(lunar_lat * 1000)
    end
  end

  test "Lunar Position at 00:00:00 U.T. - Altitude - DR4 237 (14.64)" do
    for {fixed, lunar_alt} <- SampleDates.fixed_with(:lunar_alt) do
      mecca = lunar_altitude(fixed, mecca())
      assert trunc(mecca * 100) == trunc(lunar_alt * 100)
    end
  end

  test "Next New Moon (R.D.) - DR4 231 (14.47)" do
    for {fixed, new_moon_after} <- SampleDates.fixed_with(:new_moon_after) do
      value = new_moon_at_or_after(fixed)
      assert trunc(value * 1000) == trunc(new_moon_after * 1000)
    end
  end

  test "In Mecca Moonrise - DR4 244 (14.83)" do
    for {fixed, {moonrise, _, _, _} = _date} <- SampleDates.fixed_with(:moonrise) do
      s0 = seconds_from_moment(moonrise)
      moonrise_mecca = moonrise(fixed, mecca())
      t1 = mod(moonrise_mecca, 1)
      s1 = seconds_from_moment(t1)
      # The times from the Sample Data and the calculated times are
      # considered equal if they differ by less than 60 seconds.
      assert abs(s0 - s1) < 60
    end
  end

  test "In Mecca Moonset - DR4 245 (14.84)" do
    for {fixed, {moonset, _, _, _} = _date} <- SampleDates.fixed_with(:moonset) do
      moonset_mecca = moonset(fixed, mecca())
      if is_nil(moonset) do
        assert moonset_mecca == bogus()
      else
        time = mod(moonset_mecca, 1)
        assert trunc(time * 1000) == trunc(moonset * 1000)
      end
    end
  end

end