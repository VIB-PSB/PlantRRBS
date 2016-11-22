#!/bin/bash
# BSseeker: align bisulfite reads
#$ -N bsa
#$ -l h_vmem=10G
date
module unload python
module load BSseeker
module list
if [[ ( $# != 10 ) || ( $# == 1 && $1 == '-h' ) ]]; then
 echo "usage: bsseeker_align.sh <forward fastq file> <reverse fastq file> <reference> <reference dir> <mismatches> <adapter file> <output bam file> <low bound> <up bound> <cut format>"
 exit
fi
echo "forward=$1"
forward=$1
echo "reverse=$2"
reverse=$2
echo "reference=$3"
reference=$3
echo "reference dir=$4"
refDir=$4
echo "mismatches=$5"
mismatches=$5
echo "adapter file=$6"
adapter=$6
echo "output file=$7"
outputfile=$7
echo "low bound= $8"
low=$8
echo "up bound = $9"
up=$9
echo "cut format=${10}"
cut=${10}
#Number of slots
# https://github.com/BSSeeker/BSseeker2#questions--answers
# By default, BS-Seeker2 will create two bowtie/bowtie2 processes for directional library (four for un-directional library), and each process would run with 2 threads.
# 	User can change the number of total threads using parameter "--bt-p"/"--bt2-p". For example, "--bt-p 4" will require 8 CPUs in total.
if [[ $NSLOTS ]]; then
	cores=`echo "$NSLOTS/2" | bc`
	#cores=$NSLOTS
else
	#this requires at least -pe serial 2
	cores=1
fi 
if [[ ! -d "tmp" ]]; then
	echo "creating tmp dir"
	mkdir tmp
fi
# Assumptions:
# - fragment lenghts set from 20 to 500bp
# - MspI (C'CGG) and ApeKI (G'CWGC) enzymes
python bs_seeker2-align.py -1 $forward -2 $reverse --mismatches $mismatches -r -L $low -U $up -c $cut -a $adapter -g $reference --aligner bowtie2 -d $refDir --bt-p $cores -o $outputfile
echo "Finished on $HOSTNAME, ",`date`
