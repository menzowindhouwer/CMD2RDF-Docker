#!/bin/bash

WAIT="1"

function shutdown()
{
    date
    echo "Shutting down Tomcat"
    
    /etc/init.d/tomcat6 stop

    WAIT="0"
}

date
echo "Starting Tomcat"

/etc/init.d/tomcat6 start

# Allow any signal which would kill a process to stop Tomcat
trap shutdown HUP INT QUIT ABRT KILL ALRM TERM TSTP

echo "Waiting for Tomcat"

while [ $WAIT = "1" ] ; do
        sleep 10	# This script is not really doing anything.
done

echo "Stopped Tomcat"