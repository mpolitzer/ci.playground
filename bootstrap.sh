#!/bin/sh
. /etc/os-release

case $ID in
debian)
	apt build-dep -y --no-install-recommends .
	;;
*)
	echo unimplemented
	exit 1
	;;
esac
