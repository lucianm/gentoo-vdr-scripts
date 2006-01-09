#!/bin/bash
# $Id$
#
# Start command in background and disconnects outputs.
# Use this instead of echo "..." | at now

${@} >/dev/null 2>&1 &
