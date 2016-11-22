#!/bin/bash
# input should be context (CG, CHG or CHH) and a BSseeker CGmap.gz file

date
context=$1
inputfile=$2
outputfile=$3

echo "context: $context"
echo "inputfile: $inputfile"
echo "outputfile : $outputfile"

cat $inputfile | awk -v context=$context '{if($4==context){print}}' > $outputfile

echo "Finished on $hostname"
date

