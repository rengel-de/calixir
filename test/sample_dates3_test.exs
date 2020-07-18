defmodule SampleDates3Test do
  use ExUnit.Case

  import Calixir

  alias Calixir.SampleDates

  # === Sample Data - dates3.csv - DR4 449

  test "Persian - Astronomical - DR4 260 (15.6)" do
    for {fixed, date} <- SampleDates.fixed_with(:persian) do
      assert persian_from_fixed(fixed) == date
      assert fixed_from_persian(date) == fixed
    end
  end

  test "Persian - Arithmetic - DR4 263 (15.10)" do
    for {fixed, date} <- SampleDates.fixed_with(:arithmetic_persian) do
      assert arithmetic_persian_from_fixed(fixed) == date
      assert fixed_from_arithmetic_persian(date) == fixed
    end
  end

  test "Bahai - Western - DR4 272 (16.4)" do
    for {fixed, date} <- SampleDates.fixed_with(:bahai) do
      assert bahai_from_fixed(fixed) == date
      assert fixed_from_bahai(date) == fixed
    end
  end

  test "Bahai - Astronomical - DR4 275 (16.9)" do
    for {fixed, date} <- SampleDates.fixed_with(:astro_bahai) do
      assert astro_bahai_from_fixed(fixed) == date
      assert fixed_from_astro_bahai(date) == fixed
    end
  end

  test "French Revolutionary - Original - DR4 284 (17.6)" do
    for {fixed, date} <- SampleDates.fixed_with(:french) do
      assert french_from_fixed(fixed) == date
      assert fixed_from_french(date) == fixed
    end
  end

  test "French Revolutionary - Modified - DR4 285 (17.10)" do
    for {fixed, date} <- SampleDates.fixed_with(:arithmetic_french) do
      assert arithmetic_french_from_fixed(fixed) == date
      assert fixed_from_arithmetic_french(date) == fixed
    end
  end

  test "Easter (same year) - Julian - DR4 146 (9.1)" do
    for {fixed, date} <- SampleDates.fixed_with(:orthodox_easter) do
      year = gregorian_year_from_fixed(fixed)
      assert orthodox_easter(year) |> gregorian_from_fixed == date
      assert alt_orthodox_easter(year) |> gregorian_from_fixed == date
    end
  end

  test "Easter (same year) - Gregorian - DR4 148 (9.3)" do
    for {fixed, date} <- SampleDates.fixed_with(:easter) do
      year = gregorian_year_from_fixed(fixed)
      assert easter(year) |> gregorian_from_fixed == date
    end
  end

  test "Easter (same year) - Astronomical - DR4 292 (18.9)" do
    for {fixed, date} <- SampleDates.fixed_with(:astronomical_easter) do
      year = gregorian_year_from_fixed(fixed)
      assert astronomical_easter(year) |> gregorian_from_fixed == date
    end
  end

end

