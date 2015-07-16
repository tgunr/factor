! Copyright (C) 2008 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators fry io io.binary io.encodings.binary
io.streams.byte-array kernel literals math namespaces sbufs
sequences ;
IN: base64

ERROR: malformed-base64 ;

<PRIVATE

: read1-ignoring ( ignoring stream -- ch )
    dup stream-read1 pick dupd member?
    [ drop read1-ignoring ] [ 2nip ] if ; inline recursive

: push-ignoring ( accum ch -- accum )
    dup { f 0 } member-eq? [ drop ] [ suffix! ] if ; inline

: read-ignoring ( n ignoring stream -- str/f )
    [ [ <sbuf> ] keep ] 2dip
    '[ _ _ read1-ignoring push-ignoring ] times
    [ f ] [ "" like ] if-empty ; inline

<<
CONSTANT: alphabet
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

: alphabet-inverse ( alphabet -- seq )
    dup supremum 1 + f <array> [
        '[ swap _ set-nth ] each-index
    ] keep ;
>>

: ch>base64 ( ch -- ch )
    alphabet nth ; inline

: base64>ch ( ch -- ch )
    $[ alphabet alphabet-inverse 0 CHAR: = pick set-nth ] nth
    [ malformed-base64 ] unless* ; inline

SYMBOL: column

: write1-lines ( column/f ch stream -- column' )
    [ stream-write1 ] keep swap [
        1 + swap
        '[ 76 = [ B{ CHAR: \r CHAR: \n } _ stream-write ] when ]
        [ 76 mod ] bi
    ] [ drop f ] if* ;

: write-lines ( str -- )
    column output-stream get '[
        swap [ _ write1-lines ] each
    ] change ;

: encode3 ( seq -- )
    column output-stream get '[
        swap be> { -18 -12 -6 0 } [
            shift 0x3f bitand ch>base64 _ write1-lines
        ] with each
    ] change ; inline

: encode-pad ( seq n -- )
    [ 3 0 pad-tail binary [ encode3 ] with-byte-writer ]
    [ 1 + ] bi* head-slice 4 CHAR: = pad-tail write-lines ; inline

: decode4 ( seq -- )
    [ 0 [ base64>ch swap 6 shift bitor ] reduce 3 >be ]
    [ [ CHAR: = = ] count ] bi head-slice*
    output-stream get '[ _ stream-write1 ] each ; inline

: (encode-base64) ( stream -- )
    3 over stream-read dup length {
        { 0 [ 2drop ] }
        { 3 [ encode3 (encode-base64) ] }
        [ encode-pad (encode-base64) ]
    } case ;

PRIVATE>

: encode-base64 ( -- )
    input-stream get (encode-base64) ;

: encode-base64-lines ( -- )
    0 column [ encode-base64 ] with-variable ;

<PRIVATE

: (decode-base64) ( stream -- )
    4 "\n\r" pick read-ignoring dup length {
        { 0 [ 2drop ] }
        { 4 [ decode4 (decode-base64) ] }
        [ malformed-base64 ]
    } case ;

PRIVATE>

: decode-base64 ( -- )
    input-stream get (decode-base64) ;

: >base64 ( seq -- base64 )
    binary [ binary [ encode-base64 ] with-byte-reader ] with-byte-writer ;

: base64> ( base64 -- seq )
    binary [ binary [ decode-base64 ] with-byte-reader ] with-byte-writer ;

: >base64-lines ( seq -- base64 )
    binary [ binary [ encode-base64-lines ] with-byte-reader ] with-byte-writer ;
