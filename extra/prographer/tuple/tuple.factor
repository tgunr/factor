! Copyright (C) 2021 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
! Description: A visual graph of code and data based on Prograph language
! Copyright (C) 2021 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors assocs classes classes.tuple graphviz graphviz.dot
graphviz.notation graphviz.render grouping io.encodings.utf8 kernel
math math.parser sequences sequences.deep slots splitting ui.gadgets.tracks
sequences.private variables vocabs.parser words present arrays ;

IN: sequences

: each-integer-initially ( ... n quot: ( ... i -- ... ) -- ... )
  [ ] curry 2dip  (each-integer) ; inline

: each-index-initially
  ( ... number seq quot: ( ... elt index -- ... ) -- ... )
  (each-index) rot each-integer-initially ; inline

IN: prographer.tuple

VAR: fValue

: (detuple) ( name -- string )
    "|<f"  fValue number>string append
    ">" append swap  append
    fValue 1+ set: fValue
    ;

: slots@ ( word -- seq )
  "slots" word-prop ;

: super@ ( word -- super|f )
  "superclass" word-prop ;

: tupleslots ( tuple -- seq )
  slots@
  [ name>> search ] filter
  [ name>> search ] map
  [ tuple-class? ] filter
;

: tchain ( word -- seq )
  dup
  [ dup super@ ] [ super@ dup  ] produce
  nip  swap prefix ;

: >labels ( label -- assoc )
    "| " split  [ "" = not ] filter
    2 group [ reverse ] map
    rest ;

: node>labels ( node -- labels )
    attributes>> label>>  >labels ;

FROM: graphviz => node ;
TUPLE: tuple-node < node tuple slots next# ;

: <tuple-node> ( tuple -- tuple-node )
    tuple-node new
    over >>tuple
    <node-attributes> >>attributes
    swap name>> present >>id
    { } >>slots
;

:: tuple>node ( tuple -- node )
    tuple props>> :> pl
    tuple super@ :> sc
    "slots" pl at :> sl
    tuple <tuple-node>
    "record" =shape
    "<f0>" tuple name>> append
    sc
    [
        "|<f1>" sc name>> append  append
        2 set: fValue
    ]
    [  1 set: fValue ]
    if

    sl [
         [ name>> (detuple) append ] each
    ] unless-empty
    =label
    ;

: superlabel ( <tuple-node> -- <tuple-node> )
   dup tuple>> super@
   [  name>> "|<f1>" prepend
      over attributes>> label>> prepend  =label
      2 >>next# ]
   [  1 >>next# ]
   if*
;

: index>label ( label# index -- label )
  + number>string  "|<f" prepend  ">" append ;

: slot>label ( label# slot index -- label# label )
  [ dup ] 2dip
  ! label# label# slot index
  rot
  ! label# slot index label#
  index>label
  ! label# slot label
  swap
  ! label# label slot
  name>> append
  ! label# label
;

: slots>labels ( tuple-node -- seq )
  dup
  ! tuple-node tuple-node
  next#>>
  ! tuple-node label#
  over tuple>> "slots" word-prop
  ! tuple-node label# slots
  [ slot>label ] map-index
  ! tuple-node label# seq
  2nip
  ! seq
;

: tuple>nodes ( tuple -- nodes )
  <tuple-node>
  ! tuple-node
  "record" =shape
  dup id>> "<f0>" prepend  =label
  ! tuple-node
  superlabel
  ! tuple-node
  [ slots>labels ] keep
  [ attributes>> label>> ] keep
  [ swap [ append ] each ] dip
  swap =label
;

: tuples>nodes ( seq -- nodes )
  [ tuple>nodes ] map
;

: slot-nodes ( node -- nodes )
    node>labels keys
    [ search ] filter
    [ search ] map
    ;

VAR: prevNode
:: tuple-connections ( nodes -- edges )
    f :> prevNode! V{ } clone :> edgeNodes!
    nodes
    [ prevNode
      [ prevNode  over id>> <edge>
        ! "f0" =headport "f1" =tailport
        edgeNodes swap suffix! edgeNodes!
        dup B slot-nodes
        [ edgeNodes swap tuple>node suffix! edgeNodes! ] each
        id>> prevNode!
      ]
      [ id>> prevNode! ]
      if
    ] each
    edgeNodes
    ;

: <tuple-graph> ( tuple -- graph tuple )
    <digraph> over name>> >>id
    [graph "LR" =rankdir "8,8" =size ];
    [node 8 =fontsize "record" =shape ];
    swap
    ;

: tuple-tree ( tuple -- graph|f )
    [ <tuple-graph>
      tchain [ tuple>nodes ] map
      [ add ] each
    ]
    [ f ]
    if*
    ;

: tuple-tree. ( tuple -- )
    tuple-tree
    [ preview ] when* ;

: tuple-tree-test ( -- )
    \ track
    [ tuple-tree
      [ dup preview  "~/tuple.dot" utf8 write-dot ] when*
    ] when*
    ;
