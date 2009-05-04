#include <ucontext.h>

inline static void *ucontext_stack_pointer(void *uap)
{
        ucontext_t *ucontext = (ucontext_t *)uap;
        return (void *)ucontext->uc_mcontext.mc_rsp;
}

#define UAP_PROGRAM_COUNTER(ucontext) (((ucontext_t *)(ucontext))->uc_mcontext.mc_rip)
