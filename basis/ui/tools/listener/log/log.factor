! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors io kernel lexer namespaces prettyprint sequences
strings.parser ui.tools.listener words ;
IN: ui.tools.listener.log

<PRIVATE
: L. ( -- ) 
    get-listener input>> output>> 
    [ nl "---" print .s ]
    with-output-stream*  ;

SYMBOL: LPRINT

: Lprint* ( string listener -- )
    swap LPRINT set 
    input>> output>> 
    [ LPRINT get print ]  
    with-output-stream*  ; 

: Lprint ( string -- )
    get-listener Lprint* ; 

: +colon-space ( string -- string' )  ": " append ;
: +space ( string -- string' )   " " append ; 

: (.here) ( name -- )  +colon-space Lprint ;
: (here.) ( obj name -- )  [ unparse ] dip +colon-space prepend  Lprint ;
: (here.s) ( name -- )  +colon-space Lprint L. ;
PRIVATE>

SYNTAX: .HERE last-word name>> suffix!  \ (.here) suffix! ;
SYNTAX: HERE. last-word name>> suffix!  \ (here.) suffix! ;
SYNTAX: HERE.S  last-word name>> suffix!  \ (here.s) suffix! ;
SYNTAX: HERE" last-word name>> +colon-space  ! "for the editors sake
    lexer get skip-blank parse-string append suffix!
    \ Lprint suffix! ;

