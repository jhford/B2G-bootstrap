#!/bin/bash

# This script understands how to take a device name and use the repo tool
# to sync all the sources required

REPO=./repo

repo_sync() {
	rm -rf .repo/manifest* &&
	$REPO init -u $GITREPO -b $BRANCH -m $1.xml &&
	$REPO sync
	ret=$?
	if [ "$GITREPO" = "$GIT_TEMP_REPO" ]; then
		rm -rf $GIT_TEMP_REPO
	fi
	if [ $ret -ne 0 ]; then
		echo Repo sync failed
		exit -1
	fi
}

GITREPO=${GITREPO:-"git://github.com/mozilla-b2g/b2g-manifest"}
BRANCH=${BRANCH:-master}

GIT_TEMP_REPO="tmp_manifest_repo"
if [ -n "$2" ]; then
	GITREPO=$GIT_TEMP_REPO
	GITBRANCH="master"
	rm -rf $GITREPO &&
	git init $GITREPO &&
	cp $2 $GITREPO/$1.xml &&
	cd $GITREPO &&
	git add $1.xml &&
	git commit -m "manifest" &&
	cd ..
fi

# The x86 emulator and unagi are special cases which use a manifest that
# has a different name than the device name passed to config.sh because
# we share the manifest with a slightly different device

case "$1" in
galaxy-s2|galaxy-nexus|optimus-l5|nexus-s|nexus-s-4g|pandaboard|emulator|otoro)
	repo_sync $1
	;;

"unagi")
	repo_sync otoro
	;;

"emulator-x86")
	repo_sync emulator
	;;

*)
	echo Usage: $0 \(device name\)
	echo
	echo Valid devices to configure are:
	echo - galaxy-s2
	echo - galaxy-nexus
	echo - nexus-s
	echo - nexus-s-4g
	echo - otoro
	echo - unagi
	echo - pandaboard
	echo - emulator
	echo - emulator-x86
	exit -1
	;;
esac

if [ $? -ne 0 ]; then
	echo Source configuration failed
	exit -1
fi

# We call this script directly to avoid breaking the established
# interface
echo Finished syncing sources, going to configure the tree for building
./config-device.sh $1
