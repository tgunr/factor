! Copyright (C) 2012 Dave Carlton
! See http://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax kernel math sequences
strings logging ;

IN: help.markup
: $logwords ( element -- )
    "Log Words" $heading
    unclip print-element [ \ $link swap ] { } map>assoc $list ;

IN: logging.pmlog

ABOUT: "about"

ARTICLE: "about" "A vocabulary for creating syslog messages"
"The " { $vocab-link "pmlog" } " vocabulary implements a comprehensive logging framework"
"suitable for production applications."
"The vocabulary behaves basically as you would expect."
"If the priority level of the message to send to syslogd is less"
"than the global log level value it will be sent, otherwise discarded."
$nl
"Message verbosity increases with the log level being invoked"
"with LOG_EMERG being the lowest level and highest priority"
"and LOG_DEBUG is the highest level and lowest priority"
$nl
"This permits leaving logging words in production code to issue messages"
"of interest. The default log level is " { $link LOG_INFO } "Messages with priority"
"greater than LOG_INFO will not be sent unless the global level is raised."
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

{ $subsections
    "usage"
    "levels"
    "facilities"
    "control"
} ;

ARTICLE: "usage" "Log Words"
"The log words will send to the" "syslog" $strong "information"
"about the definition containing the log word. Each log word will send"
"the file and line number of the word, the name of the defintion, along"
"with any string message."
"This information will permit you to filter the log messages when"
"searching for massges of certain words or debug levels"
"In addition, there exists a word " { $link LOG-open } "which can be used to"
"set the parameters to " { $snippet openlog } "the forst of which is a identifer string"
"for each message. The default value is " { $emphasis "PMLOG" } "which can be used to"
"filter your log messages"
$nl
"Each logging word has word kinds of logging variations."
$nl
"LOG-word - Sends just the basic information."
  { $code 
    ": main ( -- ) "
    "    [ main-code ] [ ] [ LOG-EMERG ] cleanup ;"
    ""
  }
  { $examples
    { $snippet "Aug 16 06:32:53 iMacM1 PMLOG[79134]: LOG_EMERG     : { \"resource:basis/logging/pmlog/pmlog-tests.factor\" 9 } main:" }
  }

$nl

"LOG-word\" - Sends the following string terminated by a \""
  { $code 
    ": main ( -- ) "
    "    [ main-code ] [ ] [ LOG-EMERG\" Failure!\" ] cleanup ;"
    ""
  }
  { $examples
    { $snippet "Aug 16 06:32:53 iMacM1 PMLOG[79134]: LOG_EMERG     : { \"resource:basis/logging/pmlog/pmlog-tests.factor\" 9 } main: Failure!" }
  }


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

ARTICLE: "levels" "Log Levels"
"Log levels correspond to the syslog.h header equivilents"
"Each Syslog message includes a string indicating the level value at the beginning of the text."
"The priority ranges from LOG_EMERG to LOG_TEST and is not space padded. A priority begins with the text "
{ $strong "LOG" } "E.g. LOG_INFO HEADER MESSAGE." 
$nl
"You may use this convention to create filters for your syslog"

{ $examples
  { $snippet "Aug 16 06:32:53 iMacM1 PMLOG[79134]: LOG_ERR     : { \"resource:basis/logging/pmlog/pmlog-tests.factor\" 9 } LOG-LEVEL-TEST: Error"
}
}
$nl
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
} ;

ARTICLE: "facilities" "Log Facilities"
"Log facilities correspond to the syslog.h header equivilents"
$nl
"The facility represents the machine process that created the Syslog event. For example, in the event created by the kernel, by the mail system, by security/authorization processes, etc.? In the context of this field, the facility represents a kind of filter, sending only those events whose facility matches the one defined in this field. So by changing the facility number and/or the severity level, you change the number of alerts (messages) that are sent to the syslog"
$nl
"List of available Facilities as per RFC5424:"

{ $table 
  { "Facility" "Value" "Description" }
  { { $link LOG_KERN } "0" "Kernel messages " }
  { { $link LOG_USER } "1" "User-level messages " } 
  { { $link LOG_MAIL } "2" "Mail System " }
  { { $link LOG_DAEMON } "3" "System Daemons " }
  { { $link LOG_AUTH } "4" "Security/Authorization Messages " }
  { { $link LOG_SYSLOG } "5" "Messages generated by syslogd " }
  { { $link LOG_LPR } "6" "Line Printer Subsystem " }
  { { $link LOG_NEWS } "7" "Network News Subsystem " }
  { { $link LOG_UUCP } "8" "UUCP Subsystem " }
  { { $link LOG_CRON } "9" "Clock Daemon " }
  { { $link LOG_AUTHPRIV } "10" "Security/Authorization Messages " }
  { { $link LOG_FTP } "11" "FTP Daemon " }
  { { $link LOG_NETINFO } "12" "NTP Subsystem " }
  { { $link LOG_REMOTEAUTH } "13" "Log Audit " }
  { { $link LOG_INSTALL } "14" "Log Alert " }
  { { $link LOG_RAS } "15" "Clock Daemon " }
  { { $link LOG_LOCAL0 } "16" "Local Use 0 " }
  { { $link LOG_LOCAL1 } "17" "Local Use 1 " }
  { { $link LOG_LOCAL2 } "18" "Local Use 2 " }
  { { $link LOG_LOCAL3 } "19" "Local Use 3 " }
  { { $link LOG_LOCAL4 } "20" "Local Use 4 " }
  { { $link LOG_LOCAL5 } "21" "Local Use 5 " }
  { { $link LOG_LOCAL6 } "22" "Local Use 6 " }
  { { $link LOG_LOCAL7 } "23" "Local Use 7 " }
}
;

ARTICLE: "control" "Log Control"
"These words control the logging and are intended for use when multiple levels are logging are needed. For eaxmple your default log level is LOG_INFO and you want to increase the level to LOG_DEBUG but don't want all of your other words containing LOG_DEBUG to display which is what would happen if you set the global level to LOG_DEBUG. In this situation, you would use the control word " { $link LOG-pushlevel } " to set the LOG_DEBUG level then use " { $link LOG-poplevel } "to restore at the word exit point."

"Logging Control"
{ $subsections
  LOG-open
  LOG-setlevel
  LOG-setfacility
  LOG-pushlevel
  LOG-poplevel
} ;

HELP: LOG-setfacility 
{ $description "Sets the facility value" }
{ $values { "facility" { $link "facilities" } } }
;

HELP: LOG-setlevel
{ $values { "level" integer } }
{ $description "Sets the debugging level. LOG words with priority less than the level will not send messages to the syslog" } ;

HELP: LOG-poplevel
{ $description "Returns log level to previous level" } ;

HELP: LOG-pushlevel
{ $values { "level" integer } }
{ $description "Saves the current log level and establishes a new log level. Use this to control log level in loops where you may not wish to view reams of information" }
;

IN: logging.pmlog.private 

HELP: level>string
{ $values
    { "level" integer }
    { "string" string }
}
{ $description "Returns the string used for the log level" } ;


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

HELP: logLevel
{ $var-description "Current logging level" }
{ $see-also
  logLevel
  logStack
  logLevelIndex
  LOG-setlevel
  LOG-pushlevel
  LOG-poplevel
} ;

