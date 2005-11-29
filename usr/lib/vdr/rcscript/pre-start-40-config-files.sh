create_commands_conf() {
	local CONFIG="${CONFIG:-/etc/vdr}"
	local bname="${1}"
	local order="${2}"
	local file="${CONFIG}/${bname}.conf"
	local mergedfile="/var/vdr/${bname}.conf"
	local sdir="/etc/vdr/${bname}"

	if [[ ! -L "${file}" ]]; then
		if [[ -f "${file}" ]]; then
			mv "${file}" "${file}.backup"
			einfo "  Saved original ${file} as ${file}.backup"
		fi

		ln -s "../../${mergedfile}" "${file}"
	fi

	if [[ -f "${mergedfile}" ]]; then
		if ! rm "${mergedfile}"; then
			ewarn "  Could not change ${mergedfile}"
			return
		fi
	fi
	cat > "${mergedfile}" <<-EOT
	# Warning: Do not change this file.
	# This file is generated automatically by /etc/init.d/vdr.
	# Change the source files under ${sdir}.

EOT
	test -d "${sdir}" || return 1
	SFILES=$(echo /etc/vdr/${bname}/${bname}.*.conf)
	for f in ${SFILES}; do
		[[ -f "${f}" ]] || continue
		echo "# source : ${f}" >> "${mergedfile}"
		cat "${f}" >> "${mergedfile}"
		echo >> "${mergedfile}"
	done
}

addon_main() {
	ebegin "  config files"
	if [[ ! -d /var/vdr ]]; then
		mkdir -p /var/vdr
		ewarn "    created /var/vdr"
	fi
	create_commands_conf commands "${ORDER_COMMANDS}"
	create_commands_conf reccmds "${ORDER_RECCMDS}"

	if [[ -f /etc/vdr/setup.conf ]]; then
		if [[ -n "${STARTUP_VOLUME}" ]]; then
			/usr/bin/sed -i /etc/vdr/setup.conf -e "s/^CurrentVolume =.*\$/CurrentVolume = ${STARTUP_VOLUME}/"
		fi

		if [[ -n "${STARTUP_CHANNEL}" ]]; then
			/usr/bin/sed -i /etc/vdr/setup.conf -e "s/^CurrentChannel =.*\$/CurrentChannel = ${STARTUP_CHANNEL}/"
		fi
	fi

	eend 0
}
