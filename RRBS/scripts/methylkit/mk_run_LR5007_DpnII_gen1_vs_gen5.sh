#!/bin/bash
joblist=""
for i in $(seq 1 12); do
	if [[ ${#i} == 1 ]]; then
		chr="Chr0"$i
	else
		chr="Chr"$i
	fi
	
	cd $chr

	mkdir LR5007_generation
    	cd LR5007_generation
    	for f in ../*.bed; do ln -s $f ; done
	cp ../../MK_LR5007_DpnII_gen1_vs_gen5.Rmd . 
	echo "#!/bin/bash" > "MK_LR5007_DpnII_gen1_vs_gen5_"$chr".sh"
    	echo "module load R/x86_64/2.15.1" >> "MK_LR5007_DpnII_gen1_vs_gen5_"$chr".sh"
	echo "Rscript --no-save --no-restore --no-init-file --no-site-file -e \"library(knitr);chromosome <- '$chr';knit2html('MK_LR5007_DpnII_gen1_vs_gen5.Rmd')\"" >> "MK_LR5007_DpnII_gen1_vs_gen5_"$chr".sh"
    	echo qsub -N "MK_control_LR5007_DpnII_"$chr -l h_vmem=30g "MK_LR5007_DpnII_gen1_vs_gen5_"$chr".sh"
    	qsub -N "MK_LR5007_DpnII_gen1_vs_gen5_"$chr -l h_vmem=30g "MK_LR5007_DpnII_gen1_vs_gen5_"$chr".sh"
	joblist=$joblist",MK_LR5007_DpnII_gen1_vs_gen5_"$chr
	cd ..
	cd ..
done

qsub -N gatherInfo.sh -hold_jid $joblist gatherInfo.sh LR5007_generation


