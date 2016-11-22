SUBSAMPLEDIR=$1

DATALIBS=(ICC21_control ICC26_LR5007)

CYTOSINE_TYPES=(CG+CHG+CHH CG CHG CHH)

for datalib in "${DATALIBS[@]}"
do
	for cytosine in "${CYTOSINE_TYPES[@]}"
	do
		cg_map_file="$SUBSAMPLEDIR/$cytosine.$datalib.CGmap"
		num_occurences=`cat $cg_map_file | awk '$8 >= 10' | wc -l`
		echo -e "$datalib\t$cytosine\t$num_occurences"		
	done
done
