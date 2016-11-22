#!/bin/bash
joblist=""
for i in $(seq 1 12); do
	if [[ ${#i} == 1 ]]; then
		chr="Chr0"$i
	else
		chr="Chr"$i
	fi
	
	cd $chr

	mkdir control_LR5007_ApeKI
        cd control_LR5007_ApeKI
        for f in ../*.bed; do ln -s $f ; done
	cp ../../MK_control_vs_LR5007_ApeKI.Rmd .
	echo "#!/bin/bash" > "MK_control_vs_LR5007_ApeKI_"$chr".sh"
        echo "module load R/x86_64/2.15.1" >> "MK_control_vs_LR5007_ApeKI_"$chr".sh"
	echo "Rscript --no-save --no-restore --no-init-file --no-site-file -e \"library(knitr);chromosome <- '$chr';knit2html('MK_control_vs_LR5007_ApeKI.Rmd')\"" >> "MK_control_vs_LR5007_ApeKI_"$chr".sh"
        echo qsub -N "MK_control_vs_LR5007_ApeKI_"$chr -l h_vmem=15g "MK_control_vs_LR5007_ApeKI_"$chr".sh"
        qsub -N "MK_control_vs_LR5007_ApeKI_"$chr -l h_vmem=15g "MK_control_vs_LR5007_ApeKI_"$chr".sh"
	joblist=$joblist",MK_control_vs_LR5007_ApeKI_"$chr
	cd ..
	cd ..
done

qsub -N sleeper -hold_jid $joblist -sync y -b y "sleep 1"

mkdir control_LR5007_ApeKI
cd control_LR5007_ApeKI
#diff DMR files
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.all.txt
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.hypo.txt
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.hyper.txt
for f in ../Chr*/control_LR5007_ApeKI/diff.all.txt ; do tail -n +2 $f >> diff.all.txt ; done
for f in ../Chr*/control_LR5007_ApeKI/diff.hypo.txt ; do tail -n +2 $f >> diff.hypo.txt ; done
for f in ../Chr*/control_LR5007_ApeKI/diff.hyper.txt ; do tail -n +2 $f >> diff.hyper.txt ; done
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.all.txt > diff.all.reindex.txt
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.hypo.txt > diff.hypo.reindex.txt
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.hyper.txt > diff.hyper.reindex.txt
#unite
head -n1 ../Chr01/control_LR5007_ApeKI/unite.txt > unite.txt
for f in ../Chr*/control_LR5007_ApeKI/unite.txt ; do tail -n +2 $f >> unite.txt ; done
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' unite.txt > unite.reindex.txt
cd ..
rm sleeper.*
