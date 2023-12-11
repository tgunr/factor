! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax math.rectangles strings
ui.baseline-alignment ui.gadgets ui.gadgets.borders ui.gadgets.labels
ui.gadgets.packs ui.gadgets.tracks ui.gadgets.worlds ;
IN: help.tutorial.ui

ABOUT: "ui-tutorial"

HELP: (world)
{ $description "Create a UI World" }
{ $notes "A UI World is a container for UI Gadgets." }
{ $values { "world" world } }
{ $see-also (window) window-titled }  
{ $examples
  { $code "
USING: ui ;
(world)
" }
}
    ;

HELP: (window)
{ $description "Creates a UI Window" }
{ $notes "A UI Window is a container for UI Gadgets." }
{ $see-also  (world) }
{ $notes "A UI Window is a container for UI Gadgets." }
{ $values { "world" world } }
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


ARTICLE: "ui-tutorial" "UI Tutorial" 
Introduction This tutorial will walk you through the creation of a simple
graphical user interface (GUI) using Factor's UI library. The
tutorial assumes that you have a basic understanding of Factor
and are familiar with the Factor Listener. If you are not, you
should go thru the { $link "tour" } first.

{ $heading Setting Up }
We will start by setting up the Listener.
Click on the following code to send it to the Listener:

{ $code "
USING: help.markup help.syntax strings ui.baseline-alignment
ui.gadgets.labels ui.gadgets.tracks ui.gadgets.worlds help.tutorial.ui ;
" }

$nl
Whenever you see the phrase { $strong "look at" } followed by a link click on it to see the documentation for that word. Then use the { $snippet "Back" } menu or use a { $link "ui-browser" } key to return to this help topic.

{ $heading "The UI Library" }

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
  "ui-window"
  "ui-gadgets"
  "ui-layout"
  "ui-layout1"
  ! "ui-appearance"
  ! "ui-menus"
  ! "ui-events"
  ! "ui-words"
}
    ;

ARTICLE: "ui-window" "UI Window"
Now lets create a UI Window, look at { $link (window) } 

You will note that a UI Window is just a UI World. For clarity, we created the word { $link (window) } although { $link (world) } could also be used.

Lets create a window with a title, look at { $link window-titled }

{ $code "
    \"Layout\" window-titled 
" }

You now have a UI Window with a title on the stack. At this point the window, if it were to be opened, would be empty. We need to add dimensions before opening the window.

{ $code "
    { 200 200 } >>pref-dim 
" }

Now the widnow is ready to be opened.

{ $code "
open-world-window
" }

Close the blank window and proceed to add some { $link "ui-gadgets" } .
    ;

ARTICLE: "ui-gadgets" "UI Gadgets"
The fundamental element in the UI library is the { $link gadget } which is based on a { $link rect } . If you look closely and follow the parent class of a { $link world } you will find it is a type of { $link gadget } .     
$nl
{ $see gadget }
$nl
We use gadgets to add UI elements to a { $link "ui-layout" }   which in turn is added to a window.
    ;

ARTICLE: "ui-layout" "UI Layouts"
The term { $snippet layout } is used to describe a collection of UI elements. The UI library has many different types of gadgets which can be added to a layout. Gadgets can also be extented and created as subclasses of a { $link gadget } . Typically in the code you will define a word to create a layout.

In this article we will create a simple application that will display text on the screen.

Take a look at { $link label } to see the properties of a label. As you can see, a label is a subclass of { $link aligned-gadget }  with the properties { $snippet text } and { $snippet font } . We will use the word { $link <label> } to create a default set of attributes for the label.

First, create a window with a title.
{ $code "
\"Labels\" window-titled { 200 200 } >>pref-dim
" }
$nl

Now create a simple label with the word { $link <label> }
{ $code "
 \"Label\" <label>  
" } 
$nl

We can now add the label to the window with the { $link track-add } word. Note the { $snippet "f" } passed to the word { $link track-add } , this is a flag that indicates that the track should occupy its preferred dimension.

{ $code "
 f track-add 
" } 
$nl

And open the window.
{ $code "
 open-world-window 
" } 
$nl

The should be open now but its not very good. Lets add some attributes to make it look better.

There is already a word { $link window-sized } in this tutorial to create a window with a fixed size. Lets use it to create a windoow.
{ $code "
 window-sized 
" } 
$nl

Now create a label with the word { $link <label> }
{ $code "
 \"Label\" <label>  
" } 
$nl

Lets add some attributes to make it look better. We can add a border to the label with the word { $link <border> } . A border needs a width and height.
{ $code "
 { 8 8 } <border> 
" } 
$nl

The lable is embedded in the border object. Now add the border to the window with the { $link track-add } word.
{ $code "
 f track-add 
" } 
$nl
And open the window.
{ $code "
 open-world-window 
" } 
$nl

The label should now have a nice 8X8 border around it.

{ $heading "More Layouts" }
We have been using the word { $link <track> } to contain a bunch of UI elements. There are several other words that can be used to create different types of layouts. You can see them listed at { $link "ui-layouts" }   
$nl

There is another similar word { $link <pack> } which can beused to add objects to a layout. For now, we will focus on the { $link <track> } word and the use of { $link pack } wprds to organize a layout.  
$nl

To learn more about different types of layouts, take a look at the following words:

{ $list 
  { $link "ui-grid" }
  { $link "ui-frame" }
  { $link "ui-book" }  
}
    ;

ARTICLE: "ui-layout1" "UI Layout Example"
Now that we have the fundamental concepts of UI Layouts, lets see how we can add some UI elements to our window. Lets create a layout with 3 rows and 2 columns. To do so we will need both vertical tracks and horizontal tracks. There are two words that can be used to create these. We will use the word { $link vtrack } for vertical and { $link htrack } for horizontal.
$nl

Lets create a window world to hold our layout.
{ $code "
 \"Rows\" window-titled { 200 200 } >>pref-dim 
" } 

Now create a vertical track with the word { $link vtrack } that contains a horizontal track with the word { $link htrack } that contains a label with the word { $link <label> } .

{ $code "
 vtrack
 htrack
 \"label 1\" <label> { 8 8 } <border> f track-add
 \"label 2\" <label> { 8 8 } <border> f track-add
" }
$nl

On the stack we now have our window world and two tracks. The first is a vertical track and currently empty. The second is a horizontal track that contains two labels.
Lets put them in the vertical track.
{ $code "
 f track-add
" }
$nl

Now for thee second row we will create another horizontal track with 2 labels.
{ $code "
 htrack
 \"label 3\" <label> { 8 8 } <border> f track-add
 \"label 4\" <label> { 8 8 } <border> f track-add
" }
$nl

Add it to the first row vertical track.
{ $code "
 f track-add
" }
$nl

Add the track to the window and open the window.
{ $code "
 f track-add
 open-world-window 
" } 

    ;

ARTICLE: "ui-grid" "UI Grids"
    ;

ARTICLE: "ui-frame" "UI Frame"
    ;

ARTICLE: "ui-book" "UI Book"
    ;




