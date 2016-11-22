module load samtools

bam_file=$1
depth_file=$2
name=$3

# first compute the depth file
samtools depth $bam_file > $depth_file


module purge
module load perl

# now compute the overall coverage, based on the required depth
coverage_file_1=$depth_file.coverage_1.txt
coverage_file_10=$depth_file.coverage_10.txt
size=427026737

perl compute_coverage.pl $depth_file $name $size 1 > $coverage_file_1
perl compute_coverage.pl $depth_file $name $size 10 > $coverage_file_10


