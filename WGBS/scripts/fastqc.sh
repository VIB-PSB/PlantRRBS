#! /bin/bash
# FastQC: read quality check
module load FastQC
which fastqc
if [[ ( $# != 2 && $# != 3 ) || ( $# == 1 && $1 == '-h' ) ]]; then
 echo "usage: fastqc.sh <fastq file> <output directory>"
 echo "optional: <compressed: TRUE|FALSE>"
 exit
fi
echo "fastq file: $1"
echo "output folder: $2"
if [[ ! -d $2 ]]; then
	echo "	... does not exist: creating"
	mkdir $2
	echo "success"
fi
echo "fastqc --nogroup --extract -o $2 -f fastq $1"
fastqc --nogroup --extract -o $2 -f fastq $1
echo "Finished on $HOSTNAME"
