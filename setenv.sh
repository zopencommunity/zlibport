#!/bin/sh
#set -x

if ! [ -f ./setenv.sh ]; then
	echo "Need to source from the setenv.sh directory" >&2
else
	export _BPXK_AUTOCVT="ON"
	export _CEE_RUNOPTS="FILETAG(AUTOCVT,AUTOTAG),POSIX(ON),TERMTHDACT(MSG)"
	export _TAG_REDIR_ERR="txt"
	export _TAG_REDIR_IN="txt"
	export _TAG_REDIR_OUT="txt"

	export ZLIB_VRM="zlib-1.2.12"
	export ZLIB_ROOT="${PWD}"
	
        export PATH="${ZLIB_ROOT}/bin:$PATH"

	export ZLIB_MIRROR="https://zlib.net"
	export ZLIB_CERT="${ZLIB_ROOT}/zlib.cert"
	export ZLIB_URL="https://github.com/madler/zlib.git"

	fsroot=$( basename $HOME )                         
	export ZLIB_PROD="/${fsroot}/zlibprod"     
fi
