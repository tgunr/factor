! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax arrays assocs combinators
generalizations kernel lexer math math.parser namespaces prettyprint
sequences strings strings.parser words ;

IN: libc
LIBRARY: libc

FUNCTION: void closelog (  ) 
FUNCTION: void openlog ( c-string ident, int logopt, int facility ) 
FUNCTION: int setlogmask ( int maskpri ) 
FUNCTION: void syslog ( int priority, c-string message ) 
FUNCTION: void vsyslog ( int priority, c-string message, c-string args ) 

IN: pmlog
CONSTANT: logLevelNone      -1
CONSTANT: logLevelEmergency 0
CONSTANT: logLevelAlert     1
CONSTANT: logLevelCritical  2
CONSTANT: logLevelError     3
CONSTANT: logLevelWarning   4
CONSTANT: logLevelNotice    5
CONSTANT: logLevelInfo      6
CONSTANT: logLevelDebug     7
CONSTANT: logLevelDebug1    8
CONSTANT: logLevelDebug2    9
CONSTANT: logLevelTest      99

: LOG-Level-String ( level -- string )
    {
        { logLevelNone      [ "None"     ] }
        { logLevelEmergency [ "Emerg"    ] }
        { logLevelAlert     [ "Alert"    ] }
        { logLevelCritical  [ "Critical" ] }
        { logLevelError     [ "Error"    ] }
        { logLevelWarning   [ "Warning"  ] }
        { logLevelNotice    [ "Notice"   ] }
        { logLevelInfo      [ "Info"     ] }
        { logLevelDebug     [ "Debug"    ] }
        { logLevelDebug1    [ "Debug1"   ] }
        { logLevelDebug2    [ "Debug2"   ] }
        { logLevelTest      [ "Test"     ] }
    } case ;
   
SYMBOL: logLevel 
SYMBOL: logLevelIndex 
SYMBOL: logStack 

INITIALIZE: logLevel logLevelDebug ;
INITIALIZE: logLevelIndex 0 ;
INITIALIZE: logStack [ 256 0 <array> ] ; 

: LOGsetlevel ( level -- ) logLevel set ;

: LOGpushlevel ( level -- )
    logLevel get  logLevelIndex get  logStack get  set-nth
    logLevelIndex get  1 +  dup  logLevelIndex set
    255 > [ 255 logLevelIndex set ] when
    logLevel set ;

: LOGpoplevel ( -- )
    logLevelIndex get  1 -  dup  logLevelIndex set
    0 < [ 0 logLevelIndex set ] when
    logLevelIndex get  logStack get  nth
    logLevel set
    ;

: level? ( level -- t|f )
    [  logLevel get <= ] keep
    logLevelTest = or ;

: (log) ( level name -- )  +colon-space syslog ;
: (log.) ( name -- )  +colon-space logLevelTest swap syslog ;

: (location) ( loc -- string )
    dup
    [ unparse +space ]
    [ drop "Listener " ]
    if ;

: (logloc) ( level name loc -- )
    [ dup level? ] 2dip rot
    [ (location) prepend +space  syslog ]
    [ 2drop drop ] if
    ;

: (logmsg) ( level name loc msg -- )
    [ dup level? ] 3dip 4 nrot
    [ [ (location) prepend +colon-space ] dip ! name+loc level msg
      append  syslog ]
    [ 2drop 2drop ] if
    ;

: (logstring) ( msg level name loc -- )
    (location) 
    [ dup level? ] 2dip rot
    [ prepend  +colon-space  rot append  syslog ]
    [ 2drop 2drop ] if
    ;

: (embed-location) ( word -- word )
    last-word name>> suffix!
    last-word props>> "loc" swap at suffix!
    \ (logloc) suffix! ;

: (embed-inline) ( word -- word )
    last-word name>> suffix!
    last-word props>> "loc" swap at suffix!
    lexer get skip-blank parse-string suffix!
    \ (logmsg) suffix! ; 

: (embed-string) ( word -- word )
    last-word name>> suffix!
    last-word props>> "loc" swap at suffix!
    \ (logstring) suffix! ; 


SYNTAX: LOG \ logLevelTest suffix! (embed-string) ;
SYNTAX: LOG" \ logLevelTest suffix! (embed-inline) ; ! "for the editors sake
SYNTAX: LOGHERE \ logLevelTest suffix! (embed-location) ;

SYNTAX: LOGDEBUG2 \ logLevelDebug2 suffix! (embed-string) ;
SYNTAX: LOGDEBUG2\" \ logLevelDebug2 suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOGDEBUG1 \ logLevelDebug1 suffix! (embed-string) ;
SYNTAX: LOGDEBUG1\" \ logLevelDebug1 suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOGDEBUG \ logLevelDebug suffix! (embed-string) ;
SYNTAX: LOGDEBUG" \ logLevelDebug suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOGINFO \ logLevelInfo suffix! (embed-string) ;
SYNTAX: LOGINFO" \ logLevelInfo suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOGNOTICE \ logLevelNotice suffix! (embed-string) ;
SYNTAX: LOGNOTICE" \ logLevelNotice suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOGWARNING \ logLevelWarning suffix! (embed-string) ;
SYNTAX: LOGWARNING" \ logLevelWarning suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOGERROR \ logLevelError suffix! (embed-string) ;
SYNTAX: LOGERROR" \ logLevelError suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOGCRITICAL \ logLevelCritical suffix! (embed-string) ;
SYNTAX: LOGCRITICAL" \ logLevelCritical suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOGALERT \ logLevelAlert suffix! (embed-string) ;
SYNTAX: LOGALERT" \ logLevelAlert suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOGEMERGENCY \ logLevelEmergency suffix! (embed-string) ;
SYNTAX: LOGEMERGENCY" \ logLevelEmergency suffix! (embed-inline) ; ! "for the editors sake

:: PMLOG ( msg file word level -- )
    level level?
    [ level
      file " " append
      word append
      " " append
      level LOG-Level-String append
      " " append
      msg append
      syslog
    ]
    when
;

: LOGwith ( msg level -- )
    "loc" word props>> at dup 
    [ [ "LOG " [ first ] dip  prepend  ":" append ] keep 
      second number>string append ]
      [ drop "Listener: " ] if
    word name>>  rot
    PMLOG ;

: LOGERR ( msg error -- )
    0 over =
    [ 2drop ]
    [ number>string  " " append
      "Error: " prepend 
      prepend logLevelTest LOGwith ] if ;

: LOGVALUE ( msg value -- )
    number>string " " append
    "Value: " prepend prepend 
    logLevelTest LOGwith ;

