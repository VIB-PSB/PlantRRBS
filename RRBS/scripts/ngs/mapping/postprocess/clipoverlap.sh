#!/bin/bash
#$ -l h_vmem=4G
# When two mates overlap, this tool will clip the record's whose clipped region would has the lowest average quality.
# It also checks strand. If a forward strand extends past the end of a reverse strand, that will be clipped. 
#	Similarly, if a reverse strand starts before the forward strand, the region prior to the forward strand will be clipped. 
#	If the reverse strand occurs entirely before the forward strand, both strands will be entirely clipped. 
#	If the [[#Mark entirely clipped reads as unmapped (--unmapped)|--unmapped]] option is specified rather than clipping an entire read, 
#	it will be marked as unmapped.
# The qualities on the two strands remain unchanged even with clipping.
date
module load bamUtil
module list
if [[ ( $# != 2 ) || ( $# == 1 && $1 == '-h' ) ]]; then
 echo "usage: clipoverlap.sh <bam file> <bam output file>"
 exit
fi
echo "bam file: $1"
in=$1
echo "bam output file: $2"
out=$2
echo "bam clipOverlap --params --stats --in $in --out $out"
bam clipOverlap --params --stats --in $in --out $out
echo "Finished on $HOSTNAME"
date
