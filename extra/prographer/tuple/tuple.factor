! Copyright (C) 2021 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
! Description: A visual graph of code and data based on Prograph language
! Copyright (C) 2021 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs classes classes.tuple graphviz
graphviz.attributes graphviz.dot graphviz.notation
graphviz.render grouping io.encodings.utf8 kernel math
math.parser namespaces present sequences sequences.deep
sequences.private sets slots splitting ui.gadgets.tracks
variables vocabs vocabs.parser words ;

IN: vocabs.parser

! use-vocab spews if already using, this word just sets quitely
: (use-vocab) ( vocab -- )
  manifest get
  [ [ ?load-vocab ] dip search-vocabs>> push ]
  [ [ vocab-name ] dip search-vocab-names>> adjoin ]
  2bi
;

IN: prographer.tuple

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
  dup tuple>>  vocabulary>> (use-vocab)
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

: superlabel ( <tuple-node> -- <tuple-node> )
   dup tuple>> super@
   [  name>> " | <f1> " prepend
      over attributes>> label>> prepend  =label
      2 >>next# ]
   [  1 >>next# ]
   if*
;

: index>label ( label# index -- label )
  + number>string  " | <f" prepend  "> " append ;

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
  dup id>> "<f0> " prepend  =label
  ! tuple-node
  superlabel
  ! tuple-node
  [ slots>labels ] keep
  [ attributes>> label>> ] keep
  [ swap [ append ] each ] dip
  swap =label
;

: slot-nodes ( node -- nodes )
    node>labels keys
    [ search ] filter
    [ search ] map
    ;

: slot>nodes ( seq seq -- seq )
  [ slot-nodes append ] each
  ;

: tuples>nodes ( seq -- nodes )
  [ tuple>nodes ] map
  V{ } swap slot>nodes
;

: <tuple-graph> ( tuple -- graph tuple )
    <digraph> over name>> >>id
    [graph "TB" =rankdir "8,8" =size ];
    [node 8 =fontsize "record" =shape ];
    swap
    ;

: tuple-tree ( tuple -- graph|f )
    [ <tuple-graph>
      tchain tuples>nodes
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
