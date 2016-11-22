#!/bin/bash
# Building bsseeker genome index for WGBS experiments
module load BSseeker/x86_64/2
module load bowtie/x86_64/2.1.0
module unload python
module load python/x86_64/2.7.2
module list

echo "genome fasta: $1"
genome=$1
echo "output folder: $2"
folder=$2

python bs_seeker2-build.py --file=$genome --aligner=bowtie2 --db=$folder

echo "Finished on $HOSTNAME"
