! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax strings ui.baseline-alignment
ui.gadgets.labels ui.gadgets.worlds ;
IN: help.tutorial.ui

ABOUT: "ui-tutorial"

ARTICLE: "ui-tutorial" "UI Tutorial" 
Introduction This tutorial will walk you through the creation of a simple
graphical user interface (GUI) using Factor's UI library. The
tutorial assumes that you have a basic understanding of Factor
and are familiar with the Factor Listener. If you are not, you
should go thru the { $link "tour" } first.

The UI Library

The UI library is a collection of words that allow you to
create GUI applications. The UI library is not loaded by
default. You can load it by typing the following at the
Listener prompt:
{ $code "
USE: ui
" }
$nl

The UI library is a large library. It contains many words
that you will not need for simple GUI applications. This
tutorial will only cover a small subset of the UI library.
You can find more information about the UI library in the
{ $link "ui" } article.

{ $heading 
The Hello World Application
}

{ $subsections
  "ui-world"
  "ui-window"
  ! "ui-gadgets"
  ! "ui-layout"
  ! "ui-appearance"
  ! "ui-menus"
  ! "ui-events"
  ! "ui-words"
}
    ;

HELP: (world)
{ $description "Create a UI World" }
{ $see-also  "(window)" }
{ $notes "A UI World is a container for UI Gadgets." }
{ $values { "world" world } }
{ $examples
  { $code "
USING: ui ;
(world)
" }
}
    ;

HELP: (window)
{ $description "Create a UI Window" }
{ $see-also  "(world)" }
{ $notes "A UI Window is a container for UI Gadgets." }
{ $values { "window" world } }
{ $examples
  { $code "
USING: ui ;
(window)
" }
}
    ;

HELP: window-titled
{ $description "Create a UI Window with a title" }
{ $notes "The title is a string that will be displayed in the title bar of the window." }
{ $values { "title" string } { "window" world } }
{ $examples
  { $code "
USING: ui ;
\"Hello World\" window-titled
" }
}
{ $see-also  "ui-tutorial" }
    ;


ARTICLE: "ui-window" "UI Window"
Now lets create a UI Window, look at { $link (window) } 

You will note that a UI Window is just a UI World. For clarity, we create the word { $link (window) } although { $link (world) } could also be used.

As it stands the window, if it were to be opened, would be empty. We need to add some gadgets to the window.

Lets define a word that will create a window with a title, look at { $link window-titled }


{ $code "
! create a window with a title
: window-titled ( title -- world )
    (window) swap >>title ;
" }

First we will add a simple gadget that we can use to display text on the window.

Take a look at { $link label } to see the properties of a label. As you can see, a label is a subclass of { $link aligned-gadget }  with the properties { $snippet text } and { $snippet font } property. We will use the word { $link <label> } to create a default set of attributes for the label.


    ;
