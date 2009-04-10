! Copyright (C) 2003, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.units
continuations debugger effects fry generalizations io io.files
io.styles kernel lexer locals macros math.parser namespaces
parser prettyprint quotations sequences source-files splitting
stack-checker summary unicode.case vectors vocabs vocabs.loader words
tools.vocabs tools.errors source-files.errors io.streams.string make
compiler.errors ;
IN: tools.test

TUPLE: test-failure < source-file-error continuation ;

SYMBOL: +test-failure+

M: test-failure source-file-error-type drop +test-failure+ ;

SYMBOL: test-failures
test-failures [ V{ } clone ] initialize

<PRIVATE

: <test-failure> ( error experiment file line# -- triple )
    test-failure new
        swap >>line#
        swap >>file
        swap >>asset
        swap >>error
        error-continuation get >>continuation ;

: failure ( error experiment file line# -- )
    "--> test failed!" print
    <test-failure> test-failures get push ;

: file-failure ( error file -- )
    [ f ] [ f ] bi* failure ;

:: (unit-test) ( output input -- error ? )
    [ { } input with-datastack output assert-sequence= f f ] [ t ] recover ; inline

: short-effect ( effect -- pair )
    [ in>> length ] [ out>> length ] bi 2array ;

:: (must-infer-as) ( effect quot -- error ? )
    [ quot infer short-effect effect assert= f f ] [ t ] recover ; inline

:: (must-infer) ( word/quot -- error ? )
    word/quot dup word? [ '[ _ execute ] ] when :> quot
    [ quot infer drop f f ] [ t ] recover ; inline

TUPLE: did-not-fail ;
CONSTANT: did-not-fail T{ did-not-fail }

M: did-not-fail summary drop "Did not fail" ;

:: (must-fail-with) ( quot pred -- error ? )
    [ quot call did-not-fail t ]
    [ dup pred call [ drop f f ] [ t ] if ] recover ; inline

:: (must-fail) ( quot -- error ? )
    [ quot call did-not-fail t ] [ drop f f ] recover ; inline

: experiment-title ( word -- string )
    "(" ?head drop ")" ?tail drop { { CHAR: - CHAR: \s } } substitute >title ;

MACRO: <experiment> ( word -- )
    [ stack-effect in>> length dup ]
    [ name>> experiment-title ] bi
    '[ _ ndup _ narray _ prefix ] ;

: experiment. ( seq -- )
    [ first write ": " write ] [ rest . ] bi ;

:: experiment ( word: ( -- error ? ) file line# -- )
    word <experiment> :> e
    e experiment.
    word execute [ e file line# failure ] [ drop ] if ; inline

: parse-test ( accum word -- accum )
    literalize parsed
    file get dup [ path>> ] when parsed
    lexer get line>> parsed
    \ experiment parsed ; inline

<<

SYNTAX: TEST:
    scan
    [ create-in ]
    [ "(" ")" surround search '[ _ parse-test ] ] bi
    define-syntax ;

>>

: run-test-file ( path -- )
    [ [ test-failures get ] dip '[ file>> _ = not ] filter-here ]
    [ [ run-file ] [ swap file-failure ] recover ] bi ;

: run-vocab-tests ( vocab -- )
    dup vocab source-loaded?>> [
        vocab-tests [ run-test-file ] each
    ] [ drop ] if ;

: traceback-button. ( failure -- )
    "[" write [ "Traceback" ] dip continuation>> write-object "]" print ;

PRIVATE>

TEST: unit-test
TEST: must-infer-as
TEST: must-infer
TEST: must-fail-with
TEST: must-fail

M: test-failure summary
    [ asset>> experiment. ] with-string-writer ;

M: test-failure error. ( error -- )
    [ call-next-method ]
    [ traceback-button. ]
    bi ;

: :failures ( -- ) test-failures get errors. ;

: test ( prefix -- )
    [ child-vocabs [ run-vocab-tests ] each ] with-compiler-errors
    test-failures get [
        ":failures - show " write length pprint " failing tests." print
    ] unless-empty ;

: test-all ( -- ) "" test ;
