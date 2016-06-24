! Copyright (C) 2016 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors db2 db2.connections db2.debug db2.statements
db2.statements.tests kernel mysql.db2 namespaces tools.test ;
IN: mysql.db2.tests

{ t }
[
    db2-connection get
    dup [ ] [ drop testdb ] if
    tuple?
] unit-test

    ! [ "USE `factor-test`" sql-command ] ignore-errors
    ! [ "DROP IF EXISTS TABLE `computer`;" sql-command ] ignore-errors

    ! ! [ "drop table computer;" sql-command ]
    ! ! [ [ sql-table-missing? ] [ table>> "computer" = ] bi and ] must-fail-with

    ! [ "DROP TABLE `computer`;" sql-command ] must-fail

    ! { }
    ! [
    !     "CREATE TABLE `computer` (name VARCHAR(255), version INTEGER);"
    !     sql-command
    ! ] unit-test


: test-sql-bound-commands ( -- )
    ! create-computer-table
    
    [ ] [
        <statement>
            "insert into computer (name, os, version) values($1, $2, $3);" >>sql
            { "clubber" "windows" "7" } >>in
        sql-command
    ] unit-test

    [ { { "windows" } } ] [
        <statement>
            "select os from computer where name = $1;" >>sql
            { "clubber" } >>in
        sql-query
    ] unit-test ;

! [ test-sql-bound-commands ] test-mysql

