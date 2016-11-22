#!/bin/bash
# input should be a BSseeker CGmap.gz file and an output file

date
inputfile=$1
outputfile=$2

echo "inputfile: $inputfile"
echo "outputfile : $outputfile"

cat $inputfile | awk '{if( $4=="CG" || $4=="CHG" || $4=="CHH" ){print}}' > $outputfile

echo "Finished on $hostname"
date

