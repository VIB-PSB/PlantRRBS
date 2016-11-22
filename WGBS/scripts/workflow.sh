#!/bin/bash

# Calls to process the WGBS data through means of submission of jobs to a GridEngine Cluster.
# We start with 2 fastq files, corresponding to the 2 WGBS data sets (control and LR2).
# a) ICC21_control.fastq
# b) ICC26_LR5007.fastq
# 
# (c) VIB / UGent

# Define main working directory
MAIN_DIR= /path/to/working/data/directory/

# Define location where working scripts are located
SCRIPT_DIR=$MAIN_DIR/scripts/

# Definte location where the input fastq files are located
MERGED_DATA_CONTROL=$MAIN_DIR/merged_fastq/ICC21_control.fastq
MERGED_DATA_LR2=$MAIN_DIR/merged_fastq/ICC26_LR5007.fastq

# Run FastQC on the input fastq files
FASTQC_CONTROL=$MAIN_DIR/merged_fastq/fastqc/ICC21_control/
FASTQC_LR2=$MAIN_DIR/merged_fastq/fastqc/ICC26_LR5007/
qsub -l h_vmem=2G -S /bin/csh -N Fastqc.ICC21_control $SCRIPT_DIR/fastqc.csh $MERGED_DATA_CONTROL $FASTQC_CONTROL
qsub -l h_vmem=2G -S /bin/csh -N Fastqc.ICC26_LR5007 $SCRIPT_DIR/fastqc.csh $MERGED_DATA_LR2 $FASTQC_LR2

# Run trimgalore on the input fastq files
TRIMGALORE_CONTROL=$MAIN_DIR/merged_fastq/trimgalore/ICC21_control/
TRIMGALORE_LR2=$MAIN_DIR/merged_fastq/trimgalore/ICC26_LR5007/
qsub -l h_vmem=4G -S /bin/bash -N trimgalore.ICC21_control $SCRIPT_DIR/trim_galore.sh $MAIN_DIR/merged_fastq/ICC21_control.fastq $TRIMGALORE_CONTROL
qsub -l h_vmem=4G -S /bin/bash -N trimgalore.ICC26_LR5007 $SCRIPT_DIR/trim_galore.sh $MAIN_DIR/merged_fastq/ICC26_LR5007.fastq $TRIMGALORE_LR2


# Build the reference index for our genome. This bsseeker index is a bowtie index, which is a different index from gsnap.
# 
# https://github.com/BSSeeker/BSseeker2#4-modules-descriptions 
# Quote : "The indexes for RRBS and WGBS are different. Also, indexes for RRBS are specific for fragment length parameters"
# --> no fragment length parameters necessary for WGBS, compared to RRBS (so no -l and -u settings), because the indexes for WGBS are the same regardless of the -l and -u options.
# 
# No restriction endonuclease combination for the WGBS. Use default cut-site settings (C-CGG)
GENOME_FASTA_DIR=/path/to/fasta/directory/
GENOME_FASTA=osaindica.genome.fasta
BSSEEKER_INDEX_DIR=$MAIN_DIR/genome_index/
qsub -N bsseeker2_build -S /bin/bash -l h_vmem=2G -pe serial 4 $SCRIPT_DIR/bsseeker/bsseeker_build_WGBS.sh $GENOME_FASTA_DIR/$GENOME_FASTA $BSSEEKER_INDEX_DIR

# Run bsseeker alignment program
#
# number of cores should be at least 2, due to nature of bsseeker (using at least 2 threads).
# see https://github.com/BSSeeker/BSseeker2#4-modules-descriptions
#
# it can use gzipped fastq files, which reduces the need to unzip them first.
#
# allowed mismatches same as RRBS
ZIPPED_TRIMMED_CONTROL_FILE=$MAIN_DIR/merged_fastq/trimgalore/ICC21_control/ICC21_control_trimmed.fq.gz
ZIPPED_TRIMMED_LR2_FILE=$MAIN_DIR/merged_fastq/trimgalore/ICC26_LR5007/ICC26_LR5007_trimmed.fq.gz
ALIGN_CONTROL_OUTPUT=$MAIN_DIR/alignment_output/ICC21_control_trimmed.bam
ALIGN_LR2_OUTPUT=$MAIN_DIR/alignment_output/ICC26_LR5007_trimmed.bam
ALLOWED_MISMATCHES=2
ALIGN_TMP_DIR_CONTROL=$MAIN_DIR/align_tmp/control/
ALIGN_TMP_DIR_LR2=$MAIN_DIR/align_tmp/lr2/
qsub -N bsseeker2.align.ICC21_control -S /bin/bash -l h_vmem=8G -pe serial 4 $SCRIPT_DIR/bsseeker/bsseeker_align_WGBS.sh $ZIPPED_TRIMMED_CONTROL_FILE $GENOME_FASTA $BSSEEKER_INDEX_DIR $ALLOWED_MISMATCHES $ALIGN_CONTROL_OUTPUT $ALIGN_TMP_DIR_CONTROL
qsub -N bsseeker2.align.ICC26_LR5007 -S /bin/bash -l h_vmem=8G -pe serial 4 $SCRIPT_DIR/bsseeker/bsseeker_align_WGBS.sh $ZIPPED_TRIMMED_LR2_FILE $GENOME_FASTA $BSSEEKER_INDEX_DIR $ALLOWED_MISMATCHES $ALIGN_LR2_OUTPUT $ALIGN_TMP_DIR_LR2


# In the RRBS pipeline the next step is a clipoverlap.
# however, this is only applicable when using paired-end or mate-pairs. Not necessary for single-ended sequencing as with the data from WGBS
# therefore, the next step is skipped.


# Calling of bsseeker data. 
# Minimum coverage=10
MIN_CALL_COVERAGE=10
BSSEEKER_FULL_INDEX=$MAIN_DIR/genome_index/osaindica.genome.fasta_bowtie2/
CALL_DIR=$MAIN_DIR/methylation_calling/
CALL_CONTROL_OUTPUT=$CALL_DIR/ICC21_control
CALL_LR2_OUTPUT=$CALL_DIR/ICC26_LR5007
qsub -N bsseeker2.call.ICC21_control -S /bin/bash -l h_vmem=8G $SCRIPT_DIR/bsseeker/bsseeker_call_WGBS.sh $ALIGN_CONTROL_OUTPUT_FILE $BSSEEKER_FULL_INDEX $CALL_CONTROL_OUTPUT $MIN_CALL_COVERAGE
qsub -N bsseeker2.call.ICC26_LR5007 -S /bin/bash -l h_vmem=8G $SCRIPT_DIR/bsseeker/bsseeker_call_WGBS.sh $ALIGN_LR2_OUTPUT_FILE $BSSEEKER_FULL_INDEX $CALL_LR2_OUTPUT $MIN_CALL_COVERAGE


# Compute the depth and coverage
ALIGNMENT_OUTPUT_DIR=$MAIN_DIR/alignment_output/
DEPTH_DIR=$MAIN_DIR/depth/
BAM_FILE_CONTROL=$ALIGNMENT_OUTPUT_DIR/ICC21_control.bam
BAM_FILE_CONTROL_SORTED=$ALIGNMENT_OUTPUT_DIR/ICC21_control.bam_sorted.bam
BAM_FILE_LR2=$ALIGNMENT_OUTPUT_DIR/ICC26_LR5007.bam
BAM_FILE_LR2_SORTED=$ALIGNMENT_OUTPUT_DIR/ICC26_LR5007.bam_sorted.bam
DEPTH_FILE_CONTROL=$DEPTH_DIR/ICC21_control.depth
DEPTH_FILE_CONTROL_SORTED=$DEPTH_DIR/ICC21_control.sorted.depth
DEPTH_FILE_LR2=$DEPTH_DIR/ICC26_LR5007.depth
DEPTH_FILE_LR2_SORTED=$DEPTH_DIR/ICC26_LR5007.sorted.depth
qsub -N wgbs.ICC21_control.depth_coverage.non_sorted -S /bin/bash -l h_vmem=8G $SCRIPT_DIR/compute_depth_coverage.sh $BAM_FILE_CONTROL $DEPTH_FILE_CONTROL ICC21_control
qsub -N wgbs.ICC21_control.depth_coverage.sorted -S /bin/bash -l h_vmem=8G $SCRIPT_DIR/compute_depth_coverage.sh $BAM_FILE_CONTROL_SORTED $DEPTH_FILE_CONTROL_SORTED ICC21_control_sorted
qsub -N wgbs.ICC26_LR2.depth_coverage.non_sorted -S /bin/bash -l h_vmem=8G $SCRIPT_DIR/compute_depth_coverage.sh $BAM_FILE_LR2 $DEPTH_FILE_LR2 ICC26_LR2
qsub -N wgbs.ICC26_LR2.depth_coverage.sorted -S /bin/bash -l h_vmem=8G $SCRIPT_DIR/compute_depth_coverage.sh $BAM_FILE_LR2_SORTED $DEPTH_FILE_LR2_SORTED ICC26_LR2_sorted


