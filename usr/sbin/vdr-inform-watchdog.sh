#!/bin/bash
"$@"
/usr/bin/killall -q --signal HUP vdr-watchdogd
