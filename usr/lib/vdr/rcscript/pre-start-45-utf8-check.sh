# $Id$
addon_main() {
	local LOCALE_VARS="LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY
			LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE
			LC_MEASUREMENT LC_IDENTIFICATION LC_ALL"


	# clear out all locale-variables if not already done by baselayout
	local var
	for var in $LOCALE_VARS; do
		unset $var
	done

	# set sort-order if specified in conf-file
	if [[ -n ${VDR_SORT_ORDER} ]]; then
		export LC_COLLATE="${VDR_SORT_ORDER}"
	fi
}

