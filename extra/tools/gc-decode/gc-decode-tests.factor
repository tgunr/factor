USING: bit-arrays classes.struct sequences
tools.gc-decode tools.test vm ;
QUALIFIED: effects
QUALIFIED: llvm.types
QUALIFIED: unix.process
IN: tools.gc-decode.tests

! byte-array>bit-array
{
    ?{
        t t t t f t t t
        t f f f f f f f
    }
} [
    B{ 239 1 } byte-array>bit-array
] unit-test

{ ?{ t t t t t t t t } } [ B{ 255 } byte-array>bit-array ] unit-test

! scrub-bits
{ t } [
    \ effects:<effect> word>gc-info scrub-bits
    {
        ?{ t t t f t t t t } ! 64-bit
        ?{ t t t f f f f f t t t t } ! 32-bit
    } member?
] unit-test

{
    { }
} [
    \ decode-gc-maps word>gc-info scrub-bits
] unit-test

! decode-gc-maps
{
    {
        { 151 { { ?{ } ?{ t t t } ?{ } ?{ } ?{ f t t t t } } { } } }
    }
} [
    \ effects:<effect> decode-gc-maps
] unit-test

{
    {
        { 82 { { ?{ t f } ?{ t } ?{ f } ?{ f f } ?{ } } { } } }
        { 244 { { ?{ f f } ?{ f } ?{ f } ?{ t f } ?{ } } { } } }
        { 445 { { ?{ f f } ?{ f } ?{ t } ?{ t t } ?{ } } { } } }
        { 522 { { ?{ t t } ?{ f } ?{ f } ?{ t f } ?{ } } { } } }
    }
} [
    \ unix.process:fork-process decode-gc-maps
] unit-test

! read-gc-maps
{ { } } [
    \ decode-gc-maps decode-gc-maps
] unit-test

! base-pointer-groups
{
    {
        { -1 -1 -1 -1 -1 -1 -1 }
        { -1 -1 -1 -1 -1 -1 -1 }
        { -1 -1 -1 -1 -1 -1 -1 }
        { -1 -1 -1 -1 -1 -1 5 }
        { -1 -1 -1 -1 -1 -1 5 }
        { -1 -1 -1 -1 -1 -1 -1 }
    }
} [
    \ llvm.types:resolve-types word>gc-info base-pointer-groups
] unit-test


! One of the few words that has derived roots.
{ t } [
    \ llvm.types:resolve-types word>gc-info
    {
        S{ gc-info f 0 2 2 1 6 7 6 } ! 64-bit
        S{ gc-info f 0 2 2 1 10 11 6 } ! 32-bit
    } member?
] unit-test
