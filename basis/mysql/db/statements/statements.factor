! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db.connections db.statements
io.encodings.string io.encodings.utf8 kernel
mysql.db.connections mysql.db.ffi mysql.db.lib namespaces
sequences locals ;
IN: mysql.db.statements

TUPLE: mysql-statement < statement ;

:: mysql-prepare ( stmt sql -- stmt )
    stmt sql utf8 encode dup length mysql_stmt_prepare
    [ stmt ] dip mysql-stmt-check-result stmt ;

: mysql-maybe-prepare ( statement -- statement )
    dup handle>> [
        db2-connection get handle>> mysql_stmt_init
        over sql>> mysql-prepare >>handle
    ] unless ;

M: mysql-db-connection prepare-statement*
    mysql-maybe-prepare ;

: mysql-bind-text ( handle index text -- )
    utf8 encode dup length SQLITE_TRANSIENT
    mysql_stmt_bind_param mysql-check-result ;

M: mysql-db-connection bind-sequence
    [ in>> ] [ handle>> ] bi [ ] curry
    [ 2dip 1 + swap mysql-bind-text ] curry each-index
    ;

M: mysql-db-connection reset-statement
    [ handle>> mysql-reset-statement ] keep ;

M: mysql-db-connection dispose-statement
    f >>handle drop ;

! M: mysql-db-connection next-bind-index "?" ;

! M: mysql-db-connection init-bind-index ;


