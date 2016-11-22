#!/bin/bash
mv CG.min10.summary CG.min10.summary.old
mv CHG.min10.summary CHG.min10.summary.old
mv CHH.min10.summary CHH.min10.summary.old
echo "Total context	Average meth. level	Count no C|T read" > CG.min10.summary
echo "Total context	Average meth. level	Count no C|T read" > CHG.min10.summary
echo "Total context	Average meth. level	Count no C|T read" > CHH.min10.summary
for f in *sort.clip.call.CGmap.gz; do sample=`echo $f | sed "s/.sort.*//"`; echo -n $sample" " >> CG.min10.summary ;zcat $f | awk 'BEGIN{count=0;tot=0}{if($4=="CG" && ($8+0 >= 10)){count+=$6;tot+=1}}END{avg=count/tot; print tot"\t"avg}' >> CG.min10.summary; done
for f in *sort.clip.call.CGmap.gz; do sample=`echo $f | sed "s/.sort.*//"`; echo -n $sample" " >> CHG.min10.summary ;zcat $f | awk 'BEGIN{count=0;tot=0}{if($4=="CHG" && ($8+0 >= 10)){count+=$6;tot+=1}}END{avg=count/tot; print tot"\t"avg}' >> CHG.min10.summary; done
for f in *sort.clip.call.CGmap.gz; do sample=`echo $f | sed "s/.sort.*//"`; echo -n $sample" " >> CHH.min10.summary ;zcat $f | awk 'BEGIN{count=0;tot=0}{if($4=="CHH" && ($8+0 >= 10)){count+=$6;tot+=1}}END{avg=count/tot; print tot"\t"avg}' >> CHH.min10.summary; done
