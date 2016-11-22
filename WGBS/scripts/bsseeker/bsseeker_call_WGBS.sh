#!/bin/bash
date
# BSseeker: call methylated cytosines
# For WGBS libraries only!

module purge
module load BSseeker
python /software/shared/apps/x86_64/BSseeker/2/bs_seeker2-call_methylation.py -v
module list

if [[ ( $# != 4 ) || ( $# == 1 && $1 == '-h' ) ]]; then
	echo "usage: bsseeker_call_WGBS.sh <bam file> <WGBS index dir><output prefix><minimum coverage>"
	exit
fi

echo "BAM file: $1"
bam=$1
echo "WGBS index dir: $2"
fullRefDir=$2
echo "Output prefix: $3"
outputPrefix=$3
echo "Minimum coverage: $4" 
minimumCoverage=$4

python bs_seeker2-call_methylation.py -i $bam -d $fullRefDir -o $outputPrefix -r $minimumCoverage


echo "Finished on $HOSTNAME, ",`date`
