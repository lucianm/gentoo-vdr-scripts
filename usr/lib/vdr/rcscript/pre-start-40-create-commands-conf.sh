create_commands_conf() {
	local CONFIG="${CONFIG:-/etc/vdr}"
	local bname="${1}"
	local order="${2}"
	local file="${CONFIG}/${bname}.conf"
	local newfile="/var/vdr/${bname}.conf"
	local sdir="/etc/vdr/${bname}"

	if [[ ! -L "${file}" ]]; then
		if [[ -f "${file}" ]]; then
			mv "${file}" "${file}.backup"
			einfo "Saved original ${file} as ${file}.backup"
		fi

		ln -s "../../${newfile}" "${file}"
	fi

	if ! rm "${newfile}"; then
		ewarn "Could not change ${newfile}"
		return
	fi
	cat > "${newfile}" <<-EOT
	# Warning: Do not change this file.
	# This file is generated automatically by /etc/init.d/vdr.
	# Change the source files under ${sdir}.

EOT
	test -d "${sdir}" || return 1
	SFILES=$(echo /etc/vdr/${bname}/${bname}.*.conf)
	for f in ${SFILES}; do
		[[ -f "${f}" ]] || continue
		echo "# source : ${f}" >> "${newfile}"
		cat "${f}" >> "${newfile}"
		echo >> "${newfile}"
	done
}

if [[ ! -d /var/vdr ]]; then
	ewarn "directory /var/vdr does not exist"
else
	create_commands_conf commands "${ORDER_COMMANDS}"
	create_commands_conf reccmds "${ORDER_RECCMDS}"
fi
