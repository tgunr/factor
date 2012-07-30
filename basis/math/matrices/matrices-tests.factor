USING: math.matrices math.vectors tools.test math kernel ;
IN: math.matrices.tests

[
    { { 0 } { 0 } { 0 } }
] [
    3 1 zero-matrix
] unit-test

{
    { { 1 0 0 }
       { 0 1 0 }
       { 0 0 1 } }
} [
    3 identity-matrix
] unit-test

{
    { { 1 0 0 }
       { 0 2 0 }
       { 0 0 3 } }
} [
    { 1 2 3 } diagonal-matrix
] unit-test

{
    { { 1 1 1 }
      { 4 2 1 }
      { 9 3 1 }
      { 25 5 1 } }
} [
    { 1 2 3 5 } 3 vandermonde-matrix
] unit-test

{
    {
        { 1 0 0 }
        { 0 1 0 }
        { 0 0 1 }
    }
} [
    3 3 0 eye
] unit-test

{
    {
        { 0 1 0 }
        { 0 0 1 }
        { 0 0 0 }
    }
} [
    3 3 1 eye
] unit-test

{
    {
        { 0 0 0 }
        { 1 0 0 }
        { 0 1 0 }
    }
} [
    3 3 -1 eye
] unit-test

{
    {
        { 1 0 0 0 }
        { 0 1 0 0 }
        { 0 0 1 0 }
    }
} [
    3 4 0 eye
] unit-test

{
    {
        { 0 1 0 }
        { 0 0 1 }
        { 0 0 0 }
        { 0 0 0 }
    }
} [
    4 3 1 eye
] unit-test

{
    {
        { 0 0 0 }
        { 1 0 0 }
        { 0 1 0 }
        { 0 0 1 }
    }
} [
    4 3 -1 eye
] unit-test

[
    { { 1   1/2 1/3 1/4 }
      { 1/2 1/3 1/4 1/5 }
      { 1/3 1/4 1/5 1/6 }
    }
] [ 3 4 hilbert-matrix ] unit-test

[
    { { 1 2 3 4 }
      { 2 1 2 3 }
      { 3 2 1 2 }
      { 4 3 2 1 } }
] [ 4 toeplitz-matrix ] unit-test

[
    { { 1 2 3 4 }
      { 2 3 4 0 }
      { 3 4 0 0 }
      { 4 0 0 0 } }
] [ 4 hankel-matrix ] unit-test

[
    { { 1 0 4 }
      { 0 7 0 }
      { 6 0 3 } }
] [
    { { 1 0 0 }
      { 0 2 0 }
      { 0 0 3 } }

    { { 0 0 4 }
      { 0 5 0 }
      { 6 0 0 } }

    m+
] unit-test

[
    { { 1 0 4 }
       { 0 7 0 }
       { 6 0 3 } }
] [
    { { 1 0 0 }
       { 0 2 0 }
       { 0 0 3 } }

    { { 0 0 -4 }
       { 0 -5 0 }
       { -6 0 0 } }

    m-
] unit-test

[
    { 10 20 30 }
] [
    10 { 1 2 3 } n*v
] unit-test

[
    { 3 4 }
] [
    { { 1 0 }
       { 0 1 } }

    { 3 4 }

    m.v
] unit-test

[
    { 4 3 }
] [
    { { 0 1 }
       { 1 0 } }

    { 3 4 }

    m.v
] unit-test

[
    { { 6 } }
] [
    { { 3 } } { { 2 } } m.
] unit-test

[
    { { 11 } }
] [
    { { 1 3 } } { { 5 } { 2 } } m.
] unit-test

[
    { { 28 } }
] [
    { { 2 4 6 } }

    { { 1 }
       { 2 }
       { 3 } }
    
    m.
] unit-test

[ { 0 0 1 } ] [ { 1 0 0 } { 0 1 0 } cross ] unit-test
[ { 1 0 0 } ] [ { 0 1 0 } { 0 0 1 } cross ] unit-test
[ { 0 1 0 } ] [ { 0 0 1 } { 1 0 0 } cross ] unit-test
[ { 0.0 -0.707 0.707 } ] [ { 1.0 0.0 0.0 } { 0.0 0.707 0.707 } cross ] unit-test
[ { 0 -2 2 } ] [ { -1 -1 -1 } { 1 -1 -1 } cross ] unit-test
[ { 1 0 0 } ] [ { 1 1 0 } { 1 0 0 } proj ] unit-test

[ { { 4181 6765 } { 6765 10946 } } ]
[ { { 0 1 } { 1 1 } } 20 m^n ] unit-test

{
    { { 0 5 0 10 } { 6 7 12 14 } { 0 15 0 20 } { 18 21 24 28 } }
}
[ { { 1 2 } { 3 4 } } { { 0 5 } { 6 7 } } kron ] unit-test

{
    {
        { 1 1 1 1 }
        { 1 -1 1 -1 }
        { 1 1 -1 -1 }
        { 1 -1 -1 1 }
    }
} [ { { 1 1 } { 1 -1 } } dup kron ] unit-test

{
    {
        { 1 1 1 1 1 1 1 1 }
        { 1 -1 1 -1 1 -1 1 -1 }
        { 1 1 -1 -1 1 1 -1 -1 }
        { 1 -1 -1 1 1 -1 -1 1 }
        { 1 1 1 1 -1 -1 -1 -1 }
        { 1 -1 1 -1 -1 1 -1 1 }
        { 1 1 -1 -1 -1 -1 1 1 }
        { 1 -1 -1 1 -1 1 1 -1 }
    }
} [ { { 1 1 } { 1 -1 } } dup dup kron kron ] unit-test

{
    {
        { 1 1 1 1 1 1 1 1 }
        { 1 -1 1 -1 1 -1 1 -1 }
        { 1 1 -1 -1 1 1 -1 -1 }
        { 1 -1 -1 1 1 -1 -1 1 }
        { 1 1 1 1 -1 -1 -1 -1 }
        { 1 -1 1 -1 -1 1 -1 1 }
        { 1 1 -1 -1 -1 -1 1 1 }
        { 1 -1 -1 1 -1 1 1 -1 }
    }
} [ { { 1 1 } { 1 -1 } } dup dup kron swap kron ] unit-test


! kron is not generally commutative, make sure we have the right order
{
    {
        { 1 2 3 4 5 1 2 3 4 5 }
        { 6 7 8 9 10 6 7 8 9 10 }
        { 1 2 3 4 5 -1 -2 -3 -4 -5 }
        { 6 7 8 9 10 -6 -7 -8 -9 -10 }
    }
}
[
    { { 1 1 } { 1 -1 } }
    { { 1 2 3 4 5 } { 6 7 8 9 10 } } kron
] unit-test

{
    {
        { 1 1 2 2 3 3 4 4 5 5 }
        { 1 -1 2 -2 3 -3 4 -4 5 -5 }
        { 6 6 7 7 8 8 9 9 10 10 }
        { 6 -6 7 -7 8 -8 9 -9 10 -10 }
    }
}
[
    { { 1 1 } { 1 -1 } }
    { { 1 2 3 4 5 } { 6 7 8 9 10 } } swap kron
] unit-test
