! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes colors fonts io
io.encodings.utf8 io.files kernel math namespaces openai sequences ui
ui.baseline-alignment ui.commands ui.gadgets ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.editors ui.gadgets.labels
ui.gadgets.scrollers ui.gadgets.toolbar ui.gadgets.tracks ui.gestures
ui.pens.solid ui.text ui.tools.browser.history ui.tools.common
ui.tools.deploy ui.tools.listener ui.tools.listener.log urls
webbrowser wrap.strings ;

IN: openai.openai-gui

:: <toolbar>* ( target commands -- toolbar )
    horizontal <track>
    1 >>fill
    +baseline+ >>align
    { 5 5 } >>gap
    target
    [ [ commands ] dip class-of get-command-at commands>> ]
    [ '[ [ _ ] 2dip <toolbar-button> f track-add ] ]
    bi assoc-each ;

: <toolbar>** ( target commands -- toolbar )
    over class-of get-command-at commands>>
    horizontal <track>  1 >>fill  +baseline+ >>align  { 5 5 } >>gap
    swap
    [ [ dup ] 3dip [ swap ] 2dip <toolbar-button> t track-add ] assoc-each
    nip ; 

: <toolbar> ( target -- toolbar )
    "toolbar" <toolbar>* ; 

: <tabbar> ( target -- toolbar )
    "tabbar" <toolbar>* ; 

INITIALIZED-SYMBOL: OPENAI-KEY-PATH [ "~/.config/configstore/openai-key" ]

: init-api-key ( -- )
    openai-api-key get-global [
        OPENAI-KEY-PATH get-global dup
        file-exists? [
            utf8 file-lines
            first openai-api-key set-global
        ]
        [ drop
          "Missing API key in OPENAI-KEY-PATH" print
        ]
        if
    ] unless ; 
    
: wrap-result ( string maxwidth -- string' )
    monospace-font " " text-width >integer /  wrap-string ;

: openai-doc ( -- )
    URL" https://platform.openai.com/docs/models/overview" open-url ;

: openai-test ( -- )
    init-api-key
    "text-davinci-003"
    "what is the factor programming language"
    <completion> 100 >>max_tokens create-completion
    "choices" of first "text" of print ;


: >q ( question -- )
    init-api-key
    "text-davinci-003"
    swap <completion> 1000 >>max_tokens create-completion
    "choices" of first "text" of
    listener-gadget get-tool-dim first 
    wrap-string print ; 

TUPLE: gpt-settings < track aimodel key context ;

: <aimodel> ( gpt-settings -- gpt-settings )
    aimodel>> "Model: " label-on-left ;

: <key> ( gpt-settings -- gpt-settings )
    key>> "API Key: " label-on-left ;

: <context> ( gpt-settings -- gpt-settings )
    context>> "Context Messages " label-on-left ;

: com-cancel ( gpt-settings -- )
    close-window ;

: com-save ( gpt-settings -- )
    .HERE ;

: <gpt-settings-gadget> ( -- gadget )
    vertical gpt-settings new-track
    1 >>fill  { 10 10 } >>gap  white-interior 
    "text-davinci-003" <editor> [ set-editor-string ] keep  >>aimodel
    "sk-" <editor> [ set-editor-string ] keep  >>key
    "8" <editor> [ set-editor-string ] keep  >>context
    dup <aimodel> f track-add
    dup <key> 1 track-add
    dup <context> f track-add
    horizontal <track>
    over close-action \ com-cancel <command-button> 1 track-add
    over save-action \ com-save <command-button> 1 track-add
    1 track-add
    ;

: <gpt-settings> ( -- gadget )
    <gpt-settings-gadget>
    { 5 5 } <border>  { 1 1 } >>fill ;

: com-settings ( -- )
    <gpt-settings>
    "GPT SETTINGS" open-window ; 

TUPLE: gpt-gadget < track ask response history settings ;

: com-send ( window -- )
    completion new  1000 >>max_tokens  "text-davinci-003" >>model
    HERE.S over ask>> editor-string  >>prompt
    over history>> add-history
    create-completion
    "choices" of first "text" of
    over dim>> first wrap-result
    over response>> set-editor-string
    drop ;

: com-back ( browser -- ) history>> go-back ;

: com-forward ( browser -- ) history>> go-forward ;

: com-speak ( window -- ) HERE. ;

: com-context ( window -- )  HERE. ;

: com-cost ( window -- )  HERE. ;

: <ask> ( gpt-gadget -- gpt-gadget )
    ask>> "Ask: " label-on-left ;

: <response> ( gpt-gadget -- gpt-gadget )
    response>> <scroller> COLOR: gray <solid> >>boundary ;

M: gpt-gadget history-value
    ask>> editor-string 1 2array ;

M: gpt-gadget set-history-value
    [ first ] dip ask>> set-editor-string ; 

gpt-gadget "toolbar" f {
    { T{ key-down f f "RET" } com-send }
    { f com-back }
    { f com-forward }
    { f com-settings }
} define-command-map

gpt-gadget "tabbar" f {
    { f com-speak }
    { f com-context }
    { f com-cost }
} define-command-map

: first-ask ( ask -- editor )
    <editor> dup swapd set-editor-string ;

: <gpt-gadget> ( ask -- gadget )
    vertical gpt-gadget new-track
    1 >>fill  { 10 10 } >>gap  white-interior 
    [ first-ask ] dip  swap >>ask
    <multiline-editor>  10 >>min-rows  80 >>min-cols  >>response
    <gpt-settings> >>settings
    dup <history> >>history
    dup <tabbar> f track-add
    dup <response> 1 track-add
    dup <ask> f track-add
    dup <toolbar> f track-add 
    ;

: gpt-new ( ask -- )
    init-api-key
    <gpt-gadget>
    { 5 5 } <border>  { 1 1 } >>fill
    "GPT" open-window ; 

: gpt-window ( -- )   "hello world" gpt-new ;

MAIN: gpt-window
