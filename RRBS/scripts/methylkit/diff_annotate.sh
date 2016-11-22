#!/bin/bash

for f in */diff.all.*pos; do 

echo $f ; 
dir=`dirname $f`
file=`basename $f`

cd $dir
echo $PWD
echo qsub -l h_vmem=5g ../extractFeatByCoordinate.sh $file 
qsub -l h_vmem=5g ../extractFeatByCoordinate.sh $file 

cd ../

done
