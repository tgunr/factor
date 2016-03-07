USING: accessors compiler.cfg compiler.cfg.builder.blocks
compiler.cfg.instructions compiler.cfg.stacks.local
compiler.cfg.utilities compiler.test kernel make namespaces sequences
tools.test ;
IN: compiler.cfg.builder.blocks.tests

! (begin-basic-block)
{ 20 } [
    { } 20 insns>block (begin-basic-block)
    predecessors>> first number>>
] cfg-unit-test

! begin-branch
{ f } [
    height-state get <basic-block> begin-branch drop height-state get eq?
] cfg-unit-test

{ f } [
    <basic-block> dup begin-branch eq?
] cfg-unit-test

! emit-trivial-block
{
    V{ T{ ##no-tco } T{ ##branch } }
} [
    [ [ drop ##no-tco, ] emit-trivial-block ] V{ } make drop
    basic-block get successors>> first instructions>>
] cfg-unit-test

! end-basic-block
{ f } [
    f end-basic-block basic-block get
] unit-test

! make-kill-block
{ t } [
    <basic-block> [ make-kill-block ] keep kill-block?>>
] unit-test

{
    { "succ" "succ" "succ" }
} [
    3 [ <basic-block> ] replicate <basic-block> "succ" >>number
    dupd connect-Nto1-bbs [ successors>> first number>> ] map
] unit-test
