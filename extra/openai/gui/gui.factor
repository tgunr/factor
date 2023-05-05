! Copyright (C) 2023 Dave Carlton.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs colors fonts help.apropos
help.home help.topics io io.encodings.utf8 io.files kernel math
namespaces openai sequences ui ui.commands ui.gadgets
ui.gadgets.borders ui.gadgets.editors ui.gadgets.labels
ui.gadgets.scrollers ui.gadgets.toolbar ui.gadgets.tracks
ui.gadgets.viewports ui.gestures ui.pens.solid ui.text
ui.tools.browser.history ui.tools.common ui.tools.listener urls
webbrowser wrap.strings prettyprint ;

IN: openai.openai-gui

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

TUPLE: gpt-gadget < track ask response history ;

: com-send ( window -- )
    completion new  1000 >>max_tokens  "text-davinci-003" >>model
    over ask>> editor-string  >>prompt
    over history>> add-history
    create-completion
    "choices" of first "text" of
    over dim>> first wrap-result
    over response>> set-editor-string
    drop ;

: com-cancel ( window -- )
    close-window ;

: com-back ( browser -- ) history>> go-back ;

: com-forward ( browser -- ) history>> go-forward ;

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
} define-command-map

: first-ask ( ask -- editor )
    <editor> dup swapd set-editor-string ;

: <gpt-gadget> ( ask -- gadget )
    vertical gpt-gadget new-track
    1 >>fill  { 10 10 } >>gap  white-interior 
    [ first-ask ] dip  swap >>ask
    <multiline-editor>  10 >>min-rows  80 >>min-cols  >>response
    dup <history> >>history
    dup <ask> f track-add
    dup <response> 1 track-add
    dup <toolbar> f track-add 
    ;

: gpt-new ( ask -- )
    init-api-key
    <gpt-gadget>
    { 5 5 } <border>  { 1 1 } >>fill
    "GPT" open-window ; 

: gpt-window ( -- )   "hello world" gpt-new ;

MAIN: gpt-window
