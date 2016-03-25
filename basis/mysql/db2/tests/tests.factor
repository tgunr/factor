! Copyright (C) 2016 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors db2 db2.debug db2.statements db2.statements.tests
tools.test ;

IN: mysql.db2.tests

! : test-sql-bound-commands ( -- )
!     create-computer-table
    
!     [ ] [
!         <statement>
!             "insert into computer (name, os, version) values($1, $2, $3);" >>sql
!             { "clubber" "windows" "7" } >>in
!         sql-command
!     ] unit-test

!     [ { { "windows" } } ] [
!         <statement>
!             "select os from computer where name = $1;" >>sql
!             { "clubber" } >>in
!         sql-query
!     ] unit-test ;

! [ test-sql-bound-commands ] test-mysql

