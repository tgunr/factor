! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math opengl sequences ui.images ui.pens colors ;
IN: skov.basis.ui.pens.image

! Image pen
TUPLE: image-pen image fill? ;

: <image-pen> ( image -- pen ) f image-pen boa ;

M: image-pen draw-interior
    [ dim>> ] [ [ image>> ] [ fill?>> ] bi ] bi*
    [ draw-scaled-image ] [
        [ image-dim [ - 2 /i ] 2map ] keep
        '[ _ draw-image ] with-translation
    ] if ;

M: image-pen pen-pref-dim nip image>> image-dim ;

M: image-pen pen-background
     2drop transparent ;
