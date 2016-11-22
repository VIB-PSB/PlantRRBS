#!/bin/bash

for f in *.intersection.txt; do cat $f | sed "s/:/\t/g" | awk '{if($2=="C"){strand="+"}else{strand="-"};print $3"\t"$1"\t"strand}' > `echo $f | sed "s/txt/pos/"` ; done
