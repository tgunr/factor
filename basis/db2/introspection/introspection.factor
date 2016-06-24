! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: db2.connections ;
IN: db2.introspection

HOOK: all-db-objects db2-connection ( -- sequence )
HOOK: all-tables db2-connection ( -- sequence )
HOOK: all-indices db2-connection ( -- sequence )
HOOK: temporary-db-objects db2-connection ( -- sequence )

HOOK: table-columns db2-connection ( name -- sequence )


