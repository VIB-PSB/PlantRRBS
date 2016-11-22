#!/bin/bash
#$ -N bss2mk
#$ -l h_vmem=2G
# This script should be ran per chromosome for memory constraints of methylkit
date
module load perl
if [[ ( $# != 4 ) || ( $# == 1 && $1 == '-h' ) ]]; then
 echo "usage: bsseeker2MethylKit.sh <input file (CGmap.gz file)> <output file> <coverage> <chromosome index>"
 exit
fi
input=$1
output=$2
coverage=$3
chr=$4
if [[ ! -d `dirname $output` ]];then
	echo "Create directory: "`dirname $output`
	mkdir -p `dirname $output`	
fi
perl BSSeeker2MethylKit.pl -i $input -o $output -c $coverage --chromosome $chr
echo "Finished on $HOSTNAME"
date
