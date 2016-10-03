! Copyright (C) 2004, 2008 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators fry io.backend io.directories
io.files.info io.files.links io.files.types io.pathnames kernel make
sequences splitting tools.walker ;
IN: io.directories.hierarchy

<PRIVATE

: directory-tree-files% ( path prefix -- )
    [ normalize-path ] bi@
    [ dup directory-entries ] dip '[
        [ name>> [ append-path ] [ _ prepend-path ] bi ]
        [ directory? ] bi over ,
        [ directory-tree-files% ] [ 2drop ] if
    ] with each ;

PRIVATE>

: directory-tree-files ( path -- seq )
    [ "" directory-tree-files% ] { } make ;

: with-directory-tree-files ( path quot -- )
    '[ "" directory-tree-files @ ] with-directory ; inline

: delete-tree ( path -- )
    dup link-info directory? [
        [ [ [ delete-tree ] each ] with-directory-files ]
        [ delete-directory ]
        bi
    ] [ delete-file ] if ;

DEFER: copy-trees-into

: copy-tree ( from to -- )
    normalize-path
    over link-info type>>
    {
        { +symbolic-link+ [ copy-link ] }
        { +directory+ [ '[ _ copy-trees-into ] with-directory-files ] }
        [ drop copy-file ]
    } case ;

: copy-tree-into ( from to -- )
    to-directory copy-tree ;

: copy-trees-into ( files to -- )
    '[ _ copy-tree-into ] each ;
