#!/bin/sh

# /etc/X11/xinit/xinitrc
#
# global xinitrc file, used by all X sessions started by xinit (startx)
# invoke global X session script
wal -R > ~/wal.log 2>&1
. /etc/X11/Xsession
