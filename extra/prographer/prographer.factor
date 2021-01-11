! File: prographer.factor
! Version: 0.1
! DRI: Dave Carlton
! Description: A visual graph of code and data based on Prograph language
! Copyright (C) 2021 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors assocs graphviz graphviz.notation graphviz.render
kernel math.parser sequences ui.gadgets.tracks variables ;
IN: prographer


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
    f :> prevNode! V{ } :> edgeNodes!
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
    <graph> over name>> >>id
    [graph "LR" =rankdir "8,8" =size ];
    [node 8 =fontsize "record" =shape ];

    over tchain  [ tuple>node ] map
    [ [ add ] each ] keep
    tuple-connections  [ add ] each
    nip
    ;
        
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
        "aligned-gadget" [add-node
            "<f0> gadget | baseline | cap-height" =label
        ];
        "node3" [add-node
            "<f0> 3.43322790286038071e-06|44.79998779296875|0" =label
        ];
        "node4" [add-node
            "<f0> 0xf7fc4380| <f1> | <f2> |2" =label
        ];
        "node5" [add-node
            "<f0> (nil)| | |-1" =label
        ];
        "node6" [add-node
            "<f0> 0xf7fc4380| <f1> | <f2> |1" =label
        ];
        "node7" [add-node
            "<f0> 0xf7fc4380| <f1> | <f2> |2" =label
        ];
        "node8" [add-node
            "<f0> (nil)| | |-1" =label
        ];
        "node9" [add-node
            "<f0> (nil)| | |-1" =label
        ];
        "node10" [add-node
            "<f0> (nil)| <f1> | <f2> |-1" =label
        ];
        "node11" [add-node
            "<f0> (nil)| <f1> | <f2> |-1" =label
        ];
        "node12" [add-node
            "<f0> 0xf7fc43e0| | |1" =label
        ];

        "track" "pack"   [-> "f1" =tailport "f0" =headport ];
        "node1" "node3"   [-> "f0" =tailport "f0" =headport ];
        "node1" "node4"   [-> "f1" =tailport "f0" =headport ];
        "node1" "node5"   [-> "f2" =tailport "f0" =headport ];
        "node4" "node3"   [-> "f0" =tailport "f0" =headport ];
        "node4" "node6"   [-> "f1" =tailport "f0" =headport ];
        "node4" "node10"  [-> "f2" =tailport "f0" =headport ];
        "node6" "node3"   [-> "f0" =tailport "f0" =headport ];
        "node6" "node7"   [-> "f1" =tailport "f0" =headport ];
        "node6" "node9"   [-> "f2" =tailport "f0" =headport ];
        "node7" "node3"   [-> "f0" =tailport "f0" =headport ];
        "node7" "node1"   [-> "f1" =tailport "f0" =headport ];
        "node7" "node8"   [-> "f2" =tailport "f0" =headport ];
        "node10" "node11" [-> "f1" =tailport "f0" =headport ];
        "node10" "node12" [-> "f2" =tailport "f0" =headport ];
        "node11" "node1"  [-> "f2" =tailport "f0" =headport ];
    ;


\ track tuple-tree
preview


    
