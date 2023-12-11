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

! define a window with a title
: window-titled ( title -- window )
    (window) swap >>title ;

: window-plain ( -- world )
    "Layout" window-titled ;

! create a window with a title and a preferred dimension
: window-sized ( -- world )
    (window) "Layout" >>title
    { 640 480 } >>pref-dim ;

! create a vertical track
: vtrack ( -- track )
    vertical <track> ;

! create a horizontal track
: htrack ( -- track )
    horizontal <track> ;

! create a layout with a label in a vertical track
: layout1 ( -- layout )
    ! vtrack  
    "Label 1" <label> ! f track-add
    ;

! create a layout with two labels in a verical track
: layout2-v ( -- layout )
    vtrack  
    "Label 1" <label> f track-add
    "Label 2" <label> f track-add
    ;

! create a layout with two labels in a horizontal track
: layout2-h ( -- layout )
    htrack  
    "Label 1" <label> f track-add
    "Label 2" <label> f track-add
    ;

! add a border to a layout
: layout2-v-border ( -- layout )
    vtrack
    "Label 1" <label> { 8 8 } <border> f track-add
    "Label 2" <label> { 8 8 } <border> f track-add
    ;

! add a border to a layout
: layout2-h-border ( -- layout )
    vtrack
    "Label 1" <label> { 8 8 } <border> f track-add
    "Label 2" <label> { 8 8 } <border> f track-add
    ;

! add colored border
: layout2-v-color ( -- layout )
    vtrack
    "Label 1" <label> { 8 8 } "red" named-color <colored-border> f track-add
    "Label 2" <label> { 8 8 } "blue" named-color <colored-border> f track-add
    ;

! add a layout to a window and open it
: set-gadgets ( layout window -- )
    swap f track-add  open-world-window ;

! create a window with a layout
: layout-window ( layout -- )
    window-sized set-gadgets ;

: rows-example ( -- )
    "Rows" window-titled
    vtrack
    htrack
    "Label 1" <label> { 8 8 } <border> f track-add
    "Label 2" <label> { 8 8 } <border> f track-add
    f track-add
    open-world-window
    ;

    

