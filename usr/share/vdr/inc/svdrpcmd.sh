# Detect the svdrpsend.pl/svdrpsend script
# changed in vdr-1.7.23

svdrp_command() {

	if [ -e /usr/bin/svdrpsend.pl ]; then
		SVDRPCMD=/usr/bin/svdrpsend.pl
	else
		SVDRPCMD=/usr/bin/svdrpsend
	fi
}
