! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax kernel math sequences
strings ;

IN: help.markup
: $logwords ( element -- )
    "Log Words" $heading
    unclip print-element [ \ $link swap ] { } map>assoc $list ;

IN: pmlog
ABOUT: "pmlog"

ARTICLE: "pmlog" "LOG: A vocabulary for creating syslog entries"
"This vocabulary defines words to create syslog entries."
"The vocabulary behaves basically as you would expect."
"If the priority level of the message to send to syslogd is less"
"than the global log level value it will be sent, otherwise discarded."
$nl
"Message verbosity increases with the log level being invoked"
"with EMERGENCY being the lowest level and highest priority"
"and DEBUG is the highest level and lowest priority"
$nl
"This permits leaving logging words in production code to issue messages"
"of interest. The default log level is ERROR. Messages with priority"
"greater than ERROR will not be sent unless the global level is raised."
$nl
"During testing several words exist which will issue message regardless"
"of the global level. It is expected you will remove such words"
"before shipping the code"
$nl

{ $logwords
  { }
  \ LOGEMERGENCY
  \ LOGALERT
  \ LOGCRITICAL
  \ LOGERROR
  \ LOGWARNING
  \ LOGNOTICE
  \ LOGINFO
  \ LOGDEBUG
  \ LOGDEBUG1
  \ LOGDEBUG2
  \ LOG
  \ LOGHERE
} 

$nl
"Global Control"
{ $subsections
  logLevel
  LOGsetlevel
  LOGpushlevel
  LOGpoplevel
}

"Log Levels"
{ $subsections
  logLevelNone      
  logLevelEmergency     
  logLevelAlert     
  logLevelCritical  
  logLevelError     
  logLevelWarning   
  logLevelNotice    
  logLevelInfo      
  logLevelDebug     
  logLevelDebug1    
  logLevelDebug2    
  logLevelTest      
}

"Test Words"
{ $subsections
  LOGwith
  LOGERR
  LOGVALUE
}


{ $vocab-link "pmlog" }
;

ARTICLE: "Logging" "Using LOG Words"
"The loggings will send to the" "syslog" $strong "information"
"about the definition containing the log word. Each log wrods will send"
"the file and line number of the word, the name of the defintion, along"
"with any string message."
"This information will permit you to filter the log messages when"
"searching for massges of certain words or debug levels"
$nl
"Each logging word has three kinds of logging variations."
$nl
"LOG - Sends just the basic information."
  { $example 
    ": main ( -- ) "
    "    [ main-code ] [ ] [ LOGINFO ] cleanup ;"
  } 
$nl
"LOG\" - Sends the following string terminated by a \""
$nl
">LOG - Sends the string on top of the stack."
$nl
    ;

! HELP: LOG\" { $syntax "LOG\" \"" } ;


HELP: LOGwith
{ $values 
  { "msg" "string to send to syslog" }
  { "level" "log level" }    
}
{ $description "Sends message to syslogd using the specified log level." } ;

HELP: LOGEMERGENCY
{ $syntax "LOGEMERGENCY" }
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the EMERGENCY log level." } 
{ $examples
  { $example "USING: logging.pmlog"
    ": main ( -- ) "
    "    [ main-code ] [ ] [ LOGEMERGENCY ] cleanup ;"
    " "
  }
}
{ $see-also
  \ LOGEMERGENCY"   ! "
} ;


HELP: LOGEMERGENCY"
{ $syntax "LOGEMERGENCY\" message\"" }
{ $values { "message" "a message string to syslog" } }
{ $description "Reads from the input string until the next occurrence of \" and creates a new message string and sends it to the syslog." }
{ $examples
  { $example "USING: logging.pmlog;" "LOGEMERENCY\" an emergency message\"" "" }
  { $example ": main ( -- ) "
    "    [ main-code ]"
    "    [ ] [ LOGEMERGENCY\" Emergency happened\" ]"
    "  cleanup ;"
    " "
  } 
} 
{ $see-also
  \ LOGEMERGENCY
} ;


! HELP: >LOGEMERGENCY
! { $syntax "string >LOGEMERGENCY" }
! { $values { "msg" string } }
! { $description "Sends message to syslogd using the EMERGENCY log level." } 
! { $examples
!   { $example ": main ( -- )"
!     "   [ main-code ]"
!     "   [ ]"
!     "   [ error value number>string"
!     "      \"Value: \" prepend >LOGEmergency "
!     "   ] cleanup ;"
!     ""
!   }
! }  
! { $see-also
!   \ LOGEMERGENCY
!   \ LOGEMERGENCY" ! "
! } ;



HELP: LOGALERT
{ $values { "msg" "string to send to syslog" } }
  { $description "Sends message to syslogd using the ALERT log level." } ;

HELP: LOGCRITICAL
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the CRITICAL log level." } ;

HELP: LOGWARNING
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the WARNING log level." } ;

HELP: LOGNOTICE
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the NOTICE log level." } ;

HELP: LOGINFO
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the INFO log level." } ;

HELP: LOGDEBUG
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the DEBUG log level." } ;

! HELP: LOGDEBUG"
! { $values { "msg" "string to send to syslog" } }
! { $description "Sends following string to syslogd using the DEBUG log level." } ;

HELP: LOGDEBUG1
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the DEBUG1 log level." } ;

HELP: LOGDEBUG2
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the DEBUG2 log level." } ;

HELP: LOGHERE
{ $description "Sends test message to syslogd regardless of log level."
  "Typically used to verify code is reached" } ;

! HELP: LOG" 
! { $values { "msg" "string to send to syslog" } }
! { $description "Sends note message to syslogd regardless of log level." } ;

HELP: LOG
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends note message to syslogd regardless of log level." } ;

! HELP: LOGERR
!   { $values
!     { "msg" "string to send to syslog" }
!     { "error" integer }
!   } 
!   { $description "Conditionally test the error value and sends test message to syslogd regardless of log level." } ;

! HELP: LOGERROR
! { $values { "msg" "string to send to syslog" } }
! { $description "Sends message to syslogd using the ERROR log level." } ;

HELP: LOGsetlevel
{ $values { "level" integer } }
{ $description "Sets the debugging level. LOG words with priority less than the level will not send messages to the syslog" } ;

HELP: LOGpoplevel
{ $description "Returns log level to previous level" } ;

HELP: LOGpushlevel
{ $values { "level" integer } }
{ $description "Saves the current log level and establishes a new log level. Use this to control log level in loops where you may not wish to view reams of information" }
;

HELP: LOGVALUE
{ $values
  { "msg" "string to send to syslog" }
  { "value" integer }
}
  { $description "Test message along with a value to syslogd regardless of log level." } ;

HELP: logLevelNone
{ $values
        { "value" integer }
}
{ $description "Value for no log level" } ;

HELP: logLevelEmergency
{ $values
        { "value" integer }
}
{ $description "Value for the EMERGENCY log level" } ;

HELP: logLevelAlert
{ $values
        { "value" integer }
}
{ $description "Value for the ALERT log level" } ;

HELP: logLevelCritical
{ $values
        { "value" integer }
}
{ $description "Value for the CRITICAL log level" } ;

HELP: logLevelError
{ $values
        { "value" integer }
}
{ $description "Value for the ERROR log level" } ;

HELP: logLevelWarning
{ $values
        { "value" integer }
}
{ $description "Value for the WARNING log level" } ;

HELP: logLevelInfo
{ $values
        { "value" integer }
}
{ $description "Value for the INFO log level" } ;

HELP: logLevelNotice
{ $values
        { "value" integer }
}
{ $description "Value for the NOTICE log level" } ;

HELP: logLevelDebug
{ $values
        { "value" integer }
}
{ $description "Value for the DEBUG log level" } ;

HELP: logLevelTest
{ $values
        { "value" integer }
}
{ $description "Value for the testing log level, log level is ignored." } ;

HELP: level>string
{ $values
    { "level" integer }
    { "string" string }
}
{ $description "Returns the string used for the log level" } ;


HELP: logLevel
{ $var-description "Current logging level" }
{ $see-also
  logLevel
  logStack
  logLevelIndex
  LOGsetlevel
  LOGpushlevel
  LOGpoplevel
}

;

HELP: logLevelIndex
{ $var-description "Holds the current index value into the log level stack" }
{ $see-also
  logLevel
  logStack
  logLevelIndex
  LOGsetlevel
  LOGpushlevel
  LOGpoplevel
}
;

HELP: logStack
{ $var-description "Holds an array of log levels." }
{ $see-also
  logLevel
  logStack
  logLevelIndex
  LOGsetlevel
  LOGpushlevel
  LOGpoplevel
}
;


