! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.


USING: accessors alien.c-types alien.data arrays assocs
classes.struct combinators combinators.smart db2 db2.binders
db2.connections db2.queries db2.result-sets db2.statements
db2.types db2.utils destructors kernel libc locals make math
math.parser math.ranges multiline mysql.db2.ffi mysql.db2.lib
mysql.db2.result-sets mysql.db2.statements namespaces
orm.persistent orm.queries sequences ;

IN: mysql.db2.connections

TUPLE: mysql-db-connection < db2-connection ;

: <mysql-db-connection> ( handle -- db2-connection )
    mysql-db-connection new-db-connection ; inline

: MYSQL ( -- MYSQL )
    db2-connection get handle>> ;

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

SYMBOL: mysql-counter

: next-bind ( -- string )
    mysql-counter [ inc ] [ get ] bi
    number>string "$" prepend ;

M: mysql-db-connection n>bind-sequence ( n -- sequence )
    [1,b] [ number>string "$" prepend ] map ;

M:: mysql-db-connection continue-bind-sequence ( previous n -- sequence )
    previous 1 +
    dup n +
    [a,b] [ number>string "$" prepend ] map ;

ERROR: db-assigned-keys-not-empty assoc ;
: check-db-assigned-assoc ( assoc -- assoc )
    dup [ first column-primary-key? ] filter
    [ db-assigned-keys-not-empty ] unless-empty ;

M: mysql-db-connection insert-db-assigned-key-sql
    [ <statement> ] dip
    [ >persistent ] [ ] bi {
        [ drop [ "select " "add_" ] dip table-name>> trim-double-quotes 3append quote-sql-name add-sql "(" add-sql ]
        [

            filter-tuple-values check-db-assigned-assoc
            [ length n>bind-string add-sql ");" add-sql ]
            [ [ [ second ] [ first type>> ] bi <in-binder-low> ] map >>in ] bi
            { INTEGER } >>out
        ]
    } 2cleave ;

M: mysql-db-connection insert-tuple-set-key ( tuple statement -- )
    sql-query first first set-primary-key drop ;

M: mysql-db-connection insert-user-assigned-key-sql
    [ <statement> ] dip
    [ >persistent ] [ ] bi {
        [ drop table-name>> quote-sql-name "INSERT INTO " "(" surround add-sql ]
        [
            filter-tuple-values
            [
                keys
                [ [ column-name>> quote-sql-name ] map ", " join ]
                [
                    length n>bind-string
                    ") values(" ");" surround
                ] bi append add-sql
            ]
            [ [ [ second ] [ first type>> ] bi <in-binder-low> ] map >>in ] bi
        ]
    } 2cleave ;

/*
M: mysql-db-connection insert-user-assigned-key-sql
    [ <statement> ] dip >persistent {
        [ table-name>> quote-sql-name "INSERT INTO " prepend add-sql "(" add-sql ]
        [
            [
                columns>>
                [
                    [
                        [ ", " % ] [ column-name>> quote-sql-name % ] interleave 
                        ")" %
                    ] "" make add-sql
                ] [
                    " values(" %
                    [ ", " % ] [
                        dup type>> +random-key+ = [
                            [
                                bind-name%
                                slot-name>>
                                f
                                random-id-generator
                            ] [ type>> ] bi <generator-bind> 1,
                        ] [
                            bind%
                        ] if
                    ] interleave
                    ");" 0%
                ] bi
            ]
    } cleave ;
*/


: mysql-create-table ( tuple-class -- string )
    >persistent dup table-name>> quote-sql-name
    [
        [
            [ columns>> ] dip
            "CREATE TABLE " % %
            "(" % [ ", " % ] [
                [ column-name>> quote-sql-name % " " % ]
                [ type>> sql-create-type>string % ]
                [ drop ] tri
                ! [ modifiers % ] bi
            ] interleave
        ] [
            drop
            find-primary-key [
                ", " %
                "PRIMARY KEY(" %
                [ "," % ] [ column-name>> quote-sql-name % ] interleave
                ")" %
            ] unless-empty
            ");" %
        ] 2bi
    ] "" make ;

:: mysql-create-function ( tuple-class -- string )
    tuple-class >persistent :> persistent
    persistent table-name>> :> table-name
    table-name trim-double-quotes :> table-name-unquoted
    persistent columns>> :> columns
    columns remove-primary-key :> columns-minus-key

    [
        "CREATE FUNCTION " "add_" table-name-unquoted append quote-sql-name "("

        columns-minus-key [ type>> sql-type>string ] map ", " join

        ") returns bigint as 'insert into "

        table-name quote-sql-name "(" columns-minus-key [ column-name>> quote-sql-name ] map ", " join
        ") values("
        1 columns-minus-key length [a,b]
        [ number>string "$" prepend ] map ", " join

        "); select currval(''" table-name-unquoted "_"
        persistent find-primary-key first column-name>>
        "_seq'');' language sql;"
    ] "" append-outputs-as ;

M: mysql-db-connection create-table-sql ( tuple-class -- seq )
    [ mysql-create-table ]
    [ dup db-assigned-key? [ mysql-create-function 2array ] [ drop ] if ] bi ;

:: mysql-drop-table ( tuple-class -- string )
    tuple-class >persistent table-name>> :> table-name
    [
        "drop table " table-name quote-sql-name ";"
    ] "" append-outputs-as ;

:: mysql-drop-function ( tuple-class -- string )
    tuple-class >persistent :> persistent
    persistent table-name>> :> table-name
    table-name trim-double-quotes :> table-name-unquoted
    persistent columns>> :> columns
    columns remove-primary-key :> columns-minus-key
    [
        "drop function " "add_" table-name-unquoted append quote-sql-name
        "("
        columns-minus-key [ type>> sql-type>string ] map ", " join
        ");"
    ] "" append-outputs-as ;

M: mysql-db-connection drop-table-sql ( tuple-class -- seq )
    [ mysql-drop-table ]
    [ dup db-assigned-key? [ mysql-drop-function 2array ] [ drop ] if ] bi ;
    
