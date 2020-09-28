defmodule Calixir do
  @moduledoc """
  Documentation for Calixir.

  This module contains all the translated functions of
  `calendrica-4.0.cl` ordered as presented in DR4.

  Some functions are not needed for calendar conversions,
  thus they have been omitted.
  """

  import Kernel, except: [round: 1]

  @type duration :: number
  @type meters :: number
  @type fraction_of_day :: number
  @type latitude :: -180..180
  @type longitude :: -180..180
  @type elevation :: meters
  @type zone :: fraction_of_day
  @type location :: {latitude, longitude, elevation, zone}
  @type moment :: number
  @type season :: 0..360
  @type circle :: -180..180

  # === 1. Calendar Basics, DR4 1ff

  # === 1.1 Calendar Units and Taxonomy, DR4 4ff

  # === 1.2 Fixed Day Numbers, DR4 10ff

  @doc """
  Identity function for fixed dates/moments.
  If internal timekeeping is shifted, change `epoch` to be RD date
  of origin of internal count. `epoch` should be an integer.
  see lines 693-699 of calendrica-4.0.cl
  DR4 12 (1.1), rd
  """
  def rd(tee) do
    epoch = 0
    tee - epoch
  end

  # === 1.3 Negative Years, DR4 15

  # === 1.4 Epochs, DR4 15f

  # === 1.5. Julian Day Numbers, DR4 16ff

  @doc """
  Returns the moment corresponding to the Julian Day Number `0`.
  JD0 = noon on Monday, January 1, 4713 B.C.E. (Julian)
      = noon on November 24, -4713 (Gregorian)
  DR4 18 (1.3), jd-epoch
  """
  def jd_epoch, do: -1_721_424.5

  @doc """
  Returns the moment corresponding to the Julian Day Number `jd`.
  DR4 18 (1.4), moment-from-jd
  """
  def moment_from_jd(jd), do: jd + jd_epoch()

  @doc """
  Returns the Julian Day Number `jd` corresponding to the moment `tee`.
  DR4 18 (1.5), jd-from-moment
  """
  def jd_from_moment(tee), do: tee - jd_epoch()

  @doc """
  MJD Epoch.
  = midnight on Wednesday, November 17, 1858 (Gregorian)
  DR4 19 (1.6), mjd-epoch
  """
  def mjd_epoch, do: 678_576    # R.D. = Fixed

  @doc """
  Returns the fixed date corresponding to the MJD Number `mjd`.
  DR4 19 (1.7), fixed-from-mjd
  """
  def fixed_from_mjd(mjd), do: mjd + mjd_epoch()

  @doc """
  Returns the MJD Number `mjd` corresponding to `fixed` date.
  DR4 19 (1.8), mjd-from-fixed
  """
  def mjd_from_fixed(fixed), do: fixed - mjd_epoch()

  # === 1.6 Unix Time Representation, DR4 19

  @doc """
  Returns the moment corresponding to the Unix epoch.
  = midnight Universal Time on January 1, 1970 (Gregorian)
  DR4 19 (1.9), unix-epoch
  """
  def unix_epoch, do: 719_163

  @doc """
  Returns the moment corresponding to the Unix date `s`.
  DR4 19 (1.10), moment-from-unix
  """
  def moment_from_unix(s), do: unix_epoch() + s / (24 * 60 * 60)
  def fixed_from_unix(s), do: floor(moment_from_unix(s))

  @doc """
  Returns the moment corresponding to the Unix date `s`.
  DR4 19 (1.11), unix-from-moment
  """
  def unix_from_moment(tee), do: (24 * 60 * 60) * (tee - unix_epoch())
  def unix_from_fixed(fixed), do: unix_from_moment(fixed * 1.0)

  # === 1.7 Mathematical Notation, DR4 20ff

  @doc """
  Returns the `fixed` date corresponing to moment `tee`.
  DR4 20 (1.12), fixed-from-moment
  """
  def fixed_from_moment(tee), do: floor(tee)

  @doc """
  Returns the `fixed` date corresponing to moment `tee`.
  DR4 20 (1.13), fixed-from-jd
  """
  def fixed_from_jd(tee), do: floor(moment_from_jd(tee))

  @doc """
  Returns the Julian Day Number `jd` corresponding to the moment `tee`.
  DR4 20 (1.14), jd-from-fixed
  """
  def jd_from_fixed(fixed), do: jd_from_moment(fixed)

  @doc """
  Rounded value.
  DR4 20 (1.15), round
  """
  def round(x), do: floor(x + 0.5)

  @doc """
  Sign of `y`.
  DR4 20 (1.16), sign
  """
  def sign(y), do: y < 0 && -1 || y > 0 && 1 || 0

  @doc """
  Modified modulo function.
  DR4 21 (1.17)
  """
  def mod(x, y), do: x - y * floor(x / y)

  @doc """
  Returns the time of day (= the day fraction of a moment).
  DR4 21 (1.18)
  """
  def time_from_moment(tee), do: mod(moment(tee), 1)

  # DR4 21 (1.19), not implemented
  # DR4 21 (1.20), not implemented
  # DR4 21 (1.21), not implemented

  @doc """
  Greatest common denominator.
  DR4 21 (1.22), gcd
  """
  def gcd(x, 0), do: x
  def gcd(x, y), do: gcd(y, mod(x, y))

  @doc """
  Least common multiple.
  DR4 21 (1.23), lcm
  """
  def lcm(x, y), do: floor(x * y / gcd(x, y))

  @doc """
  Returns the Interval Modulus.
  The value of `x` shifted into the range
  [`a`..`b`). Returns `x` if `a=b`.
  DR4 22 (1.24), mod3 aka imod
  """
  # works with floats and integers
  def mod3(x, a, b) when a == b, do: x
  def mod3(x, a, b), do: a + mod(x - a, b - a)
  # works with integers only
  def imod(x, a..b) when a == b, do: x
  def imod(x, a..b), do: a + mod(x - a, b - a)

  # DR4 22 (1.25), not implemented
  # DR4 22 (1.26), not implemented
  # DR4 22 (1.27), not implemented

  @doc """
  Returns the adjusted modulus of `x` and `y`.
  DR4 22 (1.28)
  """
  def amod(x, y), do: y + mod(x, -y)

  # DR4 22 (1.29), not implemented

  @doc """
  Sum `expression` for `index` = `initial` and successive integers,
  as long as `condition` holds.
  DR4 23 (1.30), lines 634-641 of calendrica-4.0.cl
  """
  @spec sum((integer -> number), integer, (integer -> boolean)) :: number
  def sum(expression, initial, condition) do
    if not condition.(initial),
       do: 0,
       else: expression.(initial) + sum(expression, initial + 1, condition)
  end

  @doc """
  Product of `expression` for `index` = `initial` and successive integers,
  as long as `condition` holds.
  DR4 23 (1.31), lines 643-651 of calendrica-4.0.cl
  """
  @spec prod((integer -> number), integer, (integer -> boolean)) :: number
  def prod(expression, initial, condition) do
    if not condition.(initial),
       do: 1,
       else: expression.(initial) * prod(expression, initial + 1, condition)
  end

  # === 1.8 Search, DR4 23ff

  @doc """
  Returns the first integer greater or equal to initial index `i`
  such that condition `p` holds.
  DR4 23 (1.32), MIN
  """
  def next(i, p), do: p.(i) && i || next(i + 1, p)

  @doc """
  Returns the last integer greater or equal to initial index, `i`
  such that condition `p` holds.
  DR4 24 (1.33), MAX
  """
  def final(i, p), do: not p.(i) && i - 1 || final(i + 1, p)

  # DR4 24 (1.34), not implemented

  @doc """
  Bisection search for `x` in [`lo`..`hi`] such that condition `e` holds.
  `p` determines when to go left.
  lines 653-663 of calendrica-4.0.cl
  DR4 24 (1.35), binary-search
  """
  # @spec binary_search(number, number, (number -> boolean),number, (number -> boolean)) :: number
  def binary_search(lo, hi, p, e) do
    x = (lo + hi) / 2
    if p.(lo, hi) do
      x
    else
      if e.(x) do
        binary_search(lo, x, p, e)
      else
        binary_search(x, hi, p, e)
      end
    end
  end

  @doc """
  Use bisection to find inverse of angular function
  `f` at `y` within interval `a`..`b`.
  lines 665-672 of calendrica-4.0.cl
  DR4 25 (1.36), invert-angular
  """
  def invert_angular(f, y, a, b), do: invert_angular(f, y, a, b, 1 / 10000)
  def invert_angular(f, y, a, b, epsilon) do
    binary_search(a, b,
      fn lo, hi -> hi - lo <= epsilon end,
      fn x -> mod(f.(x) - y, 360) < 180 end)
  end

  # === 1.9 Dates and Lists

  @doc """
  Convert each element of a list of moments into a fixed date.
  DR4 26 (1.37), list-of-fixed-from-moments
  """
  def list_of_fixed_from_moments([]), do: []
  def list_of_fixed_from_moments([head | tail]) do
    [fixed_from_moment(head)] ++ list_of_fixed_from_moments(tail)
  end

  @doc """
  True if `tee` is in half_open `range`.
  DR4 26 (1.38), in-range?
  """
  def in_range?(tee, a..b = _range) do
    a <= tee and tee < b
  end

  @doc """
  Those moments in list `ell` that occur in `range`.
  DR4 26 (1.39), list-range
  """
  def list_range(ell, range) do
    Enum.filter(ell, fn x -> x in range end)
  end

  @doc """
  Returns the list of occurrences of n-th day of c-day cycle in `range`.
  `delta` is the position in cycle of RD 0.
  `a` and `b` define the range to be searched.
  DR4 27 (1.40), positions-in-range
  """
  def positions_in_range(p, c, delta, a, b) do
    date = mod3(p - delta, a, a + c)
    if date >= b,
       do:   [],
       else: [date] ++ positions_in_range(p, c, delta, a + c, b)
  end

  # === 1.10 Mixed-Radix Notation, DR4 27ff

  @doc """
  The number corresponding to `a` in radix notation
  with base `b` for whole part and `c` for fraction.
  DR4 27 (1.41), from-radix
  """
  @spec from_radix([number], [number], [number]) :: number
  def from_radix(a, b), do: from_radix(a, b, [])
  def from_radix(a, b, c) do
    sum(
      fn i ->
        Enum.fetch!(a, i) *
          prod(fn j -> Enum.fetch!(b ++ c, j) end, i, fn j -> j < length(b) + length(c) end)
      end,
      0,
      fn i -> i < length(a) end
    ) / Enum.reduce(c, 1, &(&1 * &2))
  end

  @doc """
  The radix notation corresponding to `x` with base `b`
  for whole part and `c` for fraction.
  DR4 28 (1.42), to-radix
  """
  @spec to_radix(number, [number], [number]) :: [number]
  def to_radix(x, b, c \\ [])

  def to_radix(x, [], []), do: [x]

  def to_radix(x, b, []) do
    pos = length(b) - 1
    bpos = Enum.fetch!(b, pos)
    to_radix(floor(x / bpos), Enum.take(b, pos)) ++ [mod(x, bpos)]
  end

  def to_radix(x, b, c) do
    to_radix(x * Enum.reduce(c, 1, &(&1 * &2)), b ++ c)
  end

  @doc """
  Time of day from `hms` = hour:minute:second.
  DR4 28 (1.43), time-from-clock
  """
  def time_from_clock(h, m, s), do: time_from_clock({h, m, s})

  def time_from_clock({h, m, s} = _clock) do
    (h + ((m + (s / 60)) / 60)) / 24
  end

  @doc """
  Clock time hour:minute:second from moment `tee`.
  DR4 28 (1.44), clock-from-moment
  """
  def clock_from_moment(tee) do
    time = time_from_moment(tee)
    hour = floor(time * 24)
    minute = floor(mod(time * 1440, 60))
    second = trunc(mod(time * 86_400, 60))
    {hour, minute, second}
  end

  @doc """
  Convert a number of degrees into a list of degrees.
  DR4 29 (1.45)
  """
  def angle_from_degrees(alpha) do
    [dms0, dms1, dms2] = dms = to_radix(abs(alpha), [], [60, 60])
    alpha >= 0 and dms || [-dms0, -dms1, -dms2]
  end

  @doc """
  Convert angle `d` degrees, `m` arcminutes, `s` arcseconds
  into decimal degrees.
  Alternate Variant!
  DR4 29 (1.45)
  """
  def angle({d, m, s}), do: angle(d, m, s)
  def angle(d, m, s), do: d + (m + s / 60) / 60

  # === 1.11 A Simple Calendar, DR4 29ff

  @doc """
  Epyptian Epoch.
  ```
  The epoch chosen by the famous Alexandrian astronomer Ptolemy,
  author of the __Almagest__, for this calendar, and called the
  __Nabonassar Era__ fater the Chaldean king Nobonassar, is given ...
  as JD 1448638.
  ```
  = February 26, 747 BCE (Julian)
  DR4 30 (1.46), egyptian-epoch
  """
  def egyptian_epoch, do: fixed_from_jd(1448638)

  @doc """
  Returns the `fixed` date corresponding to the Egyptian date.
  DR4 30 (1.47), fixed-from-egyptian
  """
  def fixed_from_egyptian({year, month, day}) do
    fixed_from_egyptian(year, month, day)
  end

  def fixed_from_egyptian(year, month, day) do
    egyptian_epoch() + 365 * (year - 1) + 30 * (month - 1) + day - 1
  end

  @doc """
  Returns the `fixed_date` corresponding to the Egyptian date.
  (Alternate calculation)
  DR4 31 (1.48), alt-fixed-from-egyptian
  """
  def alt_fixed_from_egyptian({year, month, day}) do
    alt_fixed_from_egyptian(year, month, day)
  end

  def alt_fixed_from_egyptian(year, month, day) do
    l1 = [365, 30, 1]
    l2 = Enum.map([year, month, day], &(&1 - 1))
    l = [l1, l2]
    b = fn {x, y} -> x * y end
    egyptian_epoch() + sigma(l, b)
  end

  @doc """
  Returns the Egyptian date `{year, month, day}` corresponding to `fixed_date`.
  DR4 31 (1.49), egyptian-from-fixed
  """
  def egyptian_from_fixed(fixed) do
    days = fixed - egyptian_epoch()
    year = floor(days / 365) + 1
    month = floor(mod(days, 365) / 30) + 1
    day = days - 365 * (year - 1) - 30 * (month - 1) + 1
    {year, month, day}
  end

  @doc """
  Armenian Epoch.
  DR4 31 (1.50), armenian-epoch
  """
  def armenian_epoch, do: 201443

  @doc """
  Returns the `fixed` date corresponding to the Armenian date.
  DR4 31 (1.51), fixed-from-armenian
  """
  def fixed_from_armenian({year, month, day}) do
    fixed_from_armenian(year, month, day)
  end

  def fixed_from_armenian(year, month, day) do
    armenian_epoch() + fixed_from_egyptian(year, month, day) - egyptian_epoch()
  end

  @doc """
  Returns the Armenian date `{year, month, day}` corresponding to `fixed_date`.
  DR4 31 (1.52), armenian-from-fixed
  """
  def armenian_from_fixed(fixed) do
    egyptian_from_fixed(fixed + egyptian_epoch() - armenian_epoch())
  end

  # === 1.12 Cycles of Days, DR4 33ff

  def sunday,    do: 0   # DR4 33 (1.53)
  def monday,    do: 1   # DR4 33 (1.54)
  def tuesday,   do: 2   # DR4 33 (1.55)
  def wednesday, do: 3   # DR4 33 (1.56)
  def thursday,  do: 4   # DR4 33 (1.57)
  def friday,    do: 5   # DR4 33 (1.58)
  def saturday,  do: 6   # DR4 33 (1.59)

  @doc """
  Returns the weekday of `fixed`.
  DR4 33 (1.60)
  """
  def day_of_week_from_fixed(fixed) when is_tuple(fixed) do
    day_of_week_from_fixed(elem(fixed, 1))
  end

  def day_of_week_from_fixed(fixed) do
    mod(fixed - rd(0) - sunday(), 7)
  end

  # DR4 33 (1.61), not implemented

  @doc """
  DR4 34 (1.62)
  """
  def kday_on_or_before(k, fixed) do
    fixed - day_of_week_from_fixed(fixed - k)
  end

  # DR4 34 (1.63), not implemented
  # DR4 34 (1.64), not implemented

  @doc """
  DR4 34 (1.65)
  """
  def kday_on_or_after(k, fixed) do
    kday_on_or_before(k, fixed + 6)
  end

  @doc """
  DR4 34 (1.66)
  """
  def kday_nearest(k, fixed) do
    kday_on_or_before(k, fixed + 3)
  end

  @doc """
  DR4 34 (1.67)
  """
  def kday_before(k, fixed) do
    kday_on_or_before(k, fixed - 1)
  end

  @doc """
  DR4 34 (1.68)
  """
  def kday_after(k, fixed) do
    kday_on_or_before(k, fixed + 7)
  end

  # DR4 34 (1.69), not implemented

  # === 1.13 Simultaneous Cycles, DR4 35ff

  # DR4 35 (1.70), not implemented
  # DR4 36 (1.71), not implemented
  # DR4 36 (1.72), not implemented
  # DR4 36 (1.73), not implemented
  # DR4 37 (1.74), not implemented
  # DR4 37 (1.75), not implemented

  @doc """
  The `n`-th name of the AkanDayName cycle.
  DR4 38 (1.76), akan-day-name
  """
  def akan_day_name(n) do
    {amod(n, 6), amod(n, 7)}
  end

  @doc """
  Number of names from AkanDayName name `a_name1` to the
  next occurrence of AkanDayName name `a_name2`.
  DR4 38 (1.77), akan-name-difference
  """
  def akan_day_name_difference({prefix1, stem1} = _a_name1, {prefix2, stem2} = _a_name2) do
    prefix_difference = prefix2 - prefix1
    stem_difference = stem2 - stem1
    amod(prefix_difference + 36 * (stem_difference - prefix_difference), 42)
  end

  @doc """
  AkanDayName Epoch.
  DR4 38 (1.78), akan-day-name-epoch
  """
  def akan_day_name_epoch, do: rd(37)

  @doc """
  AkanDayName name for `fixed` date.
  DR4 38 (1.79), akan-name-from-fixed
  """
  def akan_day_name_from_fixed(fixed) do
    akan_day_name(fixed - akan_day_name_epoch())
  end

  @doc """
  Fixed date of latest date on or before `fixed` date
  that has AkanDayName `name`.
  DR4 38 (1.80), akan-day-name-on-or-before
  """
  def akan_day_name_on_or_before(name_, fixed) do
    imod(akan_day_name_difference(akan_day_name_from_fixed(0), name_), fixed..(fixed - 42))
  end

  # === 1.14 Cycles of Years, DR4 39ff

  # DR4 39 (1.81), not implemented
  # DR4 39 (1.82), not implemented
  # DR4 41 (1.83), not implemented
  # DR4 41 (1.84), not implemented
  # DR4 41 (1.85), not implemented
  # DR4 42 (1.86), not implemented
  # DR4 42 (1.87), not implemented
  # DR4 42 (1.88), not implemented
  # DR4 42 (1.89), not implemented
  # DR4 43 (1.90), not implemented
  # DR4 43 (1.91), not implemented
  # DR4 43 (1.92), not implemented
  # DR4 44 (1.93), not implemented
  # DR4 44 (1.94), not implemented
  # DR4 45 (1.95), not implemented

  # === 1.15 Approximating the Year Number, DR4 46f

  # DR4 46 (1.96), not implemented

  # === 1.16 Warnings about Calculations, DR4 47ff

  @doc """
  Used to denote nonexistent dates.
  DR4 47 (1.97), bogus
  """
  def bogus, do: "bogus"


  # Part I - Arithmetical Calendars, DR4 53ff

  # === 2 The Gregorian Calendar, DR4 55ff

  # === 2.1 Structure, DR4 55ff

  # DR4 56 (2.1), not implemented
  # DR4 56 (2.2), not implemented

  @doc """
  Gregorian Epoch.
  DR4 58 (2.3), gregorian-epoch = R.D. 1.
  """
  def gregorian_epoch, do: rd(1)

  # === 2.2 Implementation, DR4 59ff

  def january,   do:  1   # DR4 59 (2.4)
  def february,  do:  2   # DR4 59 (2.5)
  def march,     do:  3   # DR4 59 (2.6)
  def april,     do:  4   # DR4 59 (2.7)
  def may,       do:  5   # DR4 59 (2.8)
  def june,      do:  6   # DR4 59 (2.9)
  def july,      do:  7   # DR4 59 (2.10)
  def august,    do:  8   # DR4 59 (2.11)
  def september, do:  9   # DR4 59 (2.12)
  def october,   do: 10   # DR4 59 (2.13)
  def november,  do: 11   # DR4 59 (2.14)
  def december,  do: 12   # DR4 59 (2.15)

  @doc """
  Returns true if the given year is a leap year.
  DR4 59 (2.16), gregorian-leap-year?
  """
  def gregorian_leap_year?(year) do
    mod(year, 4) == 0 and mod(year, 400) not in [100, 200, 300]
  end

  @doc """
  Returns the `fixed` date corresponding to the Gregorian `date`.
  DR4 60 (2.17), fixed-from-gregorian
  """
  def fixed_from_gregorian({year, month, day}) do
    fixed_from_gregorian(year, month, day)
  end

  def fixed_from_gregorian(year, month, day) do
    correction =
      cond do
        month <= 2 -> 0
        gregorian_leap_year?(year) -> -1
        true -> -2
      end

    gregorian_epoch() - 1 +
      365 * (year - 1) +
      floor((year - 1) / 4) -
      floor((year - 1) / 100) +
      floor((year - 1) / 400) +
      floor((367 * month - 362) / 12) +
      correction +
      day
  end

  @doc """
  Returns the Fixed date corresponding the January, 1st of the Gregorian year.
  DR4 60 (2.18), gregorian-new-year
  """
  def gregorian_new_year({year, _, _}), do: fixed_from_gregorian(year, 1, 1)
  def gregorian_new_year(year), do: fixed_from_gregorian(year, 1, 1)

  @doc """
  Returns the Fixed date corresponding the December, 31st of the Gregorian year.
  DR4 60 (2.19), gregorian-year-end
  """
  def gregorian_year_end({year, _, _}), do: fixed_from_gregorian(year, 12, 31)
  def gregorian_year_end(year), do: fixed_from_gregorian(year, 12, 31)

  @doc """
  Returns the range of dates (= number of days) of the Gregorian year `year`.
  DR4 60 (2.20), gregorian-year-range
  """
  def gregorian_year_range({year, _, _}), do: gregorian_year_range(year)
  def gregorian_year_range(year) do
    a = gregorian_new_year(year)
    b = gregorian_new_year(year + 1)
    a..b
  end

  @doc """
  Returns the `year`of the Gregorian date corresponding to the Fixed date `fixed`.
  DR4 61 (2.21), gregorian-year-from-fixed
  """
  def gregorian_year_from_fixed(fixed) do
    d0 = fixed - gregorian_epoch()
    n400 = floor(d0 / 146_097)
    d1 = mod(d0, 146_097)
    n100 = floor(d1 / 36_524)
    d2 = mod(d1, 36_524)
    n4 = floor(d2 / 1_461)
    d3 = mod(d2, 1_461)
    n1 = floor(d3 / 365)

    year = (400 * n400) + (100 * n100) + (4 * n4) + n1 |> trunc
    ((n100 == 4) || (n1 == 4)) && year || year + 1
  end

  @doc """
  Returns the ordinal day of `fixed` in its Gregorian year.
  DR4 61 (2.22)
  """
  def gregorian_ordinal_day(fixed) do
    d0 = fixed - gregorian_epoch()
    d1 = mod(d0, 146_097)
    n100 = floor(d1 / 36_524)
    d2 = mod(d1, 36_524)
    d3 = mod(d2, 1_461)
    n1 = floor(d3 / 365)
    (n1 != 4 and n100 != 4) && mod(d3, 365) + 1 || 366
  end

  @doc """
  Returns the Gregorian date `{year, month, day}` corresponding to `fixed_date`.
  DR4 62 (2.23), gregorian-from-fixed
  """
  def gregorian_from_fixed(fixed) do
    year = gregorian_year_from_fixed(fixed)
    prior_days = fixed - gregorian_new_year(year)
    correction =
      cond do
        fixed < fixed_from_gregorian(year, march(), 1) -> 0
        gregorian_leap_year?(year) -> 1
        true -> 2
      end
    month = floor((12 * (prior_days + correction) + 373) / 367)
    day = floor(fixed - fixed_from_gregorian(year, month, 1) + 1)
    {year, month, day}
  end

  @doc """
  Returns the number of days between two Gregorian dates `date1`, `date2`.
  DR4 62 (2.24), gregorian-date-difference
  """
  def gregorian_date_difference({y1, m1, d1}, {y2, m2, d2}) do
    fixed1 = fixed_from_gregorian(y1, m1, d1)
    fixed2 = fixed_from_gregorian(y2, m2, d2)
    fixed2 - fixed1
  end

  @doc """
  Returns the ordinal day number of the Gregorian date `date`.
  DR4 62 (2.25), day-number
  """
  def day_number({year, _, _} = date) do
    gregorian_date_difference({year - 1, december(), 31}, date)
  end

  @doc """
  Returns the number of days remaining in the Gregorian year after the date `date`.
  DR4 62 (2.26), days-remaining
  """
  def days_remaining({year, _, _} = date) do
    gregorian_date_difference(date, {year, december(), 31})
  end

  @doc """
  Returns the last day of a Gregorian month given by `date` and `month`.
  DR4 63 (2.27), last-day-of-gregorian-month
  """
  def last_day_of_gregorian_month({year, month, _}) do
    last_day_of_gregorian_month(year, month)
  end

  def last_day_of_gregorian_month(year, month) do
    date_1 = {year, month, 1}
    year_2 = if month == 12, do: year + 1, else: year
    month_2 = mod(month + 1, 12)
    date_2 = {year_2, month_2, 1}
    gregorian_date_difference(date_1, date_2)
  end

  # === 2.3 Alternative Formulas, DR4 63ff

  # DR4 65 (2.28), alt-fixed-from-gregorian, not implemented
  # DR4 66 (2.29), alt-gregorian-from-fixed, not implemented
  # DR4 67 (2.30), alt-gregorian-year-from-fixed, not implemented

  # === 2.4 The Zeller Congruence, DR4 67f

  # DR4 68 (2.31), not implemented

  # === 2.5 Holidays, DR4 69ff

  @doc """
  U.S. Indepence Day
  DR4 69 (2.32), independence-day
  """
  def independence_day({year, _, _}), do: independence_day(year)
  def independence_day(year), do: fixed_from_gregorian(year, july(), 4)

  @doc """
  Returns the Fixed date of the `n`-th `k`-day (`n != 0` and `kday` the day
  of the week) on, or after or before, a given Gregorian date `g_date`
  (counting forward when `n > 0`, or backward when `n < 0`).
  DR4 69 (2.33), nth-kday
  """
  def nth_kday(n, k, g_date) do
    cond do
      n > 0 -> 7 * n + kday_before(k, fixed_from_gregorian(g_date))
      n < 0 -> 7 * n + kday_after(k, fixed_from_gregorian(g_date))
      true -> "bogus"
    end
  end

  @doc """
  Returns the Fixed date of the first `k`-day after a given Gregorian date `date`.
  DR4 69 (2.34), first-kday
  """
  def first_kday(k, date), do: nth_kday(1, k, date)

  @doc """
  Returns the Fixed date of the last `k`-day before, a given Gregorian date `date`.
  DR4 69 (2.35), last-kday
  """
  def last_kday(k, date), do: nth_kday(-1, k, date)

  @doc """
  U.S. Labor Day
  DR4 69 (2.36), labor-day
  """
  def labor_day({year, _, _}), do: labor_day(year)
  def labor_day(year), do: first_kday(monday(), {year, september(), 1})

  @doc """
  U.S. Memorial Day
  DR4 70 (2.37), memorial-day
  """
  def memorial_day({year, _, _}), do: memorial_day(year)
  def memorial_day(year), do: last_kday(monday(), {year, may(), 31})

  @doc """
  U.S. Election Day
  DR4 70 (2.38), election-day
  """
  def election_day({year, _, _}), do: election_day(year)
  def election_day(year), do: first_kday(tuesday(), {year, november(), 2})

  @doc """
  U.S. Daylight Saving Start
  DR4 70 (2.39), daylight-saving-start
  """
  def daylight_saving_start({year, _, _}), do: daylight_saving_start(year)
  def daylight_saving_start(year), do: nth_kday(2, sunday(), {year, march(), 1})

  @doc """
  U.S. Daylight Saving End
  (as of 2007, the second Sunday in March and the first Sunday in November)
  DR4 70 (2.40), daylight-saving-end
  """
  def daylight_saving_end({year, _, _}), do: daylight_saving_end(year)
  def daylight_saving_end(year), do: first_kday(sunday(), {year, november(), 1})

  @doc """
  Christmas
  DR4 70 (2.41), christmas
  """
  def christmas({year, _, _}), do: christmas(year)
  def christmas(year), do: fixed_from_gregorian(year, december(), 25)

  @doc """
  Advent
  DR4 70 (2.42), advent
  """
  def advent({year, _, _}), do: advent(year)
  def advent(year), do: kday_nearest(sunday(), fixed_from_gregorian({year, november(), 30}))

  @doc """
  Epiphany
  DR4 71 (2.43), epiphany
  """
  def epiphany({year, _, _}), do: epiphany(year)
  def epiphany(year), do: first_kday(sunday(), {year, january(), 2})

  @doc """
  Unlucky Fridays in Range
  DR4 71 (2.44), unlucky-fridays-in-range
  """
  def unlucky_fridays_in_range(a..b) do
    fri = kday_on_or_after(friday(), a)
    {_, _, day} = gregorian_from_fixed(fri)
    ell = if day == 13, do: [fri], else: []
    if fri not in a..b do
      []
    else
      ell ++ unlucky_fridays_in_range((fri + 1)..b)
    end
  end

  @doc """
  Unlucky Fridays
  DR4 71 (2.45), unlucky-fridays
  """
  def unlucky_fridays({year, _, _}) do
    unlucky_fridays(year)
  end

  def unlucky_fridays(year) do
    year |> gregorian_year_range |> unlucky_fridays_in_range
  end

  # === 3 The Julian Calendar, DR4 75ff

  # === 3.1 Structure and implementation, DR4 75ff

  @doc """
  Returns true if the given year is a leap year.
  DR4 75 (3.1), julian-leap-year
  """
  def julian_leap_year?(year) when year > 0, do: mod(year, 4) == 0
  def julian_leap_year?(year), do: mod(year, 4) == 3

  @doc """
  Julian Epoch.
  {:gregorian, {0, 12, 30}}
  DR4 76 (3.2), julian-epoch
  """
  def julian_epoch, do: -1

  @doc """
  Returns the `fixed` date corresponding to the `date`.
  DR4 76 (3.3), fixed-from-julian
  """
  def fixed_from_julian({year, month, day}) do
    fixed_from_julian(year, month, day)
  end

  def fixed_from_julian(year, month, day) do
    y = (year < 0) && (year + 1) || year

    correction =
      cond do
        month <= 2 -> 0
        julian_leap_year?(year) -> -1
        true -> -2
      end

    julian_epoch() - 1 +
      365 * (y - 1) +
      floor((y - 1) / 4) +
      floor((367 * month - 362) / 12) +
      correction +
      day
  end

  @doc """
  Returns the Julian date `{year, month, day}` corresponding to `fixed_date`.
  DR4 76 (3.4), julian-from-fixed
  """
  def julian_from_fixed(fixed) do
    approx = floor((4 * (fixed - julian_epoch()) + 1464) / 1461)
    year = (approx <= 0) && (approx - 1) || approx
    prior_days = fixed - fixed_from_julian(year, 1, 1)

    correction =
      cond do
        fixed < fixed_from_julian(year, 3, 1) -> 0
        julian_leap_year?(year) -> 1
        true -> 2
      end

    month = floor((12 * (prior_days + correction) + 373) / 367)
    day = fixed - fixed_from_julian(year, month, 1) + 1
    {year, month, day}
  end

  # === 3.2 Roman Nomenclature, DR4 77ff

  @doc """
  Kalends, Nones, and Ides.
  __
  The *kalends* are always the first of the month.
  The *ides* are near the middle of the month - the thirteenth
  of the month, ecept in March, May, July, and October, when
  they fall on the fifteenth...
  The *nones* are always 8 days before the ides.
  DR4 77
  __
  """
  def kalends, do: 1    # DR4 77 (3.5)
  def nones,   do: 2    # DR4 77 (3.6)
  def ides,    do: 3    # DR4 77 (3.7)

  @doc """
  Ides of month.
  DR4 77 (3.8), ides-of-month
  """
  def ides_of_month(month) when month in [3, 5, 7, 10], do: 15
  def ides_of_month(_), do: 13

  @doc """
  Nones of month.
  DR4 78 (3.9), nones_of_month
  """
  def nones_of_month(month), do: ides_of_month(month) - 8

  @doc """
  Returns the `fixed` date corresponding to the Roman `date`.
  DR4 80 (3.10), fixed-from-roman
  """
  def fixed_from_roman({year, month, event, count, leap}) do
    fixed_from_roman(year, month, event, count, leap)
  end

  def fixed_from_roman(year, month, event, count, leap) do
    day =
      cond do
        event == kalends() -> 1
        event == nones() -> nones_of_month(month)
        event == ides() -> ides_of_month(month)
      end
    fixed = fixed_from_julian(year, month, day)
    julian_leap_corr = (
      julian_leap_year?(year) and
      month == march() and
      event == kalends() and
      16 >= count and count >= 6
      ) && 0 || 1
    roman_leap_corr = leap && 1 || 0

    fixed - count + julian_leap_corr + roman_leap_corr
  end

  @doc """
  Returns the Romam date corresponding to the `fixed` date.
  DR4 80 (3.11), roman-from-fixed
  """
  def roman_from_fixed(fixed) do
    {year, month, day} = julian_from_fixed(fixed)
    nones = nones_of_month(month)
    ides = ides_of_month(month)

    cond do
      day == 1 ->
        {year, month, kalends(), 1, false}

      day <= nones ->
        {year, month, nones(), nones - day + 1, false}

      day <= ides ->
        {year, month, ides(), ides - day + 1, false}

      month != february() or not julian_leap_year?(year) ->
        (month = amod(month + 1, 12)
         year = (month != 1 && year) || (year != -1 && year + 1) || 1
         kalends = fixed_from_roman(year, month, kalends(), 1, false)
         {year, month, kalends(), kalends - fixed + 1, false})

      day < 25 ->
        {year, march(), kalends(), 30 - day, false}

      true ->
        {year, march(), kalends(), 31 - day, day == 25}
    end
  end

  # === 3.3 Roman Years, DR4 81

  @doc """
  Returns the year on the Julian calendar of the founding of Rome.
  DR4 81 (3.12), year-rome-founded
  """
  def year_rome_founded, do: bce(753)

  @doc """
  Returns the Julian year equivalent to AUC `year`.
  DR4 81 (3.13), julian-year-from-auc
  """
  def julian_year_from_auc(year) do
    if 1 <= year and year <= -year_rome_founded() do
      year + year_rome_founded() - 1
    else
      year + year_rome_founded()
    end
  end

  @doc """
  Returns the year AUC equivalent to Julian `year`.
  DR4 81 (3.14), auc-year-from-julian
  """
  def julian_year_to_auc(year) do
    if year_rome_founded() <= year and year <= -1 do
      year - year_rome_founded() + 1
    else
      year - year_rome_founded()
    end
  end

  # === 3.4 Olympiads, DR4 82

  @doc """
  Returns the start of the Olympiads.
  DR4 82 (3.15), olympiad-start
  """
  def olympiad_start, do: bce(776)

  @doc """
  Returns the year on the Julian calendar of the olympiad.
  DR4 82 (3.16), julian-year-from-olympiad
  """
  def julian_year_from_olympiad({cycle, year} = _o_date) do
    years = olympiad_start() + 4 * (cycle - 1) + year - 1
    (years < 0 && years) || (years + 1)
  end

  @doc """
  Returns the Olympiad corresponding to Julian year `j_year`.
  DR4 82 (3.17), olympiad-from-julian-year
  """
  def olympiad_from_julian_year({j_year, _, _} = _j_date) do
    olympiad_from_julian_year(j_year)
  end

  def olympiad_from_julian_year(j_year) do
    offset = (j_year < 0 && 0) || 1
    years = j_year - olympiad_start() - offset
    cycle = floor(years / 4) + 1
    year = mod(years, 4) + 1
    {cycle, year}
  end

  # === 3.5 Seasons, DR4 83f

  def spring, do:   0  # DR4 83 (3.18)
  def summer, do:  90  # DR4 83 (3.19)
  def autumn, do: 180  # DR4 83 (3.20)
  def winter, do: 270  # DR4 83 (3.21)

  @doc """
  Returns the occurrences of seasons in `g_year` with `year_length`.
  DR4 83 (3.22), cycle-in-gregorian
  """
  def cycle_in_gregorian(season, g_year, year_length, start) do
    a..b = gregorian_year_range(g_year)
    pos = (season / 360) * year_length
    delta = pos - mod(start, year_length)
    positions_in_range(pos, year_length, delta, a, b)
  end

  @doc """
  DR4 84 (3.23), julian-season-in-gregorian
  """
  def julian_season_in_gregorian(season, g_year) do
    year_length = 365.25   # = 365 + 6h
    offset = (season / 360) * year_length
    start = fixed_from_julian(bce(1), march(), 23) + offset
    cycle_in_gregorian(season, g_year, year_length, start)
  end

  # === 3.6 Holidays, DR4 84f

  @doc """
  Returns the list of the fixed dates of Julian month `j_month` and
  Julian day `j_day` that occur in Gregorian year `g_year`.
  DR4 85 (3.24), julian-in-gregorian
  """
  def julian_in_gregorian(j_month, j_day, g_year) do
    year_range = gregorian_year_range(g_year)
    jan1 = gregorian_new_year(g_year)
    {y, _, _} = julian_from_fixed(jan1)
    y_corr = (y == -1 && 1) || y + 1
    date0 = fixed_from_julian(y, j_month, j_day)
    date1 = fixed_from_julian(y_corr, j_month, j_day)
    Enum.filter([date0, date1], &(&1 in year_range))
  end

  @doc """
  DR4 85 (3.25), eastern-orthodox-christmas
  """
  def eastern_orthodox_christmas(g_year) do
    julian_in_gregorian(december(), 25, g_year)
  end

  # === 4 The Coptic and Ethiopic Calendars, DR4 89ff

  # === 4.1 The Coptic Calendar, DR4 89ff

  @doc """
  Coptic Epoch.
  `= fixed-from-julian(ce(284), august, 29)`
  DR4 90 (4.1), coptic-epoch
  """
  def coptic_epoch, do: 103605

  @doc """
  Returns true if the given year is a leap year.
  DR4 90 (4.2), coptic-leap-year?
  """
  def coptic_leap_year?(year), do: mod(year, 4) == 3

  @doc """
  Returns the `fixed_date` corresponding to the Coptic date.
  DR4 90 (4.3), fixed-from-coptic
  """
  def fixed_from_coptic({year, month, day}) do
    fixed_from_coptic(year, month, day)
  end

  def fixed_from_coptic(year, month, day) do
    coptic_epoch() - 1 +
      365 * (year - 1) +
      floor(year / 4) +
      30 * (month - 1) +
      day
  end

  @doc """
  Returns the Coptic date `{year, month, day}` corresponding to `fixed_date`.
  DR4 91 (4.4), coptic-from-fixed
  """
  def coptic_from_fixed(fixed) do
    year = floor((4 * (fixed - coptic_epoch()) + 1463) / 1461)
    month = floor((fixed - fixed_from_coptic(year, 1, 1)) / 30) + 1
    day = fixed + 1 - fixed_from_coptic(year, month, 1)
    {year, month, day}
  end

  # === 4.2 The Ethiopic Calendar, DR4 91f

  @doc """
  Ethiopic Epoch.
  = August 29, 8 CE (Julian)
  DR4 92 (4.5), ethiopic-epoch
  """
  def ethiopic_epoch, do: 2796

  @doc """
  Returns the Fixed date corresponding to the Ethiopic date.
  DR4 92 (4.6), fixed-from-ethiopic
  """
  def fixed_from_ethiopic({year, month, day}) do
    fixed_from_ethiopic(year, month, day)
  end

  def fixed_from_ethiopic(year, month, day) do
    ethiopic_epoch() + fixed_from_coptic(year, month, day) - coptic_epoch()
  end

  @doc """
  Returns the Ethiopic date `{year, month, day}` corresponding to `fixed`.
  DR4 92 (4.7), ethiopic-from-fixed
  """
  def ethiopic_from_fixed(fixed) do
    coptic_from_fixed(fixed + coptic_epoch() - ethiopic_epoch())
  end

  # === 4.3 Holidays, DR4 92f

  @doc """
  Returns the list of the fixed dates of Coptic month `c_month` and
  Coptic day `c_day` that occur in Gregorian year `g_year`.
  DR4 92 (4.8), coptic-in-gregorian
  """
  def coptic_in_gregorian(c_month, c_day, g_year) do
    year_range = gregorian_year_range(g_year)
    jan1 = gregorian_new_year(g_year)
    {y, _, _} = coptic_from_fixed(jan1)
    date0 = fixed_from_coptic(y, c_month, c_day)
    date1 = fixed_from_coptic(y + 1, c_month, c_day)
    Enum.filter([date0, date1], &(&1 in year_range))
  end

  @doc """
  Coptic Christmas.
  DR4 93 (4.9), coptic-christmas
  """
  def coptic_christmas(g_year) do
    coptic_in_gregorian(4, 29, g_year)
  end

  # === 5 The ISO Calendar, DR4 95ff

  @doc """
  Returns the Fixed date corresponding to the ISO `year, week, day` date.
  DR4 95 (5.1), fixed-from-iso
  """
  def fixed_from_iso({year, week, day}) do
    fixed_from_iso(year, week, day)
  end

  def fixed_from_iso(year, week, day) do
    nth_kday(week, sunday(), {year - 1, december(), 28}) + day
  end

  @doc """
  Returns the ISO date `[year, week, day]` equivalent to `fixed` date.
  DR4 96 (5.2), iso-from-fixed
  """
  def iso_from_fixed(fixed) do
    approx = gregorian_year_from_fixed(fixed - 3)
    year = fixed >= fixed_from_iso(approx + 1, 1, 1) && (approx + 1) || approx
    week = floor((fixed - fixed_from_iso(year, 1, 1)) / 7 ) + 1
    day = amod(fixed, 7)
    {year, week, day}
  end

  @doc """
  Returns true, if `year` is a long (= 53 week) year,
  instead of the normal short (= 52 week) year.
  DR4 97 (5.3), iso-long-year?
  """
  def iso_long_year?({year, _, _}), do: iso_long_year?(year)
  def iso_long_year?(year) do
    jan1 = year |> gregorian_new_year |> day_of_week_from_fixed
    dec31 = year |> gregorian_year_end |> day_of_week_from_fixed
    jan1 == thursday() or dec31 == thursday()
  end

  # === 6 The Icelandic Calendar, DR4 99ff

  @doc """
  Icelandic Epoch.
  __
  The Epoch of the Icelandic calendar is Thursday, April 19, in year 1
  of the Gregorian calendar, the onset of Icelandic summer.
  __
  = Thursday, April 19, 1 (Gregorian)
  DR4 100 (6.1), icelandic_epoch
  """
  def icelandic_epoch, do: 109

  @doc """
  Returns the week of the begin of the Icelandic summer.
  DR4 100 (6.2), icelandic-summer
  """
  def icelandic_summer(year) do
    kday_on_or_after(thursday(), fixed_from_gregorian(year, 4, 19))
  end

  @doc """
  Returns the week of the begin of the Icelandic winter.
  DR4 100 (6.3), icelandic-winter
  """
  def icelandic_winter(year) do
    icelandic_summer(year + 1) - 180
  end

  @doc """
  Returns the Fixed date corresponding to the Icelandic date `{year, season, week, weekday}`.
  DR4 100 (6.4), fixed-from-icelandic
  """
  def fixed_from_icelandic({year, season, week, weekday}) do
    fixed_from_icelandic(year, season, week, weekday)
  end

  def fixed_from_icelandic(year, season, week, weekday) do
    start = (season == summer() && icelandic_summer(year)) || icelandic_winter(year)
    shift = season == summer() && thursday() || saturday()
    start + 7 * (week - 1) + mod(weekday - shift, 7)
  end

  @doc """
  Returns the Icelandic date `{year, season, week, weekday}` equivalent to `fixed` date.
  DR4 101 (6.5), icelandic-from-fixed
  """
  def icelandic_from_fixed(fixed) do
    approx = floor((fixed - icelandic_epoch() + 369) * 400 / 146097)
    year = (fixed >= icelandic_summer(approx) && approx) || (approx - 1)
    season = (fixed < icelandic_winter(year) && summer()) || winter()
    start = (season == summer() && icelandic_summer(year)) || icelandic_winter(year)
    week = floor((fixed - start) / 7) + 1
    weekday = day_of_week_from_fixed(fixed)
    {year, season, week, weekday}
  end

  @doc """
  Returns true if the given year is a leap year.
  Ordinary years, with 52 weeks, have 364 days; leap years have 371 years (53 weeks).
  DR4 101 (6.6), icelandic-leap-year
  """
  def icelandic_leap_year?(year) do
    icelandic_summer(year + 1) - icelandic_summer(year) != 364
  end

  @doc """
  Returns the month of the season.
  The months of each season are numbered 1..6 and can be determined from the date
  by counting units of 30 days from the start of the season.
  DR4 101 (6.7) icelandic-month
  """
  def icelandic_month({year, season, _, _} = i_date) do
    fixed = fixed_from_icelandic(i_date)
    midsummer = icelandic_winter(year) - 90
    start =
      cond do
        season == winter() -> icelandic_winter(year)
        fixed >= midsummer -> midsummer - 90
        fixed < (icelandic_summer(year) + 90) -> icelandic_summer(year)
        true -> midsummer
      end
    floor((fixed - start) / 30) + 1
  end

  # === 7 The Islamic Calendar, DR4 105ff

  # === 7.1 Structure and Implementation, DR4 105ff

  @doc """
  Islamic Epoch.
  __
  The Calendar is computed, by the majority of the Muslim world, starting
  at sunset of Thursday, July 15, &22 C.E. (Julian), the year of Mohammad's
  migration to Medina from Mecca.. The introduction of the calöendar is
  often attrituted to the Caliph 'Umar in 639 C.E., but there is evidence
  that it was in use before his succession. Muslims count R.D. 227015 =
  Friday, July 16, 622 C.E. (Julian) as the beginning of the Islamic year 1,
  that is, as Muharram 1, A.H. (Anno Hegira).
  __
  DR4 106 (7.1), islamic-epoch = fixed-from-julian(ce(622), july, 16)
  """
  def islamic_epoch, do: 227015

  @doc """
  Returns true if the given year is a leap year.
  DR4 102 (7.2), islamic-leap-year
  """
  def islamic_leap_year?(year), do: mod((14 + 11 * year), 30) < 11

  @doc """
  Returns the Fixed date corresponding to the Islamic date `{year, month, day}`.
  DR4 107 (7.3), fixed-from-islamic
  """
  def fixed_from_islamic({year, month, day}) do
    fixed_from_islamic(year, month, day)
  end

  def fixed_from_islamic(year, month, day) do
    islamic_epoch() - 1 +
      (year - 1) * 354 +
      floor((3 + 11 * year) / 30) +
      29 * (month - 1) +
      floor(month / 2) +
      day
  end

  @doc """
  Returns the Islamic date `{year, season, week, weekday}` equivalent to `fixed` date.
  DR4 108 (7.4), islamic-from-fixed
  """
  def islamic_from_fixed(fixed) do
    year = floor((30 * (fixed - islamic_epoch()) + 10646) / 10631)
    prior_days = fixed - fixed_from_islamic(year, 1, 1)
    month = floor((11 * prior_days + 330) / 325)
    day = fixed - fixed_from_islamic(year, month, 1) + 1
    {year, month, day}
  end

  # === 7.2. Holidays, DR4 108f

  @doc """
  Returns the list of the fixed dates of a Islamic date
  that occur in Gregorian year `g_year`.
  DR4 108 (7.5), islamic-in-gregorian
  """
  def islamic_in_gregorian(i_month, i_day, g_year) do
    jan1 = gregorian_new_year(g_year)
    {y, _, _} = islamic_from_fixed(jan1)
    year_range = gregorian_year_range(g_year)
    date0 = fixed_from_islamic(y, i_month, i_day)
    date1 = fixed_from_islamic(y + 1, i_month, i_day)
    date2 = fixed_from_islamic(y + 2, i_month, i_day)
    Enum.filter([date0, date1, date2], &(&1 in year_range))
  end

  @doc """
  Returns the Gregorian date of the Mawlid holiday.
  DR4 109 (7.6), mawlid
  """
  def mawlid(g_year), do: islamic_in_gregorian(3, 12, g_year)

  # === 8 The Hebrew Calendar, DR4 113ff

  # === 8.1 Structur and History, DR4 114ff

  @nisan       1       # DR4 114 (8.1)
  @iyyar       2       # DR4 114 (8.2)
  @sivan       3       # DR4 114 (8.3)
  @tammuz      4       # DR4 114 (8.4)
  @av          5       # DR4 114 (8.5)
  @elul        6       # DR4 115 (8.6)
  @tishri      7       # DR4 115 (8.7)
  @marheshvan  8       # DR4 115 (8.8)
  @kislev      9       # DR4 115 (8.9)
  @tevet      10       # DR4 115 (8.10)
  @shevat     11       # DR4 115 (8.11)
  @adar       12       # DR4 115 (8.12)
  @adarii     13       # DR4 115 (8.13)

  def nisan,      do: @nisan       # DR4 114 (8.1)
  def iyyar,      do: @iyyar       # DR4 114 (8.2)
  def sivan,      do: @sivan       # DR4 114 (8.3)
  def tammuz,     do: @tammuz      # DR4 114 (8.4)
  def av,         do: @av          # DR4 114 (8.5)
  def elul,       do: @elul        # DR4 115 (8.6)
  def tishri,     do: @tishri      # DR4 115 (8.7)
  def marheshvan, do: @marheshvan  # DR4 115 (8.8)
  def kislev,     do: @kislev      # DR4 115 (8.9)
  def tevet,      do: @tevet       # DR4 115 (8.10)
  def shevat,     do: @shevat      # DR4 115 (8.11)
  def adar,       do: @adar        # DR4 115 (8.12)
  def adarii,     do: @adarii      # DR4 115 (8.13)

  @doc """
  Returns true if the given year is a leap year.
  DR4 115 (8.14), hebrew-leap-year
  """
  def hebrew_leap_year?(year), do: mod(7 * year + 1, 19) < 7

  @doc """
  DR4 115 (8.15), last-month-of-hebrew-year
  """
  def last_month_of_hebrew_year(year) do
    hebrew_leap_year?(year) && @adarii || @adar
  end

  @doc """
  DR4 115 (8.16), hebrew-sabbatical-year?
  """
  def hebrew_sabbatical_year?(year), do: mod(year, 7) == 0

  # === 8.2 Implementation, DR4 119ff

  @doc """
  Hebrew Epoch.
  = `(Tishri 1, 1 AM) = fixed-from-julian(bce(3761), october, 7)`
  DR4 119 (8.17), hebrew-epoch
  """
  def hebrew_epoch, do: -1373427

  # DR4 119 (8.18), (not implemented)

  @doc """
  Returns the moment of mean conjunction of `h_month` in Hebrew `h_year`.
  DR4 119 (8.19), molad
  """
  def molad(year, month) do
    y = (month < @tishri && year + 1) || year
    month_this_year = month - @tishri
    months_unit_new_year = floor((235 * y - 234) / 19)
    months_elapsed = month_this_year + months_unit_new_year
    hebrew_epoch() - (876 / 25920) +
      months_elapsed * (29 + hr(12) + (793 / 25920))
  end

  @doc """
  Returns the number of days elapsed from the (Sunday) noon prior
  to the epoch of the Hebrew calendar to the mean conjunction (molad)
  of Tishri of Hebrew year `h_year`, or one day later.
  DR4 121 (8.20), hebrew-calendar-elapsed-days
  """
  def hebrew_calendar_elapsed_days(year) do
    # months_elapsed = floor((235 * h_year - 234) / 19)
    # parts_elapsed = 12084 + 13753 * months_elapsed
    # days = 29 * months_elapsed + floor(parts-elapsed / 25920)
    days = floor(molad(year, @tishri) - hebrew_epoch() + hr(12))
    (mod(3 * (days + 1), 7) < 3) && (days + 1) || days
  end

  @doc """
  Delays to start of Hebrew year `h_year` to keep ordinary year in
  range 353-356 and leap year in range 383-386.
  DR4 122 (8.21), hebrew-year-length-correction
  """
  def hebrew_year_length_correction(year) do
    ny0 = hebrew_calendar_elapsed_days(year - 1)
    ny1 = hebrew_calendar_elapsed_days(year)
    ny2 = hebrew_calendar_elapsed_days(year + 1)
    cond do
      ny2 - ny1 == 356 -> 2   # Next year would be too long.
      ny1 - ny0 == 382 -> 1   # Previous year too short.
      true -> 0
    end
  end

  @doc """
  Fixed date of Hebrew new year `h_year`.
  DR4 122 (8.22), hebrew-new-year
  """
  def hebrew_new_year(year) do
    hebrew_epoch() + hebrew_calendar_elapsed_days(year) + hebrew_year_length_correction(year)
  end

  @doc """
  Last day of month `month` in Hebrew year `year`.
  DR4 122 (8.23), last-day-of-hebrew-month
  """
  def last_day_of_hebrew_month(year, month) do
    case month do
      @nisan -> 30
      @iyyar -> 29
      @sivan -> 30
      @tammuz -> 29
      @av -> 30
      @elul -> 29
      @tishri -> 30
      @marheshvan -> long_marheshvan?(year) && 30 || 29
      @kislev -> short_kislev?(year) && 29 || 30
      @tevet -> 29
      @shevat -> 30
      @adar -> hebrew_leap_year?(year) && 30 || 29
      @adarii -> 29
    end
  end

  @doc """
  True if Marheshvan is long in Hebrew year `h_year`.
  DR4 122 (8.24), long-marheshvan?
  """
  def long_marheshvan?(year) do
    days_in_hebrew_year(year) in [355, 385]
  end

  @doc """
  True if Kislev is short in Hebrew year `h_year`.
  DR4 122 (8.25), short-kislev?
  """
  def short_kislev?(year) do
    days_in_hebrew_year(year) in [353, 383]
  end

  @doc """
  Number of days in Hebrew year `h_year`.
  DR4 123 (8.26), days-in-hebrew-year
  """
  def days_in_hebrew_year(year) do
    hebrew_new_year(year + 1) - hebrew_new_year(year)
  end

  @doc """
  Returns the Fixed date corresponding to the Hebrew date `{year, month, day}`.
  DR4 123 (8.27), fixed-from-hebrew
  """
  def fixed_from_hebrew({year, month, day}) do
    fixed_from_hebrew(year, month, day)
  end

  def fixed_from_hebrew(year, month, day) do

    days_in_months = fn months ->
      Enum.map(months, &(last_day_of_hebrew_month(year, &1))) |> Enum.sum
    end

    previous_days =
      cond do
        month == @nisan -> days_in_months.(@tishri..last_month_of_hebrew_year(year))
        month < @tishri -> (
                             sum1 = days_in_months.(@tishri..last_month_of_hebrew_year(year))
                             sum2 = days_in_months.(@nisan..(month - 1))
                             sum1 + sum2
                             )
        month == @tishri -> 0
        month > @tishri -> days_in_months.(@tishri..(month - 1))
      end
    hebrew_new_year(year) + previous_days + day - 1
  end

  @doc """
  Returns the Hebrew date `{year, month, day}` equivalent to `fixed` date.
  DR4 123 (8.28), hebrew-from-fixed
  """
  def hebrew_from_fixed(fixed) do
    approx = floor((98496 / 35975351) * (fixed - hebrew_epoch())) + 1
    year = Enum.find((approx + 1)..(approx - 1), fn y ->
      hebrew_new_year(y) <= fixed
    end)

    start = (fixed < fixed_from_hebrew(year, @nisan, 1) && @tishri) || @nisan
    month = Enum.find(start..(start + 13), fn m ->
      fixed <= fixed_from_hebrew(year, m, last_day_of_hebrew_month(year, m))
    end)

    day = fixed - fixed_from_hebrew(year, month, 1) + 1
    {year, month, day}
  end

  # === 8.3 Inverting the Molad, DR4 125ff

  @doc """
  Fixed date of the molad that occurs `moon` days
  and fractional days into the week.
  DR4 126 (8.29), fixed-from-molad
  """
  def fixed_from_molad(moon) do
    r = mod(74377 * moon - (2879 / 2160), 7)
    time_from_moment(molad(1, @tishri) + r * 765433)
  end

  # === 8.4 Holidays and Fast Days, DR4 128ff

  @doc """
  Fixed date of Yom Kippur occurring in Gregorian year `g_year`.
  DR4 128 (8.30), yom-kippur
  """
  def yom_kippur(g_year) do
    year = g_year - gregorian_year_from_fixed(hebrew_epoch()) + 1
    fixed_from_hebrew(year, @tishri, 10)
  end

  @doc """
  Fixed date of Passover occurring in Gregorian year `g_year`.
  DR4 129 (8.31), passover
  """
  def passover(g_year) do
    year = g_year - gregorian_year_from_fixed(hebrew_epoch())
    fixed_from_hebrew(year, @nisan, 15)
  end

  @doc """
  Number of elapsed weeks and days in the omer at `fixed`.
  Returns bogus if that date does not fall during the omer.
  DR4 129 (8.32), omer
  """
  def omer(fixed) do
    g_year = gregorian_year_from_fixed(fixed)
    c = fixed - passover(g_year)
    (1 <= c and c <= 49) && [floor(c / 7), mod(c, 7)] || "bogus"
  end

  @doc """
  Fixed date of Purim occurring in Gregorian year `g_year`.
  DR4 129 (8.33), purim
  """
  def purim(g_year) do
    h_year = g_year - gregorian_year_from_fixed(hebrew_epoch())
    last_month = last_month_of_hebrew_year(h_year)
    fixed_from_hebrew(h_year, last_month, 14)
  end

  @doc """
  Fixed date of Ta'anit Esther occurring in Gregorian year `g_year`.
  DR4 130 (8.34), ta-anit-esther
  """
  def ta_anit_esther(g_year) do
    purim_date = purim(g_year)
    if day_of_week_from_fixed(purim_date) == sunday() do
      purim_date - 3
    else
      purim_date - 1
    end
  end

  @doc """
  Fixed date of Tishah be-Av occurring in Gregorian year `g_year`.
  DR4 130 (8.35), tishah-be-av
  """
  def tishah_be_av(g_year) do
    year = g_year - gregorian_year_from_fixed(hebrew_epoch())
    av9 = fixed_from_hebrew(year, @av, 9)
    if day_of_week_from_fixed(av9) == saturday() do
      av9 + 1
    else
      av9
    end
  end

  @doc """
  Fixed date of Yom ha-Zikkaron occurring in Gregorian year `g_year`.
  DR4 131 (8.36), yom-ha-zikkaron
  """
  def yom_ha_zikkaron(g_year) do
    h_year = g_year - gregorian_year_from_fixed(hebrew_epoch())
    iyyar4 = fixed_from_hebrew(h_year, @iyyar, 4)
    cond do
      day_of_week_from_fixed(iyyar4) in [thursday(), friday()] -> (
                                                                    kday_before(wednesday(), iyyar4))
      day_of_week_from_fixed(iyyar4) == sunday() -> iyyar4 + 1
      true -> iyyar4
    end
  end

  @doc """
  List of fixed dates of Sh'ela occurring in Gregorian year `g_year`.
  DR4 131 (8.37), sh-ela
  """
  def sh_ela(g_year) do
    coptic_in_gregorian(3, 26, g_year)
  end

  @doc """
  List of fixed date of Birkath ha-Hama occurring in Gregorian year `g_year`.
  DR4 131 (8.38), birkath-ha-hama
  """
  def birkath_ha_hama(g_year) do
    dates = coptic_in_gregorian(7, 30, g_year)
    if dates != [] do
      {year, _, _} = coptic_from_fixed(hd(dates))
      mod(year, 28) == 17 && dates || []
    else
      []
    end
  end

  @doc """
  Moment(s) of `season` in Gregorian year `g_year`.
  DR4 132 (8.39), samuel-season-in-gregorian
  """
  def samuel_season_in_gregorian(season, g_year) do
    cap_Y = 365 + hr(6)
    offset = (season / 360) * cap_Y
    moment = fixed_from_hebrew(1, @adar, 21) + hr(18) + offset
    cycle_in_gregorian(season, g_year, cap_Y, moment)
  end

  @doc """
  List of fixed date of Birkath ha-Hama in Gregorian year `g_year`.
  DR4 132 (8.40), alt-birkath-ha-hama
  """
  def alt_birkath_ha_hama(g_year) do
    cap_Y = 365 + hr(6)
    season = spring() + hr(6) * (360 / cap_Y)
    moments = samuel_season_in_gregorian(season, g_year)

    if moments != [] and
       day_of_week_from_fixed(hd(moments)) == wednesday() and
       time_from_moment(hd(moments)) == hr(0) do
       [fixed_from_moment(hd(moments))]
    else
       []
    end
  end

  @doc """
  Moment(s) of `season` in Gregorian year `g_year` per R. Adda bar Ahava.
  DR4 133 (8.41), adda-season-in-gregorian
  """
  def adda_season_in_gregorian(season, g_year) do
    cap_Y = 365 + hr(5 + 3791/4104)
    offset = (season / 360) * cap_Y
    moment = fixed_from_hebrew(1, @adar, 28) + hr(18) + offset
    cycle_in_gregorian(season, g_year, cap_Y, moment)
  end

  # === 8.5 The Drift of the Hebrew Calendar, DR4 133f

  @doc """
  List of the fixed dates of Hebrew month `h_month`, day
  `h_day` that occur in Gregorian year `g_year`.
  DR4 133 (8.42), hebrew-in-gregorian
  """
  def hebrew_in_gregorian(h_month, h_day, g_year) do
    year_range = gregorian_year_range(g_year)
    jan1 = gregorian_new_year(g_year)
    {y, _, _} = hebrew_from_fixed(jan1)
    date0 = fixed_from_hebrew(y, h_month, h_day)
    date1 = fixed_from_hebrew(y + 1, h_month, h_day)
    date2 = fixed_from_hebrew(y + 2, h_month, h_day)
    Enum.filter([date0, date1, date2], &(&1 in year_range))
  end

  @doc """
  Fixed date(s) of first day of Hanukkah in Gregorian year `g_year`.
  DR4 134 (8.43), hanukkah
  """
  def hanukkah(g_year) do
    hebrew_in_gregorian(@kislev, 25, g_year)
  end

  # === 8.6 Personal Days, DR4 134ff

  @doc """
  Fixed date of the anniversary of Hebrew `birthdate` in Hebrew `h_year`.
  DR4 135 (8.44), hebrew-birthday
  """
  def hebrew_birthday({birth_year, birth_month, birth_day} = _birth_date, h_year) do
    hebrew_birthday(birth_year, birth_month, birth_day, h_year)
  end

  def hebrew_birthday(birth_year, birth_month, birth_day, h_year) do
    if birth_month == last_month_of_hebrew_year(birth_year) do
      fixed_from_hebrew(h_year, last_month_of_hebrew_year(h_year), birth_day)
    else
      fixed_from_hebrew(h_year, birth_month, 1) + birth_day - 1
    end
  end

  @doc """
  List of the fixed dates of Hebrew `birthday` in Gregorian `g_year`.
  DR4 135 (8.45), hebrew-birthday-in-gregorian
  """
  def birthday_in_gregorian(birthdate, g_year) do
    year_range = gregorian_year_range(g_year)
    jan1 = gregorian_new_year(g_year)
    {y, _, _} = hebrew_from_fixed(jan1)
    date0 = hebrew_birthday(birthdate, y)
    date1 = hebrew_birthday(birthdate, y + 1)
    date2 = hebrew_birthday(birthdate, y + 2)
    Enum.filter([date0, date1, date2], &(&1 in year_range))
  end

  @doc """
  Fixed date of the anniversary of Hebrew `death_date` in Hebrew `h_year`.
  DR4 136 (8.46), yahrzeit
  """
  def yahrzeit({death_year, death_month, death_day} = _death_date, h_year) do
    yahrzeit(death_year, death_month, death_day, h_year)
  end

  def yahrzeit(death_year, death_month, death_day, h_year) do
    cond do
      death_month == @marheshvan and death_day == 30 and not long_marheshvan?(death_year + 1) ->
        fixed_from_hebrew(h_year, @kislev, 1) - 1
      death_month == @kislev and death_day == 30 and short_kislev?(death_year + 1) ->
        fixed_from_hebrew(h_year, @tevet, 1) - 1
      death_month == @adarii ->
        fixed_from_hebrew(h_year, last_month_of_hebrew_year(h_year), death_day)
      death_month == @adar and death_day == 30 and not hebrew_leap_year?(h_year) ->
        fixed_from_hebrew(h_year, @shevat, 30)
      true ->
        fixed_from_hebrew(h_year, death_month, 1) + death_day - 1
    end
  end

  @doc """
  List of the fixed dates of `death_date` (yahrzeit) in Gregorian year `g_year`.
  DR4 137 (8.47), yahrzeit-in-gregorian
  """
  def yahrzeit_in_gregorian(death_date, g_year) do
    year_range = gregorian_year_range(g_year)
    jan1 = gregorian_new_year(g_year)
    {y, _, _} = hebrew_from_fixed(jan1)
    date0 = yahrzeit(death_date, y)
    date1 = yahrzeit(death_date, y + 1)
    date2 = yahrzeit(death_date, y + 2)
    Enum.filter([date0, date1, date2], &(&1 in year_range))
  end

  # === 8.7 Possible Days of the Week, DR4 137ff

  @doc """
  List of possible weekdays.
  DR4 138 (8.48)
  """
  def possible_weekdays, do: [sunday(), tuesday(), thursday(), saturday()]

  @doc """
  Shift each weekday on list `l` by `cap-Delta` days.
  DR4 138 (8.49), shift-days
  """
  def shift_days([], _delta), do: []
  def shift_days([head | tail] = _l, delta) do
    [mod(head + delta, 7)] ++ shift_days(tail, delta)
  end

  @doc """
  Possible days of week.
  DR4 139 (8.50), possible-hebrew-days
  """
  def possible_hebrew_days(h_month, h_day) do
    h_date0 = {5, @nisan, 1}
    h_year = h_month > @elul && 6 || 5
    h_date = {h_year, h_month, h_day}
    n = fixed_from_hebrew(h_date) - fixed_from_hebrew(h_date0)
    basic = [tuesday(), thursday(), saturday()]
    extra =
      cond do
        h_month == @marheshvan and h_day == 30 ->
          []
        h_month == @kislev and h_day < 30 ->
          [monday(), wednesday(), friday()]
        h_month == @kislev and h_day == 30 ->
          [monday()]
        h_month in [@tevet, @shevat] ->
          [sunday(), monday()]
        h_month == @adar and h_day < 30 ->
          [sunday(), monday()]
        true ->
          [sunday()]
      end
    shift_days(basic ++ extra, n)
  end

  # === 9 The Ecclesiastical Calendars, DR4 143ff

  # === 9.1 Orthodox Easter, DR4 145ff

  @doc """
  Returns the Fixed date Gregorian `g_year` of Orthodox Easter.
  DR4 146 (9.1), orthodox-easter
  """
  def orthodox_easter(g_year) do
    j_year = g_year > 0 && g_year || g_year - 1
    shifted_epact = mod(14 + 11 * (mod(g_year, 19)), 30)
    paschal_moon = fixed_from_julian(j_year, 4, 19) - shifted_epact
    kday_after(sunday(), paschal_moon)
  end

  @doc """
  Returns the Fixed date Gregorian `g_year` of Orthodox Easter.
  DR4 146 (9.2), alt-orthodox-easter
  """
  def alt_orthodox_easter(g_year) do
    paschal_moon =
      354 * g_year +
        30 * floor((7 * g_year + 8) / 19) +
        floor(g_year / 4) -
        floor(g_year / 19) -
        273 + gregorian_epoch()
    kday_after(sunday(), paschal_moon)
  end

  # === 9.2 Gregorian Easter, DR4 147ff

  @doc """
  Returns the fixed date of Christian Gregorian date of easter.
  DR4 148 (9.3), easter
  """
  def easter(year) do
    century = floor(year / 100) + 1
    shifted_epact = mod(14 + 11 * mod(year, 19) - floor(century * 3 / 4) + floor((5 + 8 * century) / 25), 30)
    adjusted_epact =
      if shifted_epact == 0 or (shifted_epact == 1 and 10 < mod(year, 19)) do
        shifted_epact + 1
      else
        shifted_epact
      end
    paschal_moon = fixed_from_gregorian(year, 4, 19) - adjusted_epact
    kday_after(sunday(), paschal_moon)
  end

  # === 9.3 Astronomical Easter, DR4 150

  # (see section 18.4)

  # === 9.4 Movable Christian Holidays, DR4 150ff

  @doc """
  Returns the fixed Date of Christian Gregorian date of pentecost.
  DR4 152 (9.4), pentecost
  """
  def pentecost(year), do: easter(year) + 49

  # === 10 The Old Hindu Calendars, DR4 155ff

  # === 10.1 Structure and History, DR4 155ff

  @doc """
  The OldHindu epoch is the first day of year 0 of the Kali Yuga:
  = February 18, 3102 BCE (Julian)
  = January 23, -3101 (Gregorian)
  = -1132959 RD
  DR4 156 (10.1), hindu-epoch
  """
  def hindu_epoch, do: -1132959

  @doc """
  Elapsed days (Ahargana) to `fixed` since Hindu epoch (KY).
  DR4 156 (10.2), hindu-day-count
  """
  def hindu_day_count(fixed), do: fixed - hindu_epoch()

  @doc """
  Length of Old Hindu solar year.
  DR4 157 (10.3), arya-solar-year
  """
  def arya_solar_year, do: 1577917500 / 4320000

  @doc """
  Number of days in one revolution of Jupiter around the Sun.
  DR4 157 (10.4), arya-jovian-period
  """
  def arya_jovian_period, do: 1577917500 / 364224

  @doc """
  Year of Jupiter cycle at fixed `date`.
  DR4 157 (10.5), jovian-year
  """
  def jovian_year(fixed) do
    amod(27 + floor(hindu_day_count(fixed) / (arya_jovian_period() / 12)), 60)
  end

  # === 10.2 The Solar Calendar, DR4 158ff

  @doc """
  Length of Old Hindu solar month.
  DR4 158 (10.6), arya-solar-month
  """
  def arya_solar_month, do: arya_solar_year() / 12

  @doc """
  Fixed date corresponding to Old Hindu solar date `s_date`.
  DR4 158 (10.7), fixed-from-old-hindu-solar
  """
  def fixed_from_old_hindu_solar({year, month, day}) do
    fixed_from_old_hindu_solar(year, month, day)
  end

  def fixed_from_old_hindu_solar(year, month, day) do
    ceil(
      hindu_epoch() +
        year * arya_solar_year() +
        (month - 1) * arya_solar_month() +
        day - hr(30))
  end

  @doc """
  Old Hindu solar fixed equivalent to `fixed`.
  DR4 159 (10.8), old-hindu-solar-from-fixed
  """
  def old_hindu_solar_from_fixed(fixed) do
    sun = hindu_day_count(fixed) + hr(6)
    year = floor(sun / arya_solar_year())
    month = mod(floor(sun / arya_solar_month()), 12) + 1
    day = floor(mod(sun, arya_solar_month())) + 1
    {year, month, day}
  end

  # === 10.3 The Lunisolar Calendar, DR4 160ff

  @doc """
  Length of Old Hindu lunar month.
  = 29.53058181... days
  DR4 160 (10.9), arya-lunar-month
  """
  def arya_lunar_month, do: 1577917500 / 53433336

  @doc """
  Length of Old Hindu lunar day.
  DR4 160 (10.10), arya-lunar-day
  """
  def arya_lunar_day, do: arya_lunar_month() / 30

  @doc """
  True if `l_year` is a leap year on the old Hindu calendar.
  DR4 163 (10.11), old-hindu-lunar-leap-year?
  """
  def old_hindu_leap_year?(l_year) do
    mod(l_year * arya_solar_year() - arya_solar_month(),
      arya_lunar_month()) >= 23902504679 / 1282400064
  end

  # DR4 164 (10.12), not implemented

  @doc """
  Old Hindu lunar fixed equivalent to fixed `fixed`.
  DR4 165 (10.13), old-hindu-lunar-from-fixed
  """
  def old_hindu_lunar_from_fixed(fixed) do
    sun = hindu_day_count(fixed) + hr(6)
    new_moon_ = sun - mod(sun, arya_lunar_month())
    m = mod(new_moon_, arya_solar_month())
    leap = arya_solar_month() - arya_lunar_month() >= m && m > 0
    month = mod(ceil(new_moon_ / arya_solar_month()), 12) + 1
    day = mod(floor(sun / arya_lunar_day()), 30) + 1
    year = ceil((new_moon_ + arya_solar_month()) / arya_solar_year()) - 1
    {year, month, leap, day}
  end

  @doc """
  Fixed date corresponding to Old Hindu lunar date `l_date`.
  DR4 165 (10.14), fixed-from-old-hindu-lunar
  """
  def fixed_from_old_hindu_lunar({year, month, leap, day}) do
    fixed_from_old_hindu_lunar(year, month, leap, day)
  end

  def fixed_from_old_hindu_lunar(year, month, leap, day) do
    mina = (12 * year - 1) * arya_solar_month()
    lunar_new_year = arya_lunar_month() * (floor(mina / arya_lunar_month()) + 1)

    c = ceil((lunar_new_year - mina) / (arya_solar_month() - arya_lunar_month()))
    f = (not leap and c <= month) && month || month - 1

    ceil(
      hindu_epoch() +
        lunar_new_year +
        arya_lunar_month() * f +
        (day - 1) * arya_lunar_day() -
        hr(6))
  end

  # === 11 The Mayan Calendars, DR4 169ff

  # === 11.1 The Long Count, DR4 170f

  @doc """
  Mayan Epoch.
  Fixed date of start of the Mayan calendar, according
  to the Goodman-Martinez-Thompson correlation.
  Monday, August 11, -3113 (Gregorian),
  = September 6, 3114 BCE (Julian),
  = 584283 (JD) = -1137142 (R.D.)
  DR4 171 (11.1), mayan-epoch
  """
  def mayan_epoch, do: -1137142

  @doc """
  Fixed date corresponding to Mayan Long Count `count`.
  DR4 171 (11.2), fixed-from-mayan-long-count
  """
  def fixed_from_mayan_long_count({baktun, katun, tun, uinal, kin}) do
    fixed_from_mayan_long_count(baktun, katun, tun, uinal, kin)
  end

  def fixed_from_mayan_long_count(baktun, katun, tun, uinal, kin) do
    mayan_epoch() + from_radix([baktun, katun, tun, uinal, kin], [20, 20, 18, 20])
  end

  @doc """
  Mayan long count date of fixed `date`.
  DR4 171 (11.3), mayan-long-count-from-fixed
  """
  def mayan_long_count_from_fixed(fixed) do
    to_radix(fixed - mayan_epoch(), [20, 20, 18, 20])
    |> List.to_tuple
  end

  # === 11.2 The Haab and Tzolkin Calendars, DR4 171ff

  @doc """
  Number of days into cycle of Mayan haab date `h_date`.
  DR4 173 (11.4), mayan-haab-ordinal
  """
  def mayan_haab_ordinal({month, day} = _h_date) do
    (month - 1) * 20 + day
  end

  @doc """
  MayanHaab Epoch.
  __The long count date 0.0.0.0.0 is considered to be the haab date
  8 Cumku (...), which we specify by giving the starting R.D. date
  of the haab cycle preceding the start of the long count.__
  `mayan-haab-epoch = mayan-epoch - mayan-haab-ordinal(18, 8)`
  DR4 173 (11.5), mayan-haab-epoch
  """
  def mayan_haab_epoch, do: -1137490

  @doc """
  Mayan haab date of fixed `date`.
  DR4 173 (11.6), mayan-haab-from-fixed
  """
  def mayan_haab_from_fixed(fixed) do
    count = mod(fixed - mayan_haab_epoch(), 365)
    day = mod(count, 20)
    month = floor(count / 20) + 1
    {month, day}
  end

  @doc """
  Fixed date of latest date on or before `fixed` date
  that is Mayan haab date `haab`.
  DR4 173 (11.7), mayan-haab-on-or-before
  PyCalCal
  """
  def mayan_haab_on_or_before(haab, fixed) do
    fixed - mod(fixed - mayan_haab_epoch() - mayan_haab_ordinal(haab), 365)
  end

  @doc """
  MayanTzolkin Epoch.
  __
  The long count date 0.0.0.0.0 is taken to be the tzolkin date
  4 Ahau (...). Representing tzolkin dates as pairs of positive
  integers `{number, name}` where `number`abd `name`are integers
  in the ranges 1 to 13 and 1 to 20, respectively, we specify
  ___
  `mayan-tzolkin-epoch = mayan-epoch - mayan-tzolkin-ordinal(4, 20)`
  = -1137301
  DR4 175 (11.8), mayan-tzolkin-epoch
  """
  def mayan_tzolkin_epoch, do: -1137301

  @doc """
  Mayan tzolkin date of `fixed` date.
  DR4 175 (11.9), mayan-tzolkin-from-fixed
  """
  def mayan_tzolkin_from_fixed(fixed) do
    count = fixed - mayan_tzolkin_epoch() + 1
    number = amod(count, 13)
    name_ = amod(count, 20)
    {number, name_}
  end

  @doc """
  Number of days into Mayan tzolkin cycle of `t_date`.
  DR4 175 (11.10), mayan-tzolkin-ordinal
  """
  def mayan_tzolkin_ordinal({number, name_} = _t_date) do
    mod(number - 1 + 39 * (number - name_), 260)
  end

  @doc """
  Fixed date of latest date on or before `fixed` date
  that is Mayan tzolkin date `tzolkin`.
  DR4 175 (11.11), mayan-tzolkin-on-or-before
  """
  def mayan_tzolkin_on_or_before(tzolkin, fixed) do
    fixed - mod(fixed - mayan_tzolkin_epoch() - mayan_tzolkin_ordinal(tzolkin), 260)
  end

  @doc """
  Year bearer of year containing fixed `date`.
  Returns bogus for uayeb.
  DR4 176 (11.12), mayan-year-bearer-from-fixed
  """
  def year_bearer_from_fixed(fixed) do
    x = mayan_haab_on_or_before({1, 0}, fixed)
    {month, _day} = mayan_haab_from_fixed(fixed)
    if month == 19 do
      bogus()
    else
      {_, mayan_tzolkin_name} = mayan_tzolkin_from_fixed(x)
      mayan_tzolkin_name
    end
  end

  @doc """
  Fixed date of latest date on or before `fixed`, that is
  Mayan haab date `haab` and tzolkin date `tzolkin`.
  Returns bogus for impossible combinations.
  DR4 176 (11.13), mayan-calendar-round-on-or-before
  """
  def mayan_calendar_round_on_or_before(haab, tzolkin, fixed) do
    haab_count = mayan_haab_ordinal(haab) + mayan_haab_epoch()
    tzolkin_count = mayan_tzolkin_ordinal(tzolkin) + mayan_tzolkin_epoch()
    diff = tzolkin_count - haab_count
    if mod(diff, 5) == 0 do
      fixed - mod(fixed - haab_count - (365 * diff), 18980)
    else
      bogus()
    end
  end

  # === 11.3 The Aztec Calendars, DR4 177ff

  @doc """
  __
  The precise correlation between Aztec dates and our R.D. dates
  is based on the recorded Aztec Dates of the fall of (what later
  became) Mexico City to Mermán Cortés, August 13, 1521 (Julian).
  __
  Known date of Aztec cycles (Caso's correlation)
  August, 13, 1521 (Julian)
  DR4 177 (11.14), aztec-correlation
  """
  def aztec_correlation, do: 555403

  @doc """
  AztecXihuitl Epoch.
  = aztec_xihuitl_correlation
  (not DR4)
  """
  def aztec_xihuitl_epoch, do: 555202   # = correlation()

  @doc """
  Number of elapsed days into cycle of Aztec xihuitl `x_date`.
  DR4 178 (11.15), aztec-xihuitl-ordinal
  """
  def aztec_xihuitl_ordinal({month, day} = _x_date) do
    (month - 1) * 20 + day - 1
  end

  @doc """
  Start of a xihuitl cycle.
  DR4 178 (11.16), aztec-xihuitl-correlation
  """
  def aztec_xihuitl_correlation do
    aztec_correlation() - aztec_xihuitl_ordinal({11, 2}) # = R.D. 555202
  end

  @doc """
  Aztec xihuitl date of `fixed` date.
  DR4 178 (11.17), aztec-xihuitl-from-fixed
  """
  def aztec_xihuitl_from_fixed(fixed) do
    count = mod(fixed - aztec_xihuitl_correlation(), 365)
    day = mod(count, 20) + 1
    month = floor(count / 20) + 1
    {month, day}
  end

  @doc """
  Fixed date of latest date on or before `fixed` date
  that is Aztec xihuitl date `xihuitl`.
  DR4 179 (11.18), aztec-xihuitl-on-or-before
  """
  def aztec_xihuitl_on_or_before(xihuitl, fixed) do
    fixed - mod(fixed - aztec_xihuitl_correlation() - aztec_xihuitl_ordinal(xihuitl), 365)
  end

  @doc """
  Number of days into Aztec tonalpohualli cycle of `t_date`.
  DR4 179 (11.19), aztec-tonalpohualli-ordinal
  (Error in book: `name` and `number` are interchanged!)
  """
  def aztec_tonalpohualli_ordinal({number, name_} = _t_date) do
    mod(number - 1 + 39 * (number - name_), 260)
  end

  @doc """
  Start of a tonalpohualli cycle.
  = R.D. 555299
  DR4 179 (11.20), aztec-tonalpohualli-correlation
  """
  def aztec_tonalpohualli_correlation do
    aztec_correlation() - aztec_tonalpohualli_ordinal({1, 5})
  end

  @doc """
  Aztec tonalpohualli date of `fixed` date.
  DR4 179 (11.21), aztec-tonalpohualli-from-fixed
  """
  def aztec_tonalpohualli_from_fixed(fixed) do
    count = fixed - aztec_tonalpohualli_correlation() + 1
    number_ = amod(count, 13)
    name_ = amod(count, 20)
    {number_, name_}
  end

  @doc """
  Fixed date of latest date on or before `fixed` date
  that is Aztec tonalpohualli date `tonalpohualli`.
  DR4 180 (11.22), aztec-tonalpohualli-on-or-before
  """
  def aztec_tonalpohualli_on_or_before(tonalpohualli, fixed) do
    fixed - mod(fixed - aztec_tonalpohualli_correlation() - aztec_tonalpohualli_ordinal(tonalpohualli), 260)
  end

  @doc """
  Designation of year containing fixed `date`.
  Returns bogus for nemontemi.
  DR4 180 (11.23), aztec-xiuhmolpilli-from-fixed
  """
  def aztec_xiuhmolpilli_from_fixed(fixed) do
    {month, _} = aztec_xihuitl_from_fixed(fixed)
    if month == 19 do
      bogus()
    else
      x = aztec_xihuitl_on_or_before({18, 20}, fixed + 364)
      aztec_tonalpohualli_from_fixed(x)
    end
  end

  @doc """
  Fixed date of latest xihuitl_tonalpohualli combination on or before `fixed`.
  That is the date on or before `fixed` that is Aztec xihuitl date `xihuitl`
  and tonalpohualli date `tonalpohualli`.
  Returns bogus for impossible combinations.
  DR4 180 (11.24), aztec-xihuitl-tonalpohualli-on-or-before
  """
  def aztec_xiuitl_tonalpohuaulli_on_or_before(xihuitl, tonalpohualli, fixed) do
    xihuitl_count = aztec_xihuitl_ordinal(xihuitl) + aztec_xihuitl_correlation()
    tonalpohualli_count = aztec_tonalpohualli_ordinal(tonalpohualli) + aztec_tonalpohualli_correlation()
    diff = tonalpohualli_count - xihuitl_count
    if mod(diff, 5) == 0 do
      fixed - mod(fixed - xihuitl_count - (365 * diff), 18980)
    else
      bogus()
    end
  end

  # === 12 The Balinese Pawukon Calendar, DR4 185ff

  # === 12.1 Structure and Implementation, DR4 185ff

  @doc """
  Positions of `fixed` in ten cycles of Balinese Pawukon calendar.
  DR4 185 (12.1), bali-pawukon-from-fixed
  """
  def bali_pawukon_from_fixed(fixed) do
    {
      bali_luang_from_fixed(fixed),
      bali_dwiwara_from_fixed(fixed),
      bali_triwara_from_fixed(fixed),
      bali_caturwara_from_fixed(fixed),
      bali_pancawara_from_fixed(fixed),
      bali_sadwara_from_fixed(fixed),
      bali_saptawara_from_fixed(fixed),
      bali_asatawara_from_fixed(fixed),
      bali_sangawara_from_fixed(fixed),
      bali_dasawara_from_fixed(fixed)
    }
  end

  @doc """
  BaliPawukon Epoch.
  = `fixed_from_jd(146)`
  DR4 187 (12.2), bali-epoch
  """
  def bali_pawukon_epoch, do: -1721279

  @doc """
  Position of `fixed` in 210-day Pawukon cycle.
  DR4 187 (12.3), bali-day-from-fixed
  """
  def bali_day_from_fixed(fixed) do
    mod(fixed - bali_pawukon_epoch(), 210)
  end

  @doc """
  Position of `fixed` in 3-day Balinese cycle.
  DR4 187 (12.4), bali-triwara-from-fixed
  """
  def bali_triwara_from_fixed(fixed) do
    mod(bali_day_from_fixed(fixed), 3) + 1
  end

  @doc """
  Position of `fixed` in 6-day Balinese cycle.
  DR4 187 (12.5), bali-sadwara-from-fixed
  """
  def bali_sadwara_from_fixed(fixed) do
    mod(bali_day_from_fixed(fixed), 6) + 1
  end

  @doc """
  Position of `fixed` in Balinese week.
  DR4 187 (12.6), bali-saptawara-from-fixed
  """
  def bali_saptawara_from_fixed(fixed) do
    mod(bali_day_from_fixed(fixed), 7) + 1
  end

  @doc """
  Position of `fixed` in 5-day Balinese cycle.
  DR4 187 (12.7), bali-pancawara-from-fixed
  """
  def bali_pancawara_from_fixed(fixed) do
    amod(bali_day_from_fixed(fixed) + 2, 5)
  end

  @doc """
  Week number of `date` in Balinese cycle.
  DR4 187 (12.8), bali-week-from-fixed
  """
  def bali_week_from_fixed(fixed) do
    floor(bali_day_from_fixed(fixed) / 7) + 1
  end

  @doc """
  Position of `date` in 10-day Balinese cycle.
  DR4 188 (12.9), bali-dasawara-from-fixed
  """
  def bali_dasawara_from_fixed(fixed) do
    list_i = [5, 9, 7, 4, 8]
    list_j = [5, 4, 3, 7, 8, 6, 9]
    i = bali_pancawara_from_fixed(fixed) - 1  # Position in 5-day cycle
    j = bali_saptawara_from_fixed(fixed) - 1  # Weekday
    mod(1 + Enum.at(list_i, i) + Enum.at(list_j, j), 10)
  end

  @doc """
  Position of `fixed` in 2-day Balinese cycle.
  DR4 188 (12.10), bali-dwiwara-from-fixed
  """
  def bali_dwiwara_from_fixed(fixed) do
    amod(bali_dasawara_from_fixed(fixed), 2)
  end

  @doc """
  Membership of `fixed` in "1-day" Balinese cycle.
  DR4 188 (12.11), bali-luang-from-fixed
  """
  def bali_luang_from_fixed(fixed) do
    mod(bali_dasawara_from_fixed(fixed), 2) == 0
  end

  @doc """
  Position of `date` in 9-day Balinese cycle.
  DR4 188 (12.12), bali-sangawara-from-fixed
  """
  def bali_sangawara_from_fixed(fixed) do
    mod(max(0, bali_day_from_fixed(fixed) - 3), 9) + 1
  end

  @doc """
  Position of `fixed` in 8-day Balinese cycle.
  DR4 188 (12.13), bali-asatawara-from-fixed
  """
  def bali_asatawara_from_fixed(fixed) do
    day = bali_day_from_fixed(fixed)
    mod(max(6, 4 + mod(day - 70, 210)), 8) + 1
  end

  @doc """
  Position of `fixed` in 4-day Balinese cycle.
  DR4 189 (12.14), bali-caturwara-from-fixed
  """
  def bali_caturwara_from_fixed(fixed) do
    amod(bali_asatawara_from_fixed(fixed), 4)
  end

  @doc """
  Last fixed date on or before `date` with Pawukon `b_date`.
  DR4 189 (12.15), bali-on-or-before
  """
  def bali_on_or_before({
    _luang, _dwiwara, _triwara, _caturwara, pancawara, sadwara,
    saptawara, _asatawara, _sangawara, _dasawara} = _b_date, fixed) do
    a5 = pancawara - 1                       # Position in 5-day subcycle
    a6 = sadwara - 1                         # Position in 6-day subcycle
    b7 = saptawara - 1                       # Position in 7-day subcycle
    b35 = mod(a5 + 14 + 15 * (b7 - a5), 35)  # Position in 35-day subcycle
    days = a6 + 36 * (b35 - a6)              # Position in full cycle
    delta = bali_day_from_fixed(0)
    fixed - mod(fixed + delta - days, 210)
  end

  # === 12.2 Conjunction Days, DR4 190ff

  @doc """
  Occurrences of Kajeng Keliwon (9th day of each 15-day subcycle
  of Pawukon) in Gregorian year `g_year`.
  DR4 190 (12.16), kajeng-keliwon
  """
  def kajeng_keliwon(g_year) do
    a..b = gregorian_year_range(g_year)
    delta = bali_day_from_fixed(0)
    positions_in_range(8, 15, delta, a, b)
  end

  @doc """
  Occurrences of Tumpek (14th day of Pawukon and every 35th
  subsequent day) within Gregorian year `g_year`.
  DR4 190 (12.17), tumpek
  """
  def tumpek(g_year) do
    a..b = gregorian_year_range(g_year)
    delta = bali_day_from_fixed(0)
    positions_in_range(13, 35, delta, a, b)
  end

  # === 13 Generic Cyclical Calendars, DR4 195ff

  # (not implemented)


  # === Part II - Astronomical Calendars

  # === 14 Time and Astronmy, DR4 203ff

  # === 14.1 Position, DR4 204ff

  @doc """
  Urbana, Illinois.
  DR4 204 (14.1), urbana
  """
  def urbana, do: {40.1, -88.2, 225, hr(-6)}

  @doc """
  Greenwich.
  DR4 204 (14.2), greenwich
  """
  def greenwich, do: {51.4777815, 0, 46.9, hr(0)}

  @doc """
  Mecca.
  DR4 204 (14.3), mecca
  """
  # def mecca, do: {angle(21, 25, 24), angle(39, 49, 24), 298, hr(3)}
  def mecca, do: {6427 / 300, 11947 / 300, 298, 1 / 8}

  @doc """
  Jerusalem.
  DR4 204 (14.4), jerusalem
  """
  def jerusalem, do:  {31.78, 35.24, 740, hr(2)}

  @doc """
  Acre.
  DR4 204 (14.5), acre
  """
  def acre, do: {32.94, 35.09, 22, hr(2)}

  @doc """
  Angle (clockwise from North) to face `focus` when standing in `location`.
  DR4 205 (14.6), direction
  """
  def direction({phi, psi, _, _} = _location, {phi_prime, psi_prime, _, _} = _focus) do
    y = sin_degrees(psi_prime - psi)
    x = cos_degrees(phi) * tan_degrees(phi_prime) - sin_degrees(phi) * cos_degrees(psi - psi_prime)
    cond do
      x == 0 and y == 0 or phi_prime == deg(90) -> deg(0)
      phi_prime == deg(-90) -> deg(180)
      true -> arctan_degrees(y, x)
    end
  end

  @doc """
  Arctangent of `y/x` in degrees.
  Returns bogus if `x` and `y` are both 0.
  see lines 3462-3476 of calendrica-4.0.cl
  DR4 205 (14.7) arctan
  """
  def arctan_degrees(0, 0), do: bogus()
  def arctan_degrees(y, 0), do: mod(sign(y) * deg(90), 360)
  def arctan_degrees(y, x) do
    alpha = mod(degrees_from_radians(:math.atan(y / x)), 360)
    if x >= 0,
       do: alpha,
       else: mod(alpha + deg(180), 360)
  end

  # === 14.2 Time, DR4 206ff

  @doc """
  Difference between UT and local mean time at `longitude`
  as a fraction of a day.
  DR4 208 (14.8), zone-from-longitude
  """
  def zone_from_longitude(longitude) do
    longitude  / 360
  end

  @doc """
  Universal time from local `t_local` at `location`.
  DR4 208 (14.9), universal-from-local
  """
  def universal_from_local(t_local, {_, longitude, _, _} = _location) do
    t_local - zone_from_longitude(longitude)
  end

  @doc """
  Local time from universal `t_universal` at `location`.
  DR4 208 (14.10), local-from-universal
  """
  def local_from_universal(t_universal, {_, longitude, _, _} = _location) do
    t_universal + zone_from_longitude(longitude)
  end

  @doc """
  Standard time from `t_universal` in universal time at `location`.
  DR4 208 (14.11), standard-from-universal
  """
  def standard_from_universal(t_universal, {_, _, _, zone} = _location) do
    t_universal + zone
  end

  @doc """
  Universal time from `t_standard` in standard time at `location`.
  DR4 208 (14.12), universal-from-standard
  """
  def universal_from_standard(t_standard, {_, _, _, zone} = _location) do
    t_standard - zone
  end

  @doc """
  Standard time from local `t_local` at `location`.
  DR4 208 (14.13), standard-from-local
  """
  def standard_from_local(t_local, location) do
    t_universal = universal_from_local(t_local, location)
    standard_from_universal(t_universal, location)
  end

  @doc """
  Local time from standard `t_standard` at `location`.
  DR4 208 (14.14), local-from-standard
  """
  def local_from_standard(t_standard, location) do
    t_standard
    |> universal_from_standard(location)
    |> local_from_universal(location)
  end

  @doc """
  Dynamical Time minus Universal Time (in days) for moment `tee`.
  Adapted from "Astronomical Algorithms" by Jean Meeus, Willmann-Bell
  (1991) for years 1600-1986 and from polynomials on the NASA Eclipse
  web site for other years.
  DR4 210 (14.15), ephemeris-correction
  """
  def ephemeris_correction(tee) do
    year = gregorian_year_from_fixed(floor(tee))

    c = gregorian_date_difference({1900, 1, 1}, {year, 7, 1}) / 36525

    yy = (year - 1820) / 100
    c2051 = (-20 + 32 * yy * yy + 0.5628 * (2150 - year)) / 86400

    y2000 = year - 2000
    c2006 =
      poly(y2000, [
        62.92,
        0.32217,
        0.005589
      ]) / 86400

    c1987 =
      poly(y2000, [
        63.86,
        0.3345,
        -0.060374,
        0.0017275,
        0.000651814,
        0.00002373599
      ]) / 86400

    c1900 =
      poly(c, [
        -0.00002,
        0.000297,
        0.025184,
        -0.181133,
        0.553040,
        -0.861938,
        0.677066,
        -0.212591
      ])

    c1800 =
      poly(c, [
        -0.000009,
        0.003844,
        0.083563,
        0.865736,
        4.867575,
        15.845535,
        31.332267,
        38.291999,
        28.316289,
        11.636204,
        2.043794
      ])

    y1700 = year - 1700
    c1700 =
      poly(y1700, [
        8.118780842,
        -0.005092142,
        0.003336121,
        -0.0000266484
      ]) / 86400

    y1600 = year - 1600
    c1600 =
      poly(y1600, [
        120,
        -0.9808,
        -0.01532,
        0.000140272128
      ]) / 86400

    y1000 = (year - 1000) / 100
    c500 =
      poly(y1000, [
        1574.2,
        -556.01,
        71.23472,
        0.319781,
        -0.8503463,
        -0.005050998,
        0.0083572073
      ]) / 86400

    y0 = year / 100
    c0 =
      poly(y0, [
        10583.6,
        -1014.41,
        33.78311,
        -5.952053,
        -0.1798452,
        0.022174192,
        0.0090316521
      ]) / 86400

    y1820 = (year - 1820) / 100
    other =
      poly(y1820, [
        -20,
        0,
        32
      ]) / 86400

    cond do
      2051 <= year and year <= 2150 -> c2051
      2006 <= year and year <= 2050 -> c2006
      1987 <= year and year <= 2005 -> c1987
      1900 <= year and year <= 1986 -> c1900
      1800 <= year and year <= 1899 -> c1800
      1700 <= year and year <= 1799 -> c1700
      1600 <= year and year <= 1699 -> c1600
      500  <= year and year <= 1599 -> c500
      -500 <  year and year <  500  -> c0
      true -> other
    end
  end

  @doc """
  Dynamical time at Universal moment `t_universal`.
  DR4 212 (14.16), dynamical-from-universal
  """
  def dynamical_from_universal(t_universal) do
    t_universal + ephemeris_correction(t_universal)
  end

  @doc """
  Universal moment from Dynamical time `tee`.
  DR4 212 (14.17), universal-from-dynamical
  """
  def universal_from_dynamical(tee) do
    tee - ephemeris_correction(tee)
  end

  @doc """
  Julian centuries since 2000 at moment `tee`.
  DR4 212 (14.18), julian-centuries
  """
  def julian_centuries(tee) do
    (dynamical_from_universal(tee) - j2000()) / 36525
  end

  @doc """
  Noon at start of Gregorian year 2000 (precalculated).
  = `gregorian_new_year(2000) + hr(12)`
  DR4 212 (14.19), j2000
  """
  def j2000, do: 730120.5

  # === 14.3 The Day, DR4 212ff

  @doc """
  Equation of time (as fraction of day) for moment `tee`.
  Adapted from "Astronomical Algorithms" by Jean Meeus,
  Willmann-Bell, 2nd edn., 1998, p. 185.
  lines 4017-4046 of calendrica-4.0.cl
  DR4 215 (14.20), equation-of-time
  """
  def equation_of_time(tee) do
    c = julian_centuries(tee)
    c2 = c * c
    c3 = c2 * c

    lambda = 280.46645 + 36000.76983 * c + 0.0003032 * c2
    anomaly = 357.52910 + 35999.05030 * c - 0.0001559 * c2 - 0.00000048 * c3
    eccentricity = 0.016708617 - 0.000042037 * c - 0.0000001236 * c2

    epsilon = obliquity(tee)
    yy = tan_degrees(epsilon / 2)
    y = yy * yy

    equation = (
      y * sin_degrees(2 * lambda) -
        2 * eccentricity * sin_degrees(anomaly) +
        4 * eccentricity * y * sin_degrees(anomaly) * cos_degrees(2 * lambda) -
        0.5 * y * y * sin_degrees(4 * lambda) -
        1.25 * eccentricity * eccentricity * sin_degrees(2 * anomaly)
      ) / (2 * :math.pi())

    sign(equation) * min(abs(equation), hr(12))
  end

  @doc """
  Sundial time from local time `t_local` at `location`.
  DR4 217 (14.21), apparent-from-local
  """
  def apparent_from_local(t_local, location) do
    t_universal = universal_from_local(t_local, location)
    t_local + equation_of_time(t_universal)
  end

  @doc """
  Local time from sundial time `tee` at `location`.
  DR4 218 (14.22), local-from-apparent
  """
  def local_from_apparent(t_local, location) do
    t_universal = universal_from_local(t_local, location)
    t_local - equation_of_time(t_universal)
  end

  @doc """
  True (apparent) time at universal time `tee` at `location`.
  DR4 218 (14.23), apparent-from-universal
  """
  def apparent_from_universal(t_universal, location) do
    t_local = local_from_universal(t_universal, location)
    apparent_from_local(t_local, location)
  end

  @doc """
  Universal time from sundial time `tee` at `location`.
  DR4 218 (14.24), universal-from-apparent
  """
  def universal_from_apparent(t_apparent, location) do
    t_local = local_from_apparent(t_apparent, location)
    universal_from_local(t_local, location)
  end

  @doc """
  Universal time of true (apparent) midnight of `fixed` date at `location`.
  DR4 218 (14.25), midnight
  """
  def midnight(fixed, location) do
    universal_from_apparent(fixed, location)
  end

  @doc """
  Universal time on `fixed` date of midday at `location`.
  DR4 218 (14.26), midday
  """
  def midday(fixed, location) do
    universal_from_apparent(fixed + hr(12), location)
  end

  @doc """
  Mean sidereal time of day from moment `tee` expressed as hour angle.
  Adapted from "Astronomical Algorithms" by Jean Meeus,
  Willmann-Bell, Inc., 2nd edn., 1998, p. 88.
  lines 3923-3933 of calendrica-4.0.cl
  DR4 219 (14.27), sidereal-from-moment
  """
  def sidereal_from_moment(tee) do
    c = (tee - j2000()) / 36525
    mod(poly(c, deg([
      280.46061837,
      36525 * 360.98564736629,
      0.000387933,
      -1 / 38_710_000
    ])), 360)
  end

  # === 14.4 The Year, DR4 219ff

  @doc """
  Obliquity of ecliptic at moment `tee`.
  lines 3620-3628 of calendrica-4.0.cl
  DR4 220 (14.28), obliquity
  """
  def obliquity(tee) do
    c = julian_centuries(tee)
    angle(23, 26, 21.448) +
      poly(c, [
        0,
        -angle(0, 0, 46.8150),
        -angle(0, 0, 0.00059),
        angle(0, 0, 0.001813)
      ])
  end

  @doc """
  Declination at moment UT `tee` of object at
  latitude `beta` and longitude `lambda`.
  DR4 220 (14.29), declination
  lines 3630-3639 of calendrica-4.0.cl
  """
  def declination(tee, latitude, longitude) do
    epsilon = obliquity(tee)
    arcsin_degrees(
      sin_degrees(latitude) * cos_degrees(epsilon) +
        cos_degrees(latitude) * sin_degrees(epsilon) * sin_degrees(longitude)
    )
  end

  @doc """
  Right ascension at moment UT `tee` of object at
  latitude `beta` and longitude `lambda`.
  DR4 220 (14.30), right-ascension
  lines 3641-3651 of calendrica-4.0.cl
  """
  def right_ascension(tee, latitude, longitude) do
    epsilon = obliquity(tee)
    arctan_degrees(
      sin_degrees(longitude) * cos_degrees(epsilon) - tan_degrees(latitude) * sin_degrees(epsilon),
      cos_degrees(longitude)
    )
  end

  @doc """
  DR4 221 (14.31), mean-tropical-year
  """
  def mean_tropical_year, do: 365.242189

  @doc """
  DR4 221 (14.32), mean-sidereal-year
  """
  def mean_sidereal_year, do: 365.25636

  @doc """
  Longitude of sun at moment `tee`.
  Adapted from "Planetary Programs and Tables from -4000
  to +2800" by Pierre Bretagnon and Jean-Louis Simon,
  Willmann-Bell, 1986.
  lines 4048-4098 of calendrica-4.0.cl
  DR4 223 (14.33), solar-longitude
  """
  @spec solar_longitude(moment) :: season
  def solar_longitude(moment) do
    c = julian_centuries(moment)

    coefficients = [  # DR4 224, Table 14.1, x
      403406, 195207, 119433, 112392, 3891, 2819, 1721,
      660, 350, 334, 314, 268, 242, 234, 158, 132, 129, 114,
      99, 93, 86, 78, 72, 68, 64, 46, 38, 37, 32, 29, 28, 27, 27,
      25, 24, 21, 21, 20, 18, 17, 14, 13, 13, 13, 12, 10, 10, 10,
      10
    ]

    addends = [ # DR4 224, Table 14.1, y
      270.54861, 340.19128, 63.91854, 331.26220,
      317.843, 86.631, 240.052, 310.26, 247.23,
      260.87, 297.82, 343.14, 166.79, 81.53,
      3.50, 132.75, 182.95, 162.03, 29.8,
      266.4, 249.2, 157.6, 257.8, 185.1, 69.9,
      8.0, 197.1, 250.4, 65.3, 162.7, 341.5,
      291.6, 98.5, 146.7, 110.0, 5.2, 342.6,
      230.9, 256.1, 45.3, 242.9, 115.2, 151.8,
      285.3, 53.3, 126.6, 205.7, 85.9,
      146.1
    ]

    multipliers = [ # DR4 224, Table 14.1, z
      0.9287892, 35999.1376958, 35999.4089666,
      35998.7287385, 71998.20261, 71998.4403,
      36000.35726, 71997.4812, 32964.4678,
      -19.4410, 445267.1117, 45036.8840, 3.1008,
      22518.4434, -19.9739, 65928.9345,
      9038.0293, 3034.7684, 33718.148, 3034.448,
      -2280.773, 29929.992, 31556.493, 149.588,
      9037.750, 107997.405, -4444.176, 151.771,
      67555.316, 31556.080, -4561.540,
      107996.706, 1221.655, 62894.167,
      31437.369, 14578.298, -31931.757,
      34777.243, 1221.999, 62894.511,
      -4442.039, 107997.909, 119.066, 16859.071,
      -4.578, 26895.292, -39.127, 12297.536,
      90073.778
    ]

    periods =
      [coefficients, addends, multipliers]
      |> Enum.zip
      |> Enum.map(fn {x, y, z} -> x * sin_degrees(y + z * c) end)
      |> Enum.sum

    longitude = 282.7771834 + 36000.76953744 * c + 0.000005729577951308232 * periods

    mod(longitude + aberration(moment) + nutation(moment), 360)
  end

  @doc """
  Longitudinal nutation at moment `tee`.
  DR4 223 (14.34), nutation
  lines 4100-4110 of calendrica-4.0.cl
  """
  @spec nutation(moment) :: circle
  def nutation(moment) do
    c = julian_centuries(moment)
    c2 = c * c
    a = 124.90 - 1934.134 * c + 0.002063 * c2
    b = 201.11 + 72001.5377 * c + 0.00057 * c2

    (-0.004778 * sin_degrees(a)) - (0.0003667 * sin_degrees(b))
  end

  @doc """
  Aberration at moment `tee`.
  DR4 223 (14.35), aberration
  lines 4112-4120 of calendrica-4.0.cl
  """
  @spec aberration(moment) :: circle
  def aberration(moment) do
    c = julian_centuries(moment)

    0.0000974 * cos_degrees(177.63 + 35999.01848 * c) - 0.005575
  end

  @doc """
  Moment UT of the first time at or after `tee` when the solar longitude
  will be `lambda` degrees.
  lines 4122-4135 of calendrica-4.0.cl
  DR4 224 (14.36), solar-longitude-after
  """
  @spec solar_longitude_after(season, moment) :: moment
  def solar_longitude_after(season, moment) do
    rate = mean_tropical_year() / 360
    tau = moment + rate * mod(season - solar_longitude(moment), 360)
    a = max(moment, tau - 5)
    b = tau + 5

    invert_angular(&solar_longitude/1, season, a, b)
  end

  @doc """
  Moment UT of `season` in Gregorian year `g_year`.
  seelines 4157-4161 of calendrica-4.0.cl
  DR4 224 (14.37), season-in-gregorian
  """
  def season_in_gregorian(season, g_year) do
    jan1 = gregorian_new_year(g_year)
    solar_longitude_after(season, jan1)
  end

  @doc """
  Standard time of the winter solstice in Urbana, Illinois.
  DR4 225 (14.38), urbana-winter
  """
  def urbana_winter(g_year) do
    standard_from_universal(season_in_gregorian(winter(), g_year), urbana())
  end

  @doc """
  Precession at moment `tee` using 0,0 as J2000 coordinates.
  Adapted from "Astronomical Algorithms" by Jean Meeus,
  Willmann-Bell, 2nd edn., 1998, pp. 136-137.
  DR4 225 (14.39), precession
  """
  def precession(tee) do
    c = julian_centuries(tee)
    eta = mod(poly(c, [0, arcsecs(47.0029), arcsecs(-0.03302), arcsecs(0.000060)]), 360)
    cap_P = mod(poly(c, [deg(174.876384), arcsecs(-869.8089), arcsecs(0.03536)]), 360)
    p = mod(poly(c, [0, arcsecs(5029.0966), arcsecs(1.11113), arcsecs(0.000006)]), 360)
    cap_A = cos_degrees(eta) * sin_degrees(cap_P)
    cap_B = cos_degrees(cap_P)
    arg = arctan_degrees(cap_A, cap_B)
    mod(p + cap_P - arg, 360)
  end

  @doc """
  Sidereal solar longitude at moment `tee`.
  DR4 225 (14.40), sidereal-solar-longitude
  """
  def sidereal_solar_longitude(tee) do
    sidereal_start = 336.13605101930455 # pre-calculated
    mod(solar_longitude(tee) - precession(tee) + sidereal_start, 360)
  end

  @doc """
  Geocentric altitude of sun at `tee` at `location`,
  as a positive/negative angle in degrees, ignoring
  parallax and refraction.
  DR4 226 (14.41), solar-altitude
  """
  def solar_altitude(tee, {phi, psi, _, _} = _location) do
    lambda = solar_longitude(tee)
    alpha = right_ascension(tee, 0, lambda)
    declination = declination(tee, 0, lambda)
    theta0 = sidereal_from_moment(tee)
    cap_H = mod(theta0 + psi - alpha, 360)
    altitude = arcsin_degrees(
      sin_degrees(phi) * sin_degrees(declination) +
        cos_degrees(phi) * cos_degrees(declination) * cos_degrees(cap_H))
    imod(altitude, -180..180)
  end

  # === 14.5 Astronomical Solar Calendars, DR4 226f

  @doc """
  Approximate `moment` at or before `tee` when solar longitude
  just exceeded `lambda` degrees.
  DR4 226 (14.42), estimate-prior-solar-longitude
  """
  def estimate_prior_solar_longitude(lambda, tee) do
    rate = mean_tropical_year() / deg(360)
    tau = tee - rate * (mod(solar_longitude(tee) - lambda, 360))
    declination = imod(solar_longitude(tau) - lambda, -180..180)
    min(tee, tau - rate * declination)
  end

  # DR4 227 (14.43), not implemented

  # === 14.6 The Month, DR4 227ff

  @doc """
  DR4 227 (14.44), mean-synodic-month
  """
  def mean_synodic_month, do: 29.530588861
  def lunation,           do: mean_synodic_month()

  @doc """
  Moment of `n`-th new moon after (or before) the new moon of January 11, 1.
  Adapted from "Astronomical Algorithms" by Jean Meeus,
  Willmann-Bell, corrected 2nd edn., 2005.
  DR4 229 (14.45), nth-new-moon
  """
  def nth_new_moon(n) do
    n0 = 24724
    k = n - n0
    c = k / 1236.85

    approx =
      j2000() +
        poly(c, [5.09766, mean_synodic_month() * 1236.85, 0.00015437, -0.000000150, 0.00000000073])

    cap_E = poly(c, [1, -0.002516, -0.0000074])
    solar_anomaly = poly(c, [2.5534, 1236.85 * 29.10535670, -0.0000014, -0.00000011])

    lunar_anomaly =
      poly(c, [201.5643, 385.81693528 * 1236.85, 0.0107582, 0.00001238, -0.000000058])

    moon_argument =
      poly(c, [160.7108, 390.67050284 * 1236.85, -0.0016118, -0.00000227, 0.000000011])

    omega = poly(c, [124.7746, -1.56375588 * 1236.85, 0.0020672, 0.00000215])

    e_factor = [0, 1, 0, 0, 1, 1, 2, 0, 0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    solar_coeff = [0, 1, 0, 0, -1, 1, 2, 0, 0, 1, 0, 1, 1, -1, 2, 0, 3, 1, 0, 1, -1, -1, 1, 0]
    lunar_coeff = [1, 0, 2, 0, 1, 1, 0, 1, 1, 2, 3, 0, 0, 2, 1, 2, 0, 1, 2, 1, 1, 1, 3, 4]
    moon_coeff = [0, 0, 0, 2, 0, 0, 0, -2, 2, 0, 0, 2, -2, 0, 0, -2, 0, -2, 2, 2, 2, -2, 0, 0]

    sine_coeff = [
      -0.40720, 0.17241, 0.01608, 0.01039, 0.00739, -0.00514, 0.00208, -0.00111,
      -0.00057, 0.00056, -0.00042, 0.00042, 0.00038, -0.00024, -0.00007, 0.00004,
      0.00004, 0.00003, 0.00003, -0.00003, 0.00003, -0.00002, -0.00002, 0.00002]

    correction =
      -0.00017 * sin_degrees(omega) +
        sigma([sine_coeff, e_factor, solar_coeff, lunar_coeff, moon_coeff],
          fn {v, w, x, y, z} ->
            v * :math.pow(cap_E, w) *
              sin_degrees(x * solar_anomaly + y * lunar_anomaly + z * moon_argument)
          end)

    add_const = [
      251.88, 251.83, 349.42, 84.66, 141.74, 207.14, 154.84, 34.52, 207.19,
      291.34, 161.72, 239.56, 331.55]

    add_coeff = [
      0.016321, 26.651886, 36.412478, 18.206239, 53.303771, 2.453732, 7.306860,
      27.261239, 0.121824, 1.844379, 24.198154, 25.513099, 3.592518]

    add_factor = [
      0.000165, 0.000164, 0.000126, 0.000110, 0.000062, 0.000060, 0.000056,
      0.000047, 0.000042, 0.000040, 0.000037, 0.000035, 0.000023]

    extra = 0.000325 * sin_degrees(poly(c, [299.77, 132.8475848, -0.009173]))

    additional =
      [add_const, add_coeff, add_factor]
      |> Enum.zip
      |> Enum.map(fn {i, j, l} -> l * sin_degrees(i + j * k) end)
      |> Enum.sum

    universal_from_dynamical(approx + correction + extra + additional)
  end

  @doc """
  Moment UT of last new moon before `tee`.
  DR4 230 (14.46), new-moon-before
  """
  def new_moon_before(tee) do
    t0 = nth_new_moon(0)
    phi = lunar_phase(tee)
    n = round(((tee - t0) / mean_synodic_month()) - (phi / 360))
    nth_new_moon(final(n - 1, fn k -> nth_new_moon(k) < tee end))
  end


  @doc """
  Moment UT of first new moon at or after `tee`.
  DR4 231 (14.47), new-moon-at-or-after
  """
  def new_moon_at_or_after(tee) do
    t0 = nth_new_moon(0)
    phi = lunar_phase(tee)
    n = round(((tee - t0) / mean_synodic_month()) - (phi / 360))
    nth_new_moon(next(n, fn k -> nth_new_moon(k) >= tee end))
  end

  @doc """
  Longitude of moon (in degrees) at moment `tee`.
  Adapted from "Astronomical Algorithms" by Jean Meeus,
  Willmann-Bell, 2nd edn., 1998, pp. 338-342.
  DR4 232 (14.48), lunar-longitude
  """
  def lunar_longitude(tee) do
    c = julian_centuries(tee)
    ml = mean_lunar_longitude(c)             # cap_L_prime
    le = lunar_elongation(c)                 # cap_D
    sa = solar_anomaly(c)                    # cap_M
    la = lunar_anomaly(c)                    # cap_M_prime
    mn = moon_node(c)                        # cap_F
    ee = poly(c, [1, -0.002516, -0.0000074]) # cap_E

    vs = [ # sine_coeff, DR4 233, Table 14.5, v
      6288774, 1274027, 658314, 213618, -185116, -114332,
      58793, 57066, 53322, 45758, -40923, -34720, -30383,
      15327, -12528, 10980, 10675, 10034, 8548, -7888,
      -6766, -5163, 4987, 4036, 3994, 3861, 3665, -2689,
      -2602, 2390, -2348, 2236, -2120, -2069, 2048, -1773,
      -1595, 1215, -1110, -892, -810, 759, -713, -700, 691,
      596, 549, 537, 520, -487, -399, -381, 351, -340, 330,
      327, -323, 299, 294]

    ws = [ # args_lunar_elongation, DR4 233, Table 14.5, w
      0, 2, 2, 0, 0, 0, 2, 2, 2, 2, 0, 1, 0, 2, 0, 0, 4, 0, 4, 2, 2, 1,
      1, 2, 2, 4, 2, 0, 2, 2, 1, 2, 0, 0, 2, 2, 2, 4, 0, 3, 2, 4, 0, 2,
      2, 2, 4, 0, 4, 1, 2, 0, 1, 3, 4, 2, 0, 1, 2]

    xs = [ # args_solar_anomaly, DR4 233, Table 14.5, x
      0, 0, 0, 0, 1, 0, 0, -1, 0, -1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1,
      0, 1, -1, 0, 0, 0, 1, 0, -1, 0, -2, 1, 2, -2, 0, 0, -1, 0, 0, 1,
      -1, 2, 2, 1, -1, 0, 0, -1, 0, 1, 0, 1, 0, 0, -1, 2, 1, 0]

    ys = [ # args_lunar_anomaly, DR4 233, Table 14.5, y
      1, -1, 0, 2, 0, 0, -2, -1, 1, 0, -1, 0, 1, 0, 1, 1, -1, 3, -2,
      -1, 0, -1, 0, 1, 2, 0, -3, -2, -1, -2, 1, 0, 2, 0, -1, 1, 0,
      -1, 2, -1, 1, -2, -1, -1, -2, 0, 1, 4, 0, -2, 0, 2, 1, -2, -3,
      2, 1, -1, 3]

    zs = [ # args_moon_node, DR4 233, Table 14.5, z
      0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, -2, 2, -2, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, -2, 2, 0, 2, 0, 0, 0, 0,
      0, 0, -2, 0, 0, 0, 0, -2, -2, 0, 0, 0, 0, 0, 0, 0]

    sum =
      [vs, ws, xs, ys, zs]
      |> Enum.zip
      |> Enum.map(fn {v, w, x, y, z} ->
        v * :math.pow(ee, abs(x)) *
          sin_degrees(w * le + x * sa + y * la + z * mn)
      end)
      |> Enum.sum

    correction = sum / 1000000
    venus = sin_degrees(119.75 + c * 131.849) * 3958 / 1000000
    jupiter = sin_degrees(53.09 + c * 479264.29) * 318 / 1000000
    flat_earth = sin_degrees(ml - mn) * 1962 / 1000000

    mod(ml + correction + venus + jupiter + flat_earth + nutation(tee), 360)
  end

  @doc """
  Mean longitude of moon (in degrees) at moment
  given in Julian centuries `c`.
  Adapted from "Astronomical Algorithms" by Jean Meeus,
  Willmann-Bell, 2nd edn., 1998, pp. 337-340.
  DR4 233 (14.49), mean-lunar-longitude
  """
  def mean_lunar_longitude(c) do
    l = [218.3164477, 481267.88123421, -0.0015786, 1/538841, -1/65194000]
    mod(poly(c, l), 360)
  end

  @doc """
  Elongation of moon (in degrees) at moment
  given in Julian centuries `c`.
  Adapted from "Astronomical Algorithms" by Jean Meeus,
  Willmann-Bell, 2nd edn., 1998, p. 338.
  DR4 234 (14.50), lunar-elongation
  """
  def lunar_elongation(c) do
    l = [297.8501921, 445267.1114034, -0.0018819, 1/545868, -1/113065000]
    mod(poly(c, l), 360)
  end

  @doc """
  Mean anomaly of sun (in degrees) at moment
  given in Julian centuries `c`.
  Adapted from "Astronomical Algorithms" by Jean Meeus,
  Willmann-Bell, 2nd edn., 1998, p. 338.
  DR4 234 (14.51), solar-anomaly
  """
  def solar_anomaly(c) do
    l = [357.5291092, 35999.0502909, -0.0001536, 1/24490000]
    mod(poly(c, l), 360)
  end

  @doc """
  Mean anomaly of moon (in degrees) at moment
  given in Julian centuries `c`.
  Adapted from "Astronomical Algorithms" by Jean Meeus,
  Willmann-Bell, 2nd edn., 1998, p. 338.
  DR4 234 (14.52), lunar-anomaly
  """
  def lunar_anomaly(c) do
    l = [134.9633964, 477198.8675055, 0.0087414, 1/69699, -1/14712000]
    mod(poly(c, l), 360)
  end

  @doc """
  Moon's argument of latitude (in degrees) at moment
  given in Julian centuries `c`.
  Adapted from "Astronomical Algorithms" by Jean Meeus,
  Willmann-Bell, 2nd edn., 1998, p. 338.
  DR4 234 (14.53), moon-node
  """
  def moon_node(c) do
    l = [93.2720950, 483202.0175233, -0.0036539, -1 / 3526000, 1 / 863310000]
    mod(poly(c, l), 360)
  end

  @doc """
  Angular distance of the lunar node from the equinoctial
  point on `fixed` date.
  DR4 234 (14.54), lunar-node
  """
  def lunar_node(fixed) do
    c = julian_centuries(fixed)
    mod3(moon_node(c), -90, 90)
  end

  @doc """
  Sidereal lunar longitude at moment `tee`.
  DR4 234 (14.55), sidereal-lunar-longitude
  """
  def sidereal_lunar_longitude(tee) do
    sidereal_start = 156.13605090692624  # DR4, 411
    mod(lunar_longitude(tee) - precession(tee) + sidereal_start, 360)
  end

  @doc """
  Lunar phase, as an angle in degrees, at moment `tee`.
  An angle of 0 means a new moon, 90 degrees means the
  first quarter, 180 means a full moon, and 270 degrees
  means the last quarter.
  DR4 235 (14.56), lunar-phase
  """
  def lunar_phase(tee) do
    phi = mod(lunar_longitude(tee) - solar_longitude(tee), 360)
    t0 = nth_new_moon(0)
    n = round ((tee - t0) / mean_synodic_month())
    phi_prime = 360 * mod((tee - nth_new_moon(n)) / mean_synodic_month(), 1)

    (abs(phi - phi_prime) > 180 && phi_prime || phi)
  end

  @doc """
  Moment UT of the last time at or before `tee`
  when the lunar_phase was `phi` degrees.
  DR4 235 (14.57), lunar-phase-at-or-before
  """
  def lunar_phase_at_or_before(phi, tee) do
    tau = tee - (mean_synodic_month() / 360) * mod(lunar_phase(tee) - phi, 360)
    a = tau - 2
    b = min(tee, tau + 2)

    invert_angular(&lunar_phase/1, phi, a, b)
  end

  @doc """
  Moment UT of the next time at or after `tee`
  when the lunar_phase is `phi` degrees.
  DR4 235 (14.58), lunar-phase-at-or-after
  """
  def lunar_phase_at_or_after(phi, tee) do
    tau = tee +
      (mean_synodic_month() / 360) *
        mod(phi - lunar_phase(tee), 360)
    a = max(tee, tau - 2)
    b = tau + 2

    invert_angular(&lunar_phase/1, phi, a, b)
  end

  def new_moon,           do:   0  # DR4 236 (14.59)
  def first_quarter_moon, do:  90  # DR4 236 (14.60)
  def full_moon,          do: 180  # DR4 236 (14.61)
  def last_quarter_moon,  do: 270  # DR4 236 (14.62)

  @doc """
  Latitude of moon (in degrees) at moment `tee`.
  Adapted from "Astronomical Algorithms" by Jean Meeus,
  Willmann-Bell, 2nd edn., 1998, pp. 338-342.
  DR4 (14.63), lunar-latitude
  """
  def lunar_latitude(tee) do
    c = julian_centuries(tee)
    ml = mean_lunar_longitude(c)             # cap_L_prime
    le = lunar_elongation(c)                 # cap_D
    sa = solar_anomaly(c)                    # cap_M
    la = lunar_anomaly(c)                    # cap_M_prime
    mn = moon_node(c)                        # cap_F
    ee = poly(c, [1, -0.002516, -0.0000074]) # cap_E

    vs = [  # sine-coeff, DR4 237, Table 14.6, v
      5128122, 280602, 277693, 173237, 55413, 46271, 32573,
      17198, 9266, 8822, 8216, 4324, 4200, -3359, 2463, 2211,
      2065, -1870, 1828, -1794, -1749, -1565, -1491, -1475,
      -1410, -1344, -1335, 1107, 1021, 833, 777, 671, 607,
      596, 491, -451, 439, 422, 421, -366, -351, 331, 315,
      302, -283, -229, 223, 223, -220, -220, -185, 181,
      -177, 176, 166, -164, 132, -119, 115, 107]

    ws = [ # args-lunar-elongation, DR4 237, Table 14.6, w
      0, 0, 0, 2, 2, 2, 2, 0, 2, 0, 2, 2, 2, 2, 2, 2, 2, 0, 4, 0, 0, 0,
      1, 0, 0, 0, 1, 0, 4, 4, 0, 4, 2, 2, 2, 2, 0, 2, 2, 2, 2, 4, 2, 2,
      0, 2, 1, 1, 0, 2, 1, 2, 0, 4, 4, 1, 4, 1, 4, 2]

    xs = [ # args-solar-anomaly, DR4 237, Table 14.6, x
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 1, -1, -1, -1, 1, 0, 1,
      0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1, 1,
      0, -1, -2, 0, 1, 1, 1, 1, 1, 0, -1, 1, 0, -1, 0, 0, 0, -1, -2]

    ys = [ # args-lunar-anomaly, DR4 237, Table 14.6, y
      0, 1, 1, 0, -1, -1, 0, 2, 1, 2, 0, -2, 1, 0, -1, 0, -1, -1, -1,
      0, 0, -1, 0, 1, 1, 0, 0, 3, 0, -1, 1, -2, 0, 2, 1, -2, 3, 2, -3,
      -1, 0, 0, 1, 0, 1, 1, 0, 0, -2, -1, 1, -2, 2, -2, -1, 1, 1, -1,
      0, 0]

    zs = [ # args-moon-node, DR4 237, Table 14.6, z
      1, 1, -1, -1, 1, -1, 1, 1, -1, -1, -1, -1, 1, -1, 1, 1, -1, -1,
      -1, 1, 3, 1, 1, 1, -1, -1, -1, 1, -1, 1, -3, 1, -3, -1, -1, 1,
      -1, 1, -1, 1, 1, 1, 1, -1, 3, -1, -1, 1, -1, -1, 1, -1, 1, -1,
      -1, -1, -1, -1, -1, 1]

    sum =
      [vs, ws, xs, ys, zs]
      |> Enum.zip
      |> Enum.map(fn {v, w, x, y, z} ->
        v * :math.pow(ee, abs(x)) *
          sin_degrees(w * le + x * sa + y * la + z * mn)
      end)
      |> Enum.sum

    beta = sum / 1000000

    venus = (
      sin_degrees(119.75 + c * 131.849 + mn) +
        sin_degrees(119.75 + c * 131.849 - mn)
      ) * (175 / 1000000)

    flat_earth = (
      127 * sin_degrees(ml - la) -
        115 * sin_degrees(ml + la) -
        2235 * sin_degrees(ml)
      ) / 1000000

    extra = sin_degrees(313.45 + c * 481266.484) * (382 / 1000000)

    beta + venus + flat_earth + extra
  end

  @doc """
  Geocentric altitude of moon at `tee` at `location`, as a small
  positive/negative angle in degrees, ignoring parallax and refraction.
  Adapted from "Astronomical Algorithms" by Jean Meeus,
  Willmann-Bell, 2nd edn., 1998.
  DR4 237 (14.64), lunar-altitude
  """
  def lunar_altitude(tee, {phi, psi, _, _} = _location) do
    lunar_long = lunar_longitude(tee)
    lunar_lat = lunar_latitude(tee)
    lunar_right_asc = right_ascension(tee, lunar_lat, lunar_long)
    declination = declination(tee, lunar_lat, lunar_long)
    sidereal_time = sidereal_from_moment(tee)
    local_hour_angle = mod(sidereal_time + psi - lunar_right_asc, 360)

    altitude = arcsin_degrees(
      sin_degrees(phi) * sin_degrees(declination) +
        cos_degrees(phi) * cos_degrees(declination) * cos_degrees(local_hour_angle))

    mod3(altitude, -180, 180)
  end

  @doc """
  Distance to moon (in meters) at moment `tee`.
  Adapted from "Astronomical Algorithms" by Jean Meeus,
  Willmann-Bell, 2nd edn., 1998, pp. 338-342.
  DR4 238 (14.65), lunar-distance
  """
  def lunar_distance(tee) do
    c = julian_centuries(tee)
    le = lunar_elongation(c)                 # cap_D
    sa = solar_anomaly(c)                    # cap_M
    la = lunar_anomaly(c)                    # cap_M_prime
    mn = moon_node(c)                        # cap_F
    ee = poly(c, [1, -0.002516, -0.0000074]) # cap_E

    vs = [ # cosine-coeff, DR4 239, Table 14.7, v
      -20905355, -3699111, -2955968, -569925, 48888, -3149,
      246158, -152138, -170733, -204586, -129620, 108743,
      104755, 10321, 0, 79661, -34782, -23210, -21636, 24208,
      30824, -8379, -16675, -12831, -10445, -11650, 14403,
      -7003, 0, 10056, 6322, -9884, 5751, 0, -4950, 4130, 0,
      -3958, 0, 3258, 2616, -1897, -2117, 2354, 0, 0, -1423,
      -1117, -1571, -1739, 0, -4421, 0, 0, 0, 0, 1165, 0, 0,
      8752]

    ws = [ # args-lunar-elongation, DR4 239, Table 14.7, w
      0, 2, 2, 0, 0, 0, 2, 2, 2, 2, 0, 1, 0, 2, 0, 0, 4, 0, 4, 2, 2, 1,
      1, 2, 2, 4, 2, 0, 2, 2, 1, 2, 0, 0, 2, 2, 2, 4, 0, 3, 2, 4, 0, 2,
      2, 2, 4, 0, 4, 1, 2, 0, 1, 3, 4, 2, 0, 1, 2, 2]

    xs = [ # args-solar-anomaly, DR4 239, Table 14.7, x
      0, 0, 0, 0, 1, 0, 0, -1, 0, -1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1,
      0, 1, -1, 0, 0, 0, 1, 0, -1, 0, -2, 1, 2, -2, 0, 0, -1, 0, 0, 1,
      -1, 2, 2, 1, -1, 0, 0, -1, 0, 1, 0, 1, 0, 0, -1, 2, 1, 0, 0]

    ys = [ # args-lunar-anomaly, DR4 239, Table 14.7, y
      1, -1, 0, 2, 0, 0, -2, -1, 1, 0, -1, 0, 1, 0, 1, 1, -1, 3, -2,
      -1, 0, -1, 0, 1, 2, 0, -3, -2, -1, -2, 1, 0, 2, 0, -1, 1, 0,
      -1, 2, -1, 1, -2, -1, -1, -2, 0, 1, 4, 0, -2, 0, 2, 1, -2, -3,
      2, 1, -1, 3, -1]

    zs = [ # args-moon-node, DR4 239, Table 14.7, z
      0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, -2, 2, -2, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, -2, 2, 0, 2, 0, 0, 0, 0,
      0, 0, -2, 0, 0, 0, 0, -2, -2, 0, 0, 0, 0, 0, 0, 0, -2]

    correction =
      [vs, ws, xs, ys, zs]
      |> Enum.zip
      |> Enum.map(fn {v, w, x, y, z} ->
        v * :math.pow(ee, abs(x)) * cos_degrees(w * le + x * sa + y * la + z * mn)
      end)
      |> Enum.sum

    385000560 + correction
  end

  @doc """
  Parallax of moon at `tee` at `location`.
  Adapted from "Astronomical Algorithms" by Jean Meeus,
  Willmann-Bell, 2nd edn., 1998.
  DR4 238 (14.66), lunar-parallax
  """
  def lunar_parallax(tee, location) do
    geo = lunar_altitude(tee, location)
    delta = lunar_distance(tee)
    alt = 6378140 / delta
    arcsin_degrees(alt * cos_degrees(geo))
  end

  @doc """
  Topocentric altitude of moon at `tee` at `location`, as a small
  positive/negative angle in degrees, ignoring refraction.
  DR4 239 (14.67), topocentric-lunar-altitude
  """
  def topocentric_lunar_altitude(tee, location) do
    alt = lunar_altitude(tee, location)
    parallax = lunar_parallax(tee, location)
    alt - parallax
  end

  # === 14.7 Rising and Setting of the Sun and Moon, DR4 240ff

  @doc """
  Moment in local time near `tee` when depression angle of sun is
  `alpha` (negative if above horizon) at `location`;
  `early?` is true when morning event is sought and false for evening.
  Returns bogus if depression angle is not reached.
  DR4 240 (14.68), approx-moment-of-depression
  """
  def approx_moment_of_depression(tee, location, alpha, early?) do
    try = sine_offset(tee, location, alpha)
    fixed = fixed_from_moment(tee)
    alt =
      cond do
        alpha >= 0 and early? -> fixed
        alpha >= 0 -> fixed + 1
        true -> fixed + hr(12)
      end
    value = abs(try) > 1 && sine_offset(alt, location, alpha) || try

    if abs(value) <=1 do
      offset = mod3(arcsin_degrees(value) / 360, hr(-12), hr(12))
      hours = early? && hr(6) - offset || hr(18) + offset
      local_from_apparent(fixed + hours, location)
    else
      bogus()
    end
  end

  @doc """
  Sine of angle between position of sun at local time `tee` and
  when its depression is `alpha` at `location`.
  Out of range when it does not occur.
  DR4 241 (14.69), sine-offset
  """
  def sine_offset(tee, {phi, _, _, _} = location, alpha) do
    t_prime = universal_from_local(tee, location)
    delta = declination(t_prime, 0, solar_longitude(t_prime))
    tan_degrees(phi) * tan_degrees(delta) +
      sin_degrees(alpha) / (cos_degrees(delta) * cos_degrees(phi))
  end

  @doc """
  Moment in local time near `approx` when depression angle of sun is
  `alpha` (negative if above horizon) at `location`;
  `early?` is true when morning event is sought, and false for evening.
  Returns bogus if depression angle is not reached.
  DR4 241 (14.70), moment-of-depression
  """
  def moment_of_depression(approx, location, alpha, early?) do
    tee = approx_moment_of_depression(approx, location, alpha, early?)
    cond do
      tee == bogus() -> bogus()
      abs(approx - tee) < sec(30) -> tee
      true -> moment_of_depression(tee, location, alpha, early?)
    end
  end

  @doc """
  Signifies morning.
  DR4 241 (14.71), morning
  """
  def morning, do: true

  @doc """
  Standard time in morning on `fixed` date at `location`
  when depression angle of sun is `alpha`.
  Returns bogus if there is no dawn on `date`.
  See DR4 244 for various depression angles.
  DR4 241 (14.72), dawn
  """
  def dawn(fixed, location, alpha) do
    result = moment_of_depression(fixed + hr(6), location, alpha, morning())
    if result == bogus(),
       do: bogus(),
       else: standard_from_local(result, location)
  end

  @doc """
  Signifies evening.
  DR4 241 (14.73), evening
  """
  def evening, do: false

  @doc """
  Standard time in evening on `fixed` date at `location`
  when depression angle of sun is `alpha`.
  Returns bogus if there is no dusk on `date`.
  DR4 242 (14.74), dusk
  """
  def dusk(fixed, location, alpha) do
    result = moment_of_depression(fixed + hr(18), location, alpha, evening())
    if result == bogus(),
       do: bogus(),
       else: standard_from_local(result, location)
  end

  @doc """
  Refraction angle at moment `tee` at `location`.
  The moment is not used.
  DR4 242 (14.75), refraction
  """
  def refraction(_tee, {_, _, elevation, _} = _location) do
    h = max(0, elevation)
    radius_of_earth = 6372000
    dip = arccos_degrees(radius_of_earth / (radius_of_earth + h))
    arcmins(34) + dip + arcsecs(19) * :math.sqrt(h)
  end

  @doc """
  Standard time of sunrise on `fixed` date at `location`.
  DR4 242 (14.76), sunrise
  """
  def sunrise(fixed, location) do
    alpha = refraction(fixed + hr(6), location) + arcmins(16)
    dawn(fixed, location, alpha)
  end

  @doc """
  Standard time of sunset on `fixed` date at `location`.
  DR4 242 (14.77), sunset
  """
  def sunset(fixed, location) do
    alpha = refraction(fixed + hr(18), location) + arcmins(16)
    dusk(fixed, location, alpha)
  end

  @doc """
  Standard time of sunset in Urbana, Illinois, on a given Gregorian date.
  DR4 243 (14.78), sunset
  """
  def urbana_sunset(g_date) do
    g_date
    |> fixed_from_gregorian
    |> sunset(urbana())
    |> time_from_moment
  end

  @doc """
  DR4 243 (14.79)
  """
  def cfs_alert, do: {82.5, 62.316667, 0, -0.208333}

  @doc """
  Standard time of end of Jewish sabbath on `fixed` date
  at `location` (as per Berthold Cohn).
  DR4 243 (14.80), jewish-sabbath-ends
  """
  def jewish_sabbath_ends(fixed, location) do
    dusk(fixed, location, angle(7, 5, 0))
  end

  @doc """
  Standard time of Jewish dusk on `fixed` date
  at `location` (as per Vilna Gaon).
  DR4 243 (14.81), jewish-dusk
  """
  def jewish_dusk(fixed, location) do
    dusk(fixed, location, angle(4, 40, 0))
  end

  @doc """
  Observed altitude of upper limb of moon at `tee` at `location`,
  as a small positive/negative angle in degrees, including refraction
  and elevation. 16' is the approximate half-diameter of the moon.
  DR4 243 (14.82), observed-lunar-altitude
  """
  def observed_lunar_altitude(tee, location) do
    alt = topocentric_lunar_altitude(tee, location)
    ref = refraction(tee, location) + arcmins(16)
    alt + ref
  end

  @doc """
  Standard time of moonrise on `fixed` date at `location`.
  Returns bogus if there is no moonrise on `fixed`.
  Else no moonrise this day.
  DR4 244 (14.83), moonrise
  """
  def moonrise(fixed, {latitude, _, _, _} = location) do
    t = universal_from_standard(fixed, location)
    waning = lunar_phase(t) > 180
    altitude = observed_lunar_altitude(t, location)
    offset = altitude / (4 * (90 - abs(latitude)))
    approx = # Approximate rising time
      cond do
        waning and offset > 0 -> t + 1 - offset
        waning -> t - offset
        true -> t + 0.5 + offset
      end
    rise = binary_search(
      approx - hr(6),
      approx + hr(6),
      fn lower, upper -> (upper - lower) < mn(1) end,
      fn x -> observed_lunar_altitude(x, location) > 0 end)

    if rise < (t + 1),
       do: max(standard_from_universal(rise, location), fixed),
       else: bogus()
  end

  @doc """
  Standard time of moonset on `fixed` date at `location`.
  Returns bogus if there is no moonset on `fixed`.
  Else no moonset this day.
  DR4 245 (14.84), moonset
  """
  def moonset(fixed, {latitude, _, _, _} = location) do
    t = universal_from_standard(fixed, location)
    waxing = lunar_phase(t) < 180
    altitude = observed_lunar_altitude(t, location)
    offset = altitude / (4 * (90 - abs(latitude)))
    approx = # Approximate setting time
      cond do
        waxing and offset > 0 -> t + offset
        waxing -> t + 1 + offset
        true -> t - offset + 0.5
      end
    set = binary_search(
      approx - hr(6),
      approx + hr(6),
      fn lower, upper -> (upper - lower) < mn(1) end,
      fn x -> observed_lunar_altitude(x, location) < 0 end)

    if set < t + 1,
       do: max(standard_from_universal(set, location), fixed),
       else: bogus()
  end

  # === 14.8 Times of Day, DR4 245ff

  @doc """
  Location of Padua.
  DR4 246 (14.85), padua
  """
  def padua, do: {angle(45, 24, 28), angle(11, 53, 9), 18, hr(1)}

  @doc """
  Local time of dusk in Padua, Italy on date of moment `tee`.
  DR4 246 (14.86), local-zero-hour
  """
  def local_zero_hour(tee) do
    fixed = fixed_from_moment(tee)
    sunset_padua = dusk(fixed, padua(), arcmins(16)) + mn(30)
    local_from_standard(sunset_padua, padua())
  end

  @doc """
  Local time corresponding to Italian time `tee`.
  DR4 247 (14.87), local-from-italian
  """
  def local_from_italian(tee) do
    fixed = fixed_from_moment(tee)
    z = local_zero_hour(tee - 1)
    tee - fixed + z
  end

  @doc """
  Italian time corresponding to local time `t_local`.
  DR4 247 (14.88), italian-from-local
  """
  def italian_from_local(t_local) do
    fixed = fixed_from_moment(t_local)
    z0 = local_zero_hour(t_local - 1)
    z = local_zero_hour(t_local)
    if t_local > z,                # after midnight
       do: t_local + fixed + 1 - z, # then next day
       else: t_local + fixed - z0
  end

  @doc """
  Length of daytime temporal hour on `fixed` date at `location`.
  Returns bogus if there no sunrise or sunset on `date`.
  DR4 247 (14.89), daytime-temporal-hour
  """
  def daytime_temporal_hour(fixed, location) do
    sunrise = sunrise(fixed, location)
    sunset = sunset(fixed, location)
    cond do
      sunrise == bogus() -> bogus()
      sunset == bogus() -> bogus()
      true -> (sunset - sunrise) / 12
    end
  end

  @doc """
  Length of nighttime temporal hour on `fixed` date at `location`.
  Returns bogus if there no sunrise or sunset on `date`.
  DR4 248 (14.90), nighttime-temporal-hour
  """
  def nighttime_temporal_hour(fixed, location) do
    sunrise = sunrise(fixed + 1, location)
    sunset = sunset(fixed, location)
    cond do
      sunrise == bogus() -> bogus()
      sunset == bogus() -> bogus()
      true -> (sunrise - sunset) / 12
    end
  end

  @doc """
  Standard time of temporal moment `tee` at `location`.
  Returns bogus if temporal hour is undefined that day.
  DR4 248 (14.91), standard-from-sundial
  """
  def standard_from_sundial(tee, location) do
    fixed = fixed_from_moment(tee)
    time = 24 * time_from_moment(tee)
    h =
      cond do
        6 <= time and time <= 18 -> daytime_temporal_hour(fixed, location)
        time < 6 -> nighttime_temporal_hour(fixed - 1, location)
        true -> nighttime_temporal_hour(fixed, location)
      end
    cond do
      h == bogus() -> bogus()
      6 <= time and time <= 18 -> sunrise(fixed, location) + (time - 6) * h
      time < 6 -> sunset(fixed - 1, location) + (time + 6) * h
      true -> sunset(fixed, location) + (time - 18) * h
    end
  end

  @doc """
  Standard time on `fixed` date at `location` of end of
  morning according to Jewish ritual.
  DR4 248 (14.92), jewish-morning-end
  """
  def jewish_morning_end(fixed, location) do
    standard_from_sundial(fixed + hr(10), location)
  end

  @doc """
  Standard time of asr on `fixed` date at `location`.
  According to Hanafi rule.
  Returns bogus is no asr occurs.
  DR4 249 (14.93), asr
  """
  def asr(fixed, {phi, _, _, _} = location) do
    noon = midday(fixed, location)
    delta = declination(noon, 0, solar_longitude(noon))
    altitude = arcsin_degrees(
      cos_degrees(delta) * cos_degrees(phi) +
        sin_degrees(delta) * sin_degrees(phi))
    h = mod3(arctan_degrees(tan_degrees(altitude), 2 * tan_degrees(altitude) + 1), -90, 90)
    if altitude <= 0, # No shadow
       do: bogus(),
       else: dusk(fixed, location, -h)
  end

  @doc """
  Standard time of asr on `fixed` date at `location`.
  According to Shafi'i rule.
  Returns bogus is no asr occurs.
  DR4 249 (14.94), alt-asr
  """
  def alt_asr(fixed, {phi, _, _, _} = location) do
    noon = midday(fixed, location)
    delta = declination(noon, 0, solar_longitude(noon))
    altitude = arcsin_degrees(
      cos_degrees(delta) * cos_degrees(phi) +
        sin_degrees(delta) * sin_degrees(phi))
    h = mod3(arctan_degrees(tan_degrees(altitude), tan_degrees(altitude) + 1), -90, 90)
    if altitude <= 0, # No shadow
       do: bogus(),
       else: dusk(fixed, location, -h)
  end

  # === 14.9 Lunar Crescent Visibility, DR4 249ff

  @doc """
  Angular separation of sun and moon at moment `tee`.
  DR4 250 (14.95), arc-of-light
  """
  def arc_of_light(tee) do
    arccos_degrees(
      cos_degrees(lunar_latitude(tee)) * cos_degrees(lunar_phase(tee)))
  end

  @doc """
  Best viewing time (UT) in the evening.
  Simple version.
  DR4 250 (14.96), simple-best-view
  """
  def simple_best_view(fixed, location) do
    dark = dusk(fixed, location, 4.5)
    best = dark == bogus() && fixed + 1 || dark
    universal_from_standard(best, location)
  end

  @doc """
  S. K. Shaukat's criterion for likely visibility of crescent moon
  on eve of `date` at `location`.
  Not intended for high altitudes or polar regions.
  DR4 250 (14.97), shaukat-criterion
  """
  def shaukat_criterion(fixed, location) do
    tee = simple_best_view(fixed - 1, location)
    phase = lunar_phase(tee)
    h = lunar_altitude(tee, location)
    arcl = arc_of_light(tee)
    new_moon() < phase and
    phase < first_quarter_moon() and
    10.6 <= arcl and
    arcl <= 90 and
    h > 4.1
  end

  @doc """
  Angular difference in altitudes of sun and moon
  at moment `tee` at `location`.
  DR4 251 (14.98), arc-of-vision
  """
  def arc_of_vision(tee, location) do
    lunar_altitude(tee, location) - solar_altitude(tee, location)
  end

  @doc """
  Best viewing time (UT) in the evening.
  Yallop version, per Bruin (1977).
  DR4 251 (14.99), bruin-best-view
  """
  def bruin_best_view(fixed, location) do
    sun = sunset(fixed, location)
    moon = moonset(fixed, location)
    best =
      cond do
        sun == bogus() -> fixed + 1
        moon == bogus() -> fixed + 1
        true -> (5 / 9) * sun + (4 / 9) * moon
      end
    universal_from_standard(best, location)
  end

  @doc """
  B. D. Yallop's criterion for possible visibility of crescent moon
  on eve of `fixed` at `location`.
  Not intended for high altitudes or polar regions.
  DR4 251 (14.100), yallop-criterion
  """
  def yallop_criterion(fixed, location) do
    tee = bruin_best_view(fixed - 1, location)
    phase = lunar_phase(tee)
    cap_d = lunar_semi_diameter(tee, location)
    cap_arcl = arc_of_light(tee)
    cap_w = cap_d * (1 - cos_degrees(cap_arcl))
    cap_arcv = arc_of_vision(tee, location)
    e = -0.14 # Crescent visible under perfect conditions
    q1 = poly(cap_w, [11.8371, -6.3226, 0.7319, -0.1018])
    new_moon() < phase and
    phase < first_quarter_moon() and
    cap_arcv > q1 + e
  end

  @doc """
  Topocentric lunar semi_diameter at moment `tee` and `location`.
  DR4 251 (14.101), lunar-semi-diameter
  """
  def lunar_semi_diameter(tee, location) do
    h = lunar_altitude(tee, location)
    p = lunar_parallax(tee, location)
    0.27245 * p * (1 + sin_degrees(h) * sin_degrees(p))
  end

  @doc """
  Geocentric apparent lunar diameter of the moon (in degrees) at moment `tee`.
  Adapted from "Astronomical Algorithms" by Jean Meeus,
  Willmann-Bell, 2nd edn., 1998.
  DR4 252 (14.102), lunar-diameter
  """
  def lunar_diameter(tee) do
    1792367000 / (9 * lunar_distance(tee))
  end

  @doc """
  Criterion for possible visibility of crescent moon on eve of `fixed`
  at `location`. Shaukat's criterion may be replaced with another.
  DR4 252 (14.103), visible-crescent
  """
  def visible_crescent(fixed, location) do
    shaukat_criterion(fixed, location)
  end

  @doc """
  Closest fixed date on or before `date` when crescent moon first became
  visible at `location`.
  DR4 252 (14.104), phasis-on-or-before
  """
  def phasis_on_or_before(fixed, location) do
    new_phase = lunar_phase_at_or_before(new_moon(), fixed)
    moon = fixed_from_moment(new_phase)
    age = fixed - moon
    tau =
      if age <= 3 and not visible_crescent(fixed, location),
         do: moon - 30,
         else: moon
    next(tau, fn d -> visible_crescent(d, location) end)
  end

  @doc """
  Closest fixed date on or after `date` on the eve
  of which crescent moon first became visible at `location`.
  DR4 252 (14.105), phasis-on-or-after
  """
  def phasis_on_or_after(fixed, location) do
    new_phase = lunar_phase_at_or_before(new_moon(), fixed)
    moon = fixed_from_moment(new_phase)
    age = fixed - moon
    tau =
      if 4 <= age or visible_crescent(fixed - 1, location),
         do: moon + 29,   # Next new moon
         else: fixed
    next(tau, fn d -> visible_crescent(d, location) end)
  end

  # === 15 The Persian Calendar, DR4 257ff

  # === 15.1 Structure, DR4 257ff

  @doc """
  Persian Epoch.
  __
  ... we just number the years, ..., and choose as epoch the traditional
  year of ascension of the first Yarlun King, Nyatri Tsenpo.
  __
  = `fixed-from-julian(622 C.E., march, 19)`
  DR4 258 (15.1), persian-epoch
  """
  def persian_epoch, do: 226896

  # === 15.2 The Astronomical Calendar, DR4 259f

  @doc """
  Location of Theran.
  DR4 259 (15.2), tehran
  """
  def tehran, do: {35.68, 51.42, 1100, hr(3.5)}

  @doc """
  Universal time of true noon on fixed `date` in Tehran.
  DR4 259 (15.3), midday-in-tehran
  """
  def midday_in_tehran(fixed), do: midday(fixed, tehran())

  @doc """
  Fixed date of Astronomical Persian New Year on or before `fixed` date.
  DR4 259 (15.4), persian-new-year-on-or-before
  """
  def persian_new_year_on_or_before(fixed) do
    approx = estimate_prior_solar_longitude(spring(), midday_in_tehran(fixed))
    next(floor(approx) - 1,
      fn day -> solar_longitude(midday_in_tehran(day)) <= spring() + 2 end)
  end

  @doc """
  Fixed date of Astronomical Persian date `p_date`.
  DR4 260 (15.5), fixed-from-persian
  """
  def fixed_from_persian({year, month, day}) do
    fixed_from_persian(year, month, day)
  end

  def fixed_from_persian(year, month, day) do
    years = floor(mean_tropical_year() * (0 < year && year - 1 || year))
    new_year = persian_new_year_on_or_before(persian_epoch() + 180 + years)
    days = month <= 7 && 31 * (month - 1) || 30 * (month - 1) + 6
    new_year - 1 + days + day
  end

  @doc """
  Astronomical Persian date `{year, month, day}` corresponding to `fixed` date.
  DR4 260 (15.6), persian-from-fixed
  """
  def persian_from_fixed(fixed) do
    new_year = persian_new_year_on_or_before(fixed)
    y = round((new_year - persian_epoch()) / mean_tropical_year()) + 1
    year = 0 < y && y || y - 1
    day_of_year = fixed - fixed_from_persian(year, 1, 1) + 1
    month = ceil(day_of_year <= 186 && day_of_year / 31 || (day_of_year - 6) / 30)
    day = fixed - fixed_from_persian(year, month, 1) + 1
    {year, month, day}
  end

  # === 15.3 The Arithmetical Calendar, DR4 261ff

  @doc """
  True if `p_year` is a leap year on the Persian calendar.
  DR4 262 (15.7), arithmetic-persian-leap-year?
  """
  def arithmetic_persian_leap_year?(p_year) do
    y = 0 < p_year && p_year - 474 || p_year - 473
    year = mod(y, 2820) + 474
    mod((year + 38) * 31, 128) < 31
  end

  @doc """
  Fixed date equivalent to Persian date `p_date`.
  DR4 262 (15.8), fixed-from-arithmetic-persian
  """
  def fixed_from_arithmetic_persian({p_year, month, day}) do
    fixed_from_arithmetic_persian(p_year, month, day)
  end

  def fixed_from_arithmetic_persian(p_year, month, day) do
    y = 0 < p_year && p_year - 474 || p_year - 473
    year = mod(y, 2820) + 474

    persian_epoch() - 1 +
      1029983 * floor(y / 2820) +
      365 * (year - 1) +
      floor((31 * year - 5) / 128) +
      (month <= 7 && 31 * (month - 1) || 30 * (month - 1) + 6) +
      day
  end

  @doc """
  Persian year corresponding to the `fixed` date.
  DR4 263 (15.9), arithmetic-persian-year-from-fixed
  """
  def arithmetic_persian_year_from_fixed(fixed) do
    d0 = fixed - fixed_from_arithmetic_persian(475, 1, 1)
    n2820 = floor(d0 / 1029983)
    d1 = mod(d0, 1029983)
    y2820 = (d1 == 1029982 && 2820) || floor((128 * d1 + 46878) / 46751)
    year = 474 + (2820 * n2820) + y2820
    0 < year && year || year - 1
  end

  @doc """
  Persian date corresponding to `fixed` date.
  DR4 263 (15.10), arithmetic-persian-from-fixed
  """
  def arithmetic_persian_from_fixed(fixed) do
    year = arithmetic_persian_year_from_fixed(fixed)
    day_of_year = 1 + fixed - fixed_from_arithmetic_persian(year, 1, 1)
    month = day_of_year <= 186 && ceil(day_of_year / 31) || ceil((day_of_year - 6) / 30)
    day = fixed - fixed_from_arithmetic_persian(year, month, 1) + 1
    {year, month, day}
  end

  # === 15.4 Holidays, DR4 265f

  @doc """
  Date of Persian New Year (Nowruz) in Gregorian year `g_year`.
  DR4 265 (15.11), nowruz
  """
  def nowruz(g_year) do
    persian_year = g_year - gregorian_year_from_fixed(persian_epoch()) + 1
    y = persian_year <= 0 && persian_year - 1 || persian_year
    fixed_from_persian(y, 1, 1)
  end

  # === 16 The Bahai Calendar, DR4 269ff

  # === 16.1 Structure, DR4 269ff

  @doc """
  DR4 271 (16.1)
  """
  def ayyam_i_ha, do: 0

  @doc """
  Bahai Epoch.
  __... we just number the years, ..., and choose as epoch the traditional
  year of ascension of the first Yarlun King, Nyatri Tsenpo.__
  = `fixed-from-julian(ce(622), march, 19)`
  DR4 271 (16.2), bahai-epoch
  """
  def bahai_epoch, do: 673222

  # === 16.2 The Arithmetical Calendar, DR4 271ff

  @doc """
  Fixed date of Astronomical Bahai date.
  DR4 271 (16.3), fixed-from-bahai
  """
  def fixed_from_bahai({major, cycle, year, month, day}) do
    fixed_from_bahai(major, cycle, year, month, day)
  end

  def fixed_from_bahai(major, cycle, year, month, day) do
    g_year =
      361 * (major - 1) +
        19 * (cycle - 1) +
        year - 1 +
        gregorian_year_from_fixed(bahai_epoch())

    offset =
      cond do
        month == ayyam_i_ha() -> 342
        month == 19 -> gregorian_leap_year?(g_year + 1) && 347 || 346
        true -> 19 * (month - 1)
      end

    fixed_from_gregorian(g_year, 3, 20) + offset + day
  end

  @doc """
  Bahai date corresponding to `fixed` date.
  DR4 272 (16.4), bahai-from-fixed
  """
  def bahai_from_fixed(fixed) do
    g_year = gregorian_year_from_fixed(fixed)
    start = gregorian_year_from_fixed(bahai_epoch())
    march20 = fixed_from_gregorian(g_year, 3, 20)
    years = g_year - start - (fixed <= march20 && 1 || 0)
    major = floor(years / 361) + 1
    cycle = floor(mod(years, 361) / 19) + 1
    year = mod(years, 19) + 1
    days = fixed - fixed_from_bahai(major, cycle, year, 1, 1)

    month =
      cond do
        fixed >= fixed_from_bahai(major, cycle, year, 19, 1) ->
          19
        fixed >= fixed_from_bahai(major, cycle, year, ayyam_i_ha(), 1) ->
          ayyam_i_ha()
        true ->
          floor(days / 19) + 1
      end
    day = fixed + 1 - fixed_from_bahai(major, cycle, year, month, 1)

    {major, cycle, year, month, day}
  end

  # === 16.3 The Astronomical Calendar, DR4 273ff

  @doc """
  Bahai location.
  DR4 274 (16.5), bahai-location
  """
  def bahai_location, do: {35.696111, 51.423056, 0, hr(3.5)}

  @doc """
  DR4 274 (16.6), bahai-sunset
  """
  def bahai_sunset(fixed) do
    fixed
    |> sunset(bahai_location())
    |> universal_from_standard(bahai_location())
  end

  @doc """
  Fixed date of Astronomical Bahai New Year on or before `fixed` date.
  DR4 274 (16.7), astro-bahai-new-year-on-or-before
  """
  def astro_bahai_new_year_on_or_before(fixed) do
    approx = estimate_prior_solar_longitude(spring(), bahai_sunset(fixed))
    next(floor(approx) - 1,
      fn day -> solar_longitude(bahai_sunset(day)) <= spring() + 2 end)
  end

  @doc """
  Fixed date equivalent to Bahai date.
  DR4 275 (16.8), fixed-from-astro-bahai
  """
  def fixed_from_astro_bahai({major, cycle, year, month, day}) do
    fixed_from_astro_bahai(major, cycle, year, month, day)
  end

  def fixed_from_astro_bahai(major, cycle, year, month, day) do
    years = 361 * (major - 1) + 19 * (cycle - 1) + year
    tropical_plus = floor(mean_tropical_year() * (years + 0.5))
    tropical_minus = floor(mean_tropical_year() * (years - 0.5))
    cond do
      month == 19 -> astro_bahai_new_year_on_or_before(bahai_epoch() + tropical_plus) - 20 + day
      month == ayyam_i_ha() -> astro_bahai_new_year_on_or_before(bahai_epoch() + tropical_minus) + 341 + day
      true -> astro_bahai_new_year_on_or_before(bahai_epoch() + tropical_minus) + (month - 1) * 19 + day - 1
    end
  end

  @doc """
  Bahai date corresponding to `fixed` date.
  DR4 275 (16.9), astro-bahai-from-fixed
  """
  def astro_bahai_from_fixed(fixed) do
    new_year = astro_bahai_new_year_on_or_before(fixed)
    years = round((new_year - bahai_epoch()) / mean_tropical_year())
    major = floor(years / 361) + 1
    cycle = floor(mod(years, 361) / 19) + 1
    year = mod(years, 19) + 1
    days = fixed - new_year
    month =
      cond do
        fixed >= fixed_from_astro_bahai(major, cycle, year, 19, 1) -> 19
        fixed >= fixed_from_astro_bahai(major, cycle, year, ayyam_i_ha(), 1) -> ayyam_i_ha()
        true -> floor(days / 19) + 1
      end
    day = fixed + 1 - fixed_from_astro_bahai(major, cycle, year, month, 1)

    {major, cycle, year, month, day}
  end

  # === 16.4 Holidays and Observances, DR4 277f

  @doc """
  Bahai New Year.
  DR4 277 (16.10), bahai-new-year
  """
  def bahai_new_year(g_year) do
    fixed_from_gregorian(g_year, march(), 21)
  end

  @doc """
  Date of Bahai New Year in Gregorian year `g_year`.
  DR4 277 (16.11), naw-ruz
  """
  def naw_ruz(g_year) do
    year = gregorian_new_year(g_year + 1)
    astro_bahai_new_year_on_or_before(year)
  end

  @doc """
  DR4 277 (16.12), feast-of-ridvan
  """
  def feast_of_ridvan(g_year) do
    naw_ruz(g_year) + 31
  end

  @doc """
  Date of Bahai New Year in Gregorian year `g_year`.
  DR4 278 (16.13), birth-of-the-bab
  """
  def birth_of_the_bab(g_year) do
    ny = naw_ruz(g_year)
    set1 = bahai_sunset(ny)
    m1 = new_moon_at_or_after(set1)
    m8 = new_moon_at_or_after(m1 + 190)
    day = fixed_from_moment(m8)
    set8 = bahai_sunset(day)
    m8 < set8 && day + 1 || day + 2
  end

  # === 17 The French Revolutionary Calendar, DR4 281ff

  # === 17.1 The Original Form, DR4 283f

  @doc """
  Location of Paris Observatory. Longitude corresponds to difference
  of 9m 21s between Paris time zone and Universal Time.
  DR4 283 (17.1), paris
  """
  def paris, do: {angle(48, 50, 11), angle(2, 20, 15), 27, hr(1)}

  @doc """
  Universal time of true noon on `fixed` date in Paris.
  DR4 283 (17.2), midnight-in-paris
  """
  def midnight_in_paris(fixed), do: midnight(fixed + 1, paris())

  @doc """
  Fixed date of French Revolutionary New Year on or before `fixed` date.
  DR4 283 (17.3), french-new-year-on-or-before
  """
  def french_new_year_on_or_before(fixed) do
    approx = estimate_prior_solar_longitude(autumn(), midnight_in_paris(fixed))
    next(floor(approx) - 1,
      fn day -> autumn() <= solar_longitude(midnight_in_paris(day)) end)
  end

  @doc """
  French Epoch.
  DR4 283 (17.4), french-epoch
  """
  def french_epoch, do: 654415

  @doc """
  Fixed date of French Revolutionary date.
  DR4 284 (17.5), fixed-from-french
  """
  def fixed_from_french({year, month, day}) do
    fixed_from_french(year, month, day)
  end

  def fixed_from_french(year, month, day) do
    fixed_new = french_epoch() + 180 + mean_tropical_year() * (year - 1)
    new_year = french_new_year_on_or_before(floor(fixed_new))
    new_year - 1 + 30 * (month - 1) + day
  end

  @doc """
  French Revolutionary date of `fixed` date.
  DR4 284 (17.6), french-from-fixed
  """
  def french_from_fixed(fixed) do
    new_year = french_new_year_on_or_before(fixed)
    year = round((new_year - french_epoch()) / mean_tropical_year()) + 1
    month = floor((fixed - new_year) / 30) + 1
    day = mod(fixed - new_year, 30) + 1
    {year, month, day}
  end

  @doc """
  Returns true if the given year is a leap year.
  DR4 284 (17.7), french-leap-year?
  """
  def french_leap_year?(year) do
    fixed_from_french(year + 1, 1, 1) - fixed_from_french(year, 1, 1) > 365
  end

  # === 17.2 The Modified Arithmetical Form, DR4 284ff

  @doc """
  True if `year` is a leap year on the Arithmetic French Revolutionary calendar.
  DR4 285 (17.8), arithmetic-french-leap-year?
  """
  def arithmetic_french_leap_year?(year) do
    mod(year, 4) == 0 and
    mod(year, 400) not in [100, 200, 300] and
    mod(year, 4000) != 0
  end

  @doc """
  Fixed date of Arithmetic French Revolutionary `fixed` date.
  DR4 285 (17.9), fixed-from-arithmetic-french
  """
  def fixed_from_arithmetic_french({year, month, day}) do
    fixed_from_arithmetic_french(year, month, day)
  end

  def fixed_from_arithmetic_french(year, month, day) do
    french_epoch() - 1 +
      365 * (year - 1) +
      floor((year - 1) / 4) -
      floor((year - 1) / 100) +
      floor((year - 1) / 400) -
      floor((year - 1) / 4000) +
      30 * (month - 1) +
      day
  end

  @doc """
  Arithmetic French Revolutionary date corresponding to the `fixed` date.
  DR4 285 (17.10), arithmetic-french-from-fixed
  """
  def arithmetic_french_from_fixed(fixed) do
    approx = floor((fixed - french_epoch() + 2) * 4000 / 1460969) + 1
    year = fixed < fixed_from_arithmetic_french(approx, 1, 1) && approx - 1 || approx
    month = 1 + floor((fixed - fixed_from_arithmetic_french(year, 1, 1)) / 30)
    day = 1 + fixed - fixed_from_arithmetic_french(year, month, 1)
    {year, month, day}
  end

  # === 18 Astronomical Lunar Calendars, DR4 289ff

  # === 18.1 The Babylonian Calendar, DR4 289ff

  @doc """
  Moonlag.
  __
  The lag time is simply the difference between the times of the moon
  and the sun.
  __
  DR4 290 (18.1), moonlag
  """
  def moonlag(fixed, location) do
    sun = sunset(fixed, location)
    moon = moonset(fixed, location)
    cond do
      sun == bogus() -> bogus()
      moon == bogus() -> hr(24)
      true -> moon - sun
    end
  end

  @doc """
  Location of Babylon.
  DR4 290 (18.2), 409, babylon
  """
  # @babylon {32.4794, 44.4328, 26, hr(3.5)}
  @babylon {32.4794, 44.4328, 26, 0.145833}
  def babylon, do: @babylon

  @doc """
  Moonlag criterion for visibility of crescent moon on eve of `fixed` in Babylon.
  DR4 290 (18.3), babylonian-criterion
  """
  def babylonian_criterion(fixed) do
    set = sunset(fixed - 1, @babylon)
    tee = universal_from_standard(set, @babylon)
    phase = lunar_phase(tee)

    (new_moon() < phase) and
    (phase < first_quarter_moon()) and
    (new_moon_before(tee) <= (tee - hr(24))) and
    (moonlag(fixed - 1, @babylon) > mn(48))
  end

  @doc """
  Fixed date of start of Babylonian month on or before Babylonian `fixed`.
  Using lag of moonset criterion.
  DR4 290 (18.4), babylonian-new-month-on-or-before
  """
  def babylonian_new_month_on_or_before(fixed) do
    phase = lunar_phase_at_or_before(new_moon(), fixed)
    moon = fixed_from_moment(phase)
    age = (fixed - moon)
    tau = ((age <= 3 and not babylonian_criterion(fixed)) && moon - 30 || moon)
    next(tau, fn day -> babylonian_criterion(day) end)
  end

  @doc """
  Babylonian Epoch.
  Epoch is the fixed date of start of the Babylonian calendar
  (Seleucid era): April 3, 311 BCE (Julian).
  DR4 291 (18.5), babylonian-epoch
  """
  def babylonian_epoch, do: -113502

  @doc """
  Returns true if the given year is a leap year.
  DR4 291 (18.6), babylonian-leap-year?
  """
  def babylonian_leap_year?(year) do
    mod((7 * year + 13), 19) < 7
  end

  @doc """
  Fixed date of Babylonian date.
  DR4 291 (18.7), fixed-from-babylonian
  """
  def fixed_from_babylonian({year, month, leap, day}) do
    fixed_from_babylonian(year, month, leap, day)
  end

  def fixed_from_babylonian(year, month, leap, day) do
    month1 = (leap or (mod(year, 19) == 18 and month > 6)) && month || month - 1
    months = floor(((year - 1) * 235 + 13) / 19) + month1
    midmonth = babylonian_epoch() + round(mean_synodic_month() * months) + 15
    babylonian_new_month_on_or_before(midmonth) + day - 1
  end

  @doc """
  Babylonian date corresponding to `fixed` date.
  DR4 291 (18.8), babylonian-from-fixed
  """
  def babylonian_from_fixed(fixed) do
    crescent = babylonian_new_month_on_or_before(fixed)
    months = round((crescent - babylonian_epoch()) / mean_synodic_month())
    year = floor((19 * months + 5) / 235) + 1
    approx = babylonian_epoch() + round(floor(((year - 1) * 235 + 13) / 19) * mean_synodic_month())
    new_year = babylonian_new_month_on_or_before(approx + 15)
    month1 = round((crescent - new_year) / 29.5) + 1
    special = (mod(year, 19) == 18)
    leap = if special, do: month1 == 7, else: month1 == 13
    month = (leap or (special and month1 > 6)) && month1 - 1 || month1
    day = fixed - crescent + 1

    {year, month, leap, day}
  end

  #=== 18.2 Astronomical Easter, DR4 292f

  @doc """
  Date of (proposed) astronomical Easter in Gregorian year `g_year`.
  Return the Sunday following the Paschal moon.
  DR4 292 (18.9), astronomical-easter
  """
  def astronomical_easter(g_year) do
    equinox = season_in_gregorian(spring(), g_year)
    paschal_moon = floor(apparent_from_universal(
      lunar_phase_at_or_after(full_moon(), equinox), jerusalem()))
    kday_after(sunday(), paschal_moon)
  end

  # === 18.3 The Observational Islamic Calendar, DR4 293ff

  @doc """
  Take the Al-Azhar University, Cairo, a major Islamic religious center,
  as the location of the observation.
  DR4 293 (18.10), islamic-location
  """
  @islamic_location {30.1, 31.3, 200, 1/12} # DR4 410
  def islamic_location, do: @islamic_location

  @doc """
  Fixed date equivalent to Observational Islamic date `i_date`.
  DR4 293 (18.11), fixed-from-observational-islamic
  """
  def fixed_from_observational_islamic({year, month, day} = _i_date) do
    fixed_from_observational_islamic(year, month, day)
  end

  def fixed_from_observational_islamic(year, month, day) do
    days = ((year - 1) * 12 + month - 1/2) * mean_synodic_month()
    midmonth = islamic_epoch() + floor(days)
    phasis_on_or_before(midmonth, islamic_location()) + day - 1
  end

  @doc """
  Observational Islamic date `{year, month, day}` corresponding to `fixed` date.
  DR4 294 (18.12), observational-islamic-from-fixed
  """
  def observational_islamic_from_fixed(fixed) do
    crescent = phasis_on_or_before(fixed, islamic_location())
    elapsed_months = round((crescent - islamic_epoch()) / mean_synodic_month())
    year = floor(elapsed_months / 12) + 1
    month = mod(elapsed_months, 12) + 1
    day = fixed - crescent + 1
    {year, month, day}
  end

  @doc """
  Length of lunar month based on observability at `location`,
  which includes `fixed`.
  DR4 294 (18.13), month-length
  """
  def month_length(fixed, location) do
    moon = phasis_on_or_after(fixed + 1, location)
    prev = phasis_on_or_before(fixed, location)
    moon - prev
  end

  @doc """
  `fixed` in `location` is in a month that was forced to start early.
  DR4 294 (18.14), early-month?
  """
  def early_month?(fixed, location) do
    start = phasis_on_or_before(fixed, location)
    prev = start - 15

    fixed - start >= 30 or
    month_length(prev, location) > 30 or
    (month_length(prev, location) == 30 and early_month?(prev, location))
  end

  @doc """
  Fixed date equivalent to Observational Islamic `i_date`.
  Months are never longer than 30 days.
  DR4 295 (18.15), alt-fixed-from-observational-islamic
  """
  def alt_fixed_from_observational_islamic({year, month, day} = _i_date) do
    alt_fixed_from_observational_islamic(year, month, day)
  end

  def alt_fixed_from_observational_islamic(year, month, day) do
    days = ((year - 1) * 12 + month - 1/2) * mean_synodic_month()
    midmonth = islamic_epoch() + floor(days)
    moon = phasis_on_or_before(midmonth, islamic_location())
    fixed = moon + day - 1
    early_month?(midmonth, islamic_location()) && fixed - 1 || fixed
  end

  @doc """
  Observational Islamic date `{year, month, day}` corresponding to `fixed` date.
  Months are never longer than 30 days.
  DR4 295 (18.16), alt-observational-islamic-from-fixed
  """
  def alt_observational_islamic_from_fixed(fixed) do
    early = early_month?(fixed, islamic_location())
    long = early and month_length(fixed, islamic_location()) > 29
    date_prime = long && fixed + 1 || fixed
    moon = phasis_on_or_before(date_prime, islamic_location())
    elapsed_months = round((moon - islamic_epoch()) / mean_synodic_month())
    year = floor(elapsed_months / 12) + 1
    month = mod(elapsed_months, 12) + 1
    offset = (early and not long) && -2 || -1
    day = date_prime - moon - offset
    {year, month, day}
  end

  @doc """
  Saudi visibility criterion on eve of fixed `date` in Mecca.
  DR4 296 (18.17), saudi-criterion
  """
  def saudi_criterion(fixed) do
    location = mecca()
    set = sunset(fixed - 1, mecca())
    tee = universal_from_standard(set, location)
    phase = lunar_phase(tee)
    new_moon() < phase and
    phase < first_quarter_moon() and
    moonlag(fixed - 1, location) > 0
  end

  @doc """
  Closest fixed date on or before `fixed` when Saudi visibility criterion held.
  DR4 296 (18.18), saudi-new-month-on-or-before
  """
  def saudi_new_month_on_or_before(fixed) do
    phase = lunar_phase_at_or_before(new_moon(), fixed)
    moon = fixed_from_moment(phase)
    age = fixed - moon
    tau = ((age <= 3 and not saudi_criterion(fixed)) && (moon - 30) || moon)
    next(tau, fn d -> saudi_criterion(d) end)
  end

  @doc """
  Fixed date equivalent to Saudi Islamic date `i_date`.
  DR4 296 (18.19), fixed-from-saudi-islamic
  """
  def fixed_from_saudi_islamic({year, month, day} = _i_date) do
    fixed_from_saudi_islamic(year, month, day)
  end

  def fixed_from_saudi_islamic(year, month, day) do
    days = ((year - 1) * 12 + month - 1/2) * mean_synodic_month()
    midmonth = islamic_epoch() + floor(days)
    saudi_new_month_on_or_before(midmonth) + day - 1
  end

  @doc """
  Saudi Islamic date `{year, month, day}` corresponding to `fixed` date.
  DR4 296 (18.20), saudi-islamic-from-fixed
  """
  def saudi_islamic_from_fixed(fixed) do
    crescent = saudi_new_month_on_or_before(fixed)
    elapsed_months = round((crescent - islamic_epoch()) / mean_synodic_month())
    year = floor(elapsed_months / 12) + 1
    month = mod(elapsed_months, 12) + 1
    day = fixed - crescent + 1
    {year, month, day}
  end

  # === 18.4 The Classical Hebrew Calendar, DR4 297ff

  @doc """
  Take Haifa, a city at the western edge of Israel, as the location of the observation.
  DR4 297 (18.21), hebrew-location
  """
  # @hebrew_location {32.82, 35, 0, hr(2)} # DR4 410
  @hebrew_location {32.82, 35, 0, 1/12} # DR4 410
  def hebrew_location, do: @hebrew_location

  @doc """
  Fixed date of Observational (classical) Nisan 1 occurring in
  Gregorian year `g_year`.
  DR4 297 (18.22), observational-hebrew-first-of-nisan
  """
  def observational_hebrew_first_of_nisan(g_year) do
    equinox = season_in_gregorian(spring(), g_year)
    sunset_equinox = sunset(floor(equinox), @hebrew_location)
    set = universal_from_standard(sunset_equinox, @hebrew_location)
    days = equinox < set && 14 || 13
    phasis_on_or_after(floor(equinox) - days, @hebrew_location)
  end

  @doc """
  Observational Hebrew date `{year, month, day}` corresponding to `fixed` date.
  DR4 298 (18.23), observational-hebrew-from-fixed
  """
  def observational_hebrew_from_fixed(fixed) do
    crescent = phasis_on_or_before(fixed, @hebrew_location)
    g_year = gregorian_year_from_fixed(fixed)
    ny = observational_hebrew_first_of_nisan(g_year)
    new_year = fixed < ny && observational_hebrew_first_of_nisan(g_year - 1) || ny
    month = round((crescent - new_year) / 29.5) + 1
    {yy, _, _} = hebrew_from_fixed(new_year)
    year = yy + (month >= tishri() && 1 || 0)
    day = fixed - crescent + 1
    {year, month, day}
  end

  @doc """
  Fixed date equivalent to Observational Hebrew date `i_date`.
  DR4 298 (18.24), fixed-from-observational-hebrew
  """
  def fixed_from_observational_hebrew({year, month, day} = _h_date) do
    fixed_from_observational_hebrew(year, month, day)
  end

  def fixed_from_observational_hebrew(year, month, day) do
    year1 = month >= tishri() && year - 1 || year
    start = fixed_from_hebrew(year1, nisan(), 1)
    g_year = gregorian_from_fixed(start + 60)
    new_year = observational_hebrew_first_of_nisan(g_year)
    midmonth = new_year + round(29.5 * (month - 1)) + 15
    phasis_on_or_before(midmonth, @hebrew_location) + day - 1
  end

  @doc """
  Fixed date of Classical (observational) Passover Eve (Nisan 14) occurring
  in Gregorian year `g_year`.
  DR4 298 (18.25), classical-passover-eve
  """
  def classical_passover_eve(g_year) do
    observational_hebrew_first_of_nisan(g_year) + 13
  end

  @doc """
  Observational Hebrew date `{year, month, day}` corresponding to `fixed` date.
  Months are never longer than 30 days.
  DR4 299 (18.26), alt-observational-hebrew-from-fixed
  """
  def alt_observational_hebrew_from_fixed(fixed) do
    early = early_month?(fixed, @hebrew_location)
    long = early and month_length(fixed, @hebrew_location) > 29
    date_prime = long && fixed + 1 || fixed
    g_year = gregorian_year_from_fixed(date_prime)
    moon = phasis_on_or_before(date_prime, @hebrew_location)
    ny = observational_hebrew_first_of_nisan(g_year)
    new_year = date_prime < ny && observational_hebrew_first_of_nisan(g_year - 1) || ny
    month = round((moon - new_year) / 29.5) + 1
    {yy, _, _} = hebrew_from_fixed(new_year)
    year = yy + (month >= tishri() && 1 || 0)
    offset = (early and not long) && -2 || -1
    day = date_prime - moon - offset
    {year, month, day}
  end

  @doc """
  Fixed date equivalent to Observational Hebrew `i_date`.
  Months are never longer than 30 days.
  DR4 299 (18.27), alt-fixed-from-observational-hebrew
  """
  def alt_fixed_from_observational_hebrew({year, month, day} = _i_date) do
    alt_fixed_from_observational_hebrew(year, month, day)
  end

  def alt_fixed_from_observational_hebrew(year, month, day) do
    year1 = month >= tishri() && year - 1 || year
    start = fixed_from_hebrew(year1, nisan(), 1)
    g_year = gregorian_year_from_fixed(start + 60)
    new_year = observational_hebrew_first_of_nisan(g_year)
    midmonth = new_year + round(29.5 * (month - 1)) + 15
    moon = phasis_on_or_before(midmonth, @hebrew_location)
    fixed = moon + day - 1
    early_month?(midmonth, @hebrew_location) && fixed - 1 || fixed
  end

  # === 18.5 The Samaritan Calendar, DR4 300ff

  @doc """
  Location of Mt. Gerizim.
  DR4 300 (18.28), samaritan-location
  """
  def samaritan_location, do: {32.1994, 35.2728, 881, hr(2)}

  @doc """
  Universal time of true noon on `fixed` at Samaritan location.
  DR4 300 (18.29), samaritan-noon
  """
  def samaritan_noon(fixed) do
    midday(fixed, samaritan_location())
  end

  @doc """
  Fixed date of first new moon after UT moment `tee`. Modern calculation.
  DR4 300 (18.30), samaritan-new-moon-after
  """
  def samaritan_new_moon_after(tee) do
    new_moon = new_moon_at_or_after(tee)
    time = apparent_from_universal(new_moon, samaritan_location())
    ceil(time - hr(12))
  end

  @doc """
  Fixed_date of last new moon before UT moment `tee`. Modern calculation.
  DR4 300 (18.31), samaritan-new-moon-at-or-before
  """
  def samaritan_new_moon_at_or_before(tee) do
    time = tee |> new_moon_before |> apparent_from_universal(samaritan_location())
    ceil(time - hr(12))
  end

  @doc """
  Samaritan epoch.
  `fixed_from_julian(bce(1639), 3, 15)`
  DR4 301 (18.32), samaritan-epoch
  """
  def samaritan_epoch, do: -598573

  @doc """
  Fixed date of Samaritan New Year on or before `fixed` date.
  DR4 301 (18.33), samaritan-new-year-on-or-before
  """
  def samaritan_new_year_on_or_before(fixed) do
    g_year = gregorian_year_from_fixed(fixed)
    dates = [  # All possible March 11's
      julian_in_gregorian(3, 11, g_year - 1),
      julian_in_gregorian(3, 11, g_year),
      [fixed + 1]
    ]
    n = final(0, fn i -> samaritan_new_moon_after(samaritan_noon(hd(Enum.at(dates, i)))) <= fixed end)
    samaritan_new_moon_after(samaritan_noon(hd(Enum.at(dates, n))))
  end

  @doc """
  Fixed date of Samaritan date `s_date`.
  DR4 301 (18.34), fixed-from-samaritan
  """
  def fixed_from_samaritan({year, month, day} = _s_date) do
    fixed_from_samaritan(year, month, day)
  end

  def fixed_from_samaritan(year, month, day) do
    n0 = samaritan_epoch() + 50 + 365.25 * (year - ceil((month - 5) / 8))
    ny = samaritan_new_year_on_or_before(n0)
    n1 = ny +  29.5 * (month - 1) + 15
    nm = samaritan_new_moon_at_or_before(n1)
    nm + day - 1
  end

  @doc """
  Samaritan date corresponding to fixed `date`.
  DR4 302 (18.35), samaritan-from-fixed
  """
  def samaritan_from_fixed(fixed) do
    moon = fixed |> samaritan_noon |> samaritan_new_moon_at_or_before
    new_year = samaritan_new_year_on_or_before(moon)
    month = round((moon - new_year) / 29.5) + 1
    year = round ((new_year - samaritan_epoch()) / 365.25) + ceil((month - 5) / 8)
    day = fixed - moon + 1
    {year, month, day}
  end

  # === 19 The Chinese Calendar, DR4 305ff

  # === 19.1 Solar Terms, DR4 306ff

  @doc """
  Last Chinese major solar term (zhongqi) before `fixed` date.
  DR4 306 (19.1), current-major-solar-term
  """
  def current_major_solar_term(fixed) do
    s = solar_longitude(
      universal_from_standard(
        fixed, chinese_location(fixed)))
    amod(2 + floor(s / 30), 12)
  end

  @doc """
  Location of Beijing; time zone varies with `tee`.
  DR4 306 (19.2), chinese-location
  """
  def chinese_location(tee) do
    year = gregorian_year_from_fixed(floor(tee))
    latitude = angle(39, 55, 0)
    longitude = angle(116, 25, 0)
    altitude = 43.5
    hour = year < 1929 && hr(1397 / 180) || hr(8)
    {latitude, longitude, altitude, hour}
  end

  @doc """
  Moment (Beijing time) of the first time at or after `tee` (Beijing
  time) when the solar longitude   will be `lambda` degrees.
  DR4 308 (19.3), chinese-solar-longitude-on-or-after
  """
  def chinese_solar_longitude_on_or_after(lambda, tee) do
    sun = solar_longitude_after(
      lambda, universal_from_standard(
        tee, chinese_location(tee)))
    standard_from_universal(sun, chinese_location(sun))
  end

  @doc """
  Moment (in Beijing) of the first Chinese major solar term (zhongqi)
  on or after `fixed` date. The major terms begin when the sun's
  longitude is a multiple of 30 degrees.
  DR4 308 (19.4), major-solar-term-on-or-after
  """
  def major_solar_term_on_or_after(fixed) do
    s = solar_longitude(midnight_in_china(fixed))
    l = mod(30 * ceil(s / 30), 360)
    chinese_solar_longitude_on_or_after(l, fixed)
  end

  @doc """
  Last Chinese minor solar term (jieqi) before `fixed` date.
  DR4 308 (19.5), current-minor-solar-term
  """
  def current_minor_solar_term(fixed) do
    s = solar_longitude(
      universal_from_standard(
        fixed, chinese_location(fixed)))
    amod(3 + (floor((s - 15) / 30)), 12)
  end

  @doc """
  Moment (in Beijing) of the first Chinese minor solar term (jieqi)
  on or after `fixed` date.  The minor terms begin when the sun's
  longitude is an odd multiple of 15 degrees.
  DR4 308 (19.6), minor-solar-term-on-or-after
  """
  def minor_solar_term_on_or_after(fixed) do
    s = solar_longitude(midnight_in_china(fixed))
    l = mod(30 * ceil((s - 15) / 30) + 15, 360)
    chinese_solar_longitude_on_or_after(l, fixed)
  end

  @doc """
  Universal time of (clock) midnight at start of `fixed` date in China.
  DR4 309 (19.7), midnight-in-china
  """
  def midnight_in_china(fixed) do
    universal_from_standard(fixed, chinese_location(fixed))
  end

  @doc """
  Fixed date, in the Chinese zone, of winter solstice
  on or before `fixed` date.
  DR4 309 (19.8), chinese-winter-solstice-on-or-before
  """
  def chinese_winter_solstice_on_or_before(fixed) do
    approx = estimate_prior_solar_longitude(
      winter(), midnight_in_china(fixed + 1))
    next(floor(approx) - 1, fn day ->
      winter() < solar_longitude (midnight_in_china(day + 1))
    end)
  end

  # === 19.2 Months, DR4 309ff

  @doc """
  Fixed date (Beijing) of first new moon on or after `fixed` date.
  DR4 309 (19.9), chinese-new-moon-on-or-after
  """
  def chinese_new_moon_on_or_after(fixed) do
    tee = new_moon_at_or_after(midnight_in_china(fixed))
    floor(standard_from_universal(tee, chinese_location(tee)))
  end

  @doc """
  Fixed date (Beijing) of first new moon before `fixed` date.
  DR4 310 (19.10), chinese-new-moon-before
  """
  def chinese_new_moon_before(fixed) do
    tee = new_moon_before(midnight_in_china(fixed))
    floor(standard_from_universal(tee, chinese_location(tee)))
  end

  @doc """
  True if Chinese lunar month starting on `fixed` date
  has no major solar term.
  DR4 313 (19.11), chinese-no-major-solar-term?
  """
  def chinese_no_major_solar_term?(fixed) do
    current_major_solar_term(fixed) ==
      current_major_solar_term(chinese_new_moon_on_or_after(fixed + 1))
  end

  @doc """
  True if there is a Chinese leap month on or after lunar month starting
  on fixed day `m_prime` and at or before lunar month starting at fixed
  date `m`.
  DR4 313 (19.12), chinese-prior-leap-month?
  """
  def chinese_prior_leap_month?(m_prime, m) do
    m >=m_prime and
    (chinese_no_major_solar_term?(m) or
     chinese_prior_leap_month?(m_prime, (chinese_new_moon_before m)))
  end

  @doc """
  Fixed date of Chinese New Year in sui (period from solstice to solstice)
  containing `date`.
  DR4 315 (19.13), chinese-new-year-in-sui
  """
  def chinese_new_year_in_sui(fixed) do
    s1 = chinese_winter_solstice_on_or_before(fixed)     # prior solstice
    s2 = chinese_winter_solstice_on_or_before(s1 + 370)  # following solstice
    m12 = chinese_new_moon_on_or_after(s1 + 1)
    m13 = chinese_new_moon_on_or_after(m12 + 1)
    next_m11 = chinese_new_moon_before(s2 + 1)
    # Either m12 or m13 is a leap month if there are
    # 13 new moons (12 full lunar months) and
    # either m12 or m13 has no major solar term
    true_case =
      round((next_m11 - m12) / mean_synodic_month()) == 12 and
      (chinese_no_major_solar_term?(m12) or chinese_no_major_solar_term?(m13))
    true_case && chinese_new_moon_on_or_after(m13 + 1) || m13
  end

  @doc """
  Fixed date of Chinese New Year on or before `fixed` date.
  Got the New Year after--this happens if date is after the solstice
  but before the new year. So, go back half a year.
  DR4 316 (19.14), chinese-new-year-on-or-before
  """
  def chinese_new_year_on_or_before(fixed) do
    new_year = chinese_new_year_in_sui(fixed)
    fixed >= new_year && new_year || chinese_new_year_in_sui(fixed - 180)
  end

  # === 19.3 Conversion to and from Fixed Dates, DR4 316ff

  @doc """
  Chinese Epoch.
  = March 8, 2637 BCE (Julian)
  = February 15, -2636 (Gregorian)
  DR4 316 (19.15), chinese_epoch
  """
  def chinese_epoch, do: -963099

  @doc """
  Chinese date (cycle year month leap day) of `fixed` date.
  ordinal position of month in year minus 1 during or after a leap month
  DR4 317 (19.16), chinese-from-fixed
  """
  def chinese_from_fixed(fixed) do
    s1 = chinese_winter_solstice_on_or_before(fixed)     # prior solstice
    s2 = chinese_winter_solstice_on_or_before(s1 + 370)  # following solstice
    m12 = chinese_new_moon_on_or_after(s1 + 1)
    next_m11 = chinese_new_moon_before(s2 + 1)
    m = chinese_new_moon_before(fixed + 1)

    leap_year = round((next_m11 - m12) / mean_synodic_month()) == 12

    moff = (leap_year and chinese_prior_leap_month?(m12, m)) && 1 || 0
    mm = round((m - m12) / mean_synodic_month()) - moff
    month = amod(mm, 12)

    leap_month =
      leap_year and
      chinese_no_major_solar_term?(m) and
      not chinese_prior_leap_month?(m12, chinese_new_moon_before(m))
    elapsed_years = floor(1.5 - (month / 12) + (fixed - chinese_epoch()) / mean_tropical_year())
    cycle = floor((elapsed_years - 1) / 60) + 1
    year = amod(elapsed_years, 60)
    day = fixed - m + 1
    {cycle, year, month, leap_month, day}
  end

  @doc """
  Fixed date of Chinese date `c_date`.
  otherwise, there was a prior leap month that
  year, so we want the next month
  DR4 318 (19.17), fixed-from-chinese
  """
  def fixed_from_chinese({cycle, year, month, leap, day} = _c_year) do
    fixed_from_chinese(cycle, year, month, leap, day)
  end

  def fixed_from_chinese(cycle, year, month, leap, day) do
    mid_year = floor(chinese_epoch() + ((cycle - 1) * 60 + year - 1 + 0.5) * mean_tropical_year())

    new_year = chinese_new_year_on_or_before(mid_year)
    p = chinese_new_moon_on_or_after(new_year + ((month - 1) * 29))

    {_cycle, _year, dmonth, dleap, _day} = chinese_from_fixed(p)

    prior_new_moon = (month == dmonth and leap == dleap) && p || chinese_new_moon_on_or_after(p + 1)
    prior_new_moon + day - 1
  end

  # === 19.4 Sexagesimal Cycles of Names, DR4 318ff

  @doc """
  The `n`-th name of the Chinese sexagesimal cycle.
  DR4 319 (19.18), chinese-sexagesimal-name
  """
  def chinese_sexagesimal_name(n), do: {amod(n, 10), amod(n, 12)}

  @doc """
  Number of names from Chinese name `c_name1` to the
  next occurrence of Chinese name `c_name2`.
  DR4 319 (19.19), chinese-name-difference
  """
  def chinese_name_difference({stem1, branch1} = _c_name1, {stem2, branch2} = _c_name2) do
    stem_difference = stem2 - stem1
    branch_difference = branch2 - branch1
    amod(stem_difference + 25 * (branch_difference - stem_difference), 60)
  end

  @doc """
  Sexagesimal name for Chinese `year` of any cycle.
  DR4 320 (19.20), chinese-year-name
  """
  def chinese_year_name(year), do: chinese_sexagesimal_name(year)

  @doc """
  Elapsed months at start of Chinese sexagesimal month cycle.
  DR4 320 (19.21), chinese-month-name-epoch
  """
  def chinese_month_name_epoch, do: 57

  @doc """
  Sexagesimal name for month `month` of Chinese year `year`.
  DR4 320 (19.22), chinese-month-name
  """
  def chinese_month_name(month, year) do
    elapsed_months = 12 * (year - 1) + month - 1
    chinese_sexagesimal_name(elapsed_months - chinese_month_name_epoch())
  end

  @doc """
  RD date of a start of Chinese sexagesimal day cycle.
  DR4 320 (19.23), chinese-day-name-epoch
  """
  def chinese_day_name_epoch, do: 45

  @doc """
  Chinese sexagesimal name for `fixed` date.
  DR4 320 (19.24), chinese-day-name
  """
  def chinese_day_name(fixed), do: chinese_sexagesimal_name(fixed - chinese_day_name_epoch())

  @doc """
  Fixed date of latest date on or before `fixed` date
  that has Chinese `name`.
  DR4 320 (19.25), chinese-day-name-on-or-before
  """
  def chinese_day_name_on_or_before({stem, _} = name, fixed) do
    mod3(chinese_name_difference(stem, name), fixed, fixed - 60)
  end

  # === 19.5 Common Misconceptions, DR4 321f

  # (no code)

  # === 19.6 Holidays, DR4 322ff

  @doc """
  Fixed date of Chinese New Year in Gregorian year `g_year`.
  DR4 322 (19.26), chinese-new-year
  """
  def chinese_new_year(g_year) do
    {g_year, july(), 1}
    |> fixed_from_gregorian
    |> chinese_new_year_on_or_before
  end

  @doc """
  Fixed date of the Dragon Festival occurring in
  Gregorian year `g_year`.
  DR4 324 (19.27), dragon-festival
  """
  def dragon_festival(g_year) do
    elapsed_years = 1 + g_year - gregorian_year_from_fixed(chinese_epoch())
    cycle = floor((elapsed_years - 1) / 60) + 1
    year = amod(elapsed_years, 60)
    fixed_from_chinese(cycle, year, 5, false, 5)
  end

  @doc """
  Fixed date of Qingming occurring in Gregorian year `g_year`.
  DR4 324 (19.28), qing-ming
  """
  def qing_ming(g_year) do
    {g_year, march(), 30}
    |> fixed_from_gregorian
    |> minor_solar_term_on_or_after
    |> floor
  end

  # === 19.7 Chinese Age, DR4 324f

  @doc """
  Age at `fixed` date, given Chinese `birthdate`, according to the
  Chinese custom.  Returns bogus if `fixed` is before `birthdate`.
  DR4 325 (19.29), chinese-age
  """
  def chinese_age({bcycle, byear, _, _, _} = birthdate, fixed) do
    {cycle, year, _, _, _} = chinese_from_fixed(fixed)
    fixed >= fixed_from_chinese(birthdate) && (60 * (cycle - bcycle) + year - byear + 1) || bogus()
  end

  # === 19.8 Chinese Marriage Auguries, DR4 325f

  @doc """
  Lichun occurs twice (double_happiness).
  DR4 325 (19.30), double-bright
  """
  def double_bright, do: 3

  @doc """
  Lichun occurs once at the start.
  DR4 325 (19.31), bright
  """
  def bright, do: 2

  @doc """
  Lichun occurs once at the end.
  DR4 325 (19.32), blind
  """
  def blind, do: 1

  @doc """
  Lichun does not occur (double_blind year).
  DR4 325 (19.33), widow
  """
  def widow, do: 0

  @doc """
  The marriage augury type of Chinese `year` in `cycle`.
  DR4 325 (19.34), chinese-year-marriage-augury
  """
  def chinese_year_marriage_augury(cycle, year) do
    new_year = fixed_from_chinese(cycle, year, 1, false, 1)
    c = year == 60 && cycle + 1 || cycle
    y = year == 60 && 1 || year + 1
    next_new_year = fixed_from_chinese(c, y, 1, false, 1)
    first_minor_term = current_minor_solar_term(new_year)
    next_first_minor_term = current_minor_solar_term(next_new_year)

    cond do
      first_minor_term == 1 and next_first_minor_term == 12 -> widow()
      first_minor_term == 1 and next_first_minor_term != 12 -> blind()
      first_minor_term != 1 and next_first_minor_term == 12 -> bright()
      true -> double_bright()
    end
  end

  # === 19.9 The Japanese Calendar, DR4 326f

  @doc """
  Location for Japanese calendar; varies with `tee`.
  Tokyo (139 deg 46 min east) local time
  DR4 326 (19.35), japanese-location
  """
  def japanese_location(tee) do
    year = gregorian_year_from_fixed(floor(tee))
    if year < 1888,
       do:   {35.7, angle(139, 46, 0), 24, hr(9 + 143 / 450)},
       else: {35, 135, 0, hr(9)}
  end

  # === 19.10 The Korean Calendar, DR4 327ff

  @doc """
  Location for Korean calendar; varies with `tee`.
  Seoul city hall at a varying time zone.
  local mean time for longitude 126 deg 58 min
  DR4 328 (19.36), korean-location
  """
  def korean_location(tee) do
    z =
      cond do
        tee < fixed_from_gregorian(1908, 4, 1) -> 3809 / 450
        tee < fixed_from_gregorian(1912, 1, 1) -> 8.5
        tee < fixed_from_gregorian(1954, 3, 21) -> 9
        tee < fixed_from_gregorian(1961, 8, 10) -> 8.5
        true -> 9
      end

    {angle(37, 34, 0), angle(126, 58, 0), 0, hr(z)}
  end

  @doc """
  Equivalent Korean year to Chinese `cycle` and `year`.
  DR4 328 (19.37), korean-year
  """
  def korean_year(cycle, year) do
    60 * cycle + year - 364
  end

  # === 19.11 The Vietnamese Calendar, DR4 329f

  @doc """
  Location for Vietnamese calendar is Hanoi; varies with `tee`.
  Time zone has changed over the years.
  DR4 329 (19.38), vietnamese-location
  """
  def vietnamese_location(tee) do
    latitude = angle(21, 2, 0)
    longitude = angle(105, 51, 0)
    altitude = 12
    hour = tee < gregorian_new_year(1968) && 8 || 7
    {latitude, longitude, altitude, hr(hour)}
  end

  # === 20 The Modern Hindu Calendars, DR4 335ff

  @doc """
  Mean length of Hindu sidereal year.
  DR4 336 (20.1), hindu-sidereal-year
  """
  def hindu_sidereal_year, do: 365 + 279457 / 1080000

  @doc """
  Mean length of Hindu sidereal month.
  DR4 336 (20.2), hindu-sidereal-month
  """
  def hindu_sidereal_month, do: 27 + 4644439 / 14438334

  @doc """
  Mean time from new moon to new moon.
  DR4 336 (20.3), hindu-synodic-month
  """
  def hindu_synodic_month, do: 29 + 7087771 / 13358334

  # === 20.1 Hindu Astronomy, DR4 341ff

  @doc """
  This simulates the Hindu sine table.
  `entry` is an angle given as a multiplier of 225'.
  DR4 342 (20.4), hindu-sine-table
  """
  def hindu_sine_table(entry) do
    exact = 3438 * sin_degrees(entry * (225.0 / 60))
    error = 0.215 * sign(exact) * sign(abs(exact) - 1716)
    round(exact + error) / 3438.0
  end

  @doc """
  Linear interpolation for `theta` in Hindu table.
  DR4 342 (20.5), hindu-sine
  """
  def hindu_sine(theta) do
    entry = theta / (225.0 / 60)
    fraction = mod(entry, 1)
    fraction * hindu_sine_table(ceil(entry)) +
      (1 - fraction) * hindu_sine_table(floor(entry))
  end

  @doc """
  Inverse of Hindu sine function of `amp`.
  DR4 343 (20.6), hindu-arcsin
  """
  def hindu_arcsin(amp) do
    pos = next(0, fn k -> amp <= hindu_sine_table(k) end)
    below = hindu_sine_table(pos - 1)
    (amp < 0) && -arcsin_degrees(-amp) || ((pos - 1) + (amp - below) / (hindu_sine_table(pos) - below)) * (225.0 / 60)
  end

  @doc """
  Position in degrees at moment `tee` in uniform circular orbit
  of `period` days.
  DR4 344 (20.7), hindu-mean-position
  """
  def hindu_mean_position(tee, period) do
    360 * mod((tee - hindu_creation()) / period, 1)
  end

  @doc """
  Fixed date of Hindu creation.
  DR4 344 (20.8), hindu-creation
  """
  def hindu_creation do
    hindu_epoch() - 1955880000 * hindu_sidereal_year()
  end

  @doc """
  Time from aphelion to aphelion.
  DR4 344 (20.9), hindu-anomalistic-year
  """
  def hindu_anomalistic_year, do: 1577917828000 / (4320000000 - 387)

  @doc """
  Time from apogee to apogee, with bija correction.
  DR4 345 (20.10), hindu-anomalistic-month
  """
  def hindu_anomalistic_month, do: 1577917828 / (57753336 - 488199)

  @doc """
  Longitudinal position at moment `tee`.
  `period` is period of mean motion in days.
  `size` is ratio of radii of epicycle and deferent.
  `anomalistic` is the period of retrograde revolution about epicycle.
  `change` is maximum decrease in epicycle size.
  DR4 345 (20.11), hindu-true-position
  """
  def hindu_true_position(tee, period, size, anomalistic, change) do
    lambda = hindu_mean_position(tee, period)
    offset = hindu_sine(hindu_mean_position(tee, anomalistic))
    contraction = abs(offset) * change * size
    equation = hindu_arcsin(offset * (size - contraction))
    mod(lambda - equation, 360)
  end

  @doc """
  Solar longitude at moment `tee`.
  DR4 345 (20.12), hindu-solar-longitude
  """
  def hindu_solar_longitude(tee) do
    hindu_true_position(tee, hindu_sidereal_year(), 14 / 360, hindu_anomalistic_year(), 1 / 42)
  end

  @doc """
  Zodiacal sign of the sun, as integer in range 1..12, at moment `tee`.
  DR4 345 (20.13), hindu-zodiac
  """
  def hindu_zodiac(tee) do
    floor(hindu_solar_longitude(tee) / 30) + 1
  end

  @doc """
  Lunar longitude at moment `tee`.
  DR4 346 (20.14), hindu-lunar-longitude
  """
  def hindu_lunar_longitude(tee) do
    hindu_true_position(tee, hindu_sidereal_month(), 32 / 360, hindu_anomalistic_month(), 1 / 96)
  end

  @doc """
  Longitudinal distance between the sun and moon at moment `tee`.
  DR4 346 (20.15), hindu-lunar-phase
  """
  def hindu_lunar_phase(tee) do
    mod(hindu_lunar_longitude(tee) - hindu_solar_longitude(tee), 360)
  end

  @doc """
  Phase of moon (tithi) at moment `tee`, as an integer in the range 1..30.
  DR4 346 (20.16), hindu-lunar-day-from-moment
  """
  def hindu_lunar_day_from_moment(tee) do
    floor(hindu_lunar_phase(tee) / 12) + 1
  end

  @doc """
  Approximate moment of last new moon preceding moment `tee`,
  close enough to determine zodiacal sign.
  DR4 346 (20.17), hindu-new-moon-before
  """
  def hindu_new_moon_before(tee) do
    epsilon = :math.pow(2, -1000) # Safety margin
    tau = tee - hindu_lunar_phase(tee) * hindu_synodic_month() / 360
    binary_search( # search for phase start
      tau - 1,
      min(tee, tau + 1),
      fn l, u -> hindu_zodiac(l) == hindu_zodiac(u) or u - l < epsilon end,
      fn x -> hindu_lunar_phase(x) < 180 end)
  end

  # === 20.2 Calendars, DR4 347ff

  @doc """
  Determine solar year at given moment `tee`.
  DR4 347 (20.18), hindu-calendar-year
  """
  def hindu_calendar_year(tee) do
    a1 = (tee - hindu_epoch()) / hindu_sidereal_year()
    a2 = hindu_solar_longitude(tee) / 360
    round(a1 - a2)
  end

  @doc """
  Years from Kali Yuga until Saka era.
  DR4 347 (20.19), hindu-solar-era
  """
  def hindu_solar_era, do: 3179

  @doc """
  Hindu (Orissa) solar date equivalent to `fixed` date.
  DR4 347 (20.20), hindu-solar-from-fixed
  """
  def hindu_solar_from_fixed(fixed) do
    critical = hindu_sunrise(fixed + 1)
    month = hindu_zodiac(critical)
    year = hindu_calendar_year(critical) - hindu_solar_era()
    approx = fixed - 3 - mod(floor(hindu_solar_longitude(critical)), 30)
    start = next(approx,
      fn i -> hindu_zodiac(hindu_sunrise(i + 1)) == month end)
    day = fixed - start + 1
    {year, month, day}
  end

  @doc """
  Fixed date corresponding to Hindu solar date `s_date`
  (Saka era; Orissa rule.)
  Search forward to correct month
  DR4 348 (20.21), fixed-from-hindu-solar
  """
  def fixed_from_hindu_solar({year, month, day}) do
    fixed_from_hindu_solar(year, month, day)
  end

  def fixed_from_hindu_solar(year, month, day) do
    s1 = year + hindu_solar_era() + (month - 1) / 12
    start = floor(s1 * hindu_sidereal_year()) + hindu_epoch()
    d1 = next(start - 3, fn d -> hindu_zodiac(hindu_sunrise(d + 1)) == month end)
    day - 1 + d1
  end

  @doc """
  Years from Kali Yuga until Vikrama era.
  DR4 349 (20.22), hindu-lunar-era
  """
  def hindu_lunar_era, do: 3044

  @doc """
  Hindu lunar date, new_moon scheme, equivalent to `fixed` date.
  DR4 349 (20.23), hindu-lunar-from-fixed
  """
  def hindu_lunar_from_fixed(fixed) do
    critical = hindu_sunrise(fixed)
    day = hindu_lunar_day_from_moment(critical) # day of month.
    leap_day = day == hindu_lunar_day_from_moment(hindu_sunrise(fixed - 1))
    last_new_moon = hindu_new_moon_before(critical)
    next_new_moon = hindu_new_moon_before(floor(last_new_moon) + 35)
    solar_month = hindu_zodiac(last_new_moon)
    leap_month = solar_month == hindu_zodiac(next_new_moon)
    month = amod(solar_month + 1, 12)
    fixed1 = month <= 2 && fixed + 180 || fixed
    year = hindu_calendar_year(fixed1) - hindu_lunar_era()
    {year, month, leap_month, day, leap_day}
  end

  @doc """
  Fixed date corresponding to Hindu lunar date `l_date`.
  DR4 350 (20.24), fixed-from-hindu-lunar
  """
  def fixed_from_hindu_lunar({year, month, leap_month, day, leap_day}) do
    fixed_from_hindu_lunar(year, month, leap_month, day, leap_day)
  end

  def fixed_from_hindu_lunar(year, month, leap_month, day, leap_day) do
    m12 = (month - 1) / 12
    approx =
      hindu_epoch() +
        (hindu_sidereal_year() *
           (year + hindu_lunar_era() + m12))

    s = floor(approx - (hindu_sidereal_year() *
                          (mod3(hindu_solar_longitude(approx) / 360 - m12, -1/2, 1/2))))

    {_, mid_month, mid_leap_month, _, _} = hindu_lunar_from_fixed(s - 15)
    k = hindu_lunar_day_from_moment(s + hr(6))
    offset =
      cond do
        3 < k and k < 27 -> k
        mid_month != month -> mod3(k, -15, 15)
        mid_leap_month and not leap_month -> mod3(k, -15, 15)
        true -> mod3(k, 15, 45)
      end
    est = s + day - offset
    tau = est - mod3(hindu_lunar_day_from_moment(est + hr(6)) - day, -15, 15)
    fixed = next(tau - 1, fn d ->
      hindu_lunar_day_from_moment(hindu_sunrise(d)) in [day, mod3(day + 1, 1, 30)]
    end)
    leap_day && (fixed + 1) || fixed
  end

  # === 20.3 Sunrise, DR4 351ff

  @doc """
  DR4 351 (20.25), ujjain
  """
  def ujjain do
    latitude = angle(23, 9, 0)
    longitude = angle(75, 46, 6)
    altitude = 0
    time = hr(5 + 461 / 9000)
    {latitude, longitude, altitude, time}
  end

  @doc """
  DR4 351 (20.26), hindu-location
  """
  def hindu_location, do: ujjain()

  @doc """
  Difference between right and oblique ascension of sun on `fixed`
  at `location`.
  DR4 352 (20.27), hindu-ascensional-difference
  """
  def hindu_ascensional_difference(fixed, location) do
    sin_delta = (1397 / 3438) * hindu_sine(hindu_tropical_longitude(fixed))
    phi = latitude(location)
    diurnal_radius = hindu_sine(90 + hindu_arcsin(sin_delta))
    tan_phi = hindu_sine(phi) / hindu_sine(90 + phi)
    earth_sine = sin_delta * tan_phi
    hindu_arcsin(-(earth_sine / diurnal_radius))
  end

  @doc """
  Hindu tropical longitude on fixed `date`.atest
  Assumes precession with maximum of 27 degrees
  and period of 7200 sidereal years
  (= 1577917828/600 days).
  DR4 352 (20.28), hindu-tropical-longitude
  """
  def hindu_tropical_longitude(fixed) do
    days = fixed - hindu_epoch()
    precession = 27 - abs(108 * mod3((600 / 1577917828) * days - 0.25, -0.5, 0.5))
    mod(hindu_solar_longitude(fixed) - precession, 360)
  end

  @doc """
  Difference between solar and sidereal day on `fixed`.
  DR4 352 (20.29), hindu-solar-sidereal-difference
  """
  def hindu_solar_sidereal_difference(fixed) do
    hindu_daily_motion(fixed) * hindu_rising_sign(fixed)
  end

  @doc """
  Sidereal daily motion of sun on `fixed`.
  DR4 353 (20.30), hindu-daily-motion
  """
  def hindu_daily_motion(fixed) do
    mean_motion = 360 / hindu_sidereal_year()
    anomaly = hindu_mean_position(fixed, hindu_anomalistic_year())
    epicycle = 14 / 360 - abs(hindu_sine(anomaly)) / 1080
    entry = floor(anomaly / angle(0, 225, 0))
    sine_table_step = hindu_sine_table(entry + 1) - hindu_sine_table(entry)
    factor = -((3438 / 225) * sine_table_step * epicycle)
    mean_motion * (factor + 1)
  end

  @doc """
  Tabulated speed of rising of current zodiacal sign on `fixed`.
  DR4 353 (20.31), hindu-rising-sign
  """
  def hindu_rising_sign(fixed) do
    i = floor(hindu_tropical_longitude(fixed) / 30)
    val = [1670/1800, 1795/1800, 1935/1800, 1935/1800, 1795/1800, 1670/1800]
    Enum.at(val, mod(i, 6))
  end

  @doc """
  Time from true to mean midnight of `fixed`.
  (This is a gross approximation to the correct value.)
  Arcsin is not needed since small
  DR4 353 (20.32), hindu-equation-of-time
  """
  def hindu_equation_of_time(fixed) do
    offset = hindu_sine(hindu_mean_position(fixed, hindu_anomalistic_year()))
    equation_sun =
      offset *
        angle(57, 18, 0) *
        ((14 / 360) - (abs(offset) / 1080))

    (hindu_daily_motion(fixed) / 360) * (equation_sun / 360) * hindu_sidereal_year()
  end

  @doc """
  Sunrise at location on `fixed`.
  DR4 354 (20.33), hindu-sunrise
  """
  def hindu_sunrise(fixed) do
    fixed + hr(6) +
      ((longitude(ujjain()) - longitude(hindu_location())) / 360) -
      hindu_equation_of_time(fixed) +
      ((1577917828 / 1582237828 / 360) *
         (hindu_ascensional_difference(fixed, hindu_location()) +
            (1 / 4 * hindu_solar_sidereal_difference(fixed))))
  end

  # === 20.4 Alternatives, DR4 354ff

  @doc """
  Sunset at hindu_location on `date`.
  DR4 354 (20.34), hindu-sunset
  """
  def hindu_sunset(fixed) do
    fixed + hr(18) +
      (longitude(ujjain()) - longitude(hindu_location())) / 360 -
      hindu_equation_of_time(fixed) +
      (1577917828 / 1582237828 / 360) *
        (-hindu_ascensional_difference(fixed, hindu_location()) +
           hindu_solar_sidereal_difference(fixed) * 3 / 4)
  end

  @doc """
  Hindu local time of temporal moment `tee`.
  DR4 355 (20.35), hindu-standard-from-sundial
  """
  def hindu_standard_from_sundial(tee) do
    fixed = fixed_from_moment(tee)
    time = time_from_moment(tee)
    q = floor(4 * time)
    a =
      cond do
        q == 0 -> hindu_sunset(fixed - 1)
        q == 3 -> hindu_sunset(fixed)
        true -> hindu_sunrise(fixed)
      end
    b =
      cond do
        q == 0 -> hindu_sunrise(fixed)
        q == 3 -> hindu_sunrise(fixed + 1)
        true -> hindu_sunset(fixed)
      end
    c =
      cond do
        q == 3 -> hr(18)
        q == 0 -> hr(-6)
        true -> hr(6)
      end
    a + 2 * (b - a) * (time - c)
  end

  @doc """
  Hindu lunar date, full_moon scheme, equivalent to `fixed` date.
  DR4 356 (20.36), hindu-fullmoon-from-fixed
  """
  def hindu_fullmoon_from_fixed(fixed) do
    {year, month, leap_month, day, leap_day} = hindu_lunar_from_fixed(fixed)
    m = if day >= 16 do
      {_, mm, _, _, _} = hindu_lunar_from_fixed(fixed + 20)
      mm
    else
      month
    end
    {year, m, leap_month, day, leap_day}
  end

  @doc """
  Fixed date equivalent to Hindu lunar `l_date` in full_moon scheme.
  DR4 356 (20.37), fixed-from-hindu-fullmoon
  """
  def fixed_from_hindu_fullmoon({year, month, leap_month, day, leap_day} = _l_date) do
    m =
      cond do
        leap_month or day <= 15 -> month
        hindu_expunged?(year, amod(month - 1, 12)) -> amod(month - 2, 12)
        true -> amod(month - 1, 12)
      end
    fixed_from_hindu_lunar(year, m, leap_month, day, leap_day)
  end

  @doc """
  True of Hindu lunar month `l_month` in `l_year` is expunged.
  DR4 356 (20.38), hindu-expunged?
  """
  def hindu_expunged?(l_year, l_month) do
    fixed = fixed_from_hindu_lunar(l_year, l_month, false, 15, false)
    {_, month, _, _, _} = hindu_lunar_from_fixed(fixed)
    l_month != month
  end

  @doc """
  Astronomical sunrise at Hindu location on `date`, per Lahiri,
  rounded to nearest minute, as a rational number.
  DR4 357 (20.39), alt-hindu-sunrise
  """
  def alt_hindu_sunrise(fixed) do
    rise = dawn(fixed, hindu_location(), angle(0, 47, 0))
    (1 / 24) * (1 / 60) * round(rise * 24 * 60)
  end

  # === 20.5 Astronomical Versions, DR4 358ff

  @doc """
  Difference between tropical and sidereal solar longitude.
  DR4 359 (20.40), ayanamsha
  """
  def ayanamsha(tee) do
    hindu_solar_longitude(tee) - sidereal_solar_longitude(tee)
  end

  @doc """
  ```
  precession(universal_from_local(
    mesha_samkranti(ce(285)),hindu_location()))
  ```
  precalculated: 336.13605101930455
  DR4 359 (20.41), sidereal-start
  """
  def sidereal_start, do: 336.13605101930455

  @doc """
  Geometrical sunset at Hindu location on `fixed`.
  DR4 360 (20.42), astro-hindu-sunset
  """
  def astro_hindu_sunset(fixed) do
    dusk(fixed, hindu_location(), 0)
  end

  @doc """
  Sidereal zodiacal sign of the sun, as integer in range 1..12, at moment `tee`.
  DR4 360 (20.43), sidereal-zodiac
  """
  def sidereal_zodiac(tee) do
    floor(sidereal_solar_longitude(tee) / 30) + 1
  end

  @doc """
  Astronomical Hindu solar year KY at given moment `tee`.
  DR4 360 (20.44), astro-hindu-calendar-year
  """
  def astro_hindu_calendar_year(tee) do
    round(
      ((tee - hindu_epoch()) / mean_sidereal_year()) -
        (sidereal_solar_longitude(tee) / 360))
  end

  @doc """
  Astronomical Hindu (Tamil) solar date equivalent to `fixed` date.
  DR4 360 (20.45), astro-hindu-solar-from-fixed
  """
  def astro_hindu_solar_from_fixed(fixed) do
    critical = astro_hindu_sunset(fixed)
    month = sidereal_zodiac(critical)
    year = astro_hindu_calendar_year(critical) - hindu_solar_era()
    approx = fixed - 3 - mod(floor(sidereal_solar_longitude(critical)), 30)
    start = next(approx, fn i -> sidereal_zodiac(astro_hindu_sunset(i)) == month end)
    day = fixed - start + 1
    {year, month, day}
  end

  @doc """
  Fixed date corresponding to Astronomical Hindu solar date
  (Tamil rule; Saka era).
  DR4 360 (20.46), fixed-from-astro-hindu-solar
  """
  def fixed_from_astro_hindu_solar({year, month, day}) do
    fixed_from_astro_hindu_solar(year, month, day)
  end

  def fixed_from_astro_hindu_solar(year, month, day) do
    approx = hindu_epoch() - 3 +
      floor((year + hindu_solar_era() + ((month - 1) / 12)) *
        mean_sidereal_year())
    start = next(approx, fn i -> sidereal_zodiac(astro_hindu_sunset(i)) == month end)
    start + day - 1
  end

  @doc """
  Phase of moon (tithi) at moment `tee`, as an integer in the range 1..30.
  DR4 361 (20.47), astro-lunar-day-from-moment
  """
  def astro_lunar_day_from_moment(tee) do
    floor(lunar_phase(tee) / 12) + 1
  end

  @doc """
  Astronomical Hindu lunar date equivalent to `fixed` date.
  DR4 361 (20.48), astro-hindu-lunar-from-fixed
  """
  def astro_hindu_lunar_from_fixed(fixed) do
    critical = alt_hindu_sunrise(fixed)
    day = astro_lunar_day_from_moment(critical)
    leap_day = day == astro_lunar_day_from_moment(alt_hindu_sunrise(fixed - 1))
    last_new_moon = new_moon_before(critical)
    next_new_moon = new_moon_at_or_after(critical)
    solar_month = sidereal_zodiac(last_new_moon)
    leap_month = solar_month == sidereal_zodiac(next_new_moon)
    month = amod(solar_month + 1, 12)
    yy = (month <= 2 && fixed + 180) || fixed
    year = astro_hindu_calendar_year(yy) - hindu_lunar_era()
    {year, month, leap_month, day, leap_day}
  end

  @doc """
  Fixed date corresponding to Hindu lunar date `l_date`.
  DR4 361 (20.49), fixed-from-astro-hindu-lunar
  """
  def fixed_from_astro_hindu_lunar({year, month, leap_month, day, leap_day}) do
    fixed_from_astro_hindu_lunar(year, month, leap_month, day, leap_day)
  end

  def fixed_from_astro_hindu_lunar(year, month, leap_month, day, leap_day) do
    approx =
      hindu_epoch() +
        mean_sidereal_year() *
          (year + hindu_lunar_era() + ((month - 1) / 12))

    s = floor(
      approx -
        hindu_sidereal_year() *
          mod3((sidereal_solar_longitude(approx) / 360) - ((month - 1) / 12), -0.5, 0.5))

    k = astro_lunar_day_from_moment(s + hr(6))

    {_, mid_month, mid_leap_month, _, _} = astro_hindu_lunar_from_fixed(s - 15)
    temp =
      cond do
        3 < k and k < 27 -> k
        mid_month != month -> mod3(k, -15, 15)
        mid_leap_month and not leap_month -> mod3(k, -15, 15)
        true -> mod3(k, 15, 45)
      end

    est = s + day - temp

    tau = est - mod3(astro_lunar_day_from_moment(est + hr(6)) - day, -15, 15)

    fixed = next(tau - 1, fn d ->
      astro_lunar_day_from_moment(alt_hindu_sunrise(d)) in [day, mod3(day + 1, 1, 30)]
    end)
    leap_day && (fixed + 1) || fixed
  end

  # === 20.6 Holidays, DR4 362ff

  @doc """
  Moment of the first time at or after `tee` when Hindu solar longitude
  will be `lambda` degrees.
  DR4 364 (20.50), hindu-solar-longitude-at-or-after
  """
  def hindu_solar_longitude_at_or_after(lambda, tee) do
    tau = tee + (hindu_sidereal_year() / 360) * mod(lambda - hindu_solar_longitude(tee), 360)
    a = max(tee, tau - 5)
    b = tau + 5
    invert_angular(&hindu_solar_longitude/1, lambda, a, b)
  end

  @doc """
  Fixed moment of Mesha samkranti (Vernal equinox) in Gregorian `g_year`.
  DR4 364 (20.51), mesha-samkranti
  """
  def mesha_samkranti(g_year) do
    jan1 = gregorian_new_year(g_year)
    hindu_solar_longitude_at_or_after(0, jan1)
  end

  @doc """
  Time lunar_day (tithi) number `k` begins at or after
  moment `tee`. `k` can be fractional (for karanas).
  DR4 365 (20.52), hindu-lunar-day-at-or-after
  """
  def hindu_lunar_day_at_or_after(k, tee) do
    phase = (k - 1) * 12
    tau = tee + mod(phase - hindu_lunar_phase(tee), 360) * hindu_synodic_month() / 360
    a = max(tee, tau - 2)
    b = tau + 2
    invert_angular(&hindu_lunar_phase/1, phase, a, b)
  end

  @doc """
  Fixed date of Hindu lunisolar new year in Gregorian `g_year`.
  Next day if new moon after sunrise,  unless lunar day ends
  before next sunrise.
  DR4 365 (20.53), hindu-lunar-new-year
  """
  def hindu_lunar_new_year(g_year) do
    jan1 = gregorian_new_year(g_year)
    mina = hindu_solar_longitude_at_or_after(330, jan1)
    new_moon_ = hindu_lunar_day_at_or_after(1, mina)
    h_day = floor(new_moon_)
    critical = hindu_sunrise(h_day)
    summand =
      cond do
        new_moon_ < critical -> 0
        hindu_lunar_day_from_moment(hindu_sunrise(h_day + 1)) == 2 -> 0
        true -> 1
      end
    h_day + summand
  end

  @doc """
  True if Hindu lunar date `l_date1` is on or before
  Hindu lunar date `l_date2`.
  DR4 367 (20.54), hindu-lunar-on-or-before?
  """
  def hindu_lunar_on_or_before?(
        {year1, month1, leap_month1, day1, leap_day1} = _l_date1,
        {year2, month2, leap_month2, day2, leap_day2} = _l_date2) do
    c1 = not leap_day1 or leap_day2
    c2 = day1 == day2 and c1
    c3 = day1 < day2 or c2
    c4 = leap_month1 == leap_month2 and c3
    c5 = leap_month1 and not leap_month2 or c4
    c6 = month1 == month2 and c5
    c7 = month1 < month2 or c6
    c8 = year1 == year2 and c7
    year1 < year2 or c8
  end

  @doc """
  Fixed date of occurrence of Hindu lunar `l_month`, `l_day` in Hindu
  lunar year `l_year`, taking leap and expunged days into account.
  When the month is
  expunged, then the following month is used.
  DR4 367 (20.55), hindu-date-occur
  """
  def hindu_date_occur(l_year, l_month, l_day) do
    try = fixed_from_hindu_lunar(l_year, l_month, false, l_day, false)
    mid = hindu_lunar_from_fixed(l_day > 15 && try - 5 || try)
    {mid_year, mid_month, mid_leap_month, _, _} = mid
    expunged? = l_month != mid_month
    l_date = {mid_year, mid_month, mid_leap_month, l_day, false}
    {_,_, _, try_day, _} = hindu_lunar_from_fixed(try)
    cond do
      expunged? -> next(try, fn d -> not hindu_lunar_on_or_before?(hindu_lunar_from_fixed(d), l_date) end) - 1
      l_day != try_day -> try - 1
      true -> try
    end
  end

  @doc """
  List of fixed dates of occurrences of Hindu lunar
  `month`, `day` in Gregorian year `g_year`.
  DR4 367 (20.56), hindu-lunar-holiday
  """
  def hindu_lunar_holiday(l_month, l_day, g_year) do
    new_year = gregorian_new_year(g_year)
    {l_year, _, _, _, _} = hindu_lunar_from_fixed(new_year)
    date1 = hindu_date_occur(l_year, l_month, l_day)
    date2 = hindu_date_occur(l_year + 1, l_month, l_day)
    list_range([date1, date2], gregorian_year_range(g_year))
  end

  @doc """
  List of fixed date(s) of Diwali in Gregorian year `g_year`.
  DR4 368 (20.57), diwali
  """
  def diwali(g_year) do
    hindu_lunar_holiday(8, 1, g_year)
  end

  @doc """
  Fixed date of occurrence of Hindu lunar `tithi` prior
  to sundial time `tee`, in Hindu lunar `l_month`, `l_year`.
  DR4 368 (20.58), hindu-tithi-occur
  """
  def hindu_tithi_occur(l_month, tithi, tee, l_year) do
    approx = hindu_date_occur(l_year, l_month, floor(tithi))
    lunar = hindu_lunar_day_at_or_after(tithi, approx - 2)
    try = fixed_from_moment(lunar)
    tee_h = standard_from_sundial(try + tee, ujjain())
    sfs = standard_from_sundial(try + 1 + tee, ujjain())
    cond do
      lunar <= tee_h -> try
      hindu_lunar_phase(sfs) > (12 * tithi) -> try
      true -> try + 1
    end
  end

  @doc """
  List of fixed dates of occurrences of Hindu lunar `tithi`
  prior to sundial time `tee`, in Hindu lunar `l_month`,
  in Gregorian year `g_year`.
  DR4 368 (20.59), hindu-lunar-event
  """
  def hindu_lunar_event(l_month, tithi, tee, g_year) do
    new_year = gregorian_new_year(g_year)
    {l_year, _, _, _, _} = hindu_lunar_from_fixed(new_year)
    date1 = hindu_tithi_occur(l_month, tithi, tee, l_year)
    date2 = hindu_tithi_occur(l_month, tithi, tee, l_year + 1)
    list_range([date1, date2], gregorian_year_range(g_year))
  end

  @doc """
  List of fixed date(s) of Night of Shiva in Gregorian year `g_year`.
  DR4 369 (20.60), shiva
  """
  def shiva(g_year) do
    hindu_lunar_event(11, 29, hr(24), g_year)
  end

  @doc """
  List of fixed date(s) of Rama's Birthday in Gregorian year `g_year`.
  DR4 369 (20.61), rama
  """
  def rama(g_year) do
    hindu_lunar_event(1, 9, hr(12), g_year)
  end

  @doc """
  Hindu lunar station (nakshatra) at sunrise on `fixed`.
  DR4 369 (20.62), hindu-lunar-station
  """
  def hindu_lunar_station(fixed) do
    critical = hindu_sunrise(fixed)
    floor(hindu_lunar_longitude(critical) / angle(0, 800, 0)) + 1
  end

  @doc """
  Number (0-10) of the name of the `n`-th (1-60) Hindu karana.
  DR4 369 (20.63), karana
  """
  def karana(n) do
    cond do
      n == 1 -> 0
      n > 57 -> n - 50
      true -> amod(n - 1, 7)
    end
  end

  @doc """
  Hindu yoga on `fixed` date.
  DR4 369 (20.64), yoga
  """
  def yoga(fixed) do
    a = hindu_solar_longitude(fixed) + hindu_lunar_longitude(fixed)
    b = angle(0, 800, 0)
    floor(mod(a / b, 27)) + 1
  end

  @doc """
  List of Wednesdays in Gregorian year `g_year`
  that are day 8 of Hindu lunar months.
  DR4 370 (20.65), sacred-wednesdays
  """
  def sacred_wednesdays(g_year) do
    sacred_wednesdays_in_range(gregorian_year_range(g_year))
  end

  @doc """
  List of Wednesdays within `range` of dates
  that are day 8 of Hindu lunar months.
  DR4 371 (20.66), sacred-wednesdays-in-range
  """
  def sacred_wednesdays_in_range(a..b = range) do
    wed = kday_on_or_after(wednesday(), a)
    {_, _, _, h_day, _} = _h_date = hindu_lunar_from_fixed(wed)
    ell = h_day == 8 && [wed] || []
    if in_range?(wed, range) do
      ell ++ sacred_wednesdays_in_range((wed+1)..b)
    else
      []
    end
  end

  # === 21 The Tibetan Calendar, DR4 375ff

  # === 21.1 Calendar, DR4 375ff

  @doc """
  Tibetan Epoch.
  __
  ... we just number the years, ..., and choose as epoch the traditional
  year of ascension of the first Yarlun King, Nyatri Tsenpo.
  __
  = `{:gregorian, {-127, 12, 7}}`
  DR4 376 (21.1), tibetan-epoch
  """
  def tibetan_epoch, do: -46410

  @doc """
  Interpolated tabular sine of solar anomaly `alpha`.
  DR4 (21.2), tibetan-sun-equation
  """
  def tibetan_sun_equation(alpha) do
    ell = [0, 6, 10, 11] |> Enum.map(&(arcmins(&1)))
    cond do
      alpha > 6 -> -tibetan_sun_equation(alpha - 6)
      alpha > 3 -> tibetan_sun_equation(6 - alpha)
      is_integer(alpha) -> Enum.fetch!(ell, alpha)
      true -> (mod(alpha, 1) * tibetan_sun_equation(ceil(alpha)) +
                 mod(-alpha, 1) * tibetan_sun_equation(floor alpha))
    end
  end

  @doc """
  Interpolated tabular sine of lunar anomaly `alpha`.
  DR4 (21.3), tibetan-moon-equation
  """
  def tibetan_moon_equation(alpha) do
    ell = [0, 5, 10, 15, 19, 22, 24, 25] |> Enum.map(&(arcmins(&1)))
    cond do
      alpha > 14 -> -tibetan_moon_equation(alpha - 14)
      alpha > 7 -> tibetan_moon_equation(14 - alpha)
      is_integer(alpha) -> Enum.fetch!(ell, alpha)
      true -> (mod(alpha, 1) * tibetan_moon_equation(ceil(alpha)) +
                 mod(-alpha, 1) * tibetan_moon_equation(floor(alpha)))
    end
  end

  @doc """
  Fixed date corresponding to Tibetan lunar date `t_date`.
  DR4 378 (21.4), fixed-from-tibetan
  """
  def fixed_from_tibetan({year, month, leap_month, day, leap_day} = _t_date) do
    fixed_from_tibetan(year, month, leap_month, day, leap_day)
  end

  def fixed_from_tibetan(year, month, leap_month, day, leap_day) do
    months = floor(
      (804 / 65) * (year - 1) +
        (67 / 65) * month +
        (leap_month && -1 || 0) +
        (64 / 65))

    days = 30 * months + day

    mean = (11135 / 11312) * days - 30 + (leap_day && 0 || -1) + (1071 / 1616)

    solar_anomaly = mod((13 / 4824) * days + (2117 / 4824), 1)

    lunar_anomaly = mod((3781 / 105840) * days + (2837 / 15120), 1)

    sun = -tibetan_sun_equation(12 * solar_anomaly)
    moon = tibetan_moon_equation(28 * lunar_anomaly)

    floor(tibetan_epoch() + mean + sun + moon)
  end

  @doc """
  Tibetan lunar date corresponding to `fixed` date.
  DR4 378 (21.5), tibetan-from-fixed
  """
  def tibetan_from_fixed(fixed) do
    days_in_year = 365 + (4975 / 18382)
    years = ceil((fixed - tibetan_epoch()) / days_in_year)
    year0 = final(years, fn y -> fixed >= fixed_from_tibetan(y, 1, false, 1, false) end)
    month0 = final(1, fn m -> fixed >= fixed_from_tibetan(year0, m, false, 1, false) end)
    est = fixed - fixed_from_tibetan(year0, month0, false, 1, false)
    day0 = final(est - 2, fn d -> fixed >= fixed_from_tibetan(year0, month0, false, d, false) end)
    leap_month = day0 > 30
    day = amod(day0, 30)
    month1 =
      cond do
        day > day0 -> month0 - 1
        leap_month -> month0 + 1
        true -> month0
      end
    month = amod(month1, 12)
    year =
      cond do
        day > day0 and month0 == 1 -> year0 - 1
        leap_month and month0 == 12 -> year0 + 1
        true -> year0
      end
    leap_day = fixed == fixed_from_tibetan(year, month, leap_month, day, true)
    {year, month, leap_month, day, leap_day}
  end

  # === 21.2 Holidays, DR4 379ff

  @doc """
  True if `t_month` is leap in Tibetan year `t_year`.
  DR4 380 (21.6), tibetan-leap-month?
  """
  def tibetan_leap_month?(t_year, t_month) do
    fixed = fixed_from_tibetan(t_year, t_month, true, 2, false)
    {_, month, _, _, _} = tibetan_from_fixed(fixed)
    t_month == month
  end

  @doc """
  True if `t_day` is leap in Tibetan month `t_month` and year `t_year`.
  DR4 381 (21.7), tibetan-leap-day?
  """
  def tibetan_leap_day?(t_year, t_month, t_day) do
    fixed1 = fixed_from_tibetan(t_year, t_month, false, t_day, true)
    {_, _, _, day1, _} = tibetan_from_fixed(fixed1)

    fixed2 = fixed_from_tibetan(t_year, t_month, tibetan_leap_month?(t_year, t_month), t_day, true)
    {_, _, _, day2, _} = tibetan_from_fixed(fixed2)

    t_day == day1 or t_day == day2
  end

  @doc """
  Fixed date of Tibetan New Year (Losar) in Tibetan year `t_year`.
  DR4 381 (21.8), losar
  """
  def losar(t_year) do
    t_leap = tibetan_leap_month?(t_year, 1)
    fixed_from_tibetan(t_year, 1, t_leap, 1, false)
  end

  @doc """
  List of fixed dates of Tibetan New Year in Gregorian year `g_year`.
  DR4 381 (21.9), tibetan-new-year
  """
  def tibetan_new_year(g_year) do
    year_range = gregorian_year_range(g_year)
    dec31 = gregorian_year_end(g_year)
    {t_year, _, _, _, _} = tibetan_from_fixed(dec31)
    Enum.filter([losar(t_year - 1), losar(t_year)], &(&1 in year_range))
  end

  # === Addendum

  @doc """
  Convert `moment` into complete Gregorian DateTime
  `{year, month, day, hour, minute, second}`.
  """
  def date_time_from_moment(moment) do
    fixed = trunc(moment)
    {year, month, day} = gregorian_from_fixed(fixed)
    {hour, minute, second} = clock_from_moment(moment)
    {year, month, day, hour, minute, second}
  end

  @doc """
  Sum powers of `x` with coefficients (from order 0 up) in list `ell`.
  see lines 685-691 of calendrica-4.0.cl
  """
  @spec poly(number, [number]) :: [number]
  def poly(_, []), do: 0
  def poly(_, [h | []]), do: h
  def poly(c, ell) do
    n = length(ell) - 1
    ell
    |> Enum.zip(0..n)
    |> Enum.map(fn {p, i} -> p * :math.pow(c, i) end)
    |> Enum.sum
  end

  @doc """
  Returns the sum of body `b` for indices `i1` .. `in`
  running simultaneously thru lists `l1` .. `ln`.
  List `l` is of the form [[i1 l1]..[in ln]]
  # `l` is a list of `n` lists of the same length `L` [l1, l2, l3, ...]
  # `b` is a lambda with `n` args
  # `sigma` sums all `L` applications of `b` to the relevant tuple of args

  ## Example

    iex> a = [1, 2, 3, 4]
    [1, 2, 3, 4]
    iex> b = [5, 6, 7, 8]
    [5, 6, 7, 8]
    iex> c = [9, 10, 11, 12]
    [9, 10, 11, 12]
    iex> l = [a,b,c]                        # THE LIST
    [[1, 2, 3, 4], [5, 6, 7, 8], [9, 10, 11, 12]]
    iex> z = Enum.zip(l)      # >>> z = zip(*l)
    [{1, 5, 9}, {2, 6, 10}, {3, 7, 11}, {4, 8, 12}]
    iex> b = fn {x, y, z} -> x * y * z end
    iex> b.(hd(z)) # apply b to first element of z
    45
    iex> mapped = Enum.map(z, &(b.(&1)))
    [45, 120, 231, 384]
    iex> Enum.sum(mapped)
    780
    iex> Calixir.sigma(l, b) # USING LIST AND FUNCTION
    780
  """
  def sigma(l, b) do
    l
    |> Enum.zip
    |> Enum.map(&(b.(&1)))
    |> Enum.sum
  end

  # === Trigonometric Functions

  @doc "Convert angle from radians to degrees."
  def degrees_from_radians(radians) do
    mod(radians * (180.0 / :math.pi()), 360)
  end

  @doc "Convert angle from degrees to radians."
  def radians_from_degrees(degrees) do
    mod(degrees, 360) / (180.0 / :math.pi())
  end

  @doc "Sine of `theta` (given in degrees)."
  def sin_degrees(theta) do
    :math.sin(radians_from_degrees(theta))
  end

  @doc "Cosine of `theta` (given in degrees)."
  def cos_degrees(theta) do
    :math.cos(radians_from_degrees(theta))
  end

  @doc "Tangent of `theta` (given in degrees)."
  def tan_degrees(theta) do
    :math.tan(radians_from_degrees(theta))
  end

  @doc "Arcsine of `x` in degrees."
  def arcsin_degrees(x) do
    degrees_from_radians(:math.asin(x))
  end

  @doc "Arccosine of `x` in degrees."
  def arccos_degrees(x) do
    degrees_from_radians(:math.acos(x))
  end

  @doc """
  `x` degrees. For typesetting purposes.
  """
  def deg(x), do: x

  @doc """
  `x` arcminutes. DR4 mins (!)
  """
  def arcmins(x), do: x / 60

  @doc """
  `x` arcseconds. DR4 secs (!)
  """
  def arcsecs(x), do: x / 3600

  # === Time

  def hours_per_day,             do: 24
  def seconds_per_minute,        do: 60
  def seconds_per_hour,          do: 60 * 60          # 3600
  def seconds_per_day,           do: 60 * 60 * 24     # 86_400
  def minutes_per_hour,          do: 60
  def minutes_per_day,           do: 60 * 24          # 1440
  def days_per_week,             do: 7
  def days_per_century,          do: 365.25 * 100     # 86_400
  def seconds_per_julian_year,   do: 365.25 * 86_400  # 31_557_600

  # === Weekdays

  def name_of_weekday(0),        do: :sunday
  def name_of_weekday(1),        do: :monday
  def name_of_weekday(2),        do: :tuesday
  def name_of_weekday(3),        do: :wednesday
  def name_of_weekday(4),        do: :thursday
  def name_of_weekday(5),        do: :friday
  def name_of_weekday(6),        do: :saturday

  # === Functions

  @doc """
  Returns a negative value indicating a BCE Julian year.
  """
  def bce(year), do: -year

  @doc """
  Returns a positive value indicating a CE Julian year.
  """
  def ce(year), do: year

  # === Year constants

  def mean_julian_year,          do: 365.25
  def mean_gregorian_year,       do: 365.2425

  @doc """
  Round moment to integer number of seconds.
  (not DR4)
  """
  def moment(tee), do: round(tee * 86_400) / 86_400

  def day_fraction(tee), do: time_from_moment(tee)     # Alias

  def days_from_moment(tee),    do: floor(tee)
  def hours_from_moment(tee),   do: tee * 24
  def minutes_from_moment(tee), do: tee * 1440
  def seconds_from_moment(tee), do: tee * 86_400

  def hours_from_clock(clock) do
    time_from_clock(clock)
  end

  def minutes_from_clock({h, m, s} = _clock) do
    h * 60 + m + s / 60
  end

  def seconds_from_clock({h, m, s} = _clock) do
    (h * 60 + m) * 60 + s
  end

  # === Time-to-fraction conversions

  @doc """
  Convert `x` hours into a fraction of a day.
  """
  def hr(x), do: x / hours_per_day()

  @doc """
  Convert `x` minutes into a fraction of a day.
  """
  def mn(x), do: x / minutes_per_day()

  @doc """
  Convert `x` seconds into a fraction of a day.
  """
  def sec(x), do: x / seconds_per_day()

  @doc """
  Convert `x` days into a fraction of a century.
  (not DR4)
  """
  def cent(x), do: x / days_per_century()

  # === Addendum: Location and getters

  def location(latitude, longitude, elevation, zone) do
    {latitude, longitude, elevation, zone}
  end

  def latitude({latitude, _, _, _} = _location), do: latitude
  def longitude({_, longitude, _, _} = _location), do: longitude
  def elevation({_, _, elevation, _} = _location), do: elevation
  def zone({_, _, _, zone} = _location), do: zone

  # === Constructor and accessor functions not contained in DR4

  def akan_day_name_date(prefix, stem) do
    {prefix, stem}
  end

  def akan_day_name_prefix(akan_day_name_date) do
    elem(akan_day_name_date, 0)
  end

  def akan_day_name_stem(akan_day_name_date) do
    elem(akan_day_name_date, 1)
  end


  def armenian_date(year, month, day) do
    {year, month, day}
  end

  def armenian_year(armenian_date) do
    elem(armenian_date, 0)
  end

  def armenian_month(armenian_date) do
    elem(armenian_date, 1)
  end

  def armenian_day(armenian_date) do
    elem(armenian_date, 2)
  end


  def aztec_xihuitl_date(month, day) do
    {month, day}
  end

  def aztec_xihuitl_month(aztec_xihuitl_date) do
    elem(aztec_xihuitl_date, 0)
  end

  def aztec_xihuitl_day(aztec_xihuitl_date) do
    elem(aztec_xihuitl_date, 1)
  end


  def aztec_tonalpohualli_date(number, name) do
    {number, name}
  end

  def aztec_tonalpohualli_number(aztec_tonalpohualli_date) do
    elem(aztec_tonalpohualli_date, 0)
  end

  def aztec_tonalpohualli_name(aztec_tonalpohualli_date) do
    elem(aztec_tonalpohualli_date, 1)
  end


  def aztec_xiuhmolpilli_date(number, name) do
    {number, name}
  end

  def aztec_xiuhmolpilli_number(aztec_xiuhmolpilli_date) do
    elem(aztec_xiuhmolpilli_date, 0)
  end

  def aztec_xiuhmolpilli_name(aztec_xiuhmolpilli_date) do
    elem(aztec_xiuhmolpilli_date, 1)
  end


  def babylonian_date(year, month, leap, day) do
    {year, month, leap, day}
  end

  def babylonian_year(babylonian_date) do
    elem(babylonian_date, 0)
  end

  def babylonian_month(babylonian_date) do
    elem(babylonian_date, 1)
  end

  def babylonian_leap(babylonian_date) do
    elem(babylonian_date, 2)
  end

  def babylonian_day(babylonian_date) do
    elem(babylonian_date, 3)
  end


  def bahai_date(major, cycle, year, month, day) do
    {major, cycle, year, month, day}
  end

  def bahai_major(bahai_date) do
    elem(bahai_date, 0)
  end

  def bahai_cycle(bahai_date) do
    elem(bahai_date, 1)
  end

  def bahai_year(bahai_date) do
    elem(bahai_date, 2)
  end

  def bahai_month(bahai_date) do
    elem(bahai_date, 3)
  end

  def bahai_day(bahai_date) do
    elem(bahai_date, 4)
  end


  def astro_bahai_date(major, cycle, year, month, day) do
    {major, cycle, year, month, day}
  end

  def astro_bahai_major(astro_bahai_date) do
    elem(astro_bahai_date, 0)
  end

  def astro_bahai_cycle(astro_bahai_date) do
    elem(astro_bahai_date, 1)
  end

  def astro_bahai_year(astro_bahai_date) do
    elem(astro_bahai_date, 2)
  end

  def astro_bahai_month(astro_bahai_date) do
    elem(astro_bahai_date, 3)
  end

  def astro_bahai_day(astro_bahai_date) do
    elem(astro_bahai_date, 4)
  end


  def bali_pawukon_date(
        luang,
        dwiwara,
        triwara,
        caturwara,
        pancawara,
        sadwara,
        saptawara,
        asatawara,
        sangawara,
        dasawara
      ) do
    {luang, dwiwara, triwara, caturwara, pancawara, sadwara, saptawara, asatawara, sangawara, dasawara}
  end

  def bali_pawukon_luang(bali_pawukon_date) do
    elem(bali_pawukon_date, 0)
  end

  def bali_pawukon_dwiwara(bali_pawukon_date) do
    elem(bali_pawukon_date, 1)
  end

  def bali_pawukon_triwara(bali_pawukon_date) do
    elem(bali_pawukon_date, 2)
  end

  def bali_pawukon_caturwara(bali_pawukon_date) do
    elem(bali_pawukon_date, 3)
  end

  def bali_pawukon_pancawara(bali_pawukon_date) do
    elem(bali_pawukon_date, 4)
  end

  def bali_pawukon_sadwara(bali_pawukon_date) do
    elem(bali_pawukon_date, 5)
  end

  def bali_pawukon_saptawara(bali_pawukon_date) do
    elem(bali_pawukon_date, 6)
  end

  def bali_pawukon_asatawara(bali_pawukon_date) do
    elem(bali_pawukon_date, 7)
  end

  def bali_pawukon_sangawara(bali_pawukon_date) do
    elem(bali_pawukon_date, 8)
  end

  def bali_pawukon_dasawara(bali_pawukon_date) do
    elem(bali_pawukon_date, 9)
  end


  def chinese_date(cycle, year, month, leap, day) do
    {cycle, year, month, leap, day}
  end

  def chinese_cycle(chinese_date) do
    elem(chinese_date, 0)
  end

  def chinese_year(chinese_date) do
    elem(chinese_date, 1)
  end

  def chinese_month(chinese_date) do
    elem(chinese_date, 2)
  end

  def chinese_leap(chinese_date) do
    elem(chinese_date, 3)
  end

  def chinese_day(chinese_date) do
    elem(chinese_date, 4)
  end


  def coptic_date(year, month, day) do
    {year, month, day}
  end

  def coptic_year(coptic_date) do
    elem(coptic_date, 0)
  end

  def coptic_month(coptic_date) do
    elem(coptic_date, 1)
  end

  def coptic_day(coptic_date) do
    elem(coptic_date, 2)
  end


  def egyptian_date(year, month, day) do
    {year, month, day}
  end

  def egyptian_year(egyptian_date) do
    elem(egyptian_date, 0)
  end

  def egyptian_month(egyptian_date) do
    elem(egyptian_date, 1)
  end

  def egyptian_day(egyptian_date) do
    elem(egyptian_date, 2)
  end


  def ethiopic_date(year, month, day) do
    {year, month, day}
  end

  def ethiopic_year(ethiopic_date) do
    elem(ethiopic_date, 0)
  end

  def ethiopic_month(ethiopic_date) do
    elem(ethiopic_date, 1)
  end

  def ethiopic_day(ethiopic_date) do
    elem(ethiopic_date, 2)
  end


  def french_date(year, month, day) do
    {year, month, day}
  end

  def french_year(french_date) do
    elem(french_date, 0)
  end

  def french_month(french_date) do
    elem(french_date, 1)
  end

  def french_day(french_date) do
    elem(french_date, 2)
  end


  def arithmetic_french_date(year, month, day) do
    {year, month, day}
  end

  def arithmetic_french_year(arithmetic_french_date) do
    elem(arithmetic_french_date, 0)
  end

  def arithmetic_french_month(arithmetic_french_date) do
    elem(arithmetic_french_date, 1)
  end

  def arithmetic_french_day(arithmetic_french_date) do
    elem(arithmetic_french_date, 2)
  end


  def gregorian_date(year, month, day) do
    {year, month, day}
  end

  def gregorian_year(gregorian_date) do
    elem(gregorian_date, 0)
  end

  def gregorian_month(gregorian_date) do
    elem(gregorian_date, 1)
  end

  def gregorian_day(gregorian_date) do
    elem(gregorian_date, 2)
  end


  def hebrew_date(year, month, day) do
    {year, month, day}
  end

  def hebrew_year(hebrew_date) do
    elem(hebrew_date, 0)
  end

  def hebrew_month(hebrew_date) do
    elem(hebrew_date, 1)
  end

  def hebrew_day(hebrew_date) do
    elem(hebrew_date, 2)
  end


  def observational_hebrew_date(year, month, day) do
    {year, month, day}
  end

  def observational_hebrew_year(observational_hebrew_date) do
    elem(observational_hebrew_date, 0)
  end

  def observational_hebrew_month(observational_hebrew_date) do
    elem(observational_hebrew_date, 1)
  end

  def observational_hebrew_day(observational_hebrew_date) do
    elem(observational_hebrew_date, 2)
  end


  def old_hindu_solar_date(year, month, day) do
    {year, month, day}
  end

  def old_hindu_solar_year(old_hindu_solar_date) do
    elem(old_hindu_solar_date, 0)
  end

  def old_hindu_solar_month(old_hindu_solar_date) do
    elem(old_hindu_solar_date, 1)
  end

  def old_hindu_solar_day(old_hindu_solar_date) do
    elem(old_hindu_solar_date, 2)
  end


  def old_hindu_lunar_date(year, month, leap, day) do
    {year, month, leap, day}
  end

  def old_hindu_lunar_year(old_hindu_lunar_date) do
    elem(old_hindu_lunar_date, 0)
  end

  def old_hindu_lunar_month(old_hindu_lunar_date) do
    elem(old_hindu_lunar_date, 1)
  end

  def old_hindu_lunar_leap(old_hindu_lunar_date) do
    elem(old_hindu_lunar_date, 2)
  end

  def old_hindu_lunar_day(old_hindu_lunar_date) do
    elem(old_hindu_lunar_date, 3)
  end


  def hindu_solar_date(year, month, day) do
    {year, month, day}
  end

  def hindu_solar_year(hindu_solar_date) do
    elem(hindu_solar_date, 0)
  end

  def hindu_solar_month(hindu_solar_date) do
    elem(hindu_solar_date, 1)
  end

  def hindu_solar_day(hindu_solar_date) do
    elem(hindu_solar_date, 2)
  end


  def hindu_lunar_date(year, month, leap_month, day, leap_day) do
    {year, month, leap_month, day, leap_day}
  end

  def hindu_lunar_year(hindu_lunar_date) do
    elem(hindu_lunar_date, 0)
  end

  def hindu_lunar_month(hindu_lunar_date) do
    elem(hindu_lunar_date, 1)
  end

  def hindu_lunar_leap_month(hindu_lunar_date) do
    elem(hindu_lunar_date, 2)
  end

  def hindu_lunar_day(hindu_lunar_date) do
    elem(hindu_lunar_date, 3)
  end

  def hindu_lunar_leap_day(hindu_lunar_date) do
    elem(hindu_lunar_date, 4)
  end


  def astro_hindu_solar_date(year, month, day) do
    {year, month, day}
  end

  def astro_hindu_solar_year(astro_hindu_solar_date) do
    elem(astro_hindu_solar_date, 0)
  end

  def astro_hindu_solar_month(astro_hindu_solar_date) do
    elem(astro_hindu_solar_date, 1)
  end

  def astro_hindu_solar_day(astro_hindu_solar_date) do
    elem(astro_hindu_solar_date, 2)
  end


  def astro_hindu_lunar_date(year, month, leap_month, day, leap_day) do
    {year, month, leap_month, day, leap_day}
  end

  def astro_hindu_lunar_year(astro_hindu_lunar_date) do
    elem(astro_hindu_lunar_date, 0)
  end

  def astro_hindu_lunar_month(astro_hindu_lunar_date) do
    elem(astro_hindu_lunar_date, 1)
  end

  def astro_hindu_lunar_leap_month(astro_hindu_lunar_date) do
    elem(astro_hindu_lunar_date, 2)
  end

  def astro_hindu_lunar_day(astro_hindu_lunar_date) do
    elem(astro_hindu_lunar_date, 3)
  end

  def astro_hindu_lunar_leap_day(astro_hindu_lunar_date) do
    elem(astro_hindu_lunar_date, 4)
  end


  def icelandic_date(year, season, week, weekday) do
    {year, season, week, weekday}
  end

  def icelandic_year(icelandic_date) do
    elem(icelandic_date, 0)
  end

  def icelandic_season(icelandic_date) do
    elem(icelandic_date, 1)
  end

  def icelandic_week(icelandic_date) do
    elem(icelandic_date, 2)
  end

  def icelandic_weekday(icelandic_date) do
    elem(icelandic_date, 3)
  end


  def islamic_date(year, month, day) do
    {year, month, day}
  end

  def islamic_year(islamic_date) do
    elem(islamic_date, 0)
  end

  def islamic_month(islamic_date) do
    elem(islamic_date, 1)
  end

  def islamic_day(islamic_date) do
    elem(islamic_date, 2)
  end


  def observational_islamic_date(year, month, day) do
    {year, month, day}
  end

  def observational_islamic_year(observational_islamic_date) do
    elem(observational_islamic_date, 0)
  end

  def observational_islamic_month(observational_islamic_date) do
    elem(observational_islamic_date, 1)
  end

  def observational_islamic_day(observational_islamic_date) do
    elem(observational_islamic_date, 2)
  end


  def saudi_islamic_date(year, month, day) do
    {year, month, day}
  end

  def saudi_islamic_year(saudi_islamic_date) do
    elem(saudi_islamic_date, 0)
  end

  def saudi_islamic_month(saudi_islamic_date) do
    elem(saudi_islamic_date, 1)
  end

  def saudi_islamic_day(saudi_islamic_date) do
    elem(saudi_islamic_date, 2)
  end


  def iso_date(year, week, day) do
    {year, week, day}
  end

  def iso_year(iso_date) do
    elem(iso_date, 0)
  end

  def iso_week(iso_date) do
    elem(iso_date, 1)
  end

  def iso_day(iso_date) do
    elem(iso_date, 2)
  end


  def julian_date(year, month, day) do
    {year, month, day}
  end

  def julian_year(julian_date) do
    elem(julian_date, 0)
  end

  def julian_month(julian_date) do
    elem(julian_date, 1)
  end

  def julian_day(julian_date) do
    elem(julian_date, 2)
  end


  def roman_date(year, month, event, count, leap) do
    {year, month, event, count, leap}
  end

  def roman_year(roman_date) do
    elem(roman_date, 0)
  end

  def roman_month(roman_date) do
    elem(roman_date, 1)
  end

  def roman_event(roman_date) do
    elem(roman_date, 2)
  end

  def roman_count(roman_date) do
    elem(roman_date, 3)
  end

  def roman_leap(roman_date) do
    elem(roman_date, 4)
  end


  def olympiad_date(cycle, year) do
    {cycle, year}
  end

  def olympiad_cycle(olympiad_date) do
    elem(olympiad_date, 0)
  end

  def olympiad_year(olympiad_date) do
    elem(olympiad_date, 1)
  end


  def mayan_long_count_date(baktun, katun, tun, uinal, kin) do
    {baktun, katun, tun, uinal, kin}
  end

  def mayan_long_count_baktun(mayan_long_count_date) do
    elem(mayan_long_count_date, 0)
  end

  def mayan_long_count_katun(mayan_long_count_date) do
    elem(mayan_long_count_date, 1)
  end

  def mayan_long_count_tun(mayan_long_count_date) do
    elem(mayan_long_count_date, 2)
  end

  def mayan_long_count_uinal(mayan_long_count_date) do
    elem(mayan_long_count_date, 3)
  end

  def mayan_long_count_kin(mayan_long_count_date) do
    elem(mayan_long_count_date, 4)
  end


  def mayan_haab_date(month, day) do
    {month, day}
  end

  def mayan_haab_month(mayan_haab_date) do
    elem(mayan_haab_date, 0)
  end

  def mayan_haab_day(mayan_haab_date) do
    elem(mayan_haab_date, 1)
  end


  def mayan_tzolkin_date(name, number) do
    {name, number}
  end

  def mayan_tzolkin_name(mayan_tzolkin_date) do
    elem(mayan_tzolkin_date, 0)
  end

  def mayan_tzolkin_number(mayan_tzolkin_date) do
    elem(mayan_tzolkin_date, 1)
  end


  def persian_date(year, month, day) do
    {year, month, day}
  end

  def persian_year(persian_date) do
    elem(persian_date, 0)
  end

  def persian_month(persian_date) do
    elem(persian_date, 1)
  end

  def persian_day(persian_date) do
    elem(persian_date, 2)
  end


  def arithmetic_persian_date(year, month, day) do
    {year, month, day}
  end

  def arithmetic_persian_year(arithmetic_persian_date) do
    elem(arithmetic_persian_date, 0)
  end

  def arithmetic_persian_month(arithmetic_persian_date) do
    elem(arithmetic_persian_date, 1)
  end

  def arithmetic_persian_day(arithmetic_persian_date) do
    elem(arithmetic_persian_date, 2)
  end


  def samaritan_date(year, month, day) do
    {year, month, day}
  end

  def samaritan_year(samaritan_date) do
    elem(samaritan_date, 0)
  end

  def samaritan_month(samaritan_date) do
    elem(samaritan_date, 1)
  end

  def samaritan_day(samaritan_date) do
    elem(samaritan_date, 2)
  end


  def tibetan_date(year, month, leap_month, day, leap_day) do
    {year, month, leap_month, day, leap_day}
  end

  def tibetan_year(tibetan_date) do
    elem(tibetan_date, 0)
  end

  def tibetan_month(tibetan_date) do
    elem(tibetan_date, 1)
  end

  def tibetan_leap_month(tibetan_date) do
    elem(tibetan_date, 2)
  end

  def tibetan_day(tibetan_date) do
    elem(tibetan_date, 3)
  end

  def tibetan_leap_day(tibetan_date) do
    elem(tibetan_date, 4)
  end

end
