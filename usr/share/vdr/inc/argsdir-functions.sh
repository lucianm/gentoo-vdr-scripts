#
#
# Functions for retrieving information from $ARGSDIR/../conf.avail/xxx.conf,
# list all the enabled plugins in the right order


ARGSDIR=$(pkg-config --variable=argsdir vdr)
DIR_AVAILABLE=$ARGSDIR/../conf.avail
DIR_SKIPPED=$ARGSDIR/../conf.skipped

init_skipped_dir() {
	if [ ! -d "${DIR_SKIPPED}" ]; then
		mkdir -p "${DIR_SKIPPED}"
		chown vdr:vdr "${DIR_SKIPPED}"
	fi
}

# returns the path for $1.conf
get_cfg_avail_path() {
	local cfg_path=$DIR_AVAILABLE/$1.conf
	if [ -f "$cfg_path" ]; then
		echo $cfg_path
	else
		echo ""
	fi
}

# returns the names of the configured plugins, in the order they are found in ARGSDIR,
# even if some are configured multiple times, TODO: somehow, separated by : together with
# their symlink name, for being used also for checksums, for disabling / enabling, read even
# by vdrplugin-rebuild (but then regardless if _disabled, or maybe even then, differentiate between them ????)
get_configured_cfgs() {
	_scan_cfgs $ARGSDIR
}

get_available_cfgs() {
	_scan_cfgs $DIR_AVAILABLE
}

get_skipped_cfgs() {
	_scan_cfgs $DIR_SKIPPED
}

get_configured_plgs() {
	_scan_cfgs $ARGSDIR plg_names
}

get_available_plgs() {
	_scan_cfgs $DIR_AVAILABLE plg_names
}

get_skipped_plgs() {
	_scan_cfgs $DIR_SKIPPED plg_names
}

#
# scans for plugin configs in given directory, skips [vdr] itself
_scan_cfgs() {
	local configured_plugins
	for plg_cfg in $(ls $1); do
			plg_name=$(cfg_path_2_plg_name $1/$plg_cfg)
			if [ "$plg_name" == "vdr" ]; then
				cfg_vdr=$plg_cfg
			else
				[ "$configured_plugins" == "" ] || configured_plugins="$configured_plugins "
				if [ "$2" == "plg_names" ]; then
					configured_plugins="$configured_plugins$plg_name"
				else
					configured_plugins="$configured_plugins$plg_cfg"
				fi
			fi
	done
	echo $configured_plugins
}

cfg_path_2_plg_name() {
	local plg_cfg=$1
	local plg_name=$(grep '^\[' $plg_cfg);
	plg_name=${plg_name/[/};
	plg_name=${plg_name/]/};
	echo $plg_name
}

# returns value of specified option if present in /etc/vdr/conf.avail/$1.conf
# $1 long version of the option, like --option
# $2 short version of the option, like -D
# the long version of the option should be preferred, as it always exists
get_cfg_opt() {
	local cfg=$1
	local cfg_path=$(get_cfg_avail_path $cfg)
	local long_opt=$2
	local short_opt=$3
	# scan for long option like "--option=value" at the beginning of the line
	local opt=$(grep "^${long_opt}" $cfg_path)
	opt=${opt/$long_opt=/}
	if (($# == 3)) && [ "$opt" == "" ]; then
		# scan for short option like "-O value" at the beginning of the line
		opt=$(grep "^${short_opt}" $cfg_path)
		opt=${opt/$short_opt /}
	fi
	echo $opt
}

# returns true (0) if the option is turned on
# $1 long version of the option, like --option
# $2 short version of the option, like -D
# the long version of the option should be preferred, as it always exists
is_cfg_opt_on() {
	local cfg=$1
	local cfg_path=$(get_cfg_avail_path $cfg)
	local long_opt=$2
	local short_opt=$3
	# scan for long option like "--option=value" at the beginning of the line
	[ "$(grep "^${long_opt}" $cfg_path)" == "" ] || return 0
	# scan for short option like "-O value" at the beginning of the line
	if (($# == 3)); then
		[ "$(grep "^${short_opt}" $cfg_path)" == "" ] || return 0
	fi
	return 1
}


disable_cfg_opt() {
	local cfg=$1
	local cfg_path=$(get_cfg_avail_path $cfg)
	local long_opt=$2
	local short_opt=$3
	# scan for long option like "--option=value" at the beginning of the line
	[ "$(grep "^${long_opt}" $cfg_path)" == "${long_opt}" ] && sed -e "s:^${long_opt}:#${long_opt}:" -i $cfg_path
	# scan for short option like "-O value" at the beginning of the line
	(($# == 3)) && [ "$(grep "^${short_opt}" $cfg_path)" == "${short_opt}" ] && sed -e "s:^${short_opt}:#${short_opt}:" -i $cfg_path
}

enable_cfg_opt() {
	local cfg=$1
	local cfg_path=$(get_cfg_avail_path $cfg)
	local long_opt=$2
	# scan for commented out long option like "#--option=value" at the beginning of the line
	if [ "$(grep "^#${long_opt}" $cfg_path)" == "#${long_opt}" ]; then
		sed -e "s:^#${long_opt}:${long_opt}:" -i $cfg_path
	else
		# add the option at the end of the file
		echo "${long_opt}" >> $cfg_path
	fi
}
