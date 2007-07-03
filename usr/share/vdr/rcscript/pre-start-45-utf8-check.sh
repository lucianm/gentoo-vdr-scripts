# $Id$

# disable all locale settings from the system
# mostly used to get away from utf8 if vdr does
# not support it
unset_all_locale_settings() {
	local LOCALE_VARS="LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY
			LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE
			LC_MEASUREMENT LC_IDENTIFICATION LC_ALL"


	# clear out all locale-variables if not already done by baselayout
	local var
	for var in $LOCALE_VARS; do
		unset $var
	done
}


addon_main() {
	if [ -n "${CAP_UTF8}" ]; then
		# vdr supports utf8 :)
		local charmap=$(locale charmap)
		local l

		# export LANG if it is set
		[ -n "${LANG}" ] && export LANG

		if [ "${charmap}" = "ANSI_X3.4-1968" ]; then
			# User has not set any locale stuff

			ewarn "You have not set a charmap! (LANG in /etc/env.d/02locale or /etc/conf.d/vdr)"


			# Lets guess

			# try an english utf8 locale
			l="$(locale -a|grep utf8|grep ^en|head -n 1)"

			if [ "${l}" = "" ]; then
				# none found
				# try any existing utf8 locale
				l="$(locale -a|grep utf8|head -n 1)"
			fi

			if [ "${l}" != "" ]; then
				export LANG="${l}"
				ewarn "Automatically using locale ${l} to get most of vdr utf8 support."
			fi

		fi
	else
		# vdr does not support utf8
		# lets force it off
		unset_all_locale_settings
	fi

	# set sort-order if specified in conf-file
	if [ -n "${VDR_SORT_ORDER}" ]; then
		export LC_COLLATE="${VDR_SORT_ORDER}"
	fi

	# get error messages in english
	export LC_MESSAGES="C"

	return 0
}

