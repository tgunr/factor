! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data classes.struct
combinators db2.result-sets destructors kernel locals
mysql.db2.connections mysql.db2.ffi mysql.db2.lib libc
specialized-arrays sequences ;
IN: mysql.db2.result-sets

SPECIALIZED-ARRAY: MYSQL_BIND
SPECIALIZED-ARRAY: bool
SPECIALIZED-ARRAY: ulong

TUPLE: mysql-result-set < result-set bind #columns nulls lengths errors ;

M: mysql-result-set dispose ( result-set -- )
    ! the handle is a stmt handle here, not a result_set handle
    [ mysql-free-statement ]
    [ f >>handle drop ] bi ;

M: mysql-result-set #columns ( result-set -- n ) #columns>> ;

M: mysql-result-set advance-row ( result-set -- ) drop ;

M: mysql-result-set column
    B
    3drop f
    ;

M: mysql-result-set more-rows? ( result-set -- ? )
    handle>> [
        mysql_stmt_fetch {
            { 0 [ t ] }
            { MYSQL_NO_DATA [ f ] }
            { MYSQL_DATA_TRUNCATED [ "truncated, bailing out.." throw ] }
        } case
    ] [
        f
    ] if* ;


