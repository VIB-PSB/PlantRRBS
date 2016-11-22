cat $1 | sed "s/:/\t/g" | awk '{if($2=="C"){strand="+"}else{strand="-"};print $3,"\t",$1,"\t",strand}' > $1.col
