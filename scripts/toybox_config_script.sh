#!/bin/bash

#
# versions tested
#
#   toybox : 0.8.2
#   musl : 1.1.23 (rhel6/7, static)
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

# these are exposed in 'make menuconfig'
# generate a list:
#   egrep '(^config|default n)' generated/Config.in | grep -B1 'default n' | awk '/^config /{print $NF}' > /tmp/cw/tbc.txt
# see missing items:
#   for i in $(cat /tmp/cw/tbc.txt) ; do grep -q "toggle_on CONFIG_${i}" scripts/toybox_config_script.sh && echo $i yes || echo $i no ; done | grep -v ' yes$'
toggle_on CONFIG_ARP
toggle_on CONFIG_ARPING
toggle_on CONFIG_ASCII
toggle_on CONFIG_BC
toggle_on CONFIG_BLKDISCARD
toggle_on CONFIG_BOOTCHARTD
#toggle_on CONFIG_BRCTL
toggle_on CONFIG_CAT_V
toggle_on CONFIG_COMPRESS
toggle_on CONFIG_CROND
toggle_on CONFIG_CRONTAB
toggle_on CONFIG_DD
toggle_on CONFIG_DEALLOCVT
toggle_on CONFIG_DECOMPRESS
toggle_on CONFIG_DIFF
toggle_on CONFIG_EVAL
toggle_on CONFIG_EXEC
toggle_on CONFIG_EXPORT
toggle_on CONFIG_EXPR
toggle_on CONFIG_FDISK
toggle_on CONFIG_FOLD
toggle_on CONFIG_FSCK
toggle_on CONFIG_GETFATTR
toggle_on CONFIG_GETOPT
toggle_on CONFIG_GETTY
toggle_on CONFIG_GROUPADD
toggle_on CONFIG_GROUPDEL
toggle_on CONFIG_GUNZIP
toggle_on CONFIG_GZIP
#toggle_on CONFIG_HELLO
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
toggle_on CONFIG_MAN
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
toggle_on CONFIG_READELF
toggle_on CONFIG_ROUTE
toggle_on CONFIG_RTCWAKE
toggle_on CONFIG_SETFATTR
toggle_on CONFIG_SH
toggle_on CONFIG_SHIFT
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
toggle_on CONFIG_UNSET
toggle_on CONFIG_USERADD
toggle_on CONFIG_USERDEL
toggle_on CONFIG_VI
toggle_on CONFIG_WATCH
#toggle_on CONFIG_WGET
toggle_on CONFIG_XZCAT
toggle_on CONFIG_ZCAT

# XXX - disable chattr/lsattr for now
# XXX - undefined on centos 6, centos 7: FS_ENCRYPT_FL FS_INLINE_DATA_FL FS_PROJINHERIT_FL

# rhel/centos 6 and 7 specific settings
if [ "${rhel7}" -eq 1 ] ; then
	echo "handle rhel7"
	toggle_off CONFIG_CHATTR
	toggle_off CONFIG_LSATTR
elif [ "${rhel6}" -eq 1 ] ; then
	echo "handle rhel6"
	toggle_off CONFIG_BLKDISCARD
	toggle_off CONFIG_CHATTR
	toggle_off CONFIG_LOSETUP
	toggle_off CONFIG_LSATTR
fi

# musl override options
if [ "${musl}" -eq 1 ] ; then
	echo "handle musl"
	toggle_off CONFIG_SYSLOGD
fi

# uclibc override options
if [ "${uclibc}" -eq 1 ] ; then
	echo "handle uclibc"
fi

# common musl/uclibc-ng options (nsenter, etc.)
if [ "${musl}" -eq 1 -o "${uclibc}" -eq 1 ] ; then
	echo "handle common musl/uclibc"
fi

# rewrite config
make oldconfig

# build it
echo
echo "now run 'make'"
echo
