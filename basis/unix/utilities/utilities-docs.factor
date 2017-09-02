! Copyright (C) 2017 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.accessors alien.c-types alien.data
alien.strings alien.syntax arrays environment help.markup
help.syntax io.encodings.utf8 kernel libc system unix.ffi
unix.utilities vocabs sequences ;
IN: unix.utilities

HELP: advance
{ $values
    { "void*" c-ptr }
}
{ $description "Advances a pointer by native cell size" } ;

HELP: alien>strings
{ $values
    { "alien" c-ptr } { "encoding" "encoding descriptor e.g. utf8" }
    { "strings" "{ string }|f" }
}
{ $description "Extracts strings from an array of pointers to C strings" }
{ $see-also
  alien>string
  strings>alien
} ;

HELP: more?
{ $values
    { "alien" c-ptr }
    { "?" boolean }
}
{ $description "Returns dereferenced value of alien or f" } ;

HELP: strings>alien
{ $values
    { "strings" sequence } { "encoding" "encoding descriptor e.g. utf8" }
    { "array" "void*-array{" }
}
{ $description "Takes a sequence of strings, encodes them, and creates an void*-array{ of C strings" } 
{ $see-also
  alien>string
  strings>alien
} ;

ARTICLE: "unix.utilities" "unix.utilities"
{ $vocab-link "unix.utilities" }
;

ABOUT: "unix.utilities"
