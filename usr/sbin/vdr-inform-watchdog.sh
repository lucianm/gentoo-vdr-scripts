#!/bin/sh
# $Id$
"$@"
killall -q --signal HUP vdr-watchdogd
