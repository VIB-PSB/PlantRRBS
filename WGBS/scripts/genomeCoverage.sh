#! /bin/bash
# calculate genome coverage: take care 0 bases are also outputted. See also scripts in mapping/postprocess
date 
module load bedtools
bedtools -version
if [[ ( $# != 3 && $# != 4 )  || ( $# == 1 && $1 == '-h' ) ]]; then
 echo 'usage: coverage.sh <BAM file> <genome BED file> <output file>'
 echo 'optional: <spliced alignment: TRUE|FALSE>' 
 exit
fi
echo "BAM file: $1"
echo "genome BED file: $2"
echo "Output file:$3"
split=""
if [[ $# == 4 && ( $4 == "TRUE" || $4 == "True" || $4 == "true" ) ]]; then
	echo "Spliced alignment: $4"
	split="-split"
fi
echo "executing: bedtools genomecov -ibam $1 -g $2 -d $split > $3"
bedtools genomecov -ibam $1 -g $2 -d $split > $3
#nr=`cut -f3 $3 | wc -l`
nr=`awk 'BEGIN{count=0}{if(($3+0)>0){count+=1}}END{print count}'`
echo "Number of covered bases: "$nr
echo $nr > $3".count"
echo "Finished on $HOSTNAME"
date
