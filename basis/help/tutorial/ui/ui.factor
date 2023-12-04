! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel ui ui.gadgets ui.gadgets.editors
ui.gadgets.labels ui.gadgets.tracks ui.gadgets.worlds ui.tools.common
;
IN: help.tutorial.ui

! : layout-gadget ( -- track x x  )
!     vertical <track>  { 5 5 } >>gap  with-lines 
!     "{ 20 0 } <border>" <label>
!     ! { 20 20 } "blue" named-color <colored-border> f track-add
    ! "red" <model-field>  
    ! { 2 2 } "green" named-color <colored-border>
    ! f track-add 
    ! swap [ editor-string . ] <arrow> <label-control>
    ! f track-add
    ! ;

: window1-gadget ( -- world )
    <world-attributes> "Layout 1" >>title ; 

: window2-gadget ( -- world )
    <world-attributes> "Layout 2" >>title
    { 640 480 } >>pref-dim ;

! create a layout with two labels in a vertical track
: l2 ( -- layout )
    vertical <track>  
    "Label 1" <label> f track-add
    "Label 2" <label> f track-add
    ;

! create a layout with two labels in a horizontal track
: l3 ( -- layout )
    horizontal <track>  
    "Label 1" <label> f track-add
    "Label 2" <label> f track-add
    ;

! add a border to a layout
: l4 ( -- layout )
    vertical <track>  
    "Label 1" <label> { 2 2 } <border> f track-add
    "Label 2" <label> { 2 2 } <border> f track-add
    ;

: set-gadgets ( layout window -- )
    swap >>gadgets f swap open-window ;

: use-layout1 ( layout -- )
    window1-gadget set-gadgets ;
    
: use-layout2 ( layout -- )
    window2-gadget set-gadgets ;
