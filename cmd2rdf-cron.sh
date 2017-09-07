#!/bin/sh

HOME="/app"
WORK="/app/work"
DATA="/app/data/clarin"

SRC="https://vlo.clarin.eu/data/resultsets"
SET="clarin.tar.bz2"

mkdir -p $WORK
# make sure expected dirs exist
mkdir -p $WORK/harvester
mkdir -p $WORK/profiles-cache
mkdir -p $WORK/rdf-output/temp
cd $WORK
if [ -f $SET ]; then
    mv $SET $SET.BAK
    curl -o $SET -z $SET.BAK "$SRC/$SET"
else
    curl -o $SET "$SRC/$SET"
fi

if [ ! -f $SET ]; then
    echo "No (new) resultset[$SET] available at [$SRC]! Bye!"
    exit
fi

# refresh
if [ -d $DATA ]; then
    rm -rf $DATA
fi
mkdir -p $DATA
cd $DATA
tar xj $WORK/$SET

# start import
cd $HOME
$HOME/cmd2rdf-run.sh &> $HOME/cmd2rdf-`date '+%Y%m%d'`.log