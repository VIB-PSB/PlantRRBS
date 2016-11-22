#!/bin/bash

for f in */unite*.pos; do 

echo $f ; 
dir=`dirname $f`
file=`basename $f`

cd $dir
echo $PWD

jn=$dir"_annot"
echo qsub -N $jn -l h_vmem=5g ../extractFeatByCoordinate.sh $file 
qsub -N $jn -l h_vmem=5g ../extractFeatByCoordinate.sh $file 

hjn=$jn
jn=$dir"_slim"
echo qsub -N $jn -hold_jid $hjn -l h_vmem=5g slim_unite_table.sh
qsub -N $jn -hold_jid $hjn -l h_vmem=5g slim_unite_table.sh

hjn=$jn
jn=$dir"_cut"
echo qsub -N $jn -hold_jid $hjn -b y "cut -f1,2,3,4,5,6,7,8,9,12 $file.annot.slim.table > $file.annot.slim.no0.table"
qsub -N $jn -hold_jid $hjn -b y "cut -f1,2,3,4,5,6,7,8,9,12 $file.annot.slim.table > $file.annot.slim.no0.table"

cd ../

done
