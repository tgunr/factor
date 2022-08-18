namespace factor {

#include <sys/syscall.h>
#include <unistd.h>
#include <libkern/OSCacheControl.h>

#define FACTOR_CPU_STRING "arm.64"

#define __ARM_NR_cacheflush 0x0f0002

static const unsigned SIGNAL_HANDLER_STACK_FRAME_SIZE = 192;

inline static void flush_icache(cell start, cell len) {
    sys_icache_invalidate((void *)start, (size_t)len);
}

}
