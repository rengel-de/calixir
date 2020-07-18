defmodule SampleDates5Test do
  use ExUnit.Case

  import Calixir

  alias Calixir.SampleDates

  # === Sample Data - dates5.csv - DR4 451

  test "Chinese - Date - DR4 317 (19.16)" do
    for {fixed, date} <- SampleDates.fixed_with(:chinese) do
      assert chinese_from_fixed(fixed) == date
      assert fixed_from_chinese(date) == fixed
    end
  end

  test "Chinese - Name - DR4 320 (19.24)" do
    for {fixed, chinese_day_name} <- SampleDates.fixed_with(:chinese_day_name) do
      assert chinese_day_name(fixed) == chinese_day_name
    end
  end

  test "Chinese - Next Zhongqi - DR4 308 (19.4)" do
    for {fixed, next_zhongqi} <- SampleDates.fixed_with(:next_zhongqi) do
      assert abs(major_solar_term_on_or_after(fixed) - next_zhongqi) < 0.0001
    end
  end

  test "Hindu Solar - Old - DR4 159 (10.8)" do
    for {fixed, date} <- SampleDates.fixed_with(:old_hindu_solar) do
      assert old_hindu_solar_from_fixed(fixed) == date
      assert fixed_from_old_hindu_solar(date) == fixed
    end
  end

  test "Hindu Solar - Modern - DR4 347 (20.20)" do
    for {fixed, date} <- SampleDates.fixed_with(:hindu_solar) do
      assert hindu_solar_from_fixed(fixed) == date
      assert fixed_from_hindu_solar(date) == fixed
    end
  end

  test "Hindu Solar - Astronomical - DR4 360 (20.45)" do
    for {fixed, date} <- SampleDates.fixed_with(:astro_hindu_solar) do
      assert astro_hindu_solar_from_fixed(fixed) == date
      assert fixed_from_astro_hindu_solar(date) == fixed
    end
  end

  test "Hindu Lunar - Old - DR4 165 (10.13)" do
    for {fixed, date} <- SampleDates.fixed_with(:old_hindu_lunar) do
      assert old_hindu_lunar_from_fixed(fixed) == date
      assert fixed_from_old_hindu_lunar(date) == fixed
    end
  end

  test "Hindu Lunar - Modern - DR4 349 (20.23)" do
    for {fixed, date} <- SampleDates.fixed_with(:hindu_lunar) do
      assert hindu_lunar_from_fixed(fixed) == date
      assert fixed_from_hindu_lunar(date) == fixed
    end
  end

  test "Hindu Lunar - Astronomical - DR4 361 (20.48)" do
    for {fixed, date} <- SampleDates.fixed_with(:astro_hindu_lunar) do
      assert astro_hindu_lunar_from_fixed(fixed) == date
      assert fixed_from_astro_hindu_lunar(date) == fixed
    end
  end

  test "Tibetan - DR4 378 (21.5)" do
    for {fixed, date} <- SampleDates.fixed_with(:tibetan) do
      assert tibetan_from_fixed(fixed) == date
      assert fixed_from_tibetan(date) == fixed
    end
  end


end

