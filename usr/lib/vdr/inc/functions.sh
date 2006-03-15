# $Id$

include()
{
	local name="${1}"
	local vname=loaded_${name/-/_}
	local check=${!vname}
	[[ ${check:-0} == "1" ]] && return

	source /usr/lib/vdr/inc/${name}.sh
	eval ${vname}=1
}

read_caps()
{
	local capfile=/usr/lib/vdr/rcscript/vdr-capabilities.sh
	[[ -f "${capfile}" ]] && source ${capfile}
}

include message-functions

