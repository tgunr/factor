! File: colors
! Version: 0.1
! DRI: Dave Carlton
! Description: Extend colors vocab
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel math math.parser prettyprint sequences
sorting sorting.human ui.tools.operations ;
IN: colors

: nearest-color ( hex -- color value )
    unclip drop hex>
    named-colors
    [ dup named-color color>hex ] map>alist
    [ second unclip drop hex> number>string
      [ second unclip drop hex> number>string ] dip
      human<=>
    ] sort
    [ second unclip drop hex> over > ] map-find
    2nip  [ first ] keep second 
;
    
: nc ( hex -- ) nearest-color . com-copy-object ; 
