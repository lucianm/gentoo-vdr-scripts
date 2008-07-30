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

			locale _ctype= _var=
			if [ -n "${LC_ALL}" ]; then
				_var=LC_ALL
			elif [ -n "${LC_CTYPE}" ]; then
				_var=LC_CTYPE
			else
				_var=LANG
			fi

			eval _ctype=\$$_var
			if [ -n "${_ctype}" ]; then
				ewarn "You set ${_var}=${_ctype}"

				if locale -a | fgrep -x -q "${_ctype}"; then
					ewarn "This locale wants to use just ASCII chars - this should not happen!"
				else
					ewarn "This locale does not exist on your system"
					ewarn "Please have a look at /etc/locale.gen"
				fi
			else
				ewarn "You have not set a locale/charmap!"
				ewarn "Please set LANG in /etc/conf.d/vdr"

				if [ ! -e /lib/librc.so ]; then
					# baselayout1
					ewarn "or do this system-wide in /etc/env.d/02locale"
				fi
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
				einfo "Auto-selected locale: ${l}"
			else
				ewarn "Did not find an utf8 locale. You may have problems with non-ASCII characters"
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

	return 0
}

