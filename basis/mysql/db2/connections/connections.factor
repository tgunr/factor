! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data classes.struct
combinators db2.connections db2.result-sets db2.statements
destructors kernel libc locals mysql.db2 mysql.db2.ffi
mysql.db2.lib mysql.db2.result-sets mysql.db2.statements
sequences ;

IN: mysql.db2.connections

TUPLE: mysql-db-connection < db-connection ;

: <mysql-db-connection> ( handle -- db-connection )
    mysql-db-connection new-db-connection ; inline

M: mysql-db-connection dispose*
    [ handle>> mysql_close ] [ f >>handle drop ] bi ;

M: mysql-db-connection prepare-statement*
    mysql-maybe-prepare ;

M: mysql-db-connection bind-sequence
    drop ;

M: mysql-db-connection reset-statement
    [ handle>> mysql-reset-statement ] keep ;

M: mysql-db-connection dispose-statement
    f >>handle drop ;

! M: mysql-db-connection next-bind-index "?" ;

! M: mysql-db-connection init-bind-index ;

! Reference: http://dev.mysql.com/doc/refman/5.6/en/mysql-stmt-fetch.html
M:: mysql-db-connection statement>result-set ( statement -- result-set )
    statement handle>> :> handle
    [
        ! 0 int <ref> malloc-byte-array |free :> buffer0
        256 malloc :> buffer0
        256 :> buffer_length0
        0 ulong <ref> malloc-byte-array |free :> length0
        f bool <ref> malloc-byte-array |free :> error0
        f bool <ref> malloc-byte-array |free :> is_null0

        handle mysql_stmt_execute
        [ handle ] dip mysql-stmt-check-result

        statement handle \ mysql-result-set new-result-set :> result-set

        handle mysql_stmt_result_metadata :> metadata
        metadata field_count>> :> #columns

        #columns MYSQL_BIND malloc-array |free :> binds
        #columns ulong malloc-array |free :> lengths
        #columns bool malloc-array |free :> is_nulls
        #columns bool malloc-array |free :> errors

        binds [
            MYSQL_TYPE_STRING >>buffer_type
            256 malloc >>buffer
            256 >>buffer_length
            is_null0 >>is_null
            length0 >>length
            error0 >>error
        ] map drop
        


        MYSQL_BIND malloc-struct |free
            ! MYSQL_TYPE_LONG >>buffer_type
            MYSQL_TYPE_STRING >>buffer_type
            buffer0 >>buffer
            buffer_length0 >>buffer_length
            is_null0 >>is_null
            length0 >>length
            error0 >>error
        :> bind0


        bind0 result-set bind<<
        
        handle bind0 mysql_stmt_bind_result
            f = [ handle mysql_stmt_error throw ] unless
        handle mysql_stmt_store_result
            0 = [ "mysql store_result error" throw ] unless

        ! handle mysql_stmt_fetch .
        ! bind0 buffer>> alien>native-string .

        ! handle mysql_stmt_fetch .
        ! bind0 buffer>> alien>native-string .

        result-set
    ] with-destructors
    ;
    ! TODO: bind data here before more-rows? calls mysql_stmt_fetch

