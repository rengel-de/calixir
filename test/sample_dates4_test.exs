defmodule SampleDates4Test do
  use ExUnit.Case

  import Calixir

  alias Calixir.SampleDates

  # === Sample Data - dates4.csv - DR4 450

  test "Mayan - Long Count - DR4 171 (11.3)" do
    for {fixed, date} <- SampleDates.fixed_with(:mayan_long_count) do
      assert mayan_long_count_from_fixed(fixed) == date
      assert fixed_from_mayan_long_count(date) == fixed
    end
  end

  test "Mayan - Haab - DR4 173 (11.6)" do
    for {fixed, date} <- SampleDates.fixed_with(:mayan_haab) do
      assert mayan_haab_from_fixed(fixed) == date
    end
  end

  test "Aztec - Xihuitl - DR4 178 (11.17)" do
    for {fixed, date} <- SampleDates.fixed_with(:aztec_xihuitl) do
      assert aztec_xihuitl_from_fixed(fixed) == date
    end
  end

  test "Aztec - Tonalpohualli - DR4 179 (11.21)" do
    for {fixed, date} <- SampleDates.fixed_with(:aztec_tonalpohualli) do
      assert aztec_tonalpohualli_from_fixed(fixed) == date
    end
  end

  test "Balinese - Pawukon - DR4 185 (12.1)" do
    for {fixed, date} <- SampleDates.fixed_with(:bali_pawukon) do
      assert bali_pawukon_from_fixed(fixed) == date
    end
  end

  test "Babylonian - DR4 291 (18.8)" do
    for {fixed, date} <- SampleDates.fixed_with(:babylonian) do
      assert babylonian_from_fixed(fixed) == date
      assert fixed_from_babylonian(date) == fixed
    end
  end

  test "Samaritan - DR4 302 (18.35)" do
    for {fixed, date} <- SampleDates.fixed_with(:samaritan) do
      assert samaritan_from_fixed(fixed) == date
      assert fixed_from_samaritan(date) == fixed
    end
  end

end

