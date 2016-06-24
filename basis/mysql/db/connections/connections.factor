! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators db2.connections destructors kernel
mysql.db mysql.db.ffi mysql.db.lib ;
IN: mysql.db.connections

TUPLE: mysql-db-connection < db2-connection ;

: <mysql-db-connection> ( handle -- db2-connection )
    mysql-db-connection new-db-connection ; inline

M: mysql-db db>db-connection-generic ( db -- db2-connection )
    {
        [ host>> ]
        [ username>> ]
        [ password>> ]
        [ database>> ]
        [ port>> ]
    } cleave mysql-connect <mysql-db-connection> ;

M: mysql-db-connection dispose*
    [ handle>> mysql_close ] [ f >>handle drop ] bi ;
