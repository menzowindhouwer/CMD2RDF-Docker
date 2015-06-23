#!/bin/bash
export VIRT_HOME=/opt/virtuoso-opensource
export VIRT_DB=/opt/virtuoso-opensource/var/lib/virtuoso/db

export PATH=$PATH:/opt/virtuoso-opensource/bin

cd $VIRT_DB

exec /opt/virtuoso-opensource/bin/virtuoso-t -f