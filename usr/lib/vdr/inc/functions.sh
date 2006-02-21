# $Id: rc-functions.sh 133 2006-01-09 20:54:04Z zzam $

include()
{
	local name="${1}"
	local vname=loaded_${name/-/_}
	local check=${!vname}
	[[ ${check:-0} == "1" ]] && return

	source /usr/lib/vdr/inc/${name}.sh
	eval ${vname}=1
}

