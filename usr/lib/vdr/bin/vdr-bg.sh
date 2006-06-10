#!/bin/bash
# $Id$
#
# Start command in background and disconnects outputs.
# Use this instead of echo "..." | at now

export EXECUTED_BY_VDR_BG=1
${@} >/dev/null 2>&1 &
