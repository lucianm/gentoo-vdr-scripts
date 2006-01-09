# $Id$
addon_main() {
	[[ -n ${CAP_UTF8} ]] && return

	local lang_vars=$(locale)
	[[ ${lang_vars} != ${lang_vars//utf8/} ]] && einfo_level1 "disabling UTF-8 for vdr"
	# deaktiviere utf8
	for lvar in ${lang_vars}; do
		eval export ${lvar/.utf8/}
	done
}

