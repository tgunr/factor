USING: help.markup help.syntax io math strings ;
IN: interpolate

HELP: interpolate
{ $values { "str" string } }
{ $description "String interpolation using named variables and/or stack arguments, writing to the " { $link output-stream } "." }
{ $notes "Stack arguments are numbered from the top of the stack." }
{ $examples
    { $example
        "USING: interpolate ;"
        "\"Bob\" \"Alice\" \"Hi ${1}, it's ${0}.\" interpolate"
        "Hi Bob, it's Alice."
    }
    { $example
        "USING: interpolate namespaces ;"
        "\"Fred\" \"name\" [ \"Hi ${name}\" interpolate ] with-variable"
        "Hi Fred"
    }
} ;

HELP: interpolate>string
{ $values { "str" string } { "newstr" string } }
{ $description "String interpolation using named variables and/or stack arguments, captured as a " { $link string } "." }
{ $notes "Stack arguments are numbered from the top of the stack." } ;

{ interpolate interpolate>string } related-words
