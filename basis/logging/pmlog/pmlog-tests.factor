! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: formatting kernel pmlog sequences tools.test ;
IN: pmlog.tests

: PMLOGTEST ( msg -- )
    PMLogLevelTest PMLOGwith ;

: PMLOGLEVEL-TEST ( -- )
    "Emergency" LOGEMERGENCY
    "Alert" LOGALERT
    "Critical" LOGCRITICAL
    "Error" LOGERROR
    "Warning" LOGWARNING
    "Notice" LOGNOTICE
    "Info" LOGINFO
    "Debug" LOGDEBUG
    "Debug1" LOGDEBUG1
    "Debug2" LOGDEBUG2
    "plain LOG always sends" LOG
;

: PMTEST ( -- )
    LOGHERE
    "Starting test" LOG
    10 <iota> 
    [ dup
      PMLOGpushlevel
      "Log Level: %d\n" sprintf LOG
      PMLOGLEVEL-TEST
      PMLOGpoplevel
    ] each
    "This is a problem" 32 LOGERR
    "Test note" LOG
    "This is a value" -1 LOGVALUE
    ;
