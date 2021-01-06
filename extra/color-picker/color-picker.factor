! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors colors.constants formatting kernel math
math.vectors models models.arrow models.product models.range
namespaces sequences splitting ui ui.gadgets ui.gadgets.borders
ui.gadgets.editors ui.gadgets.labeled ui.gadgets.labels
ui.gadgets.packs ui.gadgets.panes ui.gadgets.sliders ui.gadgets.tracks
ui.pens.solid ;
IN: color-picker

! Simple example demonstrating the use of models.

TUPLE: color-preview < gadget ;
TUPLE: color-value < editor ;

: <color-preview> ( model -- gadget )
    color-preview new
        swap >>model
        { 200 200 } >>dim ;

: <color-value> ( model -- gadget )
    color-value new
    swap >>model ;

M: color-value model-changed
    swap value>> " " split last
    swap set-editor-string
    ;
    
M: color-preview model-changed
    swap value>> >>interior relayout-1 ;

: <color-model> ( model -- model )
    [ B first3 [ 256 /f ] tri@ 1 <rgba> <solid> ] <arrow> ;

: (label) ( name -- gadget )
    "    " <label>
    swap named-color <solid> >>interior
    { 800 400 } >>dim
    ;

: <color-slider> ( model color -- gadget )
    <shelf>
    swap (label) add-gadget
    swap horizontal <slider> 1 >>line add-gadget ;

: <color-sliders> ( -- gadget model )
    3 [ 0 0 0 255 1 <range> ] replicate
    [
        { "red" "green" "blue" }
        <filled-pile> { 5 5 } >>gap
        [ <color-slider> add-gadget ] 2reduce ]
    [ [ range-model ] map <product> ]
    bi ;

: color>str ( seq -- str )
    vtruncate v>integer first3 3dup "%d %d %d #%02x%02x%02x" sprintf ;

: <color-picker> ( -- gadget )
    vertical <track> { 5 5 } >>gap
    <color-sliders>
    [ f track-add ]
    [
        [ <color-model> <color-preview> 1 track-add ]
        [ [ color>str ] <arrow> <label-control>
          { 240 20 } >>pref-dim
          f track-add 
        ] bi
    ] bi* ;

 
SYMBOL: testg

: test ( --  )
    <color-picker> dup testg set
    gadget. ;
    ! world-attributes new
    ! { 400 400 } >>pref-dim 
    ! "Spacer Test" >>title
    ! open-window ;

MAIN-WINDOW: color-picker-window { { title "Color Picker" } }
    <color-picker> >>gadgets ;

test
