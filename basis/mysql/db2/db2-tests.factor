! Copyright (C) 2016 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel mysql.db2 tools.test ;

IN: mysql.db2.tests

FROM: mysql.db2 => new ; 

{ { "localhost" "root" "" "factor-test" } }
[ mysql-args{ "localhost" "root" "" "factor-test" } ] unit-test

{ t }
[ testdb tuple? ] unit-test

! { } db2-connection get dispose ] unit-test
