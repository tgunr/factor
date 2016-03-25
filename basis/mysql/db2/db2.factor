! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors combinators db2.connections kernel lexer
mysql.db2.lib namespaces regexp.private sequences vocabs ;

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

: with-MYSQL ( MYSQL -- )
    <mysql-db>
        over host>> >>host
        over user>> >>user
        over passwd>> >>password
    db>db-connection-generic
    db-connection set
    drop
    ;

SYNTAX: mysql{ CHAR: } lexer get take-until suffix! ;

