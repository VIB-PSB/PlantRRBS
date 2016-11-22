#! /bin/sh
#$ -cwd
module load picard-tools
echo $PICARD_HOME
if [[  ( $# != 3 && $# != 4 ) || ( $# == 1 && $1 == '-h' ) ]]; then
 echo 'usage: SortSam.csh <BAM file> <BAM out file> <Sort order: queryname or coordinate>'
 echo 'optional: <tmp dir>'
 exit
fi
echo "bam file: $1"
echo "bam output file: $2"
echo "sort order: $3"
if [[ $3 != "coordinate" && $3 != "queryname" ]]; then
 echo 'Sort argument should be coordinate or queryname'
 echo 'usage: SortSam.csh <BAM file> <BAM out file> <Sort order: queryname or coordinate>'
 exit	
fi
tmpdir=""
if [[ $# == 4 ]]; then
	echo "tmp dir: $4"
	tmpdir="TMP_DIR=$4"
fi
java -Xmx2g -jar $PICARD_HOME/picard.jar SortSam INPUT=$1 OUTPUT=$2 SORT_ORDER=$3 CREATE_INDEX=true $tmpdir
echo "Finished on $HOSTNAME"
