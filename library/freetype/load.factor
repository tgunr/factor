USING: alien io kernel parser sequences ;

"freetype" {
    { [ os "macosx" = ] [ "libfreetype.dylib.6" ] }
    { [ os "win32" = ] [ "freetype6.dll" ] }
    { [ t ] [ "libfreetype.so.6" ] }
} cond "cdecl" add-library
    
[
    "/library/freetype/freetype.factor"
    "/library/freetype/freetype-gl.factor"
] [
    dup print run-resource
] each
