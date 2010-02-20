! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax arrays kernel game.input namespaces
classes bit-arrays sequences vectors x11 x11.xlib ;
IN: game.input.linux

LIBRARY: xlib
FUNCTION: int XQueryKeymap ( Display* display, char[32] keys_return ) ;

SINGLETON: linux-game-input-backend

linux-game-input-backend game-input-backend set-global

M: linux-game-input-backend (open-game-input)
    ;

M: linux-game-input-backend (close-game-input)
    ;

M: linux-game-input-backend (reset-game-input)
    ;

M: linux-game-input-backend get-controllers
    { } ;

M: linux-game-input-backend product-string
    drop "" ;
     
M: linux-game-input-backend product-id
    drop f ;
     
M: linux-game-input-backend instance-id
    drop f ;
     
M: linux-game-input-backend read-controller
    drop controller-state new ;
     
M: linux-game-input-backend calibrate-controller
    drop ;
     
M: linux-game-input-backend vibrate-controller
    3drop ;

CONSTANT: x>hid-bit-order {
    0 0 0 0 0 0 0 0 
    0 41 30 31 32 33 34 35 
    36 37 38 39 45 46 42 43 
    20 26 8 21 23 28 24 12 
    18 19 47 48 40 224 4 22 
    7 9 10 11 13 14 15 51 
    52 53 225 49 29 27 6 25 
    5 17 16 54 55 56 229 85 
    226 44 57 58 59 60 61 62 
    63 64 65 66 67 83 71 95 
    96 97 86 92 93 94 87 91 
    90 89 99 0 0 0 68 69 
    0 0 0 0 0 0 0 88 
    228 84 70 0 0 74 82 75 
    80 79 77 81 78 73 76 127 
    129 128 102 103 0 72 0 0 
    0 0 227 231 0 0 0 0 
    0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 
    0 0 0 0 0 0 0 0 
}
     
: x-bits>hid-bits ( bit-array -- bit-array )
        256 iota [ 2array ] { } 2map-as [ first ] filter [ second ] map
        x>hid-bit-order [ nth ] curry map
        256 <bit-array> swap [ t swap pick set-nth ] each ;
        
M: linux-game-input-backend read-keyboard
        dpy get 256 <bit-array> [ XQueryKeymap drop ] keep
        x-bits>hid-bits keyboard-state boa ;
     
M: linux-game-input-backend read-mouse
    0 0 0 0 2 <vector> mouse-state boa ;
     
M: linux-game-input-backend reset-mouse
    ;
