! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel math strings ;

IN: syslog

HELP: SYSLOG
{ $values
  { "format-string" "Formatted sstring to send to syslog" }
}
{ $description "Sends message to syslog. Message is sent using LOG_DEBUG2 level" } ;

HELP: (SYSLOG-WORD)
{ $values
  { "defined-word" "Word to embed in beginning of msg" }
  { "level" "Log level to be used for msg" }
  { "msg" "Log message to be sent to syslog" }
}
{ $description "Formats a message to be sent to the syslog. The defining word is embedded at start of message" } ;

HELP: SYSLOG-Level-String
{ $values
    { "level" integer }
    { "string" string }
}
{ $description "Returns the string used for the log level" } ;

HELP: SYSLOG_TESTING
{ $description "Set to t to force logging regardless of log level." } ;

HELP: SYSLOGLEVEL-TEST
{ $description "Testing word to send a msg with each production log level. Results should be visible in your syslog." } ;

HELP: SYSLOG-WITHLEVEL
{ $values
  { "msg" "string to send to syslog" }
  { "level" "log level" }    
}
{ $description "Sends message to syslogd using the specified log level." } ;

HELP: SYSLOG-ALERT
{ $values { "msg" "string to send to syslog" } }
  { $description "Sends message to syslogd using the ALERT log level." } ;

HELP: SYSLOG-CRITICAL
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the CRITICAL log level." } ;

HELP: SYSLOG-DEBUG
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the DEBUG log level." } ;

HELP: SYSLOG-EMERG
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the EMERGENCY log level." } ;

HELP: SYSLOG-ERR
  { $values
    { "msg" "string to send to syslog" }
    { "error" integer }
  } 
  { $description "Conditionally test the error value and sends test message to syslogd regardless of log level." } ;

HELP: SYSLOG-ERROR
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the ERROR log level." } ;

HELP: SYSLOG-HERE
{ $description "Sends test message to syslogd regardless of log level. Commonly used to just verify code is reached" } ;

HELP: SYSLOG-INFO
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the INFO log level." } ;

HELP: SYSLOG-NOTE
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends note message to syslogd regardless of log level." } ;

HELP: SYSLOG-NOTICE
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the NOTICE log level." } ;

HELP: SYSLOG-POP
{ $description "Returns log level to previous level" } ;

HELP: SYSLOG-PUSH
{ $values
    { "level" integer }    
}
{ $description "Saves the current log level and establishes a new log level. Use this to control log level in loops where you may not wish to view reams of information" }
;

HELP: SYSLOG-LEVELGET
{ $values
    { "level" integer }    
}
{ $description "Get the current log level." } ;

HELP: SYSLOG-LEVELSET
{ $values
    { "level" integer }    
}
{ $description "Set the current log level." } ;

HELP: SYSLOG-VALUE
{ $values
  { "msg" "string to send to syslog" }
  { "value" integer }
}
  { $description "Test message along with a value to syslogd regardless of log level." } ;

HELP: SYSLOG-WARNING
{ $values { "msg" "string to send to syslog" } }
{ $description "Sends message to syslogd using the WARNING log level." } ;

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

HELP: LOG_DEBUG
{ $values
        { "value" integer }
}
{ $description "Value for the DEBUG log level" } ;

HELP: LOG_EMERG
{ $values
        { "value" integer }
}
{ $description "Value for the EMERGENCY log level" } ;

HELP: LOG_ERR
{ $values
        { "value" integer }
}
{ $description "Value for the ERROR log level" } ;

HELP: LOG_INFO
{ $values
        { "value" integer }
}
{ $description "Value for the INFO log level" } ;

HELP: LOG_NONE
{ $values
        { "value" integer }
}
{ $description "Value for no log level" } ;

HELP: LOG_NOTICE
{ $values
        { "value" integer }
}
{ $description "Value for the NOTICE log level" } ;

HELP: LOG_WARNING
{ $values
        { "value" integer }
}
{ $description "Value for the WARNING log level" } ;

HELP: SYSLOG-TEST
{ $description "Sends log message regardless of logging level. Use this during testing." } ;

HELP: sysLogLevel
{ $var-description "Current logging level" }
{ $see-also
  sysLogLevel
  sysLogStack
  sysLogLevelIndex
  SYSLOG-TESTING-SET
  SYSLOG-PUSH
  SYSLOG-POP
}
;

HELP: sysLogLevelIndex
{ $var-description "Holds the current index value into the log level stack" }
{ $see-also
  sysLogLevel
  sysLogStack
  sysLogLevelIndex
  SYSLOG-TESTING-SET
  SYSLOG-PUSH
  SYSLOG-POP
}
  ;

HELP: sysLogStack
{ $var-description "Holds an array of log levels." }
{ $see-also
  sysLogLevel
  sysLogStack
  sysLogLevelIndex
  SYSLOG-TESTING-SET
  SYSLOG-PUSH
  SYSLOG-POP
}
;

ARTICLE: "syslog" "SYSLOG: A vocabulary for creating syslog entries"
"This vocabulary defines words to create syslog entries. The vocabulary behaves basically as you would expect. If the priority level of the message to send to syslogd is less than the global log level value it will be sent, otherwise discarded." $nl

"Message verbosity increases with the log level being invoked with EMERGENCY being the lowest level and highest priority and DEBUG is the highest level and lowest priority" $nl

"This permits leaving logging words in production code to issue messages of interest. The default log level is ERROR. Messages with priority greater than ERROR will not be sent unless the global level is raised." $nl

"During testing several words exist which will issue message regardless of the global level. It is expected you will remove such words before shipping the code"
$nl

"Global Control"
{ $subsections
  sysLogLevel
  SYSLOG-TESTING-SET
  SYSLOG-PUSH
  SYSLOG-POP
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
  LOG_DEBUG1    
  LOG_DEBUG2    
}

"Logging Words"
{ $subsections
  SYSLOG-TEST
  SYSLOG-EMERG
  SYSLOG-ALERT
  SYSLOG-CRITICAL
  SYSLOG-ERROR
  SYSLOG-WARNING
  SYSLOG-NOTICE
  SYSLOG-INFO
  SYSLOG-DEBUG
}

"Test Words"
{ $subsections
  SYSLOG-WITHLEVEL
  SYSLOG-ERR
  SYSLOG-VALUE
  SYSLOG-NOTE
  SYSLOG-HERE
}


{ $vocab-link "syslog" }
;

ABOUT: "syslog"
