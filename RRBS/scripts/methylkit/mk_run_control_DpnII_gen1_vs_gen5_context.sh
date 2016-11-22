#!/bin/bash
joblist=""
for i in $(seq 1 12); do
	if [[ ${#i} == 1 ]]; then
		chr="Chr0"$i
	else
		chr="Chr"$i
	fi
	
	cd $chr

	mkdir control_generation_$1
    	cd control_generation_$1
    	for f in ../*.$1.*bed; do ln -s $f ; done
	cp ../../MK_control_DpnII_gen1_vs_gen5.Rmd . 
	echo "#!/bin/bash" > "MK_control_DpnII_gen1_vs_gen5_"$chr".sh"
    	echo "module load R/x86_64/2.15.1" >> "MK_control_DpnII_gen1_vs_gen5_"$chr".sh"
	echo "Rscript --no-save --no-restore --no-init-file --no-site-file -e \"library(knitr);chromosome <- '$chr';context<-'$1';knit2html('MK_control_DpnII_gen1_vs_gen5.Rmd')\"" >> "MK_control_DpnII_gen1_vs_gen5_"$chr".sh"
    	echo qsub -N "MK_control_DpnII_gen1_vs_gen5_"$chr -l h_vmem=30g "MK_control_DpnII_gen1_vs_gen5_"$chr".sh"
    	qsub -N "MK_control_DpnII_gen1_vs_gen5_"$chr -l h_vmem=30g "MK_control_DpnII_gen1_vs_gen5_"$chr".sh"
	joblist=$joblist",MK_control_DpnII_gen1_vs_gen5_"$chr
	cd ..
	cd ..
done

qsub -N gatherInfo_context.sh -l h_vmem=5g -hold_jid $joblist gatherInfo_context.sh control_generation_$1 $1

