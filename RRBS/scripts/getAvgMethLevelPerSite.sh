#!/bin/bash
mv CG.summary CG.summary.old
mv CHG.summary CHG.summary.old
mv CHH.summary CHH.summary.old
echo -P "Total context	Average meth. level	Count no C|T read" > CG.summary
echo -P "Total context	Average meth. level	Count no C|T read" > CHG.summary
echo -P "Total context	Average meth. level	Count no C|T read" > CHH.summary
for f in *sort.clip.call.CGmap.gz; do sample=`echo $f | sed "s/.sort.*//"`; echo -n $sample" " >> CG.summary ;zcat $f | awk 'BEGIN{allC=0;count=0;tot=0; na=0}{if($4=="CG"){allC+=1;if($6!="na"){count+=$6;tot+=1}else{na+=1}}}END{avg=count/tot; print allC"\t"avg"\t"na}' >> CG.summary; done
for f in *sort.clip.call.CGmap.gz; do sample=`echo $f | sed "s/.sort.*//"`; echo -n $sample" " >> CHG.summary ;zcat $f | awk 'BEGIN{allC=0;count=0;tot=0; na=0}{if($4=="CHG"){allC+=1;if($6!="na"){count+=$6;tot+=1}else{na+=1}}}END{avg=count/tot; print allC"\t"avg"\t"na}' >> CHG.summary; done
for f in *sort.clip.call.CGmap.gz; do sample=`echo $f | sed "s/.sort.*//"`; echo -n $sample" " >> CHH.summary ;zcat $f | awk 'BEGIN{allC=0;count=0;tot=0; na=0}{if($4=="CHH"){allC+=1;if($6!="na"){count+=$6;tot+=1}else{na+=1}}}END{avg=count/tot; print allC"\t"avg"\t"na}' >> CHH.summary; done
