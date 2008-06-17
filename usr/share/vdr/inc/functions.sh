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
	local capfile=/usr/share/vdr/capabilities.sh
	[ -f "${capfile}" ] && . ${capfile}
}

