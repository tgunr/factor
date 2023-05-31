! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel lexer math.parser sequences strings multiline ;
IN: cnc.gcode.parser

! <program>        ::= {<line>}
! <line>           ::= <command> <parameters> '\n'
! <command>        ::= 'G0' | 'G1'
! <parameters>     ::= {<parameter>}
! <parameter>      ::= <axis_parameter> | <feedrate_parameter>
! <axis_parameter> ::= ('X' | 'Y' | 'Z') <number>
! <feedrate_parameter> ::= 'F' <number>
! <number>         ::= <digit> { <digit> } [ '.' { <digit> } ]
! <digit>          ::= '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
                   
: number ( -- parser )
  token string>number ;

: command ( -- parser )
  "G" [ number ] sequence ;

: axis ( char -- parser )
  swap [ [ char = ] keep number ] sequence ;

: line ( -- parser )
  command [ "X" axis "Y" axis "Z" axis "F" axis ] 4 sequence ;

: gcode ( string -- command )
  line scan ;
