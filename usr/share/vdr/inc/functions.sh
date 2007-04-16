# $Id$

# Handle inclusion of script-helper-files

include()
{
	local name="${1}"
	local vname=loaded_$(echo ${name} | tr '-' '_')
	local check
	eval check=\$${vname}
	[ "${check:-0}" = "1" ] && return

	. /usr/share/vdr/inc/${name}.sh
	eval ${vname}=1
}

# Read file with definitions of capabilities of vdr-binary
# e.g. svdrp-down-command / some patches
read_caps()
{
	local capfile
	for capfile in /usr/share/vdr/capabilities.sh /usr/lib/vdr/rcscript/vdr-capabilities.sh; do
		if [ -f "${capfile}" ]; then
			. ${capfile}
			break
		fi
	done
}

