! File: crlf.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: Another fine Factor file!
! Copyright (C) 2018 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: io kernel sequences splitting namespaces ;
IN: io.crlf

SYMBOL: nonl
: nonl-t ( -- )   t nonl set ;
: nonl-f ( -- )   f nonl set ;
