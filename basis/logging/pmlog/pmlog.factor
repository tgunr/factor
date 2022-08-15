! Copyright (C) 2012 Dave Carlton
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax arrays assocs
combinators generalizations kernel lexer math math.order
math.parser namespaces prettyprint sequences strings
strings.parser words ;

IN: libc
LIBRARY: libc

FUNCTION: void closelog (  )
FUNCTION: void openlog ( c-string ident, int logopt, int facility )
FUNCTION: int setlogmask ( int maskpri )
FUNCTION: void syslog ( int priority, c-string message )
FUNCTION: void vsyslog ( int priority, c-string message, c-string args )

IN: pmlog
SYMBOL: LOG_NONE     ! t system is disabled
SYMBOL: LOG_EMERG    ! 0 system is unusable
SYMBOL: LOG_ALERT    ! 1 action must be taken immediately
SYMBOL: LOG_CRIT     ! 2 critical conditions
SYMBOL: LOG_ERR      ! 3 error conditions
SYMBOL: LOG_WARNING  ! 4 warning conditions
SYMBOL: LOG_NOTICE   ! 5 normal but significant condition
SYMBOL: LOG_INFO     ! 6 informational
SYMBOL: LOG_DEBUG    ! 7 debug-level messages

SYMBOL: LOG_KERN
SYMBOL: LOG_USER
SYMBOL: LOG_MAIL
SYMBOL: LOG_DAEMON
SYMBOL: LOG_AUTH
SYMBOL: LOG_SYSLOG
SYMBOL: LOG_LPR
SYMBOL: LOG_NEWS
SYMBOL: LOG_UUCP
SYMBOL: LOG_CRON
SYMBOL: LOG_AUTHPRIV
SYMBOL: LOG_FTP
SYMBOL: LOG_NETINFO
SYMBOL: LOG_REMOTEAUTH
SYMBOL: LOG_INSTALL
SYMBOL: LOG_RAS
SYMBOL: LOG_LOCAL0
SYMBOL: LOG_LOCAL1
SYMBOL: LOG_LOCAL2
SYMBOL: LOG_LOCAL3
SYMBOL: LOG_LOCAL4
SYMBOL: LOG_LOCAL5
SYMBOL: LOG_LOCAL6
SYMBOL: LOG_LOCAL7
SYMBOL: LOG_LAUNCHD
SYMBOL: LOG_NFACILITIES
SYMBOL: LOG_FACMASK
SYMBOL: LOG_TEST

INITIALIZE: LOG_KERN         0  3 shift ; ! kernel messages
INITIALIZE: LOG_USER         1  3 shift ; ! random user-level messages
INITIALIZE: LOG_MAIL         2  3 shift ; ! mail system
INITIALIZE: LOG_DAEMON       3  3 shift ; ! system daemons
INITIALIZE: LOG_AUTH         4  3 shift ; ! security/authorization messages
INITIALIZE: LOG_SYSLOG       5  3 shift ; ! messages generated internally by syslogd
INITIALIZE: LOG_LPR          6  3 shift ; ! line printer subsystem
INITIALIZE: LOG_NEWS         7  3 shift ; ! network news subsystem
INITIALIZE: LOG_UUCP         8  3 shift ; ! UUCP subsystem
INITIALIZE: LOG_CRON         9  3 shift ; ! clock daemon
INITIALIZE: LOG_AUTHPRIV    10  3 shift ; ! security/authorization messages private shift
INITIALIZE: LOG_FTP         11  3 shift ; ! ftp daemon
INITIALIZE: LOG_NETINFO     12  3 shift ; ! NetInfo
INITIALIZE: LOG_REMOTEAUTH  13  3 shift ; ! remote authentication/authorization
INITIALIZE: LOG_INSTALL     14  3 shift ; ! installer subsystem
INITIALIZE: LOG_RAS         15  3 shift ; ! Remote Access Service (VPN / PPP)
INITIALIZE: LOG_LOCAL0      16  3 shift ; ! reserved for local use
INITIALIZE: LOG_LOCAL1      17  3 shift ; ! reserved for local use
INITIALIZE: LOG_LOCAL2      18  3 shift ; ! reserved for local use
INITIALIZE: LOG_LOCAL3      19  3 shift ; ! reserved for local use
INITIALIZE: LOG_LOCAL4      20  3 shift ; ! reserved for local use
INITIALIZE: LOG_LOCAL5      21  3 shift ; ! reserved for local use
INITIALIZE: LOG_LOCAL6      22  3 shift ; ! reserved for local use
INITIALIZE: LOG_LOCAL7      23  3 shift ; ! reserved for local use
INITIALIZE: LOG_LAUNCHD     24  3 shift ; ! launchd - general bootstrap daemon
INITIALIZE: LOG_NFACILITIES 25          ; ! current number of facilities
INITIALIZE: LOG_FACMASK     "03F8" hex> ; ! facilities bit mask

: log-levels1 ( --  assoc )
    { }
    { LOG_NONE     
      LOG_EMERG    
      LOG_ALERT    
      LOG_CRIT     
      LOG_ERR      
      LOG_WARNING  
      LOG_NOTICE   
      LOG_INFO     
      LOG_DEBUG    
      }
    [ [ dup  swap 2array ] curry call suffix ] each
    ;

: log-levels ( --  assoc )
    H{ 
        { LOG_EMERG   0 }
        { LOG_ALERT   1 }    
        { LOG_CRIT    2 }   
        { LOG_ERR     3 }   
        { LOG_WARNING 4 }  
        { LOG_NOTICE  5 } 
        { LOG_INFO    6 } 
        { LOG_DEBUG   7 } 
    } ;

        
: level>string ( level -- string )
    {
        { LOG_EMERG   [ "LOG_EMERG   " ] }
        { LOG_ALERT   [ "LOG_ALERT   " ] }
        { LOG_CRIT    [ "LOG_CRIT    " ] }
        { LOG_ERR     [ "LOG_ERR     " ] }
        { LOG_WARNING [ "LOG_WARNING " ] }
        { LOG_NOTICE  [ "LOG_NOTICE  " ] }
        { LOG_INFO    [ "LOG_INFO    " ] }
        { LOG_DEBUG   [ "LOG_DEBUG   " ] }
    } case ;

SYMBOL: logLevel
SYMBOL: logFacility
SYMBOL: logLevelIndex
SYMBOL: logStack

INITIALIZE: LOG_NONE f ;
INITIALIZE: LOG_TEST f ;
INITIALIZE: logLevel LOG_INFO ;
INITIALIZE: logFacility LOG_SYSLOG ;
INITIALIZE: logLevelIndex 0 ; 
INITIALIZE: logStack 256 0 <array> ;

: LOG-enable ( -- )   f LOG_NONE set ;
: LOG-disable ( -- )   t LOG_NONE set  f LOG_TEST set ; 
: LOG-settest ( -- ) t LOG_TEST set ;
: LOG-setlevel ( level -- ) logLevel set  f LOG_TEST set ; 
: LOG-setfacility ( facility -- )   logFacility set ;
: LOG-setfacilities ( seq -- )   [ get logFacility get  bitor  logFacility set ] each ;

: LOG-pushlevel ( level -- )
    logLevel get  logLevelIndex get  logStack get  set-nth
    logLevelIndex get  1 +  dup  logLevelIndex set
    255 > [ 255 logLevelIndex set ] when
    logLevel set ;

: LOG-poplevel ( -- )
    logLevelIndex get  1 -  dup  logLevelIndex set
    0 < [ 0 logLevelIndex set ] when
    logLevelIndex get  logStack get  nth
    logLevel set
    ;

ERROR: undefined-log-level ;

: log-level@ ( log-level -- value )  log-levels at ;

: log-level<= ( new-log-level current-log-level -- ? )
    [ log-level@ ] dip  log-level@  <= ;
        
: log? ( log-level -- ? )
    LOG_NONE get
    [ drop f ] 
    [ logLevel get log-level<= ]
    if
    LOG_TEST get
    [ drop t ] when ;

: (syslog) ( level msg -- )
    [ log-level@ logFacility get get bitor ] dip syslog ;

: (location) ( loc -- string )
    dup
    [ unparse +space ]
    [ drop "Listener " ]
    if ;

: (loghere) ( level name loc -- )
    [ dup log? ] 2dip rot
    [ [ "IN: " prepend ] dip
        (location) prepend +space
        over level>string +colon-space prepend
        (syslog)
    ]
    [ 2drop drop ] if
    ;

: (logmsg) ( level name loc msg -- )
    [ dup log? ] 3dip 4 nrot
    [ [ (location) prepend +colon-space ] dip
      [ dup level>string +colon-space ] 2dip
      append append (syslog) ]
    [ 2drop 2drop ] if
    ;

: (logstring) ( msg level name loc -- )
    (location)
    [ dup log? ] 2dip rot
    [ prepend  +colon-space
      [ dup level>string +colon-space ] dip
      append rot append (syslog) ]
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


SYNTAX: LOG \ LOG-settest suffix! \ LOG_DEBUG suffix! (embed-string) ;
SYNTAX: LOG" \ LOG_TEST suffix! (embed-inline) ; ! "for the editors sake
SYNTAX: LOG-HERE \ LOG_TEST suffix! (embed-here) ;

SYNTAX: LOG-DEBUG \ LOG_DEBUG suffix! (embed-string) ;
SYNTAX: LOG-DEBUG" \ LOG_DEBUG suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOG-INFO \ LOG_INFO suffix! (embed-string) ;
SYNTAX: LOG-INFO" \ LOG_INFO suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOG-NOTICE \ LOG_NOTICE suffix! (embed-string) ;
SYNTAX: LOG-NOTICE" \ LOG_NOTICE suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOG-WARNING \ LOG_WARNING suffix! (embed-string) ;
SYNTAX: LOG-WARNING" \ LOG_WARNING suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOG-ERROR \ LOG_ERR suffix! (embed-string) ;
SYNTAX: LOG-ERROR" \ LOG_ERR suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOG-CRITICAL \ LOG_CRIT suffix! (embed-string) ;
SYNTAX: LOG-CRITICAL" \ LOG_CRIT suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOG-ALERT \ LOG_ALERT suffix! (embed-string) ;
SYNTAX: LOG-ALERT" \ LOG_ALERT suffix! (embed-inline) ; ! "for the editors sake

SYNTAX: LOG-EMERGENCY \ LOG_EMERG suffix! (embed-string) ;
SYNTAX: LOG-EMERGENCY" \ LOG_EMERG suffix! (embed-inline) ; ! "for the editors sake
