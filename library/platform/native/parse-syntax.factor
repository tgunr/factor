! :folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

IN: parser

USE: combinators
USE: errors
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: parser
USE: stack
USE: strings
USE: words
USE: vectors
USE: unparser

! Colon defs
: CREATE ( -- word )
    scan "in" get create dup set-word
    f over "documentation" set-word-property
    f over "stack-effect" set-word-property ;

: remember-where ( word -- )
    "line-number" get over "line" set-word-property
    "col"         get over "col"  set-word-property
    "file"        get over "file" set-word-property
    drop ;

! \x
: unicode-escape>ch ( -- esc )
    #! Read \u....
    next-ch digit> 16 *
    next-ch digit> + 16 *
    next-ch digit> + 16 *
    next-ch digit> + ;

: ascii-escape>ch ( ch -- esc )
    [
        [ CHAR: e | CHAR: \e ]
        [ CHAR: n | CHAR: \n ]
        [ CHAR: r | CHAR: \r ]
        [ CHAR: t | CHAR: \t ]
        [ CHAR: s | CHAR: \s ]
        [ CHAR: \s | CHAR: \s ]
        [ CHAR: 0 | CHAR: \0 ]
        [ CHAR: \\ | CHAR: \\ ]
        [ CHAR: \" | CHAR: \" ]
    ] assoc ;

: escape ( ch -- esc )
    dup CHAR: u = [
        drop unicode-escape>ch
    ] [
        ascii-escape>ch
    ] ifte ;

: parse-escape ( -- )
    next-ch escape dup [ drop "Bad escape" throw ] unless ;

: parse-ch ( ch -- ch )
    dup CHAR: \\ = [ drop parse-escape ] when ;

: doc-comment-here? ( parsed -- ? )
    not "in-definition" get and ;

: parsed-stack-effect ( parsed str -- parsed )
    over doc-comment-here? [
        word "stack-effect" set-word-property
    ] [
        drop
    ] ifte ;

: documentation+ ( str word -- )
    [
        "documentation" word-property [
            swap "\n" swap cat3
        ] when*
    ] keep
    "documentation" set-word-property ;

: parsed-documentation ( parsed str -- parsed )
    over doc-comment-here? [
        word documentation+
    ] [
        drop
    ] ifte ;

IN: syntax

! The variable "in-definition" is set inside a : ... ;.
! ( and #! then add "stack-effect" and "documentation"
! properties to the current word if it is set.

! Constants
: t t parsed ; parsing
: f f parsed ; parsing

! Lists
: [ [ ] ; parsing
: ] reverse parsed ; parsing

: | ( syntax: | cdr ] )
    #! See the word 'parsed'. We push a special sentinel, and
    #! 'parsed' acts accordingly.
    "|" ; parsing

! Vectors
: { f ; parsing
: } reverse list>vector parsed ; parsing

! Do not execute parsing word
: POSTPONE: ( -- ) scan-word parsed ; parsing

: :
    #! Begin a word definition. Word name follows.
    CREATE dup remember-where [ ]
    "in-definition" on ; parsing

: ;-hook ( word def -- )
    ";-hook" get [ call ] [ define-compound ] ifte* ;

: ;
    #! End a word definition.
    "in-definition" off
    reverse
    ;-hook ; parsing

! Symbols
: SYMBOL: CREATE define-symbol ; parsing

: \
    #! Parsed as a piece of code that pushes a word on the stack
    #! \ foo ==> [ foo ] car
    scan-word unit parsed [ car ] car parsed ; parsing

! Vocabularies
: DEFER: CREATE drop ; parsing
: USE: scan "use" cons@ ; parsing
: IN: scan dup "use" cons@ "in" set ; parsing

! Char literal
: CHAR: ( -- ) next-word-ch parse-ch parsed ; parsing

! String literal
: parse-string ( -- )
    next-ch dup CHAR: " = [
        drop
    ] [
        parse-ch % parse-string
    ] ifte ;

: "
    #! Note the ugly hack to carry the new value of 'pos' from
    #! the <% %> scope up to the original scope.
    <% parse-string "col" get %> swap "col" set parsed ; parsing

! Complex literal
: #{
    #! Read #{ real imaginary #}
    scan str>number scan str>number rect> "}" expect parsed ;

! Comments
: ( ")" until parsed-stack-effect ; parsing

: ! until-eol drop ; parsing

: #! until-eol parsed-documentation ; parsing

! Reading numbers in other bases

: BASE: ( base -- )
    #! Read a number in a specific base.
    scan swap base> parsed ;

: HEX: 16 BASE: ; parsing
: DEC: 10 BASE: ; parsing
: OCT: 8 BASE: ; parsing
: BIN: 2 BASE: ; parsing
