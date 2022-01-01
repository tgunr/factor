! Copyright (C) 2003, 2009 Slava Pestov.
! Copyright (C) 2008 Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ascii arrays assocs combinators grouping
io.encodings.utf8 io.files kernel lexer math math.functions
math.parser sequences splitting vocabs.loader ;
IN: colors

! FIXME: replace with MIXIN: color INSTANCE: rgba color
TUPLE: color ;

TUPLE: rgba < color
{ red read-only }
{ green read-only }
{ blue read-only }
{ alpha read-only } ;

C: <rgba> rgba

GENERIC: >rgba ( color -- rgba )

M: rgba >rgba ; inline

M: color red>> >rgba red>> ;
M: color green>> >rgba green>> ;
M: color blue>> >rgba blue>> ;

: >rgba-components ( object -- r g b a )
    >rgba { [ red>> ] [ green>> ] [ blue>> ] [ alpha>> ] } cleave ; inline

: opaque? ( color -- ? ) alpha>> 1 number= ;

CONSTANT: transparent T{ rgba f 0.0 0.0 0.0 0.0 }

: inverse-color ( color -- color' )
    >rgba-components [ [ 1.0 swap - ] tri@ ] dip <rgba> ;

: color= ( color1 color2 -- ? )
    [ >rgba-components 4array ] bi@ [ 0.00000001 ~ ] 2all? ;

<PRIVATE

: parse-color ( line -- name color )
    first4
    [ [ string>number 255 /f ] tri@ 1.0 <rgba> ] dip
    [ ascii:blank? ] trim-head H{ { CHAR: \s CHAR: - } } substitute swap ;

: parse-colors ( lines -- assoc )
    [ "!" head? ] reject
    [ 11 cut [ " \t" split harvest ] dip suffix ] map
    [ parse-color ] H{ } map>assoc ;

MEMO: colors ( -- assoc )
    "resource:basis/colors/rgb.txt"
    "resource:basis/colors/factor-colors.txt"
    "resource:basis/colors/solarized-colors.txt"
    [ utf8 file-lines parse-colors ] tri@ assoc-union assoc-union ;

ERROR: invalid-hex-color hex ;

: hex>rgba ( hex -- rgba )
    dup length {
        { 6 [ 2 group [ hex> 255 /f ] map first3 1.0 ] }
        { 8 [ 2 group [ hex> 255 /f ] map first4 ] }
        { 3 [ [ digit> 15 /f ] { } map-as first3 1.0 ] }
        { 4 [ [ digit> 15 /f ] { } map-as first4 ] }
        [ drop invalid-hex-color ]
    } case <rgba> ;

PRIVATE>

: named-colors ( -- keys ) colors keys ;

ERROR: no-such-color name ;

: named-color ( name -- color )
    dup colors at [ ] [ no-such-color ] ?if ;

: parse-color ( str -- color )
    "#" ?head [ hex>rgba ] [ named-color ] if ;

TUPLE: parsed-color < color string value ;

M: parsed-color >rgba value>> >rgba ;

SYNTAX: COLOR: scan-token dup parse-color parsed-color boa suffix! ;

{ "colors" "prettyprint" } "colors.prettyprint" require-when
