! Copyright (C) 2017 Alexander Ilin.

USING: tools.test charts ;
IN: charts.tests

! Adjustment after search is required in both directions.
{
    {
        { 1 3 } { 1 4 } { 1 5 }
        { 2 6 } { 3 7 } { 4 8 }
        { 5 9 } { 5 10 } { 5 11 } { 5 12 }
    }
} [
    { 1 5 }
    {
        { 0 1 } { 0 2 }
        { 1 3 } { 1 4 } { 1 5 }
        { 2 6 } { 3 7 } { 4 8 }
        { 5 9 } { 5 10 } { 5 11 } { 5 12 }
        { 6 13 } { 7 14 }
    } clip-data
] unit-test
