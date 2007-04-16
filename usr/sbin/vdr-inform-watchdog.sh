#!/bin/sh
# $Id$
"$@"
/usr/bin/killall -q --signal HUP vdr-watchdogd
