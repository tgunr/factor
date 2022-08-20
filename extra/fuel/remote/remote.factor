! Copyright (C) 2009, 2010 Jose Antonio Ortega Ruiz.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.servers kernel logging.pmlog math prettyprint
tty-server ;

IN: fuel.remote

<PRIVATE

: print-banner ( -- )
    LOG-HERE
    get-callstack callstack.
    "Starting server. Connect with 'M-x connect-to-factor' in Emacs"
    write nl flush ;

PRIVATE>

: fuel-start-remote-listener ( port/f -- )
    print-banner [ 9000 ] unless* <tty-server> start-server drop ;

: fuel-start-remote-listener* ( -- ) f fuel-start-remote-listener ;

! Remote connection
MAIN: fuel-start-remote-listener*
