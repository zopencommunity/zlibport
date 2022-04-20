#!/bin/sh 
#
# Pre-requisites: 
#  - cd to the directory of this script before running the script   
#  - ensure you have sourced setenv.sh, e.g. . ./setenv.sh
#  - ensure you have GNU make installed (4.1 or later)
#  - ensure you have access to c99
#
#set -x

if [ "${ZLIB_ROOT}" = '' ]; then
	echo "Need to set ZLIB_ROOT - source setenv.sh" >&2
	exit 16
fi
if [ "${ZLIB_VRM}" = '' ]; then
	echo "Need to set ZLIB_VRM - source setenv.sh" >&2
	exit 16
fi

if ! make --version >/dev/null 2>&1 ; then
	echo "You need GNU Make on your PATH in order to build ZLIB" >&2
	exit 16
fi

if ! whence c99 >/dev/null ; then
	echo "c99 required to build ZLIB. " >&2
	exit 16
fi

MY_ROOT="${PWD}"
if [ "${ZLIB_VRM}" != "zlib" ]; then
	# Non-dev - get the tar file
	rm -rf "${ZLIB_ROOT}/${ZLIB_VRM}"
	if ! mkdir -p "${ZLIB_ROOT}/${ZLIB_VRM}" ; then
		echo "Unable to make root ZLIB directory: ${ZLIB_ROOT}/${ZLIB_VRM}" >&2
		exit 16
	fi
	cd "${ZLIB_ROOT}" || exit 99

	if ! [ -f "${ZLIB_VRM}.tar" ]; then
		echo "zlib tar file not found. Attempt to download with curl" 
		if ! whence curl >/dev/null ; then 
			echo "curl not installed. You will need to upload ZLIB, or install curl/gunzip from ${ZLIB_URL}" >&2
			exit 16
		fi	
		if ! whence gunzip >/dev/null ; then
			echo "gunzip required to unzip ZLIB. You will need to upload ZLIB, or install curl/gunzip from ${ZLIB_URL}" >&2
			exit 16
		fi	
		if ! (rm -f ${ZLIB_VRM}.tar.gz; curl -s --cacert ${ZLIB_CERT} --output ${ZLIB_VRM}.tar.gz ${ZLIB_MIRROR}/${ZLIB_VRM}.tar.gz) ; then
			echo "curl failed with rc $rc when trying to download ${ZLIB_VRM}.tar.gz" >&2
			exit 16
		fi	
		chtag -b ${ZLIB_VRM}.tar.gz
		if ! gunzip ${ZLIB_VRM}.tar.gz ; then
			echo "gunzip failed with rc $rc when trying to unzip ${ZLIB_VRM}.tar.gz" >&2
			exit 16
		fi	
	fi

	tar -xf "${ZLIB_VRM}.tar" 2>/dev/null

# TBD: figure out how to not update GUID/UID
	if [ $? -gt 1 ] ; then
		echo "Unable to make untar ZLIB drop: ${ZLIB_VRM}" >&2
		exit 16
	fi
else
	cd "${ZLIB_ROOT}" || exit 99
fi
if ! chtag -R -h -t -cISO8859-1 "${ZLIB_VRM}" ; then
	echo "Unable to tag ZLIB directory tree as ASCII" >&2
	exit 16
fi

DELTA_ROOT="${PWD}"

if ! managepatches.sh ; then
	echo "Unable to apply patches" >&2
	exit 16
fi

cd "${ZLIB_ROOT}/${ZLIB_VRM}"

if [ "${ZLIB_VRM}" = "zlib" ]; then
	./bootstrap
	if [ $? -gt 0 ]; then
		echo "Bootstrap of ZLIB dev-line failed." >&2
		exit 16
	fi
fi

#
# Setup the configuration so that the system search path looks in lib and include ahead of the standard C libraries
#
export CONFIG_OPTS=""
export CC=xlclang
export CFLAGS="-qascii -Wc,lp64 -Wl,lp64 -D_OPEN_THREADS=3 -D_UNIX03_SOURCE=1 -DNSIG=39"
./configure --prefix="${ZLIB_PROD}"
if [ $? -gt 0 ]; then
	echo "Configure of ZLIB tree failed." >&2
	exit 16
fi

cd "${ZLIB_ROOT}/${ZLIB_VRM}"
if ! make libz.a ; then
	echo "MAKE of ZLIB tree failed." >&2
	exit 16
fi

if false ; then
	if ! make test ; then
		echo "Basic test of ZLIB failed." >&2
		exit 16
	fi

	if ! make check ; then
		echo "MAKE check of ZLIB tree failed." >&2
		exit 16
	fi
fi

if ! make install ; then
	echo "MAKE install of ZLIB tree failed." >&2
	exit 16
fi

echo "zlib installed into ${ZLIB_PROD}"
exit 0
