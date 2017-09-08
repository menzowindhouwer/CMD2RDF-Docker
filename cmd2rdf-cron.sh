#!/bin/sh

HOME="/app"
WORK="/app/work"
DATA="/app/data/clarin"

SRC="https://vlo.clarin.eu/data/resultsets"
SET="clarin.tar.bz2"

# make sure expected dirs exist
mkdir -p $WORK
mkdir -p $WORK/harvester
mkdir -p $WORK/profiles-cache
mkdir -p $WORK/rdf-output/temp

# check if there is a new resultset
cd $WORK
if [ -f $SET ]; then
    mv $SET $SET.BAK
fi
if [ -f $SET.BAK ]; then
    curl -s -S -o $SET -z $SET.BAK "$SRC/$SET"
else
    curl -s -S -o $SET "$SRC/$SET"
fi

if [ ! -f $SET ]; then
    echo "No (new) resultset[$SET] available at [$SRC]! Bye!"
    exit
fi

# refresh data
if [ -d $DATA ]; then
    rm -rf $DATA
fi
mkdir -p $DATA
cd $DATA
tar xjf $WORK/$SET

# start import
cd $HOME
$HOME/cmd2rdf-run.sh &> $WORK/cmd2rdf-`date '+%Y%m%d'`.log