#
include language-functions

# merging the files under /etc/vdr/commands/ to one single file under /var/vdr/merged-config-files/ and links
# it to /etc/vdr/commands.conf.
# This merged file can then be used by the vdr process.

merge_commands_conf() {
	read_vdr_language

	local CONFIG="${CONFIG:-/etc/vdr}"
	local sdir="${1}" destfile="${2}" order="${3}"

	local bname=${destfile##*/}
	local mergedfile="/var/vdr/merged-config-files/${bname}"

	# merging files
	if [ -f "${mergedfile}" ]; then
		if ! rm "${mergedfile}"; then
			ewarn "  Could not change ${mergedfile}"
			return
		fi
	fi
	cat > "${mergedfile}" <<-EOT
	# Autogenerated ${destfile}
	# Warning: Do not change this file.
	# This file is generated automatically by /etc/init.d/vdr.
	# Change the source files under ${sdir}.

EOT
	test -d "${sdir}" || return 1
	SFILES=$(echo ${sdir}/*.conf)
	local f= inputf=
	for f in ${SFILES}; do
		[ -f "${f}" ] || continue
		inputf="${f}"

		[ -f "${f}.${VDR_LANGUAGE}" ] && inputf="${f}.${VDR_LANGUAGE}"

		echo "# source : ${inputf}" >> "${mergedfile}"
		cat "${inputf}" >> "${mergedfile}"
		echo >> "${mergedfile}"
	done

	chown vdr:vdr "${mergedfile}"

	# link it to real location
	if [ -L "${destfile}" ]; then
		# remove link
		rm "${destfile}"
	else
		# no link
		if [ -f "${destfile}" ]; then
			mv "${destfile}" "${destfile}.backup"
			einfo "  Saved original ${destfile} as ${destfile}.backup"
		fi
	fi

	ln -s "${mergedfile}" "${destfile}"
}

#Usage example
# merge_commands_conf /etc/vdr/commands /etc/vdr/commands.conf "${ORDER_COMMANDS}"
# merge_commands_conf /etc/vdr/reccmds /etc/vdr/reccmds.conf "${ORDER_RECCMDS}"
