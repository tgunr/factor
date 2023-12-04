! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: help.syntax
    ;
IN: help.tutorial.ui

ABOUT: "ui-tutorial"

ARTICLE: "ui-tutorial" "UI Tutorial" "Introduction This tutorial will walk you through the creation of a simple
graphical user interface (GUI) using Factor's UI library. The
tutorial assumes that you have a basic understanding of Factor
and are familiar with the Factor Listener. If you are not, you
should read the Factor manual first."
$nl        
"The UI Library" 
"The UI library is a collection of words that allow you to
create GUI applications. The UI library is not loaded by
default. You can load it by typing the following at the
Listener prompt:"
           "USE: ui"
            "The UI library is a large library. It contains many words
            that you will not need for simple GUI applications. This
            tutorial will only cover a small subset of the UI library.
            You can find more information about the UI library in the
            Factor manual."
        
        "The Hello World Application" 
            "The first example is a simple Hello World application. It
            displays a window with a button. When you click the button,
            the application displays a message box with the text Hello
            World."
            "The first step is to create a window. The window is created
            by calling the word <b>make-window</b>. The word <b>make-window</b>
            takes a sequence of words as an argument. The sequence of
            words is called a <b>layout</b>. The layout is a list of
            words that control the arrangement of the window. The list
            of words is called a <b>layout</b>. "
    ;
