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

		# export LANG if it is set (before calling locale, Bug #217906)
		[ -n "${LANG}" ] && export LANG

		local charmap=$(locale charmap)

		if [ "${charmap}" = "ANSI_X3.4-1968" ]; then
			# User has not set any locale stuff

			ewarn "Your local charmap is ANSI_X3.4-1968."
			if [ -n "${LANG}" ]; then
				ewarn "It seems the locale you chose does not exist on your system [LANG=${LANG}]"
				ewarn "Please have a look at /etc/locale.gen"
			else
				ewarn "You have not set a charmap! (LANG in /etc/env.d/02locale or /etc/conf.d/vdr)"
			fi

			# Lets guess

			# try an english utf8 locale first
			local l="$(locale -a|grep utf8|grep ^en|head -n 1)"

			if [ "${l}" = "" ]; then
				# none found
				# try any existing utf8 locale
				l="$(locale -a|grep utf8|head -n 1)"
			fi

			if [ "${l}" != "" ]; then
				export LANG="${l}"
				ewarn "Automatically using locale ${l} to get most of vdr utf8 support."
			else
				ewarn "Not found any utf8 locale, you will have problems with chars extending ASCII"
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

