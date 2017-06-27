#//bin/sh

pidfile=http-server.pid

if [ -f $pidfile ] ; then
    kill $(cat $pidfile)
    rm -f $pidfile
fi

python -m SimpleHTTPServer &
PID=$!

echo $! > $pidfile
exit 0
