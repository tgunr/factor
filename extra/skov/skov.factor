! File: skov
! Version: 0.1
! DRI: Dave Carlton
! Description: Code for skov
! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs colors colors.gray combinators
combinators.short-circuit combinators.smart help.topics kernel
math math.functions math.order math.vectors models models.range
namespaces opengl opengl.gl sequences skov.basis.code.execution
skov.basis.ui.gadgets.buttons.round
skov.basis.ui.pens.gradient-rounded
skov.basis.ui.tools.environment.theme ui.backend ui.gadgets
ui.gadgets.buttons ui.gadgets.packs ui.pens ui.pens.caching
skov.basis.ui.tools.environment vocabs words ;
IN: skov

: ui-tools-main ( -- )
    f ui-stop-after-last-window? set-global
    environment-window ;

MAIN: ui-tools-main
