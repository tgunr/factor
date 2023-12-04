! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors colors help.markup help.syntax kernel ui ui.gadgets
ui.gadgets.labels ui.gadgets.tracks ui.gadgets.worlds ui.pens.solid
ui.theme ;

IN: ui.gadgets.borders

TUPLE: colored-border < border { color initial: contents-color } ;

: <colored-border> ( child gap color -- border )
    [ colored-border new-border ] 2dip  [ >>size ] dip  <solid> >>interior  ;

IN: help.tutorial.ui

! create a UI World
: (world) ( -- world )
    <world-attributes> <world> ; 

! create a window
: (window) ( -- world )
    (world) ;

! create a window with a title
: window-titled ( title -- window )
    (window) swap >>title ;

: window1-gadget ( -- world )
    "Layout 1" window-titled ;

! create a window with a title and a preferred dimension
: window2-gadget ( -- world )
    (window) "Layout 2" >>title
    { 640 480 } >>pref-dim ;

! create a vertical track
: vtrack ( -- track )
    vertical <track> ;

! create a horizontal track
: htrack ( -- track )
    horizontal <track> ;

! create a layout with two labels in a vertical track
: l2 ( -- layout )
    vtrack  
    "Label 1" <label> f track-add
    "Label 2" <label> f track-add
    ;

! create a layout with two labels in a horizontal track
: l3 ( -- layout )
    htrack  
    "Label 1" <label> f track-add
    "Label 2" <label> f track-add
    ;

! add a border to a layout
: l4 ( -- layout )
    vtrack
    "Label 1" <label> { 2 2 } <border> f track-add
    "Label 2" <label> { 2 2 } <border> f track-add
    ;

! add colored border
: l5 ( -- layout )
    vtrack
    "Label 1" <label> { 2 2 } "red" named-color <colored-border> f track-add
    "Label 2" <label> { 2 2 } "blue" named-color <colored-border> f track-add
    ;

: set-gadgets ( layout window -- )
    swap f track-add  open-world-window ;

: use-layout1 ( layout -- )
    window1-gadget set-gadgets ;
    
: use-layout2 ( layout -- )
    window2-gadget set-gadgets ;

