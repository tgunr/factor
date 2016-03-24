! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.data ascii byte-arrays byte-vectors grouping io
io.encodings.binary io.files io.streams.string kernel math math.parser
namespaces sequences ;

IN: tools.hexdump

<PRIVATE

SYMBOL: hexdump-group 1 hexdump-group set
SYMBOL: hexdump-address f hexdump-address set

: write-header ( len -- )
    hexdump-address get
    [ "Address: 0x" write
      hexdump-address get  alien-address >hex
      " " append write 
    ] when
    "Length: " write
    [ number>string write "d, " write ]
    [ >hex write "h" write nl ] bi ;

: write-offset ( lineno -- )
    hexdump-address get
    [ "0x" write
      16 * hexdump-address get alien-address +
      >hex  16 CHAR: 0 pad-head
      " " append  write ] 
    [ 16 * >hex 8 CHAR: 0 pad-head  " " append write ]
    if ;

: group-digits ( seq -- seq )
    hexdump-group get dup [ ] [ drop 1 ] if
    group
    [ concat " " append ] { } map-as ;

: >hex-digit ( digit -- str )
    >hex 2 CHAR: 0 pad-head ;

: >hex-digits ( bytes -- str )
    [ >hex-digit ] { } map-as 
    group-digits concat
    32 CHAR: \s pad-tail ;

: >ascii ( bytes -- str )
    [ [ printable? ] keep CHAR: . ? ] "" map-as ;

: write-hex-line ( bytes lineno -- )
    write-offset [ >hex-digits write ] [ >ascii write ] bi nl ;

: hexdump-bytes ( bytes -- )
    [ length write-header ]
    [ 16 <groups> [ write-hex-line ] each-index ] bi ;

: hexdump-set-address ( n -- )  hexdump-address set ;

PRIVATE>

GENERIC: hexdump. ( byte-array -- )

M: byte-array hexdump. f hexdump-set-address hexdump-bytes ;

M: byte-vector hexdump. f hexdump-set-address hexdump-bytes ;

GENERIC: .nhexdump ( n obj -- )
M: alien .nhexdump  dup hexdump-set-address  swap memory>byte-array hexdump-bytes ;

: hexdump ( byte-array -- str )
    [ hexdump. ] with-string-writer ;

: hexdump-file ( path -- )
    binary file-contents hexdump. ;

: hexdump1 ( -- )  1 hexdump-group set ;
: hexdump2 ( -- )  2 hexdump-group set ;
: hexdump4 ( -- )  4 hexdump-group set ;
: hexdump8 ( -- )  8 hexdump-group set ;
