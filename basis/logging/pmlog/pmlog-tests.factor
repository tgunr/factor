! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: formatting kernel logging logging.pmlog math.order
math.parser namespaces pmlog sequences tools.test ;
FROM: pmlog => log? ;
IN: pmlog.tests

: LOG-LEVEL-TEST ( -- )
    "Emergency" LOG-EMERGENCY
    "Alert" LOG-ALERT
    "Critical" LOG-CRITICAL
    "Error" LOG-ERROR
    "Warning" LOG-WARNING
    "Notice" LOG-NOTICE
    "Info" LOG-INFO
    "Debug" LOG-DEBUG
    "plain LOG always sends" LOG
;

: LOGGING-TEST ( -- )
    LOG-open
    LOG-HERE
    "Starting test" LOG
    10 <iota> 
    [ [ "Testing level: %d\n" printf ] keep
      [ LOG-pushlevel ] keep
      ! dup "TEST LEVEL: %u\n" printf
      "Log Level: %d\n" sprintf LOG
      LOG-LEVEL-TEST
      LOG-poplevel
    ] each
    "This is a problem: " 32 number>string append LOG
    LOG"Test inline log note" 
    ;

! check LOG_TEST getting reset
{ f } [ LOG-settest  LOG_DEBUG LOG-setlevel LOG_TEST get ] unit-test
! now set default values
{ } [  LOG-enable  LOG_ERR LOG-setlevel LOG_SYSLOG LOG-setfacility ] unit-test
{ 0 } [ LOG_EMERG log-level@ ] unit-test
{ 3 } [ LOG_ERR log-level@ ] unit-test
{ 7 } [ LOG_DEBUG log-level@ ] unit-test
{ t } [ LOG_EMERG LOG_ERR log-level<= ] unit-test
{ t } [ LOG_ERR   LOG_ERR log-level<= ] unit-test
{ f } [ LOG_DEBUG LOG_ERR log-level<= ] unit-test
{ t } [ LOG_EMERG log? ] unit-test
{ f } [ LOG_DEBUG log? ] unit-test
! change logLevel and check LOG_DEBUG now t
{ t } [ LOG_DEBUG LOG-setlevel  LOG_DEBUG log? ] unit-test
! change loglevel to lowest, LOG_DEBUG normally would be be f but LOG_TEST overrides
{ t } [ LOG_EMERG LOG-setlevel  LOG-settest  LOG_DEBUG log? ] unit-test
! change logLevel to highest, disable logging
{ f } [ LOG-disable LOG_DEBUG LOG-setlevel  LOG_DEBUG log? ] unit-test
! LOG_TEST should have been set to f by previous LOG-setlevel
{ f } [ LOG_TEST get ] unit-test
! Reset to defaults
{ } [ LOG-enable  LOG_INFO LOG-setlevel  LOG_SYSLOG LOG-setfacility ] unit-test
