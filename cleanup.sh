#!/bin/sh

pidfile=http-server.pid

if [ -f $pidfile ] ; then
    kill $(cat $pidfile)
    rm -f $pidfile
fi
