IN: ui.pens
USING: help.markup help.syntax kernel ui.gadgets ;

HELP: draw-interior
{ $values { "interior" object } { "gadget" gadget } } 
{ $contract "Draws the interior of a gadget by making OpenGL calls. The " { $snippet "interior" } " slot may be set to objects implementing this generic word." } ;

HELP: draw-boundary
{ $values { "boundary" object } { "gadget" gadget } } 
{ $contract "Draws the boundary of a gadget by making OpenGL calls. The " { $snippet "boundary" } " slot may be set to objects implementing this generic word." } ;

ARTICLE: "ui-pen-protocol" "UI pen protocol"
"The " { $snippet "interior" } " and " { $snippet "boundary" } " slots of a gadget facilitate easy factoring and sharing of drawing logic. Objects stored in these slots must implement the pen protocol:"
{ $subsection draw-interior }
{ $subsection draw-boundary }
"The default value of these slots is the " { $link f } " singleton, which implements the above protocol by doing nothing."
$nl
"Some other pre-defined implementations:"
{ $vocab-subsection "ui.pens.gradient" }
{ $vocab-subsection "ui.pens.image" }
{ $vocab-subsection "ui.pens.polygon" }
{ $vocab-subsection "ui.pens.solid" }
{ $vocab-subsection "ui.pens.tile" }
"Custom implementations must follow the guidelines set forth in " { $link "ui-paint-custom" } "." ;