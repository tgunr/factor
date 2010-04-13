! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: elf.nm io io.streams.string kernel multiline strings tools.test
literals ;
IN: elf.nm.tests

STRING: validation-output
0000000000000000 absolute         init.c
0000000004195436 .text            call_gmon_start
0000000000000000 absolute         crtstuff.c
0000000006295064 .ctors           __CTOR_LIST__
0000000006295080 .dtors           __DTOR_LIST__
0000000006295096 .jcr             __JCR_LIST__
0000000004195472 .text            __do_global_dtors_aux
0000000006295584 .bss             completed.7342
0000000006295592 .bss             dtor_idx.7344
0000000004195584 .text            frame_dummy
0000000000000000 absolute         crtstuff.c
0000000006295072 .ctors           __CTOR_END__
0000000004196056 .eh_frame        __FRAME_END__
0000000006295096 .jcr             __JCR_END__
0000000004195808 .text            __do_global_ctors_aux
0000000000000000 absolute         test.c
0000000006295528 .got.plt         _GLOBAL_OFFSET_TABLE_
0000000006295060 .ctors           __init_array_end
0000000006295060 .ctors           __init_array_start
0000000006295104 .dynamic         _DYNAMIC
0000000006295568 .data            data_start
0000000000000000 undefined        printf@@GLIBC_2.2.5
0000000004195648 .text            __libc_csu_fini
0000000004195392 .text            _start
0000000000000000 undefined        __gmon_start__
0000000000000000 undefined        _Jv_RegisterClasses
0000000004195864 .fini            _fini
0000000000000000 undefined        __libc_start_main@@GLIBC_2.2.5
0000000004195880 .rodata          _IO_stdin_used
0000000006295568 .data            __data_start
0000000006295576 .data            __dso_handle
0000000006295088 .dtors           __DTOR_END__
0000000004195664 .text            __libc_csu_init
0000000006295584 absolute         __bss_start
0000000006295600 absolute         _end
0000000006295584 absolute         _edata
0000000004195620 .text            main
0000000004195312 .init            _init

;

{ $ validation-output }
[ <string-writer> dup [ "resource:extra/elf/a.elf" nm ] with-output-stream >string ]
unit-test
