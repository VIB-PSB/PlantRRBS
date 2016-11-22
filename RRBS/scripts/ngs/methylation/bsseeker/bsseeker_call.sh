#!/bin/bash
date
# BSseeker: call methylated cytosines
#$ -l h_vmem=2G
# For RRBS libraries only!
module unload python
module load BSseeker
module list
if [[ ( $# != 4 ) || ( $# == 1 && $1 == '-h' ) ]]; then
 echo "usage: bsseeker_call.sh <bam file> <RRBS reference dir><output prefix><minimum coverage>"
 exit
fi
echo "BAM file: $1"
bam=$1
echo "RRBS reference dir: $2"
fullRefDir=$2
echo "Output prefix: $3"
outputPrefix=$3
echo "Minimum coverage: $4" 
minimumCoverage=$4
python bs_seeker2-call_methylation.py -i $bam -d $fullRefDir -o $outputPrefix -r $minimumCoverage
echo "Finished on $HOSTNAME, ",`date`
