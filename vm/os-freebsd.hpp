#include <osreldate.h>
#include <sys/sysctl.h>

extern "C" int getosreldate(void);

#ifndef KERN_PROC_PATHNAME
#define KERN_PROC_PATHNAME 12
#endif
