#!/bin/bash
OLDVERS="$(grep '^Version' README | awk '{ print $2 }')"
NEWVERS="$1"

echo "Updating from $OLDVERS to $NEWVERS"

if [[ "$NEWVERS" == "" ]]; then
	echo "Please specify new version"
	exit 1
fi

if [[ ! -d ../tags/"${OLDVERS}" ]]; then
	echo "WARNING: Old version $OLDVERS is not tagged"
fi

if [[ -d ../tags/"${NEWVERS}" ]]; then
	echo "new version $NEWVERS is already tagged"
	exit 1
fi

sed -e "s/^Version.*/Version ${NEWVERS}/" -i README

today=$(LC_ALL=C date +"%d %b %Y")

sed -e "3a\\
*gentoo-vdr-scripts-${NEWVERS} (${today})\\
" -i ChangeLog

echo "Commiting bump"
svn commit -m "Bumped to version ${NEWVERS}" ChangeLog README


cd ..
echo "svn copy"
svn copy trunk "tags/${NEWVERS}"
svn commit -m "Tagged version ${NEWVERS}" tags/${NEWVERS}"

