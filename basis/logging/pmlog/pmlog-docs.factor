! Copyright (C) 2012 Dave Carlton
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
  \ LOG-EMERGENCY
  \ LOG-ALERT
  \ LOG-CRITICAL
  \ LOG-ERROR
  \ LOG-WARNING
  \ LOG-NOTICE
  \ LOG-INFO
  \ LOG-DEBUG
  \ LOG
  \ LOG-HERE
} 

$nl
"Global Control"
{ $subsections
  logLevel
  LOG-setlevel
  LOG-setfacility
  LOG-pushlevel
  LOG-poplevel
}

"Log Levels"
{ $subsections
  LOG_NONE      
  LOG_EMERG     
  LOG_ALERT     
  LOG_CRIT  
  LOG_ERR  
  LOG_WARNING   
  LOG_NOTICE    
  LOG_INFO      
  LOG_DEBUG     
  LOG_TEST    
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
    "    [ main-code ] [ ] [ LOG-INFO ] cleanup ;"
  } 
$nl
"LOG\" - Sends the following string terminated by a \""
$nl
    ;

HELP: LOG-EMERGENCY
{ $syntax "LOG-EMERGENCY" }
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the EMERGENCY log level." } 
{ $examples
  { $example "USING: logging.pmlog"
    ": main ( -- ) "
    "    [ main-code ] [ ] [ LOG-EMERGENCY ] cleanup ;"
    " "
  }
}
{ $see-also
  \ LOG-EMERGENCY"   ! "
} ;


HELP: LOG-EMERGENCY"
{ $syntax "LOG-EMERGENCY\" message\"" }
{ $values { "message" "a message string to syslog" } }
{ $description "Reads from the input string until the next occurrence of \" and creates a new message string and sends it to the syslog." }
{ $examples
  { $example "USING: logging.pmlog;" "LOG-EMERENCY\" an emergency message\"" "" }
  { $example ": main ( -- ) "
    "    [ main-code ]"
    "    [ ] [ LOG-EMERGENCY\" Emergency happened\" ]"
    "  cleanup ;"
    " "
  } 
} 
{ $see-also
  \ LOG-EMERGENCY
} ;


HELP: LOG-ALERT
{ $values { "msg" "string to send to syslog" } }
  { $description "Sends message to syslogd using the ALERT log level." } ;

HELP: LOG-CRITICAL
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the CRITICAL log level." } ;

HELP: LOG-WARNING
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the WARNING log level." } ;

HELP: LOG-NOTICE
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the NOTICE log level." } ;

HELP: LOG-INFO
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the INFO log level." } ;

HELP: LOG-DEBUG
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the DEBUG log level." } ;

HELP: LOG-DEBUG"
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends following string to syslogd using the DEBUG log level." } ;

HELP: LOG-HERE
{ $description "Sends test message to syslogd regardless of log level."
  "Typically used to verify code is reached" } ;

HELP: LOG
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends note message to syslogd regardless of log level." } ;

HELP: LOG" 
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends note message to syslogd regardless of log level." } ;

HELP: LOG-setlevel
{ $values { "level" integer } }
{ $description "Sets the debugging level. LOG words with priority less than the level will not send messages to the syslog" } ;

HELP: LOG-poplevel
{ $description "Returns log level to previous level" } ;

HELP: LOG-pushlevel
{ $values { "level" integer } }
{ $description "Saves the current log level and establishes a new log level. Use this to control log level in loops where you may not wish to view reams of information" }
;

HELP: LOG_NONE
{ $values
        { "value" integer }
}
{ $description "Value for no log level" } 
{ $notes "This disables all logging except for logLevelTest" }
;

HELP: LOG_EMERG
{ $values
        { "value" integer }
}
{ $description "Value for the EMERGENCY log level" } ;

HELP: LOG_ALERT
{ $values
        { "value" integer }
}
{ $description "Value for the ALERT log level" } ;

HELP: LOG_CRIT
{ $values
        { "value" integer }
}
{ $description "Value for the CRITICAL log level" } ;

HELP: LOG_ERR
{ $values
        { "value" integer }
}
{ $description "Value for the ERROR log level" } ;

HELP: LOG_WARNING
{ $values
        { "value" integer }
}
{ $description "Value for the WARNING log level" } ;

HELP: LOG_INFO
{ $values
        { "value" integer }
}
{ $description "Value for the INFO log level" } ;

HELP: LOG_NOTICE
{ $values
        { "value" integer }
}
{ $description "Value for the NOTICE log level" } ;

HELP: LOG_DEBUG
{ $values
        { "value" integer }
}
{ $description "Value for the DEBUG log level" } ;

HELP: LOG_TEST
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
  LOG-setlevel
  LOG-pushlevel
  LOG-poplevel
}

;

HELP: logLevelIndex
{ $var-description "Holds the current index value into the log level stack" }
{ $see-also
  logLevel
  logStack
  logLevelIndex
  LOG-setlevel
  LOG-pushlevel
  LOG-poplevel
}
;

HELP: logStack
{ $var-description "Holds an array of log levels." }
{ $see-also
  logLevel
  logStack
  logLevelIndex
  LOG-setlevel
  LOG-pushlevel
  LOG-poplevel
}
;


