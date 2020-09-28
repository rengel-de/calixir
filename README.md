# Calixir

## About
  
`Calixir` is a port of the Lisp calendar software `calendrica-4.0.cl` 
of the 4th edition of the book


[Calendrical Calculations - The Ultimate Edition](https://www.cs.tau.ac.il/~nachum/calendar-book/fourth-edition/)  
by Edward M. Reingold and Nachum Dershowitz  
Cambridge University Press, 2018


to Elixir. In the software, this book is referenced as **DR4**.
Everybody interested in `Calixir` probably should get a copy of
this book in order to understand the background of the calendars 
covered by this software.

The package contains all the functions that are required to calculate the 
sample dates and the holidays. A few functions that are used for 
illustration or alternative methods of calculation have not been 
implemented.  

`Calixir` has no relationship to the software `Calendrical`, 
which is a partial port of `calendrica-3.0.cl`, the software of the 
previous edition of the Dershowitz-Reingold book, to Elixir.

The ported functions are tested against the data provided in the book. 
All the functions of the Elixir port produce exactly the same data.

The data and the tests are included in this package.


## Installation

The package is [available in Hex](https://hex.pm/docs/publish) and can be installed
by adding `calixir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:calixir, "~> 0.1.0"}
  ]
end
```

## Documentation

Documentation has been generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). The docs can
be found at [https://hexdocs.pm/calixir](https://hexdocs.pm/calixir).

## About the 'Design' of this Software

This software has no design. 

The original Lisp package `calendrica-4.0.cl` has no notion of `modules` 
that are a common means of design and separation of concerns in Elixir (and many other 
programming languages, for that matter). Instead, it uses a single large namespace. 
The functions and macros in this namespace are differentiated by prefixes 
that denote the various calendars (i.e. `gregorian_epoch`, `julian_epoch`, etc.).

During the preparation of this package I tried various approaches: I tried to factor out 
the different calendars into separate modules and even into separate packages (apps). 
These attempts resulted in one or another form of 'dependency hell', because functions of
several calendars are dependent on each other. Finally, I decided to strictly follow 
the book (DR4) in the arrangement of functions and macros and to create one mononlithic 
module that mirrors most functions of the Lisp version. (In case you are interested: 
The same approach was taken by the Python port of this software: 
[`PyCalCal`](https://github.com/espinielli/pycalcal).)

The naming of the Elixir functions follows closely the naming of the Lisp functions 
(except for using `_` instead of `-` in the function names). 

All the functions and tests of this package are heaviliy cross-refrenced by the page and 
equation numbers in DR4, so that you can easily go to the source.

If you want to 'modularize' this package, I recommend to take this package for a base and 
to create thin wrappers for the calendars or aspects of your interest. I took this approach 
for the companion package called [`Calendars`](https://hex.pm/packages/calendars), that factors out the various 
monotonous (i.e. `Gregorian`) and cyclical (i.e. `Day_of_week`, `Olympiad`) calendars contained in 
`Calixir`.

## Notes on Copyright and License

`CALENDRICA 4.0 -- Common Lisp` is written and copyrighted by E. M. Reingold and N. Dershowitz as 
described in file `COPYRIGHT_DERSHOWITZ_REINGOLD`. This copyright is part of the Common Lisp 
source file. 

This library is made public under the following conditions:

- The code can be used for personal use.
- The code can be used for demonstrations purposes.
- Non-profit reuse with attribution is fine.
- Commercial use of the algorithms should be licensed and are not allowed from this library.

The permissions above are granted **as long as attribution is given to the authors of the 
original algorithms, Nachum Dershowitz and Edward M. Reingold**.

The Calixir source code is licensed under the Apache License, Version 2.0,
the same license that is used by Elixir. You may obtain a copy of this License at 
[Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).

## Resources

The resources (source code and sample data) for this book are available as downloads 
from the publisher's website:
[Cambridge University Press](https://www.cambridge.org/ch/academic/subjects/computer-science/computing-general-interest/calendrical-calculations-ultimate-edition-4th-edition?format=PB&isbn=9781107683167#resources).   

The Lisp source file is included in this package (in the `assets` directory)
to make it easier to compare the Lisp and Elixir algorithms.
The sample data files are included in this package (also in the `assets` directory),
because they are needed for the tests.

Prof. Reingold maintains a website, [CALENDARISTS.COM](https://www.cs.tau.ac.il/~nachum/calendar-book/index.shtml), 
where you can get information about previous editions of the book and other 
calendar-related publications.

## Changelog
- 0.1.6 fixed function `last_day_of_grgorian_month`