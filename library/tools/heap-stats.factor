! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: memory
USING: errors generic kernel lists math namespaces prettyprint
stdio unparser vectors words ;

: kb. 1024 /i unparse write " KB" write ;

: (room.) ( free total -- )
    2dup swap - swap ( free used total )
    kb. " total " write
    kb. " used " write
    kb. " free" print ;

: room. ( -- )
    room
    "Data space: " write (room.)
    "Code space: " write (room.) ;

: heap-stat. ( type instances bytes -- )
    dup 0 = [
        3drop
    ] [
        rot builtin-type word-name write ": " write
        unparse write " bytes, " write
        unparse write " instances" print
    ] ifte ;

: heap-stats. ( -- )
    #! Print heap allocation breakdown.
    0 heap-stats [ dupd uncons heap-stat. 1 + ] each drop ;

: (each-object) ( quot -- )
    next-object dup [
        swap dup slip (each-object)
    ] [
        2drop
    ] ifte ; inline

: each-object ( quot -- )
    #! Applies the quotation to each object in the image.
    [
        begin-scan (each-object)
    ] [
        end-scan rethrow
    ] catch ; inline

: instances ( class -- list )
    #! Return a list of all instances of a built-in or tuple
    #! class.
    [
        [
            dup class pick = [ , ] [ drop ] ifte
        ] each-object drop
    ] make-list ;
