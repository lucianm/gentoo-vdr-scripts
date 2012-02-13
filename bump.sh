#!/bin/bash
OLDVERS="$(grep '^Version' README | awk '{ print $2 }')"
NEWVERS="$1"

echo "Updating from $OLDVERS to $NEWVERS"

if [[ "$NEWVERS" == "" ]]; then
	echo "Please specify new version"
	exit 1
fi

sed -e "s/^Version.*/Version ${NEWVERS}/" -i README

today=$(LC_ALL=C date +"%d %b %Y")

sed -e "3a\\
*gentoo-vdr-scripts-${NEWVERS} (${today})\\
" -i ChangeLog

echo "Commiting bump"
git commit -m "Bumped to version ${NEWVERS}" ChangeLog README


git tag gentoo-vdr-scripts-$NEWVERS
#git push origin :gentoo-vdr-scripts-$NEWVERS

make dist
