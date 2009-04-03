! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test sorting.title ;
IN: sorting.title.tests

: sort-me ( -- seq )
    {
        "The Beatles"
        "A river runs through it"
        "Another"
        "la vida loca"
        "Basketball"
        "racquetball"
        "Los Fujis"
        "los Fujis"
        "La cucaracha"
        "a day to remember"
        "of mice and men"
        "on belay"
        "for the horde"
    } ;
[
    {
        "Another"
        "Basketball"
        "The Beatles"
        "La cucaracha"
        "a day to remember"
        "for the horde"
        "Los Fujis"
        "los Fujis"
        "of mice and men"
        "on belay"
        "racquetball"
        "A river runs through it"
        "la vida loca"
    }
] [
    sort-me title-sort
] unit-test
