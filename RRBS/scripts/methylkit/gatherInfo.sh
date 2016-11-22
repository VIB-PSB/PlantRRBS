#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "An input directory should be provided"
fi

echo "Dir: $1"

mkdir $1
cd $1 
#diff DMR files
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.all.txt
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.hypo.txt
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.hyper.txt
for f in ../Chr*/$1/diff.all.txt ; do tail -n +2 $f >> diff.all.txt ; done
for f in ../Chr*/$1/diff.hypo.txt ; do tail -n +2 $f >> diff.hypo.txt ; done
for f in ../Chr*/$1/diff.hyper.txt ; do tail -n +2 $f >> diff.hyper.txt ; done
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.all.txt > diff.all.reindex.txt
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.hypo.txt > diff.hypo.reindex.txt
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.hyper.txt > diff.hyper.reindex.txt

tail -n +2 diff.all.pos | awk '{print $4"\t"$3"\t"$6}' > diff.all.pos

#unite
head -n1 ../Chr01/$1/unite.txt > unite.txt
for f in ../Chr*/$1/unite.txt ; do tail -n +2 $f >> unite.txt ; done
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' unite.txt > unite.reindex.txt

echo "Finished on $HOSTNAME"

