#!/usr/bin/env bash

export GDK_SCALE=2
export GDK_DPI_SCALE=0.5
export QT_AUTO_SCREEN_SCALE_FACTOR=1


xset s off -dpms

xrdb -merge "${HOME}/.Xresources"
wal -R -o wal-set

