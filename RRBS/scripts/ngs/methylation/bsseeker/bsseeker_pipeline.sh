#!/bin/bash
# pipeline to align and call methylation reads
if [[ ( $# != 12 ) || ( $# == 1 && $1 == '-h' ) ]]; then
 echo "usage: bsseeker_pipeline.sh <sample ID> <forward fastq.gz file> <reverse fastq.gz file> <reference> <reference dir> <mismatches> <adapter file> <RRBS reference dir> <minimum coverage> <low bound> <up bound> <cut format>"
 exit
fi
echo "sampleID=$1"
echo "forward=$2"
echo "reverse=$3"
echo "reference=$4"
echo "reference dir=$5"
echo "mismatches=$6"
echo "adapter file=$7"
echo "RRBS reference dir= $8"
echo "minimum coverage calling= ${9}"
echo "low bound=${10}"
echo "high bound=${11}"
echo "cut format=${12}"
if [[ ! -d "align" ]]; then
	echo "mkdir align"
	mkdir align
fi
# aligning to reference
jobA="bsseeker_align_$1"
output="align/$1.bam"
qsub -pe serial 8 -N $jobA ngs/methylation/bsseeker/bsseeker_align.sh $2 $3 $4 $5 $6 $7 $output ${10} ${11} ${12}
# sort bam file
jobS="sort_$1"
outputSB="align/$1.sort.bam"
qsub -N $jobS -hold_jid $jobA -l h_vmem=4g ngs/picard/SortSam.sh $output $outputSB coordinate
#clipping overlap
if [[ ! -e "./clipOverlap" ]]; then
	echo "mkdir clipOverlap"
	mkdir clipOverlap
fi
jobCO="clipoverlap_$1"
outputCO="clipOverlap/$1.sort.clip.bam"
qsub -N $jobCO -hold_jid $jobS ngs/mapping/postprocess/clipoverlap.sh $outputSB $outputCO
if [[ ! -e "./calling" ]]; then
	echo "mkdir calling"
	mkdir calling
fi
jobC="bsseeker_call_$1"
outputCA="calling/$1.sort.clip.call"
qsub -N $jobC -hold_jid $jobCO ngs/methylation/bsseeker/bsseeker_call.sh $outputCO $8 $outputCA ${9}
echo "Done"
