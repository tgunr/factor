! Copyright (C) 2016 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel modern.compiler tools.test ;
IN: modern.compiler.tests


{ } [
"IN: scratchpad2
SYMBOL: a"
quick-compile-string drop
] unit-test

{ } [
"IN: scratchpad2
SYMBOLS: b c ;"
quick-compile-string drop
] unit-test

{ } [
"IN: scratchpad2
USE: math
: add ( a b -- c ) + ;"
quick-compile-string drop
] unit-test