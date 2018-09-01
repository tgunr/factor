! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.crlf kernel namespaces ;
IN: io.streams.plain

MIXIN: plain-writer

M: plain-writer stream-nl
    nonl get
    [ drop ]
    [ CHAR: \n swap stream-write1 ] if ;
