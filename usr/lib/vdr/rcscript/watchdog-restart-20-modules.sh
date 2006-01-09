# $Id$
do_unload() {
	local mod=${1}
	modprobe -r ${mod}
}
	
rec_unload() {
	local mod="${1}"
	local mod_deps
	local mod_line
	local mod_tried=""
	while mod_line=$(grep "^${mod} " /proc/modules); do

		mod_deps=$(echo "$mod_line" | awk '{ gsub(","," ",$4); print $4 }')
		einfo_level2 "rec_unload ${mod} (dependency of ${mod_deps})"

		if [[ "${mod_deps}" == "-" ]]; then
			einfo "  unloading ${mod}"
			do_unload ${mod}
			MODULE_LIST="${mod} ${MODULE_LIST}"
			return
		else
			local dep
			for dep in ${mod_deps}; do
				if [[ ${mod_tried} == ${dep} ]]; then
					ewarn "break infinite recursion at ${dep}"
					return
				fi
				rec_unload ${dep}
				mod_tried=${dep}
				# handle only first entry in this inner loop
				break
			done
		fi
	done
}

kill_dvb_video_users() {
	[[ -d /sys ]] || return
	einfo_level2 "Killing programms accessing video device of dvb cards"
	local dev bname name
	for dev in /sys/class/video4linux/video?; do
		[[ -f "${dev}/name" ]] || continue
		
		name=$(cat "${dev}/name")
		[[ ${name/av7110/} == ${name} ]] && continue

		bname=${dev/*\//}
		einfo_level2 "  Killing users of device ${bname} (Name: ${name})"
		fuser -s -k -TERM /dev/${bname}
	done
}

restart_unload() {
	kill_dvb_video_users
	einfo "Unloading DVB modules"
	MODULE_LIST=""
	local mod
	local unload_mod_list="dvb_core"
	for mod in ${unload_mod_list}; do
		rec_unload ${mod}
	done
}

restart_load() {
	einfo "Loading DVB modules"
	local mod
	for mod in ${MODULE_LIST}; do
		einfo "  Loading ${mod}"
		modprobe ${mod}
	done
}

addon_main() {
	: ${WATCHDOG_RELOAD_DVB_MODULES:=no}
	if [[ "${WATCHDOG_RELOAD_DVB_MODULES}" == "yes" ]]; then
		sleep 2
		restart_unload
		sleep 2
		restart_load
		sleep 1
	fi
}

