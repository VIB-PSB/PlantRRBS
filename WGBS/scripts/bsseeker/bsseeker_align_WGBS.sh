#!/bin/bash
# BSseeker: align bisulfite reads
date
module unload python
module load BSseeker
module list

echo "input_fastq=$1"
inputfastq=$1
echo "genome_fasta=$2"
genome=$2
echo "index=$3"
index=$3
echo "mismatches=$4"
mismatches=$4
echo "output file=$5"
outputfile=$5
echo "tmp_dir=$6"
tmpdir=$6

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
if [[ ! -d $tmpdir ]]; then
	echo "creating tmp dir"
	mkdir $tmpdir
fi


python bs_seeker2-align.py -i $inputfastq --mismatches $mismatches -g $genome --aligner bowtie2 -d $index --bt-p $cores --temp_dir $tmpdir -o $outputfile

echo "Finished on $HOSTNAME, ",`date`
