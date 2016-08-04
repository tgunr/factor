USING: accessors alien alien.c-types compiler.cfg compiler.cfg.builder
compiler.cfg.builder.alien compiler.cfg.builder.alien.params
compiler.cfg.builder.blocks compiler.cfg.instructions
compiler.cfg.registers compiler.test compiler.tree.builder
compiler.tree.optimizer cpu.architecture cpu.x86.assembler
cpu.x86.assembler.operands kernel make namespaces sequences
stack-checker.alien system tools.test words ;
IN: compiler.cfg.builder.alien.tests

: dummy-assembly ( -- ass )
    int { } cdecl [
        EAX 33 MOV
    ] alien-assembly ;

{ t } [
    <basic-block> dup set-basic-block dup
    \ dummy-assembly build-tree optimize-tree first
    [ emit-node ] V{ } make drop eq?
] cfg-unit-test

: dummy-callback ( -- cb )
    void { } cdecl [ ] alien-callback ;

{ 2 t } [
    \ dummy-callback build-tree optimize-tree gensym build-cfg
    [ length ] [ second frame-pointer?>> ] bi
] unit-test

{
    V{
        T{ ##load-reference { dst 1 } { obj t } }
        T{ ##load-integer { dst 2 } { val 3 } }
        T{ ##copy { dst 4 } { src 1 } { rep any-rep } }
        T{ ##copy { dst 3 } { src 2 } { rep any-rep } }
        T{ ##inc { loc D: 2 } }
        T{ ##branch }
    }
} [
    <basic-block> dup set-basic-block
    \ dummy-callback build-tree optimize-tree 3 swap nth child>>
    [ emit-callback-body drop ] V{ } make
] cfg-unit-test

! caller-parameters
cpu x86.64? [
    {
        V{
            { 1 int-rep RDI }
            { 2 float-rep XMM0 }
            { 3 double-rep XMM1 }
            { 4 int-rep RSI }
        }
        V{ }
    } [
        void { int float double char } cdecl f "func"
        alien-invoke-params boa caller-parameters
    ] cfg-unit-test
] when

! unbox-parameters

! unboxing ints is only needed on 32bit archs
cpu x86.32?
{
    { 2 4 }
    { { int-rep f f } { int-rep f f } }
    V{
        T{ ##unbox-any-c-ptr { dst 2 } { src 1 } }
        T{ ##unbox
           { dst 4 }
           { src 3 }
           { unboxer "to_fixnum" }
           { rep int-rep }
        }
    }
}
{
    { 2 3 }
    { { int-rep f f } { int-rep f f } }
    V{ T{ ##unbox-any-c-ptr { dst 2 } { src 1 } } }
} ? [
    [ { c-string int } unbox-parameters ] V{ } make
] cfg-unit-test

! with-param-regs*
{
    V{ }
    V{ }
    f f
} [
    cdecl [ ] with-param-regs
    reg-values get stack-values get
] unit-test
