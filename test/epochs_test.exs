defmodule EpochsTest do
  use ExUnit.Case

  import Calixir

  test "epochs" do

    assert babylonian_epoch() == fixed_from_julian(bce(311), 4, 3)

    assert bahai_epoch() == fixed_from_gregorian(1844, 3, 21)

    assert chinese_epoch() == fixed_from_gregorian(-2636, 2, 15)

    assert coptic_epoch() == fixed_from_julian(284, 8, 29)

    assert egyptian_epoch() == fixed_from_jd(1448638)

    assert ethiopic_epoch() == fixed_from_julian(8, 8, 29)

    assert french_epoch() == fixed_from_gregorian(1792, 9, 22)

    assert gregorian_epoch() == fixed_from_gregorian(1, 1, 1)

    assert hebrew_epoch() == fixed_from_julian(bce(3761), 10, 7)

    assert hindu_epoch() == fixed_from_julian(bce(3102), 2, 18)

    assert islamic_epoch() == fixed_from_julian(622, 7, 16)

    assert icelandic_epoch() == fixed_from_gregorian(1, 4, 19)

    assert jd_epoch() == fixed_from_julian(bce(4713), 1, 1) + 0.5
    assert jd_epoch() == fixed_from_gregorian(-4713, 11, 24) + 0.5

    assert julian_epoch() == fixed_from_gregorian(0, 12, 30)

    assert mjd_epoch() == fixed_from_gregorian(1858, 11, 17)

    assert persian_epoch() == fixed_from_julian(622, 3, 19)

    assert samaritan_epoch() == fixed_from_julian(bce(1639), 3, 15)

    assert tibetan_epoch() == fixed_from_gregorian(-127, 12, 7)

    assert unix_epoch() == fixed_from_gregorian(1970, 1, 1)

  end

end
