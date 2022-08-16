! Copyright (C) 2012 Dave Carlton
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax arrays assocs
combinators formatting generalizations io kernel lexer math
math.order math.parser multiline namespaces prettyprint
sequences strings strings.parser words help.syntax help.markup vocabs ;

IN: libc
LIBRARY: libc

FUNCTION: void closelog (  )
FUNCTION: void openlog ( c-string ident, int logopt, int facility )
FUNCTION: int setlogmask ( int maskpri )
FUNCTION: void syslog ( int priority, c-string message )
FUNCTION: void vsyslog ( int priority, c-string message, c-string args )

IN: logging.pmlog

! Log levels
SYMBOLS: LOG_NONE LOG_EMERG LOG_ALERT LOG_CRIT LOG_ERR LOG_WARNING LOG_NOTICE LOG_INFO LOG_DEBUG ; 

! Facilities
SYMBOLS: LOG_KERN LOG_USER LOG_MAIL LOG_DAEMON LOG_AUTH LOG_SYSLOG LOG_LPR LOG_NEWS LOG_UUCP LOG_CRON LOG_AUTHPRIV LOG_FTP LOG_NETINFO LOG_REMOTEAUTH LOG_INSTALL LOG_RAS LOG_LOCAL0 LOG_LOCAL1 LOG_LOCAL2 LOG_LOCAL3 LOG_LOCAL4 LOG_LOCAL5 LOG_LOCAL6 LOG_LOCAL7 LOG_LAUNCHD ;

! VARIABLES
SYMBOL: LOG_OPEN
SYMBOL: LOG_TEST


<PRIVATE
SYMBOL: logLevel
SYMBOL: logFacility
SYMBOL: logLevelIndex
SYMBOL: logStack

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

INITIALIZE: LOG_OPEN { "PMLOG" 0 LOG_USER } ;
INITIALIZE: LOG_NONE f ;
INITIALIZE: LOG_TEST f ;
INITIALIZE: logLevel LOG_INFO ;
INITIALIZE: logFacility LOG_SYSLOG ;
INITIALIZE: logLevelIndex 0 ; 
INITIALIZE: logStack 256 0 <array> ;

CONSTANT: LOG_FACMASK "0x03F8" ! facilities bit mask

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
        { LOG_TEST    8 } 
    } ;

PRIVATE>

! Log Control
: LOG-open ( -- )   LOG_OPEN get  [ first ] keep  [ second ] keep third get  openlog ;
: LOG-enable ( -- )   f LOG_NONE set ;
: LOG-disable ( -- )   t LOG_NONE set  f LOG_TEST set ; 
: LOG-settest ( -- ) t LOG_TEST set ;
: LOG-setlevel ( level -- ) logLevel set  f LOG_TEST set ; 
: LOG-setfacility ( facility -- )   logFacility set ;
: LOG-setfacilities ( seq -- )   [ get logFacility get  bitor  logFacility set ] each ;

! Internals
<PRIVATE
: log-level@ ( log-level -- value )  log-levels at ;

: log-level<= ( new-log-level current-log-level -- ? )
    [ log-level@ ] dip  log-level@  <= ;

: @log-level ( value -- log-level )
    log-levels [ nip over = ] assoc-find
    [ drop nip ]
    [ drop 2drop LOG_DEBUG ]
    if ;

: log? ( log-level -- ? )
    ! dup "log?: level: %u\n" printf
    LOG_NONE get
    ! dup "log?: LOG_NONE: %u\n" printf
    [ drop f ] 
    [ logLevel get log-level<= ]
    if
    ! dup "log?: result %u\n" printf
    LOG_TEST get
    ! dup "log?: LOG_TEST: %u\n" printf
    [ drop t ] when
;

ERROR: undefined-log-level ;
        
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
        { LOG_TEST    [ "LOG_TEST    " ] }
    } case ;

PRIVATE>

: LOG-pushlevel ( level -- )
    logLevel get
    ! dup "OLD LEVEL: %u\n" printf
    logLevelIndex get  logStack get  set-nth
    logLevelIndex get  1 +  255 max  logLevelIndex set
    @log-level
    ! dup "NEW LEVEL: %u\n" printf
    logLevel set ;

: LOG-poplevel ( -- )
    logLevelIndex get  1 -  dup  logLevelIndex set
    0 < [ 0 logLevelIndex set ] when
    logLevelIndex get  logStack get  nth  @log-level
    ! dup "POP LEVEL: %u\n" printf
    logLevel set
    ;

: (syslog) ( level msg -- )
    ! over "(syslog): LEVEL: %u\n" printf 
    [ log-level@ logFacility get get bitor ] dip
    ! [ log-level@  ] dip
    syslog
    f LOG_TEST set ;
    
: (location) ( loc -- string )
    dup
    [ unparse +space ]
    [ drop "Listener " ]
    if ;

: (log-here) ( level name loc -- )
    [ dup log? ] 2dip rot
    [ [ "IN: " prepend ] dip
        (location) prepend +space
        over level>string +colon-space prepend
        (syslog)
    ]
    [ 2drop drop ] if
    ;

: (log-message) ( level name loc msg -- )
    [ dup log? ] 3dip 4 nrot
    [ [ (location) prepend +colon-space ] dip
      [ dup level>string +colon-space ] 2dip
      append append (syslog) ]
    [ 2drop 2drop ] if
    ;

: (log-string) ( msg level name loc -- )
    ! [ dup "(logstring): level: %u\n" printf ] 3dip 
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
    \ (log-here) suffix! ;

: (embed-message) ( word -- word )
    last-word name>> suffix!
    last-word props>> "loc" swap at suffix!
    lexer get skip-blank parse-string suffix!
    \ (log-message) suffix! ;

: (embed-string) ( word -- word )
    last-word name>> suffix!
    last-word props>> "loc" swap at suffix!
    \ (log-string) suffix! ;


SYNTAX: LOG \ LOG-settest suffix! \ LOG_DEBUG suffix! (embed-string) ;
SYNTAX: LOG" \ LOG_TEST suffix! (embed-message) ; ! "for the editors sake
SYNTAX: LOG-HERE \ LOG_TEST suffix! (embed-here) ;

SYNTAX: LOG-DEBUG \ LOG_DEBUG suffix! (embed-string) ;
SYNTAX: LOG-DEBUG" \ LOG_DEBUG suffix! (embed-message) ; ! "for the editors sake

SYNTAX: LOG-INFO \ LOG_INFO suffix! (embed-string) ;
SYNTAX: LOG-INFO" \ LOG_INFO suffix! (embed-message) ; ! "for the editors sake

SYNTAX: LOG-NOTICE \ LOG_NOTICE suffix! (embed-string) ;
SYNTAX: LOG-NOTICE" \ LOG_NOTICE suffix! (embed-message) ; ! "for the editors sake

SYNTAX: LOG-WARNING \ LOG_WARNING suffix! (embed-string) ;
SYNTAX: LOG-WARNING" \ LOG_WARNING suffix! (embed-message) ; ! "for the editors sake

SYNTAX: LOG-ERROR \ LOG_ERR suffix! (embed-string) ;
SYNTAX: LOG-ERROR" \ LOG_ERR suffix! (embed-message) ; ! "for the editors sake

SYNTAX: LOG-CRITICAL \ LOG_CRIT suffix! (embed-string) ;
SYNTAX: LOG-CRITICAL" \ LOG_CRIT suffix! (embed-message) ; ! "for the editors sake

SYNTAX: LOG-ALERT \ LOG_ALERT suffix! (embed-string) ;
SYNTAX: LOG-ALERT" \ LOG_ALERT suffix! (embed-message) ; ! "for the editors sake

SYNTAX: LOG-EMERGENCY \ LOG_EMERG suffix! (embed-string) ;
SYNTAX: LOG-EMERGENCY" \ LOG_EMERG suffix! (embed-message) ; ! "for the editors sake
