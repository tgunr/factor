! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays io.binary kernel combinators kernel.private math
namespaces make sequences words system layouts math.order accessors
cpu.x86.assembler.syntax ;
QUALIFIED: sequences
IN: cpu.x86.assembler

! A postfix assembler for x86-32 and x86-64.

! In 32-bit mode, { 1234 } is absolute indirect addressing.
! In 64-bit mode, { 1234 } is RIP-relative.
! Beware!

! Register operands -- eg, ECX
REGISTERS: 8 AL CL DL BL SPL BPL SIL DIL R8B R9B R10B R11B R12B R13B R14B R15B ;

ALIAS: AH SPL
ALIAS: CH BPL
ALIAS: DH SIL
ALIAS: BH DIL

REGISTERS: 16 AX CX DX BX SP BP SI DI R8W R9W R10W R11W R12W R13W R14W R15W ;

REGISTERS: 32 EAX ECX EDX EBX ESP EBP ESI EDI R8D R9D R10D R11D R12D R13D R14D R15D ;

REGISTERS: 64
RAX RCX RDX RBX RSP RBP RSI RDI R8 R9 R10 R11 R12 R13 R14 R15 ;

REGISTERS: 128
XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7
XMM8 XMM9 XMM10 XMM11 XMM12 XMM13 XMM14 XMM15 ;

TUPLE: byte value ;

C: <byte> byte

<PRIVATE

#! Extended AMD64 registers (R8-R15) return true.
GENERIC: extended? ( op -- ? )

M: object extended? drop f ;

PREDICATE: register < word
    "register" word-prop ;

PREDICATE: register-8 < register
    "register-size" word-prop 8 = ;

PREDICATE: register-16 < register
    "register-size" word-prop 16 = ;

PREDICATE: register-32 < register
    "register-size" word-prop 32 = ;

PREDICATE: register-64 < register
    "register-size" word-prop 64 = ;

PREDICATE: register-128 < register
    "register-size" word-prop 128 = ;

M: register extended? "register" word-prop 7 > ;

! Addressing modes
TUPLE: indirect base index scale displacement ;

M: indirect extended? base>> extended? ;

: canonicalize-EBP ( indirect -- indirect )
    #! { EBP } ==> { EBP 0 }
    dup [ base>> { EBP RBP R13 } member? ] [ displacement>> not ] bi and
    [ 0 >>displacement ] when ;

ERROR: bad-index indirect ;

: check-ESP ( indirect -- indirect )
    dup index>> { ESP RSP } memq? [ bad-index ] when ;

: canonicalize ( indirect -- indirect )
    #! Modify the indirect to work around certain addressing mode
    #! quirks.
    canonicalize-EBP check-ESP ;

: <indirect> ( base index scale displacement -- indirect )
    indirect boa canonicalize ;

: reg-code ( reg -- n ) "register" word-prop 7 bitand ;

: indirect-base* ( op -- n ) base>> EBP or reg-code ;

: indirect-index* ( op -- n ) index>> ESP or reg-code ;

: indirect-scale* ( op -- n ) scale>> 0 or ;

GENERIC: sib-present? ( op -- ? )

M: indirect sib-present?
    [ base>> { ESP RSP R12 } member? ] [ index>> ] [ scale>> ] tri or or ;

M: register sib-present? drop f ;

GENERIC: r/m ( operand -- n )

M: indirect r/m
    dup sib-present?
    [ drop ESP reg-code ] [ indirect-base* ] if ;

M: register r/m reg-code ;

! Immediate operands
UNION: immediate byte integer ;

GENERIC: fits-in-byte? ( value -- ? )

M: byte fits-in-byte? drop t ;

M: integer fits-in-byte? -128 127 between? ;

GENERIC: modifier ( op -- n )

M: indirect modifier
    dup base>> [
        displacement>> {
            { [ dup not ] [ BIN: 00 ] }
            { [ dup fits-in-byte? ] [ BIN: 01 ] }
            { [ dup immediate? ] [ BIN: 10 ] }
        } cond nip
    ] [
        drop BIN: 00
    ] if ;

M: register modifier drop BIN: 11 ;

GENERIC# n, 1 ( value n -- )

M: integer n, >le % ;
M: byte n, [ value>> ] dip n, ;
: 1, ( n -- ) 1 n, ; inline
: 4, ( n -- ) 4 n, ; inline
: 2, ( n -- ) 2 n, ; inline
: cell, ( n -- ) bootstrap-cell n, ; inline

: mod-r/m, ( reg# indirect -- )
    [ 3 shift ] [ [ modifier 6 shift ] [ r/m ] bi ] bi* bitor bitor , ;

: sib, ( indirect -- )
    dup sib-present? [
        [ indirect-base* ]
        [ indirect-index* 3 shift ]
        [ indirect-scale* 6 shift ] tri bitor bitor ,
    ] [
        drop
    ] if ;

GENERIC: displacement, ( op -- )

M: indirect displacement,
    dup displacement>> dup [
        swap base>>
        [ dup fits-in-byte? [ , ] [ 4, ] if ] [ 4, ] if
    ] [
        2drop
    ] if ;

M: register displacement, drop ;

: addressing ( reg# indirect -- )
    [ mod-r/m, ] [ sib, ] [ displacement, ] tri ;

! Utilities
UNION: operand register indirect ;

GENERIC: operand-64? ( operand -- ? )

M: indirect operand-64?
    [ base>> ] [ index>> ] bi [ operand-64? ] either? ;

M: register-64 operand-64? drop t ;

M: object operand-64? drop f ;

: rex.w? ( rex.w reg r/m -- ? )
    {
        { [ dup register-128? ] [ drop operand-64? ] }
        { [ dup not ] [ drop operand-64? ] }
        [ nip operand-64? ]
    } cond and ;

: rex.r ( m op -- n )
    extended? [ BIN: 00000100 bitor ] when ;

: rex.b ( m op -- n )
    [ extended? [ BIN: 00000001 bitor ] when ] keep
    dup indirect? [
        index>> extended? [ BIN: 00000010 bitor ] when
    ] [
        drop
    ] if ;

: rex-prefix ( reg r/m rex.w -- )
    #! Compile an AMD64 REX prefix.
    2over rex.w? BIN: 01001000 BIN: 01000000 ?
    swap rex.r swap rex.b
    dup BIN: 01000000 = [ drop ] [ , ] if ;

: 16-prefix ( reg r/m -- )
    [ register-16? ] either? [ HEX: 66 , ] when ;

: prefix ( reg r/m rex.w -- ) 2over 16-prefix rex-prefix ;

: prefix-1 ( reg rex.w -- ) f swap prefix ;

: short-operand ( reg rex.w n -- )
    #! Some instructions encode their single operand as part of
    #! the opcode.
    [ dupd prefix-1 reg-code ] dip + , ;

: opcode, ( opcode -- ) dup array? [ % ] [ , ] if ;

: extended-opcode ( opcode -- opcode' ) OCT: 17 swap 2array ;

: ssse3-opcode ( opcode -- opcode' ) OCT: 17 sequences:prefix ;

: extended-opcode, ( opcode -- ) extended-opcode opcode, ;

: opcode-or ( opcode mask -- opcode' )
    swap dup array?
    [ unclip-last rot bitor suffix ] [ bitor ] if ;

: 1-operand ( op reg,rex.w,opcode -- )
    #! The 'reg' is not really a register, but a value for the
    #! 'reg' field of the mod-r/m byte.
    first3 [ [ over ] dip prefix-1 ] dip opcode, swap addressing ;

: immediate-operand-size-bit ( imm dst reg,rex.w,opcode -- imm dst reg,rex.w,opcode )
    pick integer? [ first3 BIN: 1 opcode-or 3array ] when ;

: immediate-1 ( imm dst reg,rex.w,opcode -- )
    immediate-operand-size-bit 1-operand 1, ;

: immediate-4 ( imm dst reg,rex.w,opcode -- )
    immediate-operand-size-bit 1-operand 4, ;

: immediate-fits-in-size-bit ( imm dst reg,rex.w,opcode -- imm dst reg,rex.w,opcode )
    pick integer? [ first3 BIN: 10 opcode-or 3array ] when ;

: immediate-1/4 ( imm dst reg,rex.w,opcode -- )
    #! If imm is a byte, compile the opcode and the byte.
    #! Otherwise, set the 8-bit operand flag in the opcode, and
    #! compile the cell. The 'reg' is not really a register, but
    #! a value for the 'reg' field of the mod-r/m byte.
    pick fits-in-byte? [
        immediate-fits-in-size-bit immediate-1
    ] [
        immediate-4
    ] if ;

: (2-operand) ( dst src op -- )
    [ 2dup t rex-prefix ] dip opcode,
    reg-code swap addressing ;

: direction-bit ( dst src op -- dst' src' op' )
    pick register? pick register? not and
    [ BIN: 10 opcode-or swapd ] when ;

: operand-size-bit ( dst src op -- dst' src' op' )
    over register-8? [ BIN: 1 opcode-or ] unless ;

: 2-operand ( dst src op -- )
    #! Sets the opcode's direction bit. It is set if the
    #! destination is a direct register operand.
    2over 16-prefix
    direction-bit
    operand-size-bit
    (2-operand) ;

PRIVATE>

: [] ( reg/displacement -- indirect )
    dup integer? [ [ f f f ] dip ] [ f f f ] if <indirect> ;

: [+] ( reg displacement -- indirect )
    dup integer?
    [ dup zero? [ drop f ] when [ f f ] dip ]
    [ f f ] if
    <indirect> ;

! Moving stuff
GENERIC: PUSH ( op -- )
M: register PUSH f HEX: 50 short-operand ;
M: immediate PUSH HEX: 68 , 4, ;
M: operand PUSH { BIN: 110 f HEX: ff } 1-operand ;

GENERIC: POP ( op -- )
M: register POP f HEX: 58 short-operand ;
M: operand POP { BIN: 000 f HEX: 8f } 1-operand ;

! MOV where the src is immediate.
GENERIC: (MOV-I) ( src dst -- )
M: register (MOV-I) t HEX: b8 short-operand cell, ;
M: operand (MOV-I)
    { BIN: 000 t HEX: c6 }
    pick byte? [ immediate-1 ] [ immediate-4 ] if ;

GENERIC: MOV ( dst src -- )
M: immediate MOV swap (MOV-I) ;
M: operand MOV HEX: 88 2-operand ;

: LEA ( dst src -- ) swap HEX: 8d 2-operand ;

! Control flow
GENERIC: JMP ( op -- )
M: integer JMP HEX: e9 , 4, ;
M: operand JMP { BIN: 100 t HEX: ff } 1-operand ;

GENERIC: CALL ( op -- )
M: integer CALL HEX: e8 , 4, ;
M: operand CALL { BIN: 010 t HEX: ff } 1-operand ;

GENERIC# JUMPcc 1 ( addr opcode -- )
M: integer JUMPcc extended-opcode, 4, ;

: JO  ( dst -- ) HEX: 80 JUMPcc ;
: JNO ( dst -- ) HEX: 81 JUMPcc ;
: JB  ( dst -- ) HEX: 82 JUMPcc ;
: JAE ( dst -- ) HEX: 83 JUMPcc ;
: JE  ( dst -- ) HEX: 84 JUMPcc ; ! aka JZ
: JNE ( dst -- ) HEX: 85 JUMPcc ;
: JBE ( dst -- ) HEX: 86 JUMPcc ;
: JA  ( dst -- ) HEX: 87 JUMPcc ;
: JS  ( dst -- ) HEX: 88 JUMPcc ;
: JNS ( dst -- ) HEX: 89 JUMPcc ;
: JP  ( dst -- ) HEX: 8a JUMPcc ;
: JNP ( dst -- ) HEX: 8b JUMPcc ;
: JL  ( dst -- ) HEX: 8c JUMPcc ;
: JGE ( dst -- ) HEX: 8d JUMPcc ;
: JLE ( dst -- ) HEX: 8e JUMPcc ;
: JG  ( dst -- ) HEX: 8f JUMPcc ;

: LEAVE ( -- ) HEX: c9 , ;

: RET ( n -- )
    dup zero? [ drop HEX: c3 , ] [ HEX: c2 , 2, ] if ;

! Arithmetic

GENERIC: ADD ( dst src -- )
M: immediate ADD swap { BIN: 000 t HEX: 80 } immediate-1/4 ;
M: operand ADD OCT: 000 2-operand ;

GENERIC: OR ( dst src -- )
M: immediate OR swap { BIN: 001 t HEX: 80 } immediate-1/4 ;
M: operand OR OCT: 010 2-operand ;

GENERIC: ADC ( dst src -- )
M: immediate ADC swap { BIN: 010 t HEX: 80 } immediate-1/4 ;
M: operand ADC OCT: 020 2-operand ;

GENERIC: SBB ( dst src -- )
M: immediate SBB swap { BIN: 011 t HEX: 80 } immediate-1/4 ;
M: operand SBB OCT: 030 2-operand ;

GENERIC: AND ( dst src -- )
M: immediate AND swap { BIN: 100 t HEX: 80 } immediate-1/4 ;
M: operand AND OCT: 040 2-operand ;

GENERIC: SUB ( dst src -- )
M: immediate SUB swap { BIN: 101 t HEX: 80 } immediate-1/4 ;
M: operand SUB OCT: 050 2-operand ;

GENERIC: XOR ( dst src -- )
M: immediate XOR swap { BIN: 110 t HEX: 80 } immediate-1/4 ;
M: operand XOR OCT: 060 2-operand ;

GENERIC: CMP ( dst src -- )
M: immediate CMP swap { BIN: 111 t HEX: 80 } immediate-1/4 ;
M: operand CMP OCT: 070 2-operand ;

GENERIC: TEST ( dst src -- )
M: immediate TEST swap { BIN: 0 t HEX: f7 } immediate-4 ;
M: operand TEST OCT: 204 2-operand ;

: XCHG ( dst src -- ) OCT: 207 2-operand ;

: BSR ( dst src -- ) swap { HEX: 0f HEX: bd } (2-operand) ;

: NOT  ( dst -- ) { BIN: 010 t HEX: f7 } 1-operand ;
: NEG  ( dst -- ) { BIN: 011 t HEX: f7 } 1-operand ;
: MUL  ( dst -- ) { BIN: 100 t HEX: f7 } 1-operand ;
: IMUL ( src -- ) { BIN: 101 t HEX: f7 } 1-operand ;
: DIV  ( dst -- ) { BIN: 110 t HEX: f7 } 1-operand ;
: IDIV ( src -- ) { BIN: 111 t HEX: f7 } 1-operand ;

: CDQ ( -- ) HEX: 99 , ;
: CQO ( -- ) HEX: 48 , CDQ ;

: (SHIFT) ( dst src op -- )
    over CL eq? [
        nip t HEX: d3 3array 1-operand
    ] [
        swapd t HEX: c0 3array immediate-1
    ] if ; inline

: ROL ( dst n -- ) BIN: 000 (SHIFT) ;
: ROR ( dst n -- ) BIN: 001 (SHIFT) ;
: RCL ( dst n -- ) BIN: 010 (SHIFT) ;
: RCR ( dst n -- ) BIN: 011 (SHIFT) ;
: SHL ( dst n -- ) BIN: 100 (SHIFT) ;
: SHR ( dst n -- ) BIN: 101 (SHIFT) ;
: SAR ( dst n -- ) BIN: 111 (SHIFT) ;

: IMUL2 ( dst src -- )
    OCT: 257 extended-opcode (2-operand) ;

: IMUL3 ( dst src imm -- )
    dup fits-in-byte? [
        [ swap HEX: 6a 2-operand ] dip 1,
    ] [
        [ swap HEX: 68 2-operand ] dip 4,
    ] if ;

: MOVSX ( dst src -- )
    swap
    over register-32? OCT: 143 OCT: 276 extended-opcode ?
    pick register-16? [ BIN: 1 opcode-or ] when
    (2-operand) ;

: MOVZX ( dst src -- )
    swap
    OCT: 266 extended-opcode
    pick register-16? [ BIN: 1 opcode-or ] when
    (2-operand) ;

! Conditional move
: MOVcc ( dst src cc -- ) extended-opcode swapd (2-operand) ;

: CMOVO  ( dst src -- ) HEX: 40 MOVcc ;
: CMOVNO ( dst src -- ) HEX: 41 MOVcc ;
: CMOVB  ( dst src -- ) HEX: 42 MOVcc ;
: CMOVAE ( dst src -- ) HEX: 43 MOVcc ;
: CMOVE  ( dst src -- ) HEX: 44 MOVcc ; ! aka CMOVZ
: CMOVNE ( dst src -- ) HEX: 45 MOVcc ;
: CMOVBE ( dst src -- ) HEX: 46 MOVcc ;
: CMOVA  ( dst src -- ) HEX: 47 MOVcc ;
: CMOVS  ( dst src -- ) HEX: 48 MOVcc ;
: CMOVNS ( dst src -- ) HEX: 49 MOVcc ;
: CMOVP  ( dst src -- ) HEX: 4a MOVcc ;
: CMOVNP ( dst src -- ) HEX: 4b MOVcc ;
: CMOVL  ( dst src -- ) HEX: 4c MOVcc ;
: CMOVGE ( dst src -- ) HEX: 4d MOVcc ;
: CMOVLE ( dst src -- ) HEX: 4e MOVcc ;
: CMOVG  ( dst src -- ) HEX: 4f MOVcc ;

! CPU Identification

: CPUID ( -- ) HEX: a2 extended-opcode, ;

! Misc

: NOP ( -- ) HEX: 90 , ;
: PAUSE ( -- ) HEX: f3 , HEX: 90 , ;

: RDPMC ( -- ) HEX: 0f , HEX: 33 , ;

! x87 Floating Point Unit

: FSTPS ( operand -- ) { BIN: 011 f HEX: d9 } 1-operand ;
: FSTPL ( operand -- ) { BIN: 011 f HEX: dd } 1-operand ;

: FLDS ( operand -- ) { BIN: 000 f HEX: d9 } 1-operand ;
: FLDL ( operand -- ) { BIN: 000 f HEX: dd } 1-operand ;

! SSE multimedia instructions

<PRIVATE

: direction-bit-sse ( dst src op1 -- dst' src' op1' )
    pick register-128? [ swapd ] [ BIN: 1 bitor ] if ;

: 2-operand-sse ( dst src op1 op2 -- )
    [ , ] when* direction-bit-sse extended-opcode (2-operand) ;

: direction-op-sse ( dst src op1s -- dst' src' op1' )
    pick register-128? [ swapd first ] [ second ] if ;

: 2-operand-rm-mr-sse ( dst src op1{rm,mr} op2 -- )
    [ , ] when* direction-op-sse extended-opcode (2-operand) ;

: 2-operand-ssse3 ( dst src op1 op2 -- )
    [ , ] when* swapd ssse3-opcode (2-operand) ;

: 2-operand-rm-sse ( dst src op1 op2 -- )
    [ , ] when* swapd extended-opcode (2-operand) ;

: 2-operand-mr-sse ( dst src op1 op2 -- )
    [ , ] when* extended-opcode (2-operand) ;

: 2-operand-int/sse ( dst src op1 op2 -- )
    [ , ] when* swapd extended-opcode (2-operand) ;

: 3-operand-sse ( dst src imm op1 op2 -- )
    rot [ 2-operand-rm-sse ] dip , ;

: 2-operand-sse-cmp ( dst src cmp op1 op2 -- )
    3-operand-sse ; inline

: 2-operand-sse-shift ( dst imm reg op1 op2 -- )
    [ , ] when*
    [ f HEX: 0f ] dip 2array 3array
    swapd 1-operand , ;

PRIVATE>

: MOVUPS     ( dest src -- ) HEX: 10 f       2-operand-sse ;
: MOVUPD     ( dest src -- ) HEX: 10 HEX: 66 2-operand-sse ;
: MOVSD      ( dest src -- ) HEX: 10 HEX: f2 2-operand-sse ;
: MOVSS      ( dest src -- ) HEX: 10 HEX: f3 2-operand-sse ;
: MOVLPS     ( dest src -- ) HEX: 12 f       2-operand-sse ;
: MOVLPD     ( dest src -- ) HEX: 12 HEX: 66 2-operand-sse ;
: MOVDDUP    ( dest src -- ) HEX: 12 HEX: f2 2-operand-rm-sse ;
: MOVSLDUP   ( dest src -- ) HEX: 12 HEX: f3 2-operand-rm-sse ;
: UNPCKLPS   ( dest src -- ) HEX: 14 f       2-operand-rm-sse ;
: UNPCKLPD   ( dest src -- ) HEX: 14 HEX: 66 2-operand-rm-sse ;
: UNPCKHPS   ( dest src -- ) HEX: 15 f       2-operand-rm-sse ;
: UNPCKHPD   ( dest src -- ) HEX: 15 HEX: 66 2-operand-rm-sse ;
: MOVHPS     ( dest src -- ) HEX: 16 f       2-operand-sse ;
: MOVHPD     ( dest src -- ) HEX: 16 HEX: 66 2-operand-sse ;
: MOVSHDUP   ( dest src -- ) HEX: 16 HEX: f3 2-operand-rm-sse ;

: PREFETCHNTA ( mem -- )  { BIN: 000 f { HEX: 0f HEX: 18 } } 1-operand ;
: PREFETCHT0  ( mem -- )  { BIN: 001 f { HEX: 0f HEX: 18 } } 1-operand ;
: PREFETCHT1  ( mem -- )  { BIN: 010 f { HEX: 0f HEX: 18 } } 1-operand ;
: PREFETCHT2  ( mem -- )  { BIN: 011 f { HEX: 0f HEX: 18 } } 1-operand ;

: MOVAPS     ( dest src -- ) HEX: 28 f       2-operand-sse ;
: MOVAPD     ( dest src -- ) HEX: 28 HEX: 66 2-operand-sse ;
: CVTSI2SD   ( dest src -- ) HEX: 2a HEX: f2 2-operand-int/sse ;
: CVTSI2SS   ( dest src -- ) HEX: 2a HEX: f3 2-operand-int/sse ;
: MOVNTPS    ( dest src -- ) HEX: 2b f       2-operand-mr-sse ;
: MOVNTPD    ( dest src -- ) HEX: 2b HEX: 66 2-operand-mr-sse ;
: CVTTSD2SI  ( dest src -- ) HEX: 2c HEX: f2 2-operand-int/sse ;
: CVTTSS2SI  ( dest src -- ) HEX: 2c HEX: f3 2-operand-int/sse ;
: CVTSD2SI   ( dest src -- ) HEX: 2d HEX: f2 2-operand-int/sse ;
: CVTSS2SI   ( dest src -- ) HEX: 2d HEX: f3 2-operand-int/sse ;
: UCOMISS    ( dest src -- ) HEX: 2e f       2-operand-rm-sse ;
: UCOMISD    ( dest src -- ) HEX: 2e HEX: 66 2-operand-rm-sse ;
: COMISS     ( dest src -- ) HEX: 2f f       2-operand-rm-sse ;
: COMISD     ( dest src -- ) HEX: 2f HEX: 66 2-operand-rm-sse ;
: PSHUFB     ( dest src -- ) { HEX: 38 HEX: 00 } HEX: 66 2-operand-ssse3 ;
: PHADDW     ( dest src -- ) { HEX: 38 HEX: 01 } HEX: 66 2-operand-ssse3 ;
: PHADDD     ( dest src -- ) { HEX: 38 HEX: 02 } HEX: 66 2-operand-ssse3 ;
: PHADDSW    ( dest src -- ) { HEX: 38 HEX: 03 } HEX: 66 2-operand-ssse3 ;
: PMADDUBSW  ( dest src -- ) { HEX: 38 HEX: 04 } HEX: 66 2-operand-ssse3 ;
: PHSUBW     ( dest src -- ) { HEX: 38 HEX: 05 } HEX: 66 2-operand-ssse3 ;
: PHSUBD     ( dest src -- ) { HEX: 38 HEX: 06 } HEX: 66 2-operand-ssse3 ;
: PHSUBSW    ( dest src -- ) { HEX: 38 HEX: 07 } HEX: 66 2-operand-ssse3 ;
: PSIGNB     ( dest src -- ) { HEX: 38 HEX: 08 } HEX: 66 2-operand-ssse3 ;
: PSIGNW     ( dest src -- ) { HEX: 38 HEX: 09 } HEX: 66 2-operand-ssse3 ;
: PSIGND     ( dest src -- ) { HEX: 38 HEX: 0A } HEX: 66 2-operand-ssse3 ;
: PMULHRSW   ( dest src -- ) { HEX: 38 HEX: 0B } HEX: 66 2-operand-ssse3 ;
: PABSB      ( dest src -- ) { HEX: 38 HEX: 1C } HEX: 66 2-operand-ssse3 ;
: PABSW      ( dest src -- ) { HEX: 38 HEX: 1D } HEX: 66 2-operand-ssse3 ;
: PABSD      ( dest src -- ) { HEX: 38 HEX: 1E } HEX: 66 2-operand-ssse3 ;
: PALIGNR    ( dest src -- ) { HEX: 3A HEX: 0F } HEX: 66 2-operand-ssse3 ;
: MOVMSKPS   ( dest src -- ) HEX: 50 f       2-operand-int/sse ;
: MOVMSKPD   ( dest src -- ) HEX: 50 HEX: 66 2-operand-int/sse ;
: SQRTPS     ( dest src -- ) HEX: 51 f       2-operand-rm-sse ;
: SQRTPD     ( dest src -- ) HEX: 51 HEX: 66 2-operand-rm-sse ;
: SQRTSD     ( dest src -- ) HEX: 51 HEX: f2 2-operand-rm-sse ;
: SQRTSS     ( dest src -- ) HEX: 51 HEX: f3 2-operand-rm-sse ;
: RSQRTPS    ( dest src -- ) HEX: 52 f       2-operand-rm-sse ;
: RSQRTSS    ( dest src -- ) HEX: 52 HEX: f3 2-operand-rm-sse ;
: RCPPS      ( dest src -- ) HEX: 53 f       2-operand-rm-sse ;
: RCPSS      ( dest src -- ) HEX: 53 HEX: f3 2-operand-rm-sse ;
: ANDPS      ( dest src -- ) HEX: 54 f       2-operand-rm-sse ;
: ANDPD      ( dest src -- ) HEX: 54 HEX: 66 2-operand-rm-sse ;
: ANDNPS     ( dest src -- ) HEX: 55 f       2-operand-rm-sse ;
: ANDNPD     ( dest src -- ) HEX: 55 HEX: 66 2-operand-rm-sse ;
: ORPS       ( dest src -- ) HEX: 56 f       2-operand-rm-sse ;
: ORPD       ( dest src -- ) HEX: 56 HEX: 66 2-operand-rm-sse ;
: XORPS      ( dest src -- ) HEX: 57 f       2-operand-rm-sse ;
: XORPD      ( dest src -- ) HEX: 57 HEX: 66 2-operand-rm-sse ;
: ADDPS      ( dest src -- ) HEX: 58 f       2-operand-rm-sse ;
: ADDPD      ( dest src -- ) HEX: 58 HEX: 66 2-operand-rm-sse ;
: ADDSD      ( dest src -- ) HEX: 58 HEX: f2 2-operand-rm-sse ;
: ADDSS      ( dest src -- ) HEX: 58 HEX: f3 2-operand-rm-sse ;
: MULPS      ( dest src -- ) HEX: 59 f       2-operand-rm-sse ;
: MULPD      ( dest src -- ) HEX: 59 HEX: 66 2-operand-rm-sse ;
: MULSD      ( dest src -- ) HEX: 59 HEX: f2 2-operand-rm-sse ;
: MULSS      ( dest src -- ) HEX: 59 HEX: f3 2-operand-rm-sse ;
: CVTPS2PD   ( dest src -- ) HEX: 5a f       2-operand-rm-sse ;
: CVTPD2PS   ( dest src -- ) HEX: 5a HEX: 66 2-operand-rm-sse ;
: CVTSD2SS   ( dest src -- ) HEX: 5a HEX: f2 2-operand-rm-sse ;
: CVTSS2SD   ( dest src -- ) HEX: 5a HEX: f3 2-operand-rm-sse ;
: CVTDQ2PS   ( dest src -- ) HEX: 5b f       2-operand-rm-sse ;
: CVTPS2DQ   ( dest src -- ) HEX: 5b HEX: 66 2-operand-rm-sse ;
: CVTTPS2DQ  ( dest src -- ) HEX: 5b HEX: f3 2-operand-rm-sse ;
: SUBPS      ( dest src -- ) HEX: 5c f       2-operand-rm-sse ;
: SUBPD      ( dest src -- ) HEX: 5c HEX: 66 2-operand-rm-sse ;
: SUBSD      ( dest src -- ) HEX: 5c HEX: f2 2-operand-rm-sse ;
: SUBSS      ( dest src -- ) HEX: 5c HEX: f3 2-operand-rm-sse ;
: MINPS      ( dest src -- ) HEX: 5d f       2-operand-rm-sse ;
: MINPD      ( dest src -- ) HEX: 5d HEX: 66 2-operand-rm-sse ;
: MINSD      ( dest src -- ) HEX: 5d HEX: f2 2-operand-rm-sse ;
: MINSS      ( dest src -- ) HEX: 5d HEX: f3 2-operand-rm-sse ;
: DIVPS      ( dest src -- ) HEX: 5e f       2-operand-rm-sse ;
: DIVPD      ( dest src -- ) HEX: 5e HEX: 66 2-operand-rm-sse ;
: DIVSD      ( dest src -- ) HEX: 5e HEX: f2 2-operand-rm-sse ;
: DIVSS      ( dest src -- ) HEX: 5e HEX: f3 2-operand-rm-sse ;
: MAXPS      ( dest src -- ) HEX: 5f f       2-operand-rm-sse ;
: MAXPD      ( dest src -- ) HEX: 5f HEX: 66 2-operand-rm-sse ;
: MAXSD      ( dest src -- ) HEX: 5f HEX: f2 2-operand-rm-sse ;
: MAXSS      ( dest src -- ) HEX: 5f HEX: f3 2-operand-rm-sse ;
: PUNPCKLQDQ ( dest src -- ) HEX: 6c HEX: 66 2-operand-rm-sse ;
: PUNPCKHQDQ ( dest src -- ) HEX: 6d HEX: 66 2-operand-rm-sse ;

: MOVDQA     ( dest src -- ) { HEX: 6f HEX: 7f } HEX: 66 2-operand-rm-mr-sse ;
: MOVDQU     ( dest src -- ) { HEX: 6f HEX: 7f } HEX: f3 2-operand-rm-mr-sse ;

: PSHUFD     ( dest src imm -- ) HEX: 70 HEX: 66 3-operand-sse ;
: PSHUFLW    ( dest src imm -- ) HEX: 70 HEX: f2 3-operand-sse ;
: PSHUFHW    ( dest src imm -- ) HEX: 70 HEX: f3 3-operand-sse ;
: PSRLW      ( dest imm -- ) BIN: 010 HEX: 71 HEX: 66 2-operand-sse-shift ;
: PSRAW      ( dest imm -- ) BIN: 100 HEX: 71 HEX: 66 2-operand-sse-shift ;
: PSLLW      ( dest imm -- ) BIN: 110 HEX: 71 HEX: 66 2-operand-sse-shift ;
: PSRLD      ( dest imm -- ) BIN: 010 HEX: 72 HEX: 66 2-operand-sse-shift ;
: PSRAD      ( dest imm -- ) BIN: 100 HEX: 72 HEX: 66 2-operand-sse-shift ;
: PSLLD      ( dest imm -- ) BIN: 110 HEX: 72 HEX: 66 2-operand-sse-shift ;
: PSRLQ      ( dest imm -- ) BIN: 010 HEX: 73 HEX: 66 2-operand-sse-shift ;
: PSRLDQ     ( dest imm -- ) BIN: 011 HEX: 73 HEX: 66 2-operand-sse-shift ;
: PSLLQ      ( dest imm -- ) BIN: 110 HEX: 73 HEX: 66 2-operand-sse-shift ;
: PSLLDQ     ( dest imm -- ) BIN: 111 HEX: 73 HEX: 66 2-operand-sse-shift ;

: PCMPEQB    ( dest src -- ) HEX: 74 HEX: 66 2-operand-rm-sse ;
: PCMPEQW    ( dest src -- ) HEX: 75 HEX: 66 2-operand-rm-sse ;
: PCMPEQD    ( dest src -- ) HEX: 76 HEX: 66 2-operand-rm-sse ;
: HADDPD     ( dest src -- ) HEX: 7c HEX: 66 2-operand-rm-sse ;
: HADDPS     ( dest src -- ) HEX: 7c HEX: f2 2-operand-rm-sse ;
: HSUBPD     ( dest src -- ) HEX: 7d HEX: 66 2-operand-rm-sse ;
: HSUBPS     ( dest src -- ) HEX: 7d HEX: f2 2-operand-rm-sse ;

: LDMXCSR    ( src -- )  { BIN: 010 f { HEX: 0f HEX: ae } } 1-operand ;
: STMXCSR    ( dest -- ) { BIN: 011 f { HEX: 0f HEX: ae } } 1-operand ;
: LFENCE     ( -- ) HEX: 0f , HEX: ae , OCT: 350 , ;
: MFENCE     ( -- ) HEX: 0f , HEX: ae , OCT: 360 , ;
: SFENCE     ( -- ) HEX: 0f , HEX: ae , OCT: 370 , ;

: CMPEQPS    ( dest src -- ) 0 HEX: c2 f       2-operand-sse-cmp ;
: CMPLTPS    ( dest src -- ) 1 HEX: c2 f       2-operand-sse-cmp ;
: CMPLEPS    ( dest src -- ) 2 HEX: c2 f       2-operand-sse-cmp ;
: CMPUNORDPS ( dest src -- ) 3 HEX: c2 f       2-operand-sse-cmp ;
: CMPNEQPS   ( dest src -- ) 4 HEX: c2 f       2-operand-sse-cmp ;
: CMPNLTPS   ( dest src -- ) 5 HEX: c2 f       2-operand-sse-cmp ;
: CMPNLEPS   ( dest src -- ) 6 HEX: c2 f       2-operand-sse-cmp ;
: CMPORDPS   ( dest src -- ) 7 HEX: c2 f       2-operand-sse-cmp ;

: CMPEQPD    ( dest src -- ) 0 HEX: c2 HEX: 66 2-operand-sse-cmp ;
: CMPLTPD    ( dest src -- ) 1 HEX: c2 HEX: 66 2-operand-sse-cmp ;
: CMPLEPD    ( dest src -- ) 2 HEX: c2 HEX: 66 2-operand-sse-cmp ;
: CMPUNORDPD ( dest src -- ) 3 HEX: c2 HEX: 66 2-operand-sse-cmp ;
: CMPNEQPD   ( dest src -- ) 4 HEX: c2 HEX: 66 2-operand-sse-cmp ;
: CMPNLTPD   ( dest src -- ) 5 HEX: c2 HEX: 66 2-operand-sse-cmp ;
: CMPNLEPD   ( dest src -- ) 6 HEX: c2 HEX: 66 2-operand-sse-cmp ;
: CMPORDPD   ( dest src -- ) 7 HEX: c2 HEX: 66 2-operand-sse-cmp ;

: CMPEQSD    ( dest src -- ) 0 HEX: c2 HEX: f2 2-operand-sse-cmp ;
: CMPLTSD    ( dest src -- ) 1 HEX: c2 HEX: f2 2-operand-sse-cmp ;
: CMPLESD    ( dest src -- ) 2 HEX: c2 HEX: f2 2-operand-sse-cmp ;
: CMPUNORDSD ( dest src -- ) 3 HEX: c2 HEX: f2 2-operand-sse-cmp ;
: CMPNEQSD   ( dest src -- ) 4 HEX: c2 HEX: f2 2-operand-sse-cmp ;
: CMPNLTSD   ( dest src -- ) 5 HEX: c2 HEX: f2 2-operand-sse-cmp ;
: CMPNLESD   ( dest src -- ) 6 HEX: c2 HEX: f2 2-operand-sse-cmp ;
: CMPORDSD   ( dest src -- ) 7 HEX: c2 HEX: f2 2-operand-sse-cmp ;

: CMPEQSS    ( dest src -- ) 0 HEX: c2 HEX: f3 2-operand-sse-cmp ;
: CMPLTSS    ( dest src -- ) 1 HEX: c2 HEX: f3 2-operand-sse-cmp ;
: CMPLESS    ( dest src -- ) 2 HEX: c2 HEX: f3 2-operand-sse-cmp ;
: CMPUNORDSS ( dest src -- ) 3 HEX: c2 HEX: f3 2-operand-sse-cmp ;
: CMPNEQSS   ( dest src -- ) 4 HEX: c2 HEX: f3 2-operand-sse-cmp ;
: CMPNLTSS   ( dest src -- ) 5 HEX: c2 HEX: f3 2-operand-sse-cmp ;
: CMPNLESS   ( dest src -- ) 6 HEX: c2 HEX: f3 2-operand-sse-cmp ;
: CMPORDSS   ( dest src -- ) 7 HEX: c2 HEX: f3 2-operand-sse-cmp ;

: MOVNTI     ( dest src -- ) { HEX: 0f HEX: c3 } (2-operand) ;

: PINSRW     ( dest src imm -- ) HEX: c4 HEX: 66 3-operand-sse ;
: PEXTRW     ( dest src imm -- ) HEX: c5 HEX: 66 3-operand-sse ;
: SHUFPS     ( dest src imm -- ) HEX: c6 f       3-operand-sse ;
: SHUFPD     ( dest src imm -- ) HEX: c6 HEX: 66 3-operand-sse ;

: ADDSUBPD   ( dest src -- ) HEX: d0 HEX: 66 2-operand-rm-sse ;
: ADDSUBPS   ( dest src -- ) HEX: d0 HEX: f2 2-operand-rm-sse ;
: PADDQ      ( dest src -- ) HEX: d4 HEX: 66 2-operand-rm-sse ;
: PMINUB     ( dest src -- ) HEX: da HEX: 66 2-operand-rm-sse ;
: PMAXUB     ( dest src -- ) HEX: de HEX: 66 2-operand-rm-sse ;
: PAVGB      ( dest src -- ) HEX: e0 HEX: 66 2-operand-rm-sse ;
: PAVGW      ( dest src -- ) HEX: e3 HEX: 66 2-operand-rm-sse ;
: PMULHUW    ( dest src -- ) HEX: e4 HEX: 66 2-operand-rm-sse ;
: CVTTPD2DQ  ( dest src -- ) HEX: e6 HEX: 66 2-operand-rm-sse ;
: CVTPD2DQ   ( dest src -- ) HEX: e6 HEX: f2 2-operand-rm-sse ;
: CVTDQ2PD   ( dest src -- ) HEX: e6 HEX: f3 2-operand-rm-sse ;

: MOVNTDQ    ( dest src -- ) HEX: e7 HEX: 66 2-operand-mr-sse ;

: PMINSW     ( dest src -- ) HEX: ea HEX: 66 2-operand-rm-sse ;
: PMAXSW     ( dest src -- ) HEX: ee HEX: 66 2-operand-rm-sse ;
: LDDQU      ( dest src -- ) HEX: f0 HEX: f2 2-operand-rm-sse ;
: PMULUDQ    ( dest src -- ) HEX: f4 HEX: 66 2-operand-rm-sse ;
: PSADBW     ( dest src -- ) HEX: f6 HEX: 66 2-operand-rm-sse ;

: MASKMOVDQU ( dest src -- ) HEX: f7 HEX: 66 2-operand-rm-sse ;

: PSUBQ      ( dest src -- ) HEX: fb HEX: 66 2-operand-rm-sse ;

! x86-64 branch prediction hints

: HWNT ( -- ) HEX: 2e , ; ! Hint branch Weakly Not Taken
: HST  ( -- ) HEX: 3e , ; ! Hint branch Strongly Taken

