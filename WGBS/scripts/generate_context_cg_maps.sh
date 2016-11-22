CALLDIR=$1
OUTPUTDIR=$CALLDIR/subsampling/
SCRIPTDIR=$2
CONTROL=ICC21_control.CGmap
LR2=ICC26_LR5007.CGmap

# generate subsamples of the CGmaps per context
# possible contexts = CG, CHG or CHH 

CONTEXTS=(CG CHG CHH)

for CONTEXT in ${CONTEXTS[@]}; do
	CONTROL_CONTEXT="$OUTPUTDIR/$CONTEXT.$CONTROL"
	qsub -S /bin/bash $SCRIPTDIR/subsampleCGmap.sh $CONTEXT $CALLDIR/$CONTROL $CONTROL_CONTEXT
done

for CONTEXT in ${CONTEXTS[@]}; do
	LR2_CONTEXT="$OUTPUTDIR/$CONTEXT.$LR2"
	qsub -S /bin/bash $SCRIPTDIR/subsampleCGmap.sh $CONTEXT $CALLDIR/$LR2 $LR2_CONTEXT
done

	

