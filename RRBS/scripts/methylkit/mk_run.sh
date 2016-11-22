#!/bin/bash
# copy this file to the Chrxx folder, and change the variable chr to that chromosome
joblist=""
for i in $(seq 1 12); do
	if [[ ${#i} == 1 ]]; then
		chr="Chr0"$i
	else
		chr="Chr"$i
	fi
	
	cd $chr

	#mkdir control_enzyme
	#cd control_enzyme
	#for f in ../*.bed; do ln -s $f ; done
	#cp ../../MK_control_DpnII_vs_ApeKI.Rmd . 
	#echo "#!/bin/bash" > "MK_control_enzyme_"$chr".sh"
	#echo "module load R/x86_64/2.15.1" >> "MK_control_enzyme_"$chr".sh"	
	#echo "Rscript --no-save --no-restore --no-init-file --no-site-file -e \"library(knitr);chromosome <- '$chr';knit2html('MK_control_DpnII_vs_ApeKI.Rmd')\"" >> "MK_control_enzyme_"$chr".sh"
	#echo qsub -N "MK_control_enzyme_"$chr -l h_vmem=10g "MK_control_enzyme_"$chr".sh"
	#qsub -N "MK_control_enzyme_"$chr -l h_vmem=10g "MK_control_enzyme_"$chr".sh"
	#if [[ $chr == "Chr01" ]]; then
	#    joblist="MK_control_enzyme_"$chr
	#else
	#    joblist=$joblist",MK_control_enzyme_"$chr
	#fi
	#cd ..

	mkdir LR5007_enzyme 
        cd LR5007_enzyme
        for f in ../*.bed; do ln -s $f ; done
	cp ../../MK_LR5007_DpnII_vs_ApeKI.Rmd .
	echo "#!/bin/bash" > "MK_LR5007_enzyme_"$chr".sh"
        echo "module load R/x86_64/2.15.1" >> "MK_LR5007_enzyme_"$chr".sh"
	echo "Rscript --no-save --no-restore --no-init-file --no-site-file -e \"library(knitr);chromosome <- '$chr';knit2html('MK_LR5007_DpnII_vs_ApeKI.Rmd')\"" >> "MK_LR5007_enzyme_"$chr".sh"
        echo qsub -N "MK_LR5007_enzyme_"$chr -l h_vmem=10g "MK_LR5007_enzyme_"$chr".sh"
        qsub -N "MK_LR5007_enzyme_"$chr -l h_vmem=10g "MK_LR5007_enzyme_"$chr".sh"
	joblist=$joblist",MK_LR5007_enzyme_"$chr
	cd ..

	mkdir control_LR5007_DpnII
        cd control_LR5007_DpnII
        for f in ../*.bed; do ln -s $f ; done
	cp ../../MK_control_DpnII_vs_LR5007_DpnII.Rmd .
	echo "#!/bin/bash" > "MK_control_DpnII_vs_LR5007_DpnII_"$chr".sh"
        echo "module load R/x86_64/2.15.1" >> "MK_control_DpnII_vs_LR5007_DpnII_"$chr".sh"
	echo "Rscript --no-save --no-restore --no-init-file --no-site-file -e \"library(knitr);chromosome <- '$chr';knit2html('MK_control_DpnII_vs_LR5007_DpnII.Rmd')\"" >> "MK_control_DpnII_vs_LR5007_DpnII_"$chr".sh"
        echo qsub -N "MK_control_DpnII_vs_LR5007_DpnII_"$chr -l h_vmem=10g "MK_control_DpnII_vs_LR5007_DpnII_"$chr".sh"
        qsub -N "MK_control_DpnII_vs_LR5007_DpnII_"$chr -l h_vmem=10g "MK_control_DpnII_vs_LR5007_DpnII_"$chr".sh"
	joblist=$joblist",MK_control_DpnII_vs_LR5007_DpnII_"$chr
	cd ..
	
	#mkdir LR5007_generation
        #cd LR5007_generation
        #for f in ../*.bed; do ln -s $f ; done
	#cp ../MK_LR5007_DpnII_gen1_vs_gen5.Rmd . 
	#echo "#!/bin/bash" > "MK_LR5007_DpnII_gen1_vs_gen5_"$chr".sh"
        #echo "module load R/x86_64/2.15.1" >> "MK_LR5007_DpnII_gen1_vs_gen5_"$chr".sh"
	#echo "Rscript --no-save --no-restore --no-init-file --no-site-file -e \"library(knitr);chromosome <- '$chr';knit2html('MK_LR5007_DpnII_gen1_vs_gen5.Rmd')\"" >> "MK_LR5007_DpnII_gen1_vs_gen5_"$chr".sh"
        #echo qsub -N "MK_LR5007_DpnII_gen1_vs_gen5_"$chr -l h_vmem=10g "MK_LR5007_DpnII_gen1_vs_gen5_"$chr".sh"
        #qsub -N "MK_LR5007_DpnII_gen1_vs_gen5_"$chr -l h_vmem=10g "MK_LR5007_DpnII_gen1_vs_gen5_"$chr".sh"
	#joblist=$joblist","MK_LR5007_DpnII_gen1_vs_gen5_"$chr
	#cd ..

	cd ..
done

qsub -N sleeper -hold_jid $joblist -sync y -b y "sleep 1"

echo "merging results"
:'mkdir control_enzyme
cd control_enzyme
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.all.txt
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.hypo.txt
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.hyper.txt
for f in ../Chr*/control_enzyme/diff_all.txt ; do tail -n +2 $f >> diff.all.txt; done
for f in ../Chr*/control_enzyme/diff_hypo.txt ; do tail -n +2 $f >> diff.hypo.txt; done
for f in ../Chr*/control_enzyme/diff_hyper.txt ; do tail -n +2 $f >> diff.hyper.txt; done
'
#awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.all.txt > diff.all.reindex.txt
#awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.hypo.txt > diff.hypo.reindex.txt
#awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.hyper.txt > diff.hyper.reindex.txt
#cd ../

mkdir LR5007_enzyme
cd LR5007_enzyme
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.all.txt
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.hypo.txt
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.hyper.txt
for f in ../Chr*/LR5007_enzyme/diff.all.txt ; do tail -n +2 $f >> diff.all.txt; done
for f in ../Chr*/LR5007_enzyme/diff.hypo.txt ; do tail -n +2 $f >> diff.hypo.txt; done
for f in ../Chr*/LR5007_enzyme/diff.hyper.txt ; do tail -n +2 $f >> diff.hyper.txt; done
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.all.txt > diff.all.reindex.txt
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.hypo.txt > diff.hypo.reindex.txt
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.hyper.txt > diff.hyper.reindex.txt

cd ..
mkdir control_LR5007_DpnII
cd control_LR5007_DpnII
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.all.txt
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.hypo.txt
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.hyper.txt
for f in ../Chr*/control_LR5007_DpnII/diff.all.txt ; do tail -n +2 $f >> diff.all.txt ; done
for f in ../Chr*/control_LR5007_DpnII/diff.hypo.txt ; do tail -n +2 $f >> diff.hypo.txt ; done
for f in ../Chr*/control_LR5007_DpnII/diff.hyper.txt ; do tail -n +2 $f >> diff.hyper.txt ; done
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.all.txt > diff.all.reindex.txt
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.hypo.txt > diff.hypo.reindex.txt
awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.hyper.txt > diff.hyper.reindex.txt
cd ..
:'mkdir LR5007_generation
cd LR5007_generation
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.all.txt
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.hypo.txt
echo -e "id\tchr\tstart\tend\tstrand\tpvalue\tqvalue\tmeth.diff" >diff.hyper.txt
for f in ../Chr*/control_LR5007_DpnII/diff_all.txt ; do tail -n +2 $f >> diff.all.txt; done
for f in ../Chr*/control_LR5007_DpnII/diff_hypo.txt ; do tail -n +2 $f >> diff.hypo.txt; done
for f in ../Chr*/control_LR5007/diff_hyper.txt ; do tail -n +2 $f >> diff.hyper.txt; done
'
#awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.all.txt > diff.all.reindex.txt
#awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.hypo.txt > diff.hypo.reindex.txt
#awk '{if(NR>1){$1="";print NR-1,"\t"$0}else{print $0}}' diff.hyper.txt > diff.hyper.reindex.txt
#cd ..
rm sleeper.*
