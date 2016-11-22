genomeIndex=$1
genomeFasta=$2
adapter=$3
while read sample ; do echo $sample ; if [[ $sample != *R11* ]]; then continue; fi ; if [[ $sample == *_R03_* || $sample == *R05* || $sample == *R09* || $sample == *R13* || $sample == *R16* || $sample == *R17* || $sample == *R18* || $sample == *R20* || $sample == *R25* ]]; then file="150501HiSeq_Run_"$sample; postfix="_001_trimmed" ; else file="150324HiSeq_Run_"$sample; postfix="_001"; fi ; sh ngs/methylation/bsseeker/bsseeker_pipeline.sh $sample ../../preproc/trim_galore_50bp/$sample/$file"_R1"$postfix"_val_1.fq.gz" ../../preproc/trim_galore_50bp/$sample/$file"_R2"$postfix"_val_2.fq.gz" $genomeFasta $genomeIndex 2 $adapter $genomeIndex 10 20 500 C-CGG,-GATC ; done < samples.txt  > bsseeker_pipeline.log
