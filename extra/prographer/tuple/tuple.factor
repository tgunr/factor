! Copyright (C) 2021 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
! Description: A visual graph of code and data based on Prograph language
! Copyright (C) 2021 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors assocs graphviz graphviz.dot graphviz.notation
graphviz.render io.encodings.utf8 kernel math.parser sequences
ui.gadgets.tracks variables ;
IN: prographer.tuple

VAR: fValue

: (detuple) ( name -- string )
    "| <f"  fValue number>string append
    "> " append swap  append 
    fValue 1+ set: fValue
    ;

: super@ ( word -- super|f )
    props>> "superclass" swap at ;

: tchain ( word -- seq )
    dup  [ dup super@ ] [ super@ dup  ] produce
    nip  swap prefix
    ;
    
    
:: tuple>node ( tuple -- node )
    tuple props>> :> pl
    tuple super@ :> sc
    "slots" pl at :> sl
    tuple <node>
    "record" =shape
    "<f0> " tuple name>> append
    sc
    [
        "| <f1> " sc name>> append  append
        2 set: fValue
    ]
    [  1 set: fValue ]
    if

    sl [ 
         [ name>> (detuple) append ] each
    ] unless-empty
    =label
    ;

VAR: prevNode
:: tuple-connections ( nodes -- edges )
    f :> prevNode! V{ } clone :> edgeNodes!
    nodes
    [ prevNode 
      [ prevNode  over id>>  <edge>
        "f0" =headport "f1" =tailport

        edgeNodes swap suffix! edgeNodes!
        id>> prevNode!
      ]
      [ id>> prevNode! ]
      if
    ] each
    edgeNodes
    ;

: tuple-tree ( tuple -- graph )
    <digraph> over name>> >>id
    [graph "LR" =rankdir "8,8" =size ];
    [node 8 =fontsize "record" =shape ];
    over tchain  [ tuple>node ] map
    [ [ add ] each ] keep
    tuple-connections  [ add ] each
    nip
    ;

: tuple-tree. ( tuple -- )
    tuple-tree preview ;
    
: trecord ( -- graph )
    <digraph>
    [graph "LR" =rankdir "8,8" =size ];
[node 8 =fontsize "record" =shape ];

        "track" [add-node
            "<f0>track|<f1>pack|<f2>sizes" =label
        ];
        "pack" [add-node
            "<f0> pack| <f1> aligned-gadget" =label
        ];

        "track" "pack"   [-> "f1" =tailport "f0" =headport ];
        "node1" "node3"   [-> "f0" =tailport "f0" =headport ];
    ;


\ track tuple-tree
dup preview
"~/tuple.dot" utf8 write-dot


