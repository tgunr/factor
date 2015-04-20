! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry generalizations io io.streams.string kernel
locals macros make math math.order math.parser multiline
namespaces present sequences splitting strings vocabs.parser ;
IN: interpolate

<PRIVATE

TUPLE: named-var name ;

TUPLE: stack-var n ;

: (parse-interpolate) ( str -- )
    [
        "${" split1-slice [
            [ >string , ] unless-empty
        ] [
            [
                "}" split1-slice
                [
                    >string dup string>number
                    [ stack-var boa ] [ named-var boa ] ?if ,
                ]
                [ (parse-interpolate) ] bi*
            ] when*
        ] bi*
    ] unless-empty ;

: parse-interpolate ( str -- seq )
    [ (parse-interpolate) ] { } make ;

: max-stack-var ( seq -- n/f )
    f [
        dup stack-var? [ n>> [ or ] keep max ] [ drop ] if
    ] reduce ;

:: interpolate-quot ( str quot -- quot' )
    str parse-interpolate :> args
    args max-stack-var    :> vars

    args [
        dup named-var? [
            name>> quot call '[ _ @ present write ]
        ] [
            dup stack-var? [
                n>> 1 + '[ _ npick present write ]
            ] [
                '[ _ write ]
            ] if
        ] if
    ] map concat

    vars [
        1 + '[ _ ndrop ] append
    ] when* ; inline

PRIVATE>

MACRO: interpolate ( str -- )
    [ [ get ] ] interpolate-quot ;

: interpolate>string ( str -- newstr )
    [ interpolate ] with-string-writer ; inline

: interpolate-locals ( str -- quot )
    [ dup search [ [ ] ] [ [ get ] ] ?if ] interpolate-quot ;

SYNTAX: I[
    "]I" parse-multiline-string
    interpolate-locals append! ;
