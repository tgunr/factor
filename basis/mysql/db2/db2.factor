! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays combinators db2.connections kernel
mysql.db2.connections mysql.db2.lib parser quotations sequences
namespaces vocabs ;

IN: mysql.db2

{
    "mysql.db2.ffi"
    "mysql.db2.lib"
    "mysql.db2.connections"
    "mysql.db2.statements"
    "mysql.db2.result-sets"
} [ require ] each

TUPLE: mysql-db host user password database port socket flag ;

: <mysql-db> ( -- db )
    f f f f 0 f 0 mysql-db boa ;

M: mysql-db db>db-connection-generic 
    {
        [ host>> ]
        [ user>> ]
        [ password>> ]
        [ database>> ]
        [ port>> ]
        [ socket>> ]
        [ flag>> ]
    } cleave mysql-real-connect <mysql-db-connection>
    ;

! SYNTAX: mysql-args{ CHAR: }
!     lexer get take-until
!     string-trim-tail
!     " " split
!     suffix! ;

SYNTAX: mysql-args{ \ }
    [ >array ] parse-literal
    ;

GENERIC: new ( args <mysql-db> -- <mysql-db-connection> )

M: mysql-db new
    swap
    { >>host >>user >>password >>database >>port >>socket >>flag }
    over length head
    [ 1quotation curry call( -- ) ] 2each
    db>db-connection-generic
    dup db2-connection set
    ;

: testdb ( -- mysql-db )
    { "localhost" "root" "" "factor-test" }
    <mysql-db> new
    ;
