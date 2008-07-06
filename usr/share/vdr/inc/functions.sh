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

if ! type yesno >/dev/null 2>&1; then

yesno()
{
	[ -z "$1" ] && return 1

	case "$1" in
		[Yy][Ee][Ss]|[Tt][Rr][Uu][Ee]|[Oo][Nn]|1) return 0;;
		[Nn][Oo]|[Ff][Aa][Ll][Ss][Ee]|[Oo][Ff][Ff]|0) return 1;;
	esac

	local value=
	eval value=\$${1}
	case "${value}" in
		[Yy][Ee][Ss]|[Tt][Rr][Uu][Ee]|[Oo][Nn]|1) return 0;;
		[Nn][Oo]|[Ff][Aa][Ll][Ss][Ee]|[Oo][Ff][Ff]|0) return 1;;
		*) vewarn "\$${1} is not set properly"; return 1;;
	esac
}
fi


