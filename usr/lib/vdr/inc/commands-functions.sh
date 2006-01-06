merge_commands_conf() {
	local CONFIG="${CONFIG:-/etc/vdr}"
	local sdir="${1}"
	local destfile="${2}"
	local order="${3}"
	
	local bname=${destfile##*/}
	local mergedfile="/var/vdr/merged-config-files/${bname}.conf"

	if [[ -L "${destfile}" ]]; then
		# remove link
		rm "${destfile}"
	else
		# no link
		if [[ -f "${destfile}" ]]; then
			mv "${destfile}" "${destfile}.backup"
			einfo "  Saved original ${destfile} as ${destfile}.backup"
		fi
	fi

	ln -s "${mergedfile}" "${destfilefile}"

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
	SFILES=$(echo ${sdir}/*.conf)
	for f in ${SFILES}; do
		[[ -f "${f}" ]] || continue
		echo "# source : ${f}" >> "${mergedfile}"
		cat "${f}" >> "${mergedfile}"
		echo >> "${mergedfile}"
	done
}

# merge_commands_conf /etc/vdr/commands /etc/vdr/commands.conf "${ORDER_COMMANDS}"
# merge_commands_conf /etc/vdr/reccmds /etc/vdr/reccmds.conf "${ORDER_RECCMDS}"

