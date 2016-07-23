//
//  syslogger.c
//  syslogger
//
//  Created by Dave Carlton on 7/23/16.
//  Copyright © 2016 Polymicro Systems. All rights reserved.
//

#include "syslogger.h"

#include <syslog.h>

void openlogger(const char *ident, int option, int facility) {
    openlog(ident, option, facility);
}

void syslogger(int priority, const char *msg) {
    syslog(priority, "%s", msg);
}

void closelogger(void) {
    closelog();
}

void vsyslogger(int priority, const char *format, va_list ap) {
    vsyslog(priority, format, ap);
}

#include <stdarg.h>

