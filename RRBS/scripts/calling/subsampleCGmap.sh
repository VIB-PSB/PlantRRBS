#!/bin/bash
# input should be context (CG, CHG or CHH) and a BSseeker CGmap.gz file

date
echo "context: $1"
echo "file: $2"

tmpF=`echo $2 | sed "s/CGmap.gz/$1.CGmap.tmp/g"`
outputF=`echo $2 | sed "s/CGmap.gz/$1.CGmap.gz/g"`

zcat $2 | awk -v context=$1 '{if($4==context){print}}' > $tmpF

gzip -c $tmpF > $outputF

rm $tmpF

echo "Finished on $HOSTNAME"
date
