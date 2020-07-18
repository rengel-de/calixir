defmodule SampleDates2Test do
  use ExUnit.Case

  import Calixir

  alias Calixir.SampleDates

  # === Sample Data - dates2.csv - DR4 448

  test "Akan - DR4 38 (1.79)" do
    for {fixed, date} <- SampleDates.fixed_with(:akan_name) do
      assert akan_day_name_from_fixed(fixed) == date
    end
  end

  test "Coptic - DR4 91 (4.4)" do
    for {fixed, date} <- SampleDates.fixed_with(:coptic) do
      assert coptic_from_fixed(fixed) == date
      assert fixed_from_coptic(date) == fixed
    end
  end

  test "Ethiopic - DR4 92 (4.7)" do
    for {fixed, date} <- SampleDates.fixed_with(:ethiopic) do
      assert ethiopic_from_fixed(fixed) == date
      assert fixed_from_ethiopic(date) == fixed
    end
  end

  test "ISO - DR4 96 (5.2)" do
    for {fixed, date} <- SampleDates.fixed_with(:iso) do
      assert iso_from_fixed(fixed) == date
      assert fixed_from_iso(date) == fixed
    end
  end

  test "Icelandic - DR4 101 (6.5)" do
    for {fixed, date} <- SampleDates.fixed_with(:icelandic) do
      assert icelandic_from_fixed(fixed) == date
      assert fixed_from_icelandic(date) == fixed
    end
  end

  test "Islamic - Arithemtic - DR4 108 (7.4)" do
    for {fixed, date} <- SampleDates.fixed_with(:islamic) do
      assert islamic_from_fixed(fixed) == date
      assert fixed_from_islamic(date) == fixed
    end
  end

  test "Islamic - Observational - DR4 294 (18.12)" do
    for {fixed, date} <- SampleDates.fixed_with(:observational_islamic) do
      assert observational_islamic_from_fixed(fixed) == date      # DR4 294 (18.12)
      assert fixed_from_observational_islamic(date) == fixed      # DR4 293 (18.11)
      assert alt_observational_islamic_from_fixed(fixed) == date  # DR4 295 (18.16)
      assert alt_fixed_from_observational_islamic(date) == fixed  # DR4 295 (18.15)
    end
  end

  test "Islamic - Umm al-Qura - DR4 296 (18.20)" do
    for {fixed, date} <- SampleDates.fixed_with(:saudi_islamic) do
      assert saudi_islamic_from_fixed(fixed) == date
      assert fixed_from_saudi_islamic(date) == fixed
    end
  end

  test "Hebrew - Standard - DR4 123 (8.28)" do
    for {fixed, date} <- SampleDates.fixed_with(:hebrew) do
      assert hebrew_from_fixed(fixed) == date
      assert fixed_from_hebrew(date) == fixed
    end
  end

  test "Hebrew - Observational - DR4 298 (18.23)" do
    for {fixed, date} <- SampleDates.fixed_with(:observational_hebrew) do
      assert observational_hebrew_from_fixed(fixed) == date      # DR4 298 (18.23)
      assert fixed_from_observational_hebrew(date) == fixed      # DR4 298 (18.24)
      assert alt_observational_hebrew_from_fixed(fixed) == date  # DR4 299 (18.26)
      assert alt_fixed_from_observational_hebrew(date) == fixed  # DR4 299 (18.27)
    end
  end

end

