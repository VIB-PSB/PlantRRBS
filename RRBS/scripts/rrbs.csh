#!/bin/tcsh

set prefix = $1
set genomeFasta = #/path/to/genome/fasta  #adapt!
set genomeIndex = #/path/to/genome/index
set rrbsOutput = #/path/to/RRBS/output

mkdir rawData
qsub -l h_vmem=2G -N cat.$prefix unzip.csh $prefix

set forward = rawData/$prefix.1.fastq.gz
set reverse = rawData/$prefix.2.fastq.gz

qsub -S /bin/bash -l h_vmem=2G -N fastqc1a.$prefix -hold_jid cat.$prefix ngs/fastq/fastqc.sh $forward
qsub -S /bin/bash -l h_vmem=2G -N fastqc2a.$prefix -hold_jid cat.$prefix ngs/fastq/fastqc.sh $reverse

qsub -N trim.$prefix -hold_jid cat.$prefix ~/scripts/ngs/fastq/trimgalore.sh $forward $reverse fastq

qsub -l h_vmem=2G -N fastqc1b.$prefix -hold_jid trim.$prefix ngs/fastq/fastqc.csh fastq/${prefix}.1_val_1.fq.gz
qsub -l h_vmem=2G -N fastqc2b.$prefix -hold_jid trim.$prefix ngs/fastq/fastqc.csh fastq/${prefix}.2_val_2.fq.gz

qsub -N align.$prefix -hold_jid trim.$prefix ngs/methylation/bsseeker_align.csh fastq/${prefix}.1_val_1.fq.gz fastq/${prefix}.2_val_2.fq.gz $genomeFasta $genomeIndex 2

qsub -N overlap.$prefix -hold_jid align.$prefix ngs/mapping/clipOverlap.csh fastq/${prefix}.1_val_1.fq.gz_rrbspe.bam_sorted.bam fastq/${prefix}.1_val_1.fq.gz_rrbspe.clipOverlap.bam 

mkdir methylation

qsub -N call.$prefix -hold_jid overlap.$prefix ngs/methylation/bsseeker_call.csh fastq/${prefix}.1_val_1.fq.gz_rrbspe.clipOverlap.bam $rrbsOutput methylation/$prefix.clipOverlap 10


