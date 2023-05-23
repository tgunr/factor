! File: cnc.machine.1F
! Version: 0.1
! DRI: Dave Carlton
! Description: OneFinifty CNC Machines
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: cnc cnc.SM2 cnc.bit cnc.machine cnc.tools io
 io.encodings.utf8 io.files kernel math.parser multiline sequences
    ;
FROM: cnc.machine => machine ;
IN: cnc.machine.1F

TUPLE: 1F < machine ; 

: <1F> ( -- 1F )
    1F new
    (( name model type x-max y-max z-max -- machine ))
    "1F" "OneFinity J50" +cnc+ +mm+ 1220 812 133 <machine>
    ;


: >onefinity ( -- )
    "/usr/bin/scp /Users/davec/Desktop/Resurface* root@onefinity.local:upload/"
    run-process wait-for-process 0=
    [ "ok" ] [ "fail" ] if print 
    "rsync -auv /Users/davec/Desktop/Resurface* root@onefinity.local:upload/"
    run-process wait-for-process 0=
    [ "ok" ] [ "fail" ] if print ;

: onefinity-clear ( -- ) 
    "ssh root@onefinity.local rm -r upload/*"
    run-process wait-for-process 0=
    [ "ok" ] [ "fail" ] if print ;

FROM: cnc.tools.resurface => resurface ;
: resurface ( -- )
    <1F> resurface ; 
