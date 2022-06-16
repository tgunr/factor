USING: bare multiline prettyprint prettyprint.config sequences tools.test ;

IN: bare.tests

! uint

{ 0 } [ B{ 0x00 } uint bare> ] unit-test
{ B{ 0x00 } } [ 0 uint >bare ] unit-test

{ 1 } [ B{ 0x01 } uint bare> ] unit-test
{ B{ 0x01 } } [ 1 uint >bare ] unit-test

{ 126 } [ B{ 0x7e } uint bare> ] unit-test
{ B{ 0x7e } } [ 126 uint >bare ] unit-test

{ 127 } [ B{ 0x7f } uint bare> ] unit-test
{ B{ 0x7f } } [ 127 uint >bare ] unit-test

{ 128 } [ B{ 0x80 0x01 } uint bare> ] unit-test
{ B{ 0x80 0x01 } } [ 128 uint >bare ] unit-test

{ 129 } [ B{ 0x81 0x01 } uint bare> ] unit-test
{ B{ 0x81 0x01 } } [ 129 uint >bare ] unit-test

{ 255 } [ B{ 0xFF 0x01 } uint bare> ] unit-test
{ B{ 0xFF 0x01 } } [ 255 uint >bare ] unit-test

! int

{ 0 } [ B{ 0x00 } int bare> ] unit-test
{ B{ 0x00 } } [ 0 int >bare ] unit-test

{ 1 } [ B{ 0x02 } int bare> ] unit-test
{ B{ 0x02 } } [ 1 int >bare ] unit-test

{ -1 } [ B{ 0x01 } int bare> ] unit-test
{ B{ 0x01 } } [ -1 int >bare ] unit-test

{ 63 } [ B{ 0x7e } int bare> ] unit-test
{ B{ 0x7e } } [ 63 int >bare ] unit-test

{ -63 } [ B{ 0x7d } int bare> ] unit-test
{ B{ 0x7d } } [ -63 int >bare ] unit-test

{ 64 } [ B{ 0x80 0x01 } int bare> ] unit-test
{ B{ 0x80 0x01 } } [ 64 int >bare ] unit-test

{ -64 } [ B{ 0x7f } int bare> ] unit-test
{ B{ 0x7f } } [ -64 int >bare ] unit-test

{ 65 } [ B{ 0x82 0x01 } int bare> ] unit-test
{ B{ 0x82 0x01 } } [ 65 int >bare ] unit-test

{ -65 } [ B{ 0x81 0x01 } int bare> ] unit-test
{ B{ 0x81 0x01 } } [ -65 int >bare ] unit-test

{ 255 } [ B{ 0xFE 0x03 } int bare> ] unit-test
{ B{ 0xFE 0x03 } } [ 255 int >bare ] unit-test

{ -255 } [ B{ 0xFD 0x03 } int bare> ] unit-test
{ B{ 0xFD 0x03 } } [ -255 int >bare ] unit-test

! u32

{ 0 } [ B{ 0x00 0x00 0x00 0x00 } u32 bare> ] unit-test
{ B{ 0x00 0x00 0x00 0x00 } } [ 0 u32 >bare ] unit-test

{ 1 } [ B{ 0x01 0x00 0x00 0x00 } u32 bare> ] unit-test
{ B{ 0x01 0x00 0x00 0x00 } } [ 1 u32 >bare ] unit-test

{ 255 } [ B{ 0xFF 0x00 0x00 0x00 } u32 bare> ] unit-test
{ B{ 0xFF 0x00 0x00 0x00 } } [ 255 u32 >bare ] unit-test

! i16

{ 0 } [ B{ 0x00 0x00 } i16 bare> ] unit-test
{ B{ 0x00 0x00 } } [ 0 i16 >bare ] unit-test

{ 1 } [ B{ 0x01 0x00 } i16 bare> ] unit-test
{ B{ 0x01 0x00 } } [ 1 i16 >bare ] unit-test

{ -1 } [ B{ 0xFF 0xFF } i16 bare> ] unit-test
{ B{ 0xFF 0xFF } } [ -1 i16 >bare ] unit-test

{ 255 } [ B{ 0xFF 0x00 } i16 bare> ] unit-test
{ B{ 0xFF 0x00 } } [ 255 i16 >bare ] unit-test

{ -255 } [ B{ 0x01 0xFF } i16 bare> ] unit-test
{ B{ 0x01 0xFF } } [ -255 i16 >bare ] unit-test

! f64

{ 0.0 } [ B{ 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 } f64 bare> ] unit-test
{ B{ 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 } } [ 0.0 f64 >bare ] unit-test

{ 1.0 } [ B{ 0x00 0x00 0x00 0x00 0x00 0x00 0xF0 0x3F } f64 bare> ] unit-test
{ B{ 0x00 0x00 0x00 0x00 0x00 0x00 0xF0 0x3F } } [ 1.0 f64 >bare ] unit-test

{ 2.55 } [ B{ 0x66 0x66 0x66 0x66 0x66 0x66 0x04 0x40 } f64 bare> ] unit-test
{ B{ 0x66 0x66 0x66 0x66 0x66 0x66 0x04 0x40 } } [ 2.55 f64 >bare ] unit-test

{ -25.5 } [ B{ 0x00 0x00 0x00 0x00 0x00 0x80 0x39 0xC0 } f64 bare> ] unit-test
{ B{ 0x00 0x00 0x00 0x00 0x00 0x80 0x39 0xC0 } } [ -25.5 f64 >bare ] unit-test

! bool

{ t } [ B{ 0x01 } bool bare> ] unit-test
{ B{ 0x01 } } [ t bool >bare ] unit-test

{ f } [ B{ 0x00 } bool bare> ] unit-test
{ B{ 0x00 } } [ f bool >bare ] unit-test

! str

{ "BARE" } [ B{ 0x04 0x42 0x41 0x52 0x45 } str bare> ] unit-test
{ B{ 0x04 0x42 0x41 0x52 0x45 } } [ "BARE" str >bare ] unit-test

! data

{ B{ 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb } } [
    B{ 0x10 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb }
    T{ data } bare>
] unit-test

{ B{ 0x10 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb } } [
    B{ 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb }
    T{ data } >bare
] unit-test

! data[length]

{ B{ 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb } } [
    B{ 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb }
    T{ data f 16 } bare>
] unit-test

{ B{ 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb } } [
    B{ 0xaa 0xee 0xff 0xee 0xdd 0xcc 0xbb 0xaa 0xee 0xdd 0xcc 0xbb 0xee 0xdd 0xcc 0xbb }
    T{ data f 16 } >bare
] unit-test

! enum

{ "FOO" } [ B{ 0x00 } T{ enum f { { "FOO" 0 } { "BAR" 255 } { "BUZZ" 256 } } } bare> ] unit-test
{ B{ 0x00 } } [ "FOO" T{ enum f { { "FOO" 0 } { "BAR" 255 } { "BUZZ" 256 } } } >bare ] unit-test
{ "BAR" } [ B{ 0xFF 0x01 } T{ enum f { { "FOO" 0 } { "BAR" 255 } { "BUZZ" 256 } } } bare> ] unit-test
{ B{ 0xFF 0x01 } } [ "BAR" T{ enum f { { "FOO" 0 } { "BAR" 255 } { "BUZZ" 256 } } } >bare ] unit-test
{ "BUZZ" } [ B{ 0x80 0x02 } T{ enum f { { "FOO" 0 } { "BAR" 255 } { "BUZZ" 256 } } } bare> ] unit-test
{ B{ 0x80 0x02 } } [ "BUZZ" T{ enum f { { "FOO" 0 } { "BAR" 255 } { "BUZZ" 256 } } } >bare ] unit-test

[ B{ 0x03 } T{ enum f { { "A" 0 } { "B" 1 } { "C" 2 } } } bare> ] [ invalid-enum? ] must-fail-with
[ "D" T{ enum f { { "A" 0 } { "B" 1 } { "C" 2 } } } >bare ] [ invalid-enum? ] must-fail-with

! optional<u32>

{ f } [ B{ 0x00 } T{ optional f u32 } bare> ] unit-test
{ 0 } [ B{ 0x01 0x00 0x00 0x00 0x00 } T{ optional f u32 } bare> ] unit-test
{ 1 } [ B{ 0x01 0x01 0x00 0x00 0x00 } T{ optional f u32 } bare> ] unit-test
{ 255 } [ B{ 0x01 0xFF 0x00 0x00 0x00 } T{ optional f u32 } bare> ] unit-test

! list<str>

{ { "foo" "bar" "buzz" } } [
    B{ 0x03 0x03 0x66 0x6f 0x6f 0x03 0x62 0x61 0x72 0x04 0x62 0x75 0x7A 0x7A }
    T{ list f str f } bare>
] unit-test

{ B{ 0x03 0x03 0x66 0x6f 0x6f 0x03 0x62 0x61 0x72 0x04 0x62 0x75 0x7A 0x7A } } [
    { "foo" "bar" "buzz" } T{ list f str f } >bare
] unit-test

! list<uint>[10]

{ { 0 1 254 255 256 257 126 127 128 129 } } [
    B{ 0x00 0x01 0xFE 0x01 0xFF 0x01 0x80 0x02 0x81 0x02 0x7E 0x7F 0x80 0x01 0x81 0x01 }
    T{ list f uint 10 } bare>
] unit-test

{ B{ 0x00 0x01 0xFE 0x01 0xFF 0x01 0x80 0x02 0x81 0x02 0x7E 0x7F 0x80 0x01 0x81 0x01 } } [
    { 0 1 254 255 256 257 126 127 128 129 } T{ list f uint 10 } >bare
] unit-test

! map<u32><str>

{
    B{
        0x03 0x00 0x00 0x00 0x00 0x04 0x7A 0x65 0x72 0x6F 0x01
        0x00 0x00 0x00 0x03 0x6F 0x6E 0x65 0xFF 0x00 0x00 0x00
        0x1B 0x74 0x77 0x6F 0x20 0x68 0x75 0x6E 0x64 0x72 0x65
        0x64 0x73 0x20 0x61 0x6E 0x64 0x20 0x66 0x69 0x66 0x74
        0x79 0x20 0x66 0x69 0x76 0x65
    }
} [
    H{
        { 0 "zero" }
        { 1 "one" }
        { 255 "two hundreds and fifty five" }
    } T{ bare:map f u32 str } >bare
] unit-test

{
    {
        { 0 "zero" }
        { 1 "one" }
        { 255 "two hundreds and fifty five" }
    }
} [
    B{
        0x03 0x00 0x00 0x00 0x00 0x04 0x7A 0x65 0x72 0x6F 0x01
        0x00 0x00 0x00 0x03 0x6F 0x6E 0x65 0xFF 0x00 0x00 0x00
        0x1B 0x74 0x77 0x6F 0x20 0x68 0x75 0x6E 0x64 0x72 0x65
        0x64 0x73 0x20 0x61 0x6E 0x64 0x20 0x66 0x69 0x66 0x74
        0x79 0x20 0x66 0x69 0x76 0x65
    } T{ bare:map f u32 str } bare>
] unit-test

! union

{
    {
        0
        1
        1
        -1
        255
        255
        -255
        "BARE"
    }
} [
    {
        B{ 0x00 0x00 }
        B{ 0x00 0x02 }
        B{ 0xFF 0x01 0x01 }
        B{ 0x00 0x01 }
        B{ 0x00 0xFE 0x03 }
        B{ 0xFF 0x01 0xFF 0x01 }
        B{ 0x00 0xFD 0x03 }
        B{ 0x80 0x02 0x04 0x42 0x41 0x52 0x45 }
    } [
        T{ bare:union f { { int 0 } { uint 255 } { str 256 } } } bare>
    ] sequences:map
] unit-test

[
    B{ 0x03 0x03 } T{ bare:union f { { int 0 } { uint 1 } { str 2 } } } bare>
] [ invalid-union? ] must-fail-with

! struct

{
    {
        { "foo" 255 }
        { "bar" -255 }
        { "buzz" "BARE" }
    }
} [
    B{ 0xFF 0x01 0xFD 0x03 0x04 0x42 0x41 0x52 0x45 }
    T{ struct f { { "foo" uint } { "bar" int } { "buzz" str } } } bare>
] unit-test

{
    B{ 0xFF 0x01 0xFD 0x03 0x04 0x42 0x41 0x52 0x45 }
} [
    {
        { "foo" 255 }
        { "bar" -255 }
        { "buzz" "BARE" }
    } T{ struct f { { "foo" uint } { "bar" int } { "buzz" str } } } >bare
] unit-test

! user types / schema

SCHEMA: [=[
type PublicKey data[128]
type Time str # ISO 8601

type Department enum {
  ACCOUNTING
  ADMINISTRATION
  CUSTOMER_SERVICE
  DEVELOPMENT

  # Reserved for the CEO
  JSMITH = 99
}

type Address list<str>[4] # street, city, state, country

type Customer struct {
  name: str
  email: str
  address: Address
  orders: list<struct {
    orderId: i64
    quantity: i32
  }>
  metadata: map<str><data>
}

type Employee struct {
  name: str
  email: str
  address: Address
  department: Department
  hireDate: Time
  publicKey: optional<PublicKey>
  metadata: map<str><data>
}

type TerminatedEmployee void

type Person union {Customer | Employee | TerminatedEmployee}
]=]


{
    ! Customer
    V{
        { "name" "James Smith" }
        { "email" "jsmith@example.org" }
        {
            "address"
            { "123 Main St" "Philadelphia" "PA" "United States" }
        }
        {
            "orders"
            { V{ { "orderId" 4242424242 } { "quantity" 5 } } }
        }
        { "metadata" { } }
    }
} [
    B{
        0x00 0x0b 0x4a 0x61 0x6d 0x65 0x73 0x20 0x53 0x6d 0x69
        0x74 0x68 0x12 0x6a 0x73 0x6d 0x69 0x74 0x68 0x40 0x65
        0x78 0x61 0x6d 0x70 0x6c 0x65 0x2e 0x6f 0x72 0x67 0x0b
        0x31 0x32 0x33 0x20 0x4d 0x61 0x69 0x6e 0x20 0x53 0x74
        0x0c 0x50 0x68 0x69 0x6c 0x61 0x64 0x65 0x6c 0x70 0x68
        0x69 0x61 0x02 0x50 0x41 0x0d 0x55 0x6e 0x69 0x74 0x65
        0x64 0x20 0x53 0x74 0x61 0x74 0x65 0x73 0x01 0xb2 0x41
        0xde 0xfc 0x00 0x00 0x00 0x00 0x05 0x00 0x00 0x00 0x00
    } Person bare>
] unit-test

{
    ! Employee
    V{
        { "name" "Tiffany Doe" }
        { "email" "tiffanyd@acme.corp" }
        {
            "address"
            { "123 Main St" "Philadelphia" "PA" "United States" }
        }
        { "department" "ADMINISTRATION" }
        { "hireDate" "2020-06-21T21:18:05Z" }
        { "publicKey" f }
        { "metadata" { } }
    }
} [
    B{
        0x01 0x0b 0x54 0x69 0x66 0x66 0x61 0x6e 0x79 0x20 0x44
        0x6f 0x65 0x12 0x74 0x69 0x66 0x66 0x61 0x6e 0x79 0x64
        0x40 0x61 0x63 0x6d 0x65 0x2e 0x63 0x6f 0x72 0x70 0x0b
        0x31 0x32 0x33 0x20 0x4d 0x61 0x69 0x6e 0x20 0x53 0x74
        0x0c 0x50 0x68 0x69 0x6c 0x61 0x64 0x65 0x6c 0x70 0x68
        0x69 0x61 0x02 0x50 0x41 0x0d 0x55 0x6e 0x69 0x74 0x65
        0x64 0x20 0x53 0x74 0x61 0x74 0x65 0x73 0x01 0x14 0x32
        0x30 0x32 0x30 0x2d 0x30 0x36 0x2d 0x32 0x31 0x54 0x32
        0x31 0x3a 0x31 0x38 0x3a 0x30 0x35 0x5a 0x00 0x00
    } Person bare>
] unit-test

{
    ! TerminatedEmployee
    f
} [
    B{ 0x02 } Person bare>
] unit-test

! enum checks

[
    "type Alphabet enum {
      A
      B
      C = 0
      A
      B = 99
    }" parse-schema
] [ duplicate-keys? ] must-fail-with

[
    "type Alphabet enum {
      A
      B
      C = 0
      D
      E = 99
    }" parse-schema
] [ duplicate-values? ] must-fail-with

! data checks

[ "type Foo data[0]" parse-schema ] [ invalid-length? ] must-fail-with
[ "type Foo data[18446744073709551616]" parse-schema ] [ invalid-length? ] must-fail-with

! optional checks

[ "type Foo optional<void>" parse-schema ] [ cannot-be-void? ] must-fail-with

! list checks

[ "type Foo list<void>" parse-schema ] [ cannot-be-void? ] must-fail-with
[ "type Foo list<int>[0]" parse-schema ] [ invalid-length? ] must-fail-with
[ "type Foo list<int>[18446744073709551616]" parse-schema ] [ invalid-length? ] must-fail-with

! map checks

[ "type Foo map<void><int>" parse-schema ] [ cannot-be-void? ] must-fail-with
[ "type Foo map<void><void>" parse-schema ] [ cannot-be-void? ] must-fail-with
[ "type Foo map<int><void>" parse-schema ] [ cannot-be-void? ] must-fail-with

! union checks

[ "type Thing union {int=0|int|str=0}" parse-schema ] [ duplicate-keys? ] must-fail-with
[ "type Thing union {int=0|uint|str=0}" parse-schema ] [ duplicate-values? ] must-fail-with

! struct checks

[ "type Thing struct { a: int b: int a: int }" parse-schema ] [ duplicate-keys? ] must-fail-with
[ "type Thing struct { a: void }" parse-schema ] [ cannot-be-void? ] must-fail-with

! user checks

[ "type Thing Other" parse-schema ] [ unknown-type? ] must-fail-with
