# evaluate vdr-user's $HOME
vdr_user_home=$(eval echo ~vdr)

# Handle inclusion of script-helper-files

include() {
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
read_caps() {
	local capfile=/usr/share/vdr/capabilities.sh
	[ -f "${capfile}" ] && . ${capfile}
}

# read file containing just one integer value
# $1 filename to read
# returns read value on stdout if successful, else return 0 there
read_int_from_file() {
	local fname="$1" value="0"
	if [ -r "$fname" -a -s "$fname" ]; then
		value="$(cat "$fname")"
	fi
	echo $(($value+0))
}

if ! type yesno >/dev/null 2>&1; then

yesno() {
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
