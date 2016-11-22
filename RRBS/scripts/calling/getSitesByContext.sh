#!/bin/bash
# input should be context (CG, CHG or CHH) and a BSseeker CGmap.gz file

date
echo "context: $1"
echo "file: $2"

outputF=`echo $2 | sed "s/CGmap.gz/$1.CGmap/g"`

zcat $2 | awk -v context=$1 '{if($4==context){print $1"."$3}}' > $outputF
echo "Finished on $hostname"
date
