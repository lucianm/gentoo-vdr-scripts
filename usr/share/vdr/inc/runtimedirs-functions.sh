
# Ensures that the directories needed at runtime exist before starting
# the VDR service, either under OpenRC or systemd
#

ensure_cache_dir() {
	CACHEDIR=$(get_cfg_opt vdr --cachedir)
	if [ ! -d "${CACHEDIR:-/var/cache/vdr}" ]; then
		mkdir -p "${CACHEDIR:-/var/cache/vdr}"
		chown vdr:vdr "${CACHEDIR:-/var/cache/vdr}"
		einfo "Created directory ${CACHEDIR:-/var/cache/vdr}"
	fi
}

ensure_video_dir() {
	VIDEO=$(get_cfg_opt vdr --video)
	[ -z "${VIDEO}" ] && VIDEO="/var/lib/vdr/video"
	if [ ! -d "${VIDEO}" ]; then
		mkdir -p "${VIDEO}"
		chown vdr:vdr "${VIDEO}"
		einfo "Created directory ${VIDEO}"
	fi
}
