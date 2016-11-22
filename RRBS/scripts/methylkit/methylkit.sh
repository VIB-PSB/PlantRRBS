for f in ../bsseeker/ApeKI/calling/*.CG.CGmap.gz; do
	for i in $(seq 1 12 ); do
		chr="Chr$i"
		if [[ ${#i} == 1 ]]; then
			chr="Chr0$i"
		fi
		out=`basename $f | sed "s/gz/$chr.bed/"`		
		qsub ngs/methylation/bsseeker/bsseeker2MethylKit.sh $f $chr/$out 10 $chr
	done
done

for f in ../bsseeker/ApeKI/calling/*.CHG.CGmap.gz; do
        for i in $(seq 1 12 ); do
                chr="Chr$i"
                if [[ ${#i} == 1 ]]; then
                        chr="Chr0$i"
                fi
                out=`basename $f | sed "s/gz/$chr.bed/"`
                qsub ngs/methylation/bsseeker/bsseeker2MethylKit.sh $f $chr/$out 10 $chr
        done
done

for f in ../bsseeker/ApeKI/calling/*.CHH.CGmap.gz; do
        for i in $(seq 1 12 ); do
                chr="Chr$i"
                if [[ ${#i} == 1 ]]; then
                        chr="Chr0$i"
                fi
                out=`basename $f | sed "s/gz/$chr.bed/"`
                qsub ngs/methylation/bsseeker/bsseeker2MethylKit.sh $f $chr/$out 10 $chr
        done
done


for f in ../bsseeker/DpnII/calling/*.CG.CGmap.gz; do
	for i in $(seq 1 12 ); do
		chr="Chr$i"
		if [[ ${#i} == 1 ]]; then
			chr="Chr0$i"
		fi
		out=`basename $f | sed "s/gz/$chr.bed/"`
		qsub ngs/methylation/bsseeker/bsseeker2MethylKit.sh $f $chr/$out 10 $chr
	done
done

for f in ../bsseeker/DpnII/calling/*.CHG.CGmap.gz; do
        for i in $(seq 1 12 ); do
                chr="Chr$i"
                if [[ ${#i} == 1 ]]; then
                        chr="Chr0$i"
                fi
                out=`basename $f | sed "s/gz/$chr.bed/"`
                qsub ngs/methylation/bsseeker/bsseeker2MethylKit.sh $f $chr/$out 10 $chr
        done
done

for f in ../bsseeker/DpnII/calling/*.CHH.CGmap.gz; do
        for i in $(seq 1 12 ); do
                chr="Chr$i"
                if [[ ${#i} == 1 ]]; then
                        chr="Chr0$i"
                fi
                out=`basename $f | sed "s/gz/$chr.bed/"`
                qsub ngs/methylation/bsseeker/bsseeker2MethylKit.sh $f $chr/$out 10 $chr
        done
done

