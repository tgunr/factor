! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types assocs compiler.units functors
growable io kernel lexer namespaces parser prettyprint.custom
sequences specialized-arrays specialized-arrays.private strings
vocabs vocabs.parser ;
QUALIFIED: vectors.functor
IN: specialized-vectors

<PRIVATE

FUNCTOR: define-vector ( T -- )

V   DEFINES-CLASS ${T}-vector

A   IS      ${T}-array
S   IS      ${T}-sequence
<A> IS      <${A}>

>V  DEFERS >${V}
V{  DEFINES ${V}{

WHERE

V A <A> vectors.functor:define-vector

M: V contract 2drop ;

M: V byte-length underlying>> byte-length ;

M: V pprint-delims drop \ V{ \ } ;

M: V >pprint-sequence ;

M: V pprint* pprint-object ;

SYNTAX: V{ \ } [ >V ] parse-literal ;

INSTANCE: V growable
INSTANCE: V S

;FUNCTOR

: specialized-vector-vocab ( type -- vocab )
    "specialized-vectors.instances." prepend ;

: defining-vector-message ( type -- )
    "quiet" get [ drop ] [
        "Generating specialized " " vectors..." surround print
    ] if ;

PRIVATE>

: define-vector-vocab ( type  -- vocab )
    underlying-type
    dup specialized-vector-vocab vocab
    [ ] [
        [ defining-vector-message ]
        [
            [
                dup specialized-vector-vocab
                [ define-vector ] with-current-vocab
            ] with-compilation-unit
        ]
        [ specialized-vector-vocab ]
        tri
    ] ?if ;

SYNTAX: SPECIALIZED-VECTOR:
    scan
    [ define-array-vocab use-vocab ]
    [ define-vector-vocab use-vocab ] bi ;
