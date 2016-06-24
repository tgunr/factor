! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators db2.connections db2.errors
postgresql.db2 postgresql.db2.errors postgresql.db2.ffi
postgresql.db2.lib kernel sequences splitting destructors ;
IN: postgresql.db2.connections

<PRIVATE

TUPLE: postgresql-db-connection < db2-connection ;

: <postgresql-db-connection> ( handle -- db2-connection )
    \ postgresql-db-connection new-db-connection ;

PRIVATE>

M: postgresql-db db>db-connection-generic ( db -- db2-connection )
    {
        [ host>> ]
        [ port>> ]
        [ pgopts>> ]
        [ pgtty>> ]
        [ database>> ]
        [ username>> ]
        [ password>> ]
    } cleave connect-postgres <postgresql-db-connection> ;

M: postgresql-db-connection dispose* ( db2-connection -- )
    [ handle>> PQfinish ] [ f >>handle drop ] bi ;

ERROR: postgresql:sql-error string length ;

M: postgresql-db-connection parse-sql-error
    "\n" split dup length {
        { 1 [ first parse-postgresql-sql-error ] }
        { 3 [
                first3
                [ parse-postgresql-sql-error ] 2dip
                postgresql-location >>location
        ] }
        [ postgresql:sql-error ]
    } case ;
