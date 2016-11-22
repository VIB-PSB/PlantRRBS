for f in ../bsseeker/ApeKI/calling/Sample*.CGmap.gz; do
	for i in $(seq 1 12 ); do
		chr="Chr$i"
		if [[ ${#i} == 1 ]]; then
			chr="Chr0$i"
		fi
		if [[ ! -d $chr ]]; then
			mkdir $chr
		fi
		out=`basename $f | sed "s/gz/$chr.bed/"`
		qsub ngs/methylation/bsseeker/bsseeker2MethylKit.sh $f $chr/$out 10 $chr
	done
done
