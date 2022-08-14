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

: level>string ( level -- string )
    {
        { logLevelNone      [ "LOG_None    " ] }
        { logLevelEmergency [ "LOG_Emerg   " ] }
        { logLevelAlert     [ "LOG_Alert   " ] }
        { logLevelCritical  [ "LOG_Critical" ] }
        { logLevelError     [ "LOG_Error   " ] }
        { logLevelWarning   [ "LOG_Warning " ] }
        { logLevelNotice    [ "LOG_Notice  " ] }
        { logLevelInfo      [ "LOG_Info    " ] }
        { logLevelDebug     [ "LOG_Debug   " ] }
        { logLevelDebug1    [ "LOG_Debug1  " ] }
        { logLevelDebug2    [ "LOG_Debug2  " ] }
        { logLevelTest      [ "LOG_Test    " ] }
    } case ;
   
SYMBOL: logLevel 
SYMBOL: logLevelIndex 
SYMBOL: logStack 

INITIALIZE: logLevel logLevelDebug ;
INITIALIZE: logLevelIndex 0 ;
INITIALIZE: logStack 256 0 <array> ; 

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

: (loghere) ( level name loc -- )
    [ dup level? ] 2dip rot
    [ [ "IN: " prepend ] dip 
        (location) prepend +space
        over level>string +colon-space prepend
        syslog ]
    [ 2drop drop ] if
    ;

: (logmsg) ( level name loc msg -- )
    [ dup level? ] 3dip 4 nrot
    [ [ (location) prepend +colon-space ] dip
      [ dup level>string +colon-space ] 2dip 
      append append syslog ]
    [ 2drop 2drop ] if
    ;

: (logstring) ( msg level name loc -- )
    (location) 
    [ dup level? ] 2dip rot
    [ prepend  +colon-space
      [ dup level>string +colon-space ] dip
      append rot append  syslog ]
    [ 2drop 2drop ] if
    ;

: (embed-here) ( word -- word )
    last-word name>> suffix!
    last-word props>> "loc" swap at suffix!
    \ (loghere) suffix! ;

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
SYNTAX: LOGHERE \ logLevelTest suffix! (embed-here) ;

SYNTAX: LOGDEBUG2 \ logLevelDebug2 suffix! (embed-string) ;
SYNTAX: LOGDEBUG2" \ logLevelDebug2 suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOGDEBUG1 \ logLevelDebug1 suffix! (embed-string) ;
SYNTAX: LOGDEBUG1" \ logLevelDebug1 suffix! (embed-inline) ; ! "for the editors sake

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
