#!/bin/bash
# adapter trimming
date
module load trim_galore
trim_galore -v
if [[ ( $# -lt 3 || $# -gt 7 ) || ( $# == 1 && $1 == '-h' ) ]]; then
 echo "usage: trim_galore.sh <forward fastq file> <reverse fastq file> <output directory>"
 echo "optional: <quality cut off (default: 20)> <minimum overlap (default: 1) <error (default: 0.1)> <minimum length (default: 20)>"
 exit
fi
echo "forward reads: $1"
forward=$1
echo "reverse reads: $2"
reverse=$2
echo "output dir: $3"
outputDir=$3
#defaults
qualityCutoff=20
minimumOverlap=1
error=0.1
minimumLength=20
if [[ $# -gt 3 ]]; then
	qualityCutoff=$4
fi
if [[ $# -gt 4 ]]; then
	minimumOverlap=$5
fi
if [[ $# -gt 5 ]]; then
	error=$6
fi
if [[ $# -gt 6 ]]; then
	minimumLength=$7
fi
echo "trim_galore --paired --trim1 -q $qualityCutoff --phred33 --fastqc --fastqc_args \"--nogroup\" --stringency $minimumOverlap -e $error --length $minimumLength -o $outputDir --gzip $forward $reverse"
trim_galore --paired --trim1 -q $qualityCutoff --phred33 --fastqc --fastqc_args \"--nogroup\" --stringency $minimumOverlap -e $error --length $minimumLength -o $outputDir --gzip $forward $reverse
echo "Finished on $HOSTNAME"
date
