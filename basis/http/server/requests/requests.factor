USING: accessors combinators continuations http http.parsers io io.crlf
io.encodings io.encodings.binary io.streams.limited kernel math.order
math.parser namespaces sequences splitting urls urls.encoding ;
FROM: mime.multipart => parse-multipart ;
IN: http.server.requests

ERROR: request-error ;

ERROR: no-boundary < request-error ;

ERROR: invalid-path < request-error path ;

ERROR: bad-request-line < request-error parse-error ;

: check-absolute ( url -- )
    path>> dup "/" head? [ drop ] [ invalid-path ] if ; inline

: parse-request-line-safe ( string -- triple )
    [ parse-request-line ] [ nip bad-request-line ] recover ;

: read-request-line ( request -- request )
    read-?crlf [ dup "" = ] [ drop read-?crlf ] while
    parse-request-line-safe first3
    [ >>method ] [ >url dup check-absolute >>url ] [ >>version ] tri* ;

: read-request-header ( request -- request )
    read-header >>header ;

SYMBOL: upload-limit

upload-limit [ 200,000,000 ] initialize

: parse-multipart-form-data ( string -- separator )
    ";" split1 nip
    "=" split1 nip [ no-boundary ] unless* ;

: read-multipart-data ( request -- mime-parts )
    [ "content-type" header ]
    [ "content-length" header string>number ] bi
    unlimited-input
    upload-limit get [ min ] when* limited-input
    binary decode-input
    parse-multipart-form-data parse-multipart ;

: read-content ( request -- bytes )
    "content-length" header string>number read ;

: parse-content ( request content-type -- post-data )
    [ <post-data> swap ] keep {
        { "multipart/form-data" [ read-multipart-data >>params ] }
        { "application/x-www-form-urlencoded" [ read-content query>assoc >>params ] }
        [ drop read-content >>data ]
    } case ;

: read-post-data ( request -- request )
    dup method>> "POST" = [
        dup dup "content-type" header
        ";" split1 drop parse-content >>post-data
    ] when ;

: extract-host ( request -- request )
    [ ] [ url>> ] [ "host" header parse-host ] tri
    [ >>host ] [ >>port ] bi*
    drop ;

: extract-cookies ( request -- request )
    dup "cookie" header [ parse-cookie >>cookies ] when* ;

: read-request ( -- request )
    <request>
    read-request-line
    read-request-header
    read-post-data
    extract-host
    extract-cookies ;
