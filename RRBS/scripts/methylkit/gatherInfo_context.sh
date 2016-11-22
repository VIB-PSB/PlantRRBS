#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "An input directory should be provided"
fi

echo "Dir: $1"
echo "Context: $2"

mkdir $1
cd $1 
#diff DMR files
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.all.$2.txt
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.hypo.$2.txt
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.hyper.$2.txt
for f in ../Chr*/$1/diff.all.$2.txt ; do tail -n +2 $f >> diff.all.$2.txt ; done
for f in ../Chr*/$1/diff.hypo.$2.txt ; do tail -n +2 $f >> diff.hypo.$2.txt ; done
for f in ../Chr*/$1/diff.hyper.$2.txt ; do tail -n +2 $f >> diff.hyper.$2.txt ; done
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.all.$2.txt > diff.all.reindex.$2.txt
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.hypo.$2.txt > diff.hypo.reindex.$2.txt
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.hyper.$2.txt > diff.hyper.reindex.$2.txt

tail -n +2 diff.all.$2.txt | awk '{print $4"\t"$3"\t"$6}' > diff.all.$2.pos

#unite
head -n1 ../Chr01/$1/unite.$2.txt > unite.$2.txt
for f in ../Chr*/$1/unite.$2.txt ; do tail -n +2 $f >> unite.$2.txt ; done
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' unite.$2.txt > unite.reindex.$2.txt

#annotation
bash ../extractFeatByCoordinate.sh diff.all.$2.pos

echo "Finished on $HOSTNAME"

