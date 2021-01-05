! Copyright (C) 2021 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel sequences strings ;
IN: color-picker

ABOUT: "color-picker"

ARTICLE: "color-picker" "GUI Window to select a color"
"The color-picker permits the user to select a color and display the values in RGB, HEX, and HSL."
" Conversion to other formats is easily done using "
 { $vocab-link "colors" }  "."  ;

HELP: <color-model>
{ $values
    { "model" null }
}
{ $description "" } ;

HELP: <color-pick>
{ $values
    { "gadget" null }
}
{ $description "" } ;

HELP: <color-picker>
{ $values
    { "gadget" null }
}
{ $description "" } ;

HELP: <color-preview>
{ $values
    { "model" null }
    { "gadget" null }
}
{ $description "" } ;

HELP: <color-slider>
{ $values
    { "model" null }
    { "gadget" null }
}
{ $description "" } ;

HELP: <color-sliders>
{ $values
    { "gadget" null } { "model" null }
}
{ $description "" } ;

HELP: <color-value>
{ $values
    { "model" null }
    { "gadget" null }
}
{ $description "" } ;

HELP: color-picker-window
{ $description "" } ;

HELP: color-preview
{ $class-description "" } ;

HELP: color-value
{ $class-description "" } ;

HELP: color>str
{ $values
    { "seq" sequence }
    { "str" string }
}
{ $description "" } ;

HELP: pick
{ $values
    { "gadget" null }
}
{ $description "" } ;

