! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax io multiline ;
IN: ui.tools.listener.log

ABOUT: "listener-logging"

ARTICLE: "listener-logging" "Logging to the Listener"
There are many situations when using the { $link "ui-walker" } is not feasable
and the primary debugging techinque is to resort to using log statements.
The { $vocab-link "ui.tools.listener.log" } words can be embedded into your code
and will display in the current Listener.

The words work by getting the output stream of a listener and then sending your 
debugging output to the stream. Note the use of { $link with-output-stream* } 
which does not close the stream.

{ $subsections
  .HERE
}
    ;

HELP: .HERE
{ $description Prints the name of the word where .HERE is referenced.
  Use this word to track code flow or to see if code is reached.

  In this example you can readily see the order of execution.
} 
{ $examples
  [=[
USING: ui.tools.listener.log ;
: some-word ( -- )  .HERE ;
: another-word ( -- )  .HERE ; 
: new-word ( -- )
    .HERE 1 2  some-word  another-word  2drop ;
new-word
new-word: 
some-word: 
another-word: 
   ]=] } ;

HELP: HERE.
{ $description Prints the object on top of the stack.
  In this example, you can see the value of tuple at this point
  in the code. 
} 
{ $examples
  [=[
USING: ui.tools.listener.log ;
TUPLE: new-tuple a b c ; 
: new-word ( -- )
    new-tuple new  1 >>a  2 >>b "three" >>c  dup HERE.  drop ;
new-word
new-word: T{ new-tuple { a 1 } { b 2 } { c "three" } }
   ]=] } ;

HELP: HERE.S
{ $description Prints the current datastack. You can push these values or examine them
  in the { $link "ui-inspector" } .
}
{ $examples
  [=[
USING: ui.tools.listener.log ;
: new-word ( -- )
    "This" 1  HERE.S  2drop ;
new-word
   ]=] } ;

HELP: HERE" ! "
{ $description Prints the following string }
{ $examples
  [=[
USING: ui.tools.listener.log ;
: new-word ( -- )  HERE" Kilroy was here" ;
new-word
new-word: Kilroy was here
   ]=]
      } ;
     
          
