#!/bin/bash

# where is our /video located?
source /etc/conf.d/vdr
test -z "${VIDEO}" && VIDEO=/video

# check for running programms
CMD_LST="make gcc noad cc1 transcode vcdimager mencoder tosvcd lame vdrsync.pl tcmplex tcmplex-panteltje vdr2ac3.sh"

if [ -f /tmp/sandboxpids.tmp ]
then
	logger -i "${0##*/} >> stop shutdown, because emerge is running <<"
	echo ">> stop shutdown, because emerge is running <<"
	exit
fi

for x in ${CMD_LST}
do
	if pidof $x >/dev/null
	then
		logger -i "${0##*/} >> stop shutdown, because $x is running <<"
		echo ">> stop shutdown, because $x is running <<"
		exit
	fi
done

# check if there are some users logged in
if [ "x${5}" != "x1"  -a "$(who | wc -l)" != "0" ]
then
	logger -i "${0##*/} >> stop shutdown, because $(who | wc -l) users are logged in <<"
	echo ">> stop shutdown, because $(who | wc -l) users are logged in <<"
	exit
fi

# do we want auto-shutdown?
if [ "x${5}" != "x1" -a ! -f ${VIDEO}/shutdown-enabled ]
then
	logger -i "${0##*/} >> auto-shutdown is not allowed <<"
	echo "$(date) >> auto-shutdown is not allowed <<"
	exit
fi
