#!/bin/bash
# input should be context (CG, CHG or CHH) and a BSseeker CGmap.gz file

date
echo "file: $1"

outputF=`echo $1 | sed "s/CGmap.gz/all.CGmap/g"`

zcat $1 | awk '{if( $4 == "CG" || $4 == "CHG" || $4 == "CHH" ){print $1"."$3}}' > $outputF
echo "Finished on $HOSTNAME"
date
