! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.libraries alien.syntax
arrays assocs combinators formatting kernel literals locals math
math.parser namespaces sequences words ;


<< "libsystemB" "/usr/lib/libSystem.B.dylib" cdecl add-library >>

LIBRARY: libsystemB
IN: libsystemB

FUNCTION: void closelog (  ) 
FUNCTION: void openlog ( c-string ident, int logopt, int facility ) 
FUNCTION: int setlogmask ( int maskpri ) 
FUNCTION: void syslog ( int priority, char* message ) 
FUNCTION: void vsyslog ( int priority, c-string message, c-string args ) 

IN: syslog

 ! priorities/facilities are encoded into a single 32-bit quantity, where the
 ! bottom 3 bits are the priority (0-7) and the top 28 bits are the facility
 ! (0-big number).  Both the priorities and the facilities map roughly
 ! one-to-one to strings in the syslogd(8) source code.  This mapping is
 ! included in this file.
 !
 ! priorities (these are ordered)

CONSTANT: LOG_NONE      -1
CONSTANT: LOG_EMERG     0
CONSTANT: LOG_ALERT     1
CONSTANT: LOG_CRIT      2
CONSTANT: LOG_ERR       3
CONSTANT: LOG_WARNING   4
CONSTANT: LOG_NOTICE    5
CONSTANT: LOG_INFO      6
CONSTANT: LOG_DEBUG     7
CONSTANT: LOG_DEBUG1    8
CONSTANT: LOG_DEBUG2    9

SYMBOL: SYSLOG_TESTING

CONSTANT: LOG_PID       0x01 ! log the pid with each message 
CONSTANT: LOG_CONS      0x02 ! log on the console if errors in sending 
CONSTANT: LOG_ODELAY    0x04 ! delay open until first syslog() (default) 
CONSTANT: LOG_NDELAY    0x08 ! don't delay open 
CONSTANT: LOG_NOWAIT    0x10 ! don't wait for console forks: DEPRECATED 
CONSTANT: LOG_PERROR    0x20 ! log to stderr as well 

! facility codes 
CONSTANT: LOG_KERN       $[ 00 3 shift ] ! kernel messages 
CONSTANT: LOG_USER       $[ 01 3 shift ] ! random user-level messages 
CONSTANT: LOG_MAIL       $[ 02 3 shift ] ! mail system 
CONSTANT: LOG_DAEMON     $[ 03 3 shift ] ! system daemons 
CONSTANT: LOG_AUTH       $[ 04 3 shift ] ! authorization messages 
CONSTANT: LOG_SYSLOG     $[ 05 3 shift ] ! messages generated internally by syslogd 
CONSTANT: LOG_LPR        $[ 06 3 shift ] ! line printer subsystem 
CONSTANT: LOG_NEWS       $[ 07 3 shift ] ! network news subsystem 
CONSTANT: LOG_UUCP       $[ 08 3 shift ] ! UUCP subsystem 
CONSTANT: LOG_CRON       $[ 09 3 shift ] ! clock daemon 
CONSTANT: LOG_AUTHPRIV   $[ 10 3 shift ] ! authorization messages (private) 
CONSTANT: LOG_FTP        $[ 11 3 shift ] ! ftp daemon 
CONSTANT: LOG_NTP        $[ 12 3 shift ] ! NTP subsystem 
CONSTANT: LOG_SECURITY   $[ 13 3 shift ] ! security subsystems (firewalling, etc.) 
CONSTANT: LOG_CONSOLE    $[ 14 3 shift ] ! /dev/console output 
CONSTANT: LOG_NETINFO    $[ 12 3 shift ] ! NetInfo 
CONSTANT: LOG_REMOTEAUTH $[ 13 3 shift ] ! remote authentication/authorization 
CONSTANT: LOG_INSTALL    $[ 14 3 shift ] ! installer subsystem 
CONSTANT: LOG_RAS        $[ 15 3 shift ] ! Remote Access Service (VPN / PPP) 
CONSTANT: LOG_LOCAL0     $[ 16 3 shift ] ! reserved for local use 
CONSTANT: LOG_LOCAL1     $[ 17 3 shift ] ! reserved for local use 
CONSTANT: LOG_LOCAL2     $[ 18 3 shift ] ! reserved for local use 
CONSTANT: LOG_LOCAL3     $[ 19 3 shift ] ! reserved for local use 
CONSTANT: LOG_LOCAL4     $[ 10 3 shift ] ! reserved for local use 
CONSTANT: LOG_LOCAL5     $[ 21 3 shift ] ! reserved for local use 
CONSTANT: LOG_LOCAL6     $[ 22 3 shift ] ! reserved for local use 
CONSTANT: LOG_LOCAL7     $[ 23 3 shift ] ! reserved for local use 
CONSTANT: LOG_LAUNCHD    $[ 24 3 shift ] ! launchd - general bootstrap daemon 

CONSTANT: LOG_NFACILITIES    25    ! current number of facilities 
CONSTANT: LOG_FACMASK    0x03f8    ! mask to extract facility part 

: LOG_FAC ( p -- p' )
    LOG_FACMASK and -3 shift ;

: SYSLOG-Level-String ( level -- string )
    {
        { LOG_NONE      [ "None"     ] }
        { LOG_EMERG     [ "Emerg"    ] }
        { LOG_ALERT     [ "Alert"    ] }
        { LOG_CRIT      [ "Critical" ] }
        { LOG_ERR       [ "Error"    ] }
        { LOG_WARNING   [ "Warning"  ] }
        { LOG_NOTICE    [ "Notice"   ] }
        { LOG_INFO      [ "Info"     ] }
        { LOG_DEBUG     [ "Debug"    ] }
        { LOG_DEBUG1    [ "Debug1"   ] }
        { LOG_DEBUG2    [ "Debug2"   ] }
    } case ;
   
SYMBOL: syslogMask

SYMBOL: sysLogLevel
sysLogLevel [ LOG_ERR ] initialize

SYMBOL: sysLogLevelIndex
sysLogLevelIndex [ 0 ] initialize

SYMBOL: sysLogStack
sysLogStack [ 256 0 <array> ] initialize

SYMBOL: syslogProgram

: SYSLOG_Testing ( -- )
    99 SYSLOG_TESTING set ;

: SYSLOG_SetVerbose ( level -- )
    sysLogLevel set
    ;

: SYSLOG_PushVerbose ( level -- )
    sysLogLevel get  sysLogLevelIndex get  sysLogStack get  set-nth
    sysLogLevelIndex get  1 +  dup  sysLogLevelIndex set
    255 > [ 255 sysLogLevelIndex set ] when
    sysLogLevel set
    ;

: SYSLOG_PopVerbose ( -- )
    sysLogLevelIndex get  1 -  dup  sysLogLevelIndex set
    0 < [ 0 sysLogLevelIndex set ] when
    sysLogLevelIndex get  sysLogStack get  nth
    sysLogLevel set
    ;

: (syslog) ( priority message -- ) 
    syslogProgram get  LOG_PID LOG_USER openlog
    syslog
    closelog
    ;

:: (SYSLOG) ( defined-word level msg -- )
    level sysLogLevel get <= 
    SYSLOG_TESTING get or
    [ level
      msg
      ":" append
      defined-word vocabulary>>  syslogProgram set
      defined-word name>> append
      " " append
      level SYSLOG-Level-String append
      " " append
     syslog
    ]
    when
;

: syslog-format ( msg -- formatted-msg )
    dup word? 
    [ dup props>> "loc" swap at ]
    [ { "" 0 } ]
    if
    swap word?
    [
        [ "FACTOR " [ first ] dip  prepend  ":" append ] keep 
        second number>string append
        ":" append
    ]
    [ drop "FACTOR " ]
    if
;

: SYSLOGWITHLEVEL ( msg level -- )
    drop
    syslog-format
    LOG_DEBUG swap syslog
    ;

: SYSLOG_ERR ( msg error -- )
    0 over =
    [ 2drop ]
    [ number>string  " " append
      "Error: " prepend
      prepend LOG_DEBUG SYSLOGWITHLEVEL ] if ;
: SYSLOG_VALUE ( msg value -- )
    number>string  "Value: " prepend prepend 
    LOG_DEBUG SYSLOGWITHLEVEL ;
: SYSLOG_NOTE ( msg -- )
    "NOTE: " prepend
    LOG_DEBUG SYSLOGWITHLEVEL ;
: SYSLOG_HERE ( -- )
    last-word LOG_DEBUG SYSLOGWITHLEVEL ;
: SYSLOG_TEST ( msg -- )
    LOG_DEBUG SYSLOGWITHLEVEL ;

: SYSLOG ( format-string -- )
    sprintf
    SYSLOG_TEST ; inline

: SYSLOG_EMERG ( msg -- )
    LOG_EMERG SYSLOGWITHLEVEL ;
: SYSLOG_ALERT ( msg -- )
    LOG_ALERT SYSLOGWITHLEVEL ;
: SYSLOG_CRITICAL ( msg -- )
    LOG_CRIT SYSLOGWITHLEVEL ;
: SYSLOG_ERROR ( msg -- )
    LOG_ERR SYSLOGWITHLEVEL ;
: SYSLOG_WARNING ( msg -- )
    LOG_WARNING SYSLOGWITHLEVEL ;
: SYSLOG_NOTICE ( msg -- )
    LOG_NOTICE SYSLOGWITHLEVEL ;
: SYSLOG_INFO ( msg -- )
    LOG_INFO SYSLOGWITHLEVEL ;
: SYSLOG_DEBUG ( msg -- )
    LOG_DEBUG SYSLOGWITHLEVEL ;

: SYSLOGLEVEL-TEST ( -- )
    "Emergency" SYSLOG_EMERG
    "Alert" SYSLOG_ALERT
    "Critical" SYSLOG_CRITICAL
    "Error" SYSLOG_ERROR
    "Warning" SYSLOG_WARNING
    "Notice" SYSLOG_NOTICE
    "Info" SYSLOG_INFO
    "Debug" SYSLOG_DEBUG
;

: SYSTEST ( -- )
    SYSLOG_HERE
    "Testing 1 2 3" SYSLOG_TEST
    10 iota 
    [ dup
      SYSLOG_PushVerbose
      "Log Level: %d\n" sprintf SYSLOG_NOTE
      SYSLOGLEVEL-TEST
      SYSLOG_PopVerbose
    ] each
    "This is a problem" 32 SYSLOG_ERR
    "Test note" SYSLOG_NOTE
    "This is a value" -1 SYSLOG_VALUE
    ;

