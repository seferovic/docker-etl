#!/bin/sh

buildprepdir=$(cd $(dirname $BASH_SOURCE[0]) && pwd)
source ${buildprepdir}/dscripts/conf_lib.sh
load_config '--build'


pidfile=http-server.pid

if [ -f $pidfile ] ; then
    kill $(cat $pidfile) 2>/dev/null
    rm -f $pidfile
fi

python -m SimpleHTTPServer $BUILD_PORT &
PID=$!

echo $PID > $pidfile
exit 0
