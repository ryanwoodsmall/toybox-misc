#!/bin/bash

#
# versions tested
#
#   toybox : 0.7.5
#   musl : 1.1.19 (rhel6/7, static)
#

#
# links:
#
#  musl static libc RPM build scripts:
#    https://github.com/ryanwoodsmall/musl-misc
#
#  based on busybox build scripts at:
#    https://github.com/ryanwoodsmall/busybox-misc/blob/master/scripts/bb_config_script.sh

# TODO
#  tbd : determine todo
#  this should not require "real" bash
#

# who are we
scriptname="$(basename "${BASH_SOURCE[0]}")"

# defaults
musl=0
rhel6=0
rhel7=0
uclibc=0

# simple delete/toggle_off/toggle_on  functions
function delete_setting() {
	sed -i -e "/^${1}=y/d" .config
	sed -i -e "/^# ${1} is not set/d" .config
}

function toggle_off() {
	delete_setting "${1}"
	echo "# ${1} is not set" >> .config
}

function toggle_on() {
	delete_setting "${1}"
	echo "${1}=y" >> .config
}

# options/usage
function usage() {
	cat <<-EOF
	${scriptname} [-6] [-7] [-m] [-u]
	  -6 : rhel/centos 6 specific options
	  -7 : rhel/centos 7 specific options
	  -m : musl specific options
	  -u : uclibc/uclibc-ng specific options
	EOF
	exit 1
}

# read options
while getopts ":67impsu" opt ; do
	case ${opt} in
		6)
			rhel6=1
			;;
		7)
			rhel7=1
			;;
		m)
			musl=1
			;;
		u)
			uclibc=1
			;;
		\?)
			usage
			;;
	esac
done

# backup any .config
test -e .config && cp .config{,.PRE-$(date '+%Y%m%d%H%M%S')}

# clean up after ourself
make distclean

# start with default config
test -e .config && rm -f .config
make defconfig

# rhel/centos 6 and 7 specific settings
if [ "${rhel7}" -eq 1 ] ; then
	echo "handle rhel7 here"
elif [ "${rhel6}" -eq 1 ] ; then
	echo "handle rhel6 here"
fi

# musl override options
if [ "${musl}" -eq 1 ] ; then
	echo "handle musl here"
fi

# uclibc override options
if [ "${uclibc}" -eq 1 ] ; then
	echo "handle uclibc here"
fi

# common musl/uclibc-ng options (nsenter, etc.)
if [ "${musl}" -eq 1 -o "${uclibc}" -eq 1 ] ; then
	echo "handle common musl/uclibc here"
fi

# these are exposed in 'make menuconfig'
toggle_on CONFIG_ARP
toggle_on CONFIG_ARPING
toggle_on CONFIG_ASCII
toggle_on CONFIG_BOOTCHARTD
toggle_on CONFIG_CAT_V
toggle_on CONFIG_COMPRESS
toggle_on CONFIG_CROND
toggle_on CONFIG_CRONTAB
toggle_on CONFIG_DD
toggle_on CONFIG_DEALLOCVT
toggle_on CONFIG_DECOMPRESS
toggle_on CONFIG_DIFF
toggle_on CONFIG_EXPR
toggle_on CONFIG_FDISK
toggle_on CONFIG_FOLD
toggle_on CONFIG_FSCK
toggle_on CONFIG_GETFATTR
toggle_on CONFIG_GETTY
toggle_on CONFIG_GROUPADD
toggle_on CONFIG_GROUPDEL
toggle_on CONFIG_HELLO
toggle_on CONFIG_HOST
toggle_on CONFIG_HOSTID
toggle_on CONFIG_ICONV
toggle_on CONFIG_INIT
toggle_on CONFIG_IPCRM
toggle_on CONFIG_IPCS
toggle_on CONFIG_KLOGD
toggle_on CONFIG_KLOGD_SOURCE_RING_BUFFER
toggle_on CONFIG_LAST
toggle_on CONFIG_LOGGER
toggle_on CONFIG_LSOF
toggle_on CONFIG_MDEV
toggle_on CONFIG_MDEV_CONF
toggle_on CONFIG_MKE2FS
toggle_on CONFIG_MKE2FS_EXTENDED
toggle_on CONFIG_MKE2FS_GEN
toggle_on CONFIG_MKE2FS_JOURNAL
toggle_on CONFIG_MKE2FS_LABEL
toggle_on CONFIG_MODPROBE
toggle_on CONFIG_MORE
toggle_on CONFIG_OPENVT
toggle_on CONFIG_PING
toggle_on CONFIG_ROUTE
toggle_on CONFIG_SETFATTR
toggle_on CONFIG_SH
toggle_on CONFIG_SULOGIN
toggle_on CONFIG_SYSLOGD
toggle_on CONFIG_TAR
toggle_on CONFIG_TCPSVD
toggle_on CONFIG_TELNET
toggle_on CONFIG_TELNETD
toggle_on CONFIG_TEST
toggle_on CONFIG_TFTP
toggle_on CONFIG_TFTPD
toggle_on CONFIG_TOYBOX_NORECURSE
toggle_on CONFIG_TR
toggle_on CONFIG_TRACEROUTE
toggle_on CONFIG_USERADD
toggle_on CONFIG_USERDEL
toggle_on CONFIG_VI
toggle_on CONFIG_WATCH
#toggle_on CONFIG_WGET
toggle_on CONFIG_XZCAT

# rewrite config
make oldconfig

# build it
echo
echo "now run 'make'"
echo