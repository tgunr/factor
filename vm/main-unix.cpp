#include "master.hpp"

#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>

#if defined(FACTOR_DEBUG) && defined(__arm64__)
void *try_mmap_jit(size_t size, int prot) {
    int map_flags = MAP_ANON | MAP_PRIVATE | MAP_JIT;
    printf("Try mmap with MAP_JIT: ");
    factor::print_prot_bits(prot);
    void *mem = mmap(NULL, size, prot, map_flags, -1, 0);
    if (mem == MAP_FAILED || mem == NULL) {
        printf(" FAIL: %s", strerror(errno));
        return NULL;
    }
    printf(" PASS: %p", mem);
    return mem;
}

void try_mprotect(void *mem, size_t size, int prot) {
    printf("Try mprotect: %p ", mem);
    factor::print_prot_bits(prot);
    if (mprotect(mem, size, prot) != 0)
        printf(" FAIL: %s", strerror(errno));
    else
        printf(" PASS");
}

void try_mmap_jit_and_mprotect(size_t size, int prot_mmap, int prot_mprotect) {
    void *addr = try_mmap_jit(size, prot_mmap);
    printf(" -> ");
    if (addr) {
        try_mprotect(addr, size, prot_mprotect);
    }
    putchar('\n');
}

void try_tests() {
    for (int prot_mmap = 0; prot_mmap < 8; prot_mmap++) {
        for (int prot_mprotect = 0; prot_mprotect < 8; prot_mprotect++) {
            try_mmap_jit_and_mprotect(4096, prot_mmap, prot_mprotect);
        }
    }
}
#endif

int main(int argc, char** argv) {
#if defined(FACTOR_DEBUG) && defined(__arm64__)
    try_tests();
#endif
    factor::init_mvm();
    factor::start_standalone_factor(argc, argv);
    return 0;
}
