! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors colors.constants formatting kernel math
math.functions math.vectors models models.arrow models.product
models.range sequences splitting ui ui.gadgets
ui.gadgets.borders ui.gadgets.editors ui.gadgets.labeled
ui.gadgets.labels ui.gadgets.packs ui.gadgets.sliders
ui.gadgets.tracks ui.pens.solid ;
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
    [ first3 [ 256 /f ] tri@ 1 <rgba> <solid> ] <arrow> ;

: <color-slider> ( model -- gadget )
    horizontal <slider> 1 >>line ;

: <color-sliders> ( -- gadget model )
    3 [ 0 0 0 255 1 <range> ] replicate
    [ <filled-pile> { 5 5 } >>gap [ <color-slider> add-gadget ] reduce ]
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
        [ [ color>str ] <arrow> <label-control> f track-add 
        ] bi
    ] bi* ;

: <color-pick> ( -- gadget )
    vertical <track> { 5 5 } >>gap
    <color-sliders> [ f track-add ] dip
    [ <color-model> <color-preview> 1 track-add ] keep
    [let
     [ color>str ] <arrow> <label-control> :> vlabel
     vlabel f track-add :> t
     t <color-value> :> elabel
     elabel vlabel model>> add-connection
     t elabel f track-add
    ]
    ;


: pick ( -- gadget )
    <pile>
    { 200 200 } >>dim 
    { 4 4 } >>gap 

    <shelf>
    "  red" <label>
    COLOR: red <solid> >>interior
    { 800 400 } >>dim add-gadget
    128 0 0 255 1 <range> horizontal <slider> 1 >>line add-gadget
    { 2 2 } <border> { 20 20 } >>fill
    add-gadget
    

    <shelf>
    128 0 0 255 1 <range> horizontal <slider> 1 >>line "green" <labeled-gadget>
    horizontal >>orientation add-gadget
    add-gadget
    

    <shelf>
    " blue" <label>
    COLOR: blue <solid> >>interior
    { 400 400 } >>dim add-gadget
     128 0 0 255 1 <range> horizontal <slider> 1 >>line add-gadget
    add-gadget
    
    { 10 10 }  <border>
    ;

: pickw ( -- gadget )
    pick dup
    "Picker" open-window ;


MAIN-WINDOW: color-picker-window { { title "Color Picker" } }
    <color-picker> >>gadgets ;
