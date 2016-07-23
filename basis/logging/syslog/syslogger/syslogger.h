//
//  syslogger.h
//  syslogger
//
//  Created by Dave Carlton on 7/23/16.
//  Copyright © 2016 Polymicro Systems. All rights reserved.
//

#ifndef syslogger_h
#define syslogger_h

#include <stdio.h>

#include <syslog.h>

void openlogger(const char *ident, int option, int facility);
void syslogger(int priority, const char *msg);
void closelogger(void);

#include <stdarg.h>

void vsyslogger(int priority, const char *format, va_list ap);

#endif /* syslogger_h */
