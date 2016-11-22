#!/bin/bash

#control ApeKI
qsub -l h_vmem=15g -N setCACG -b y "python3 setAnalysis.py -i Sample_R06_GCCAAT_L005.sort.clip.call.CG.CGmap.pos Sample_R07_CAGATC_L003.sort.clip.call.CG.CGmap.pos Sample_R08_ACTTGA_L005.sort.clip.call.CG.CGmap.pos Sample_R09_GATCAG_L007.sort.clip.call.CG.CGmap.pos Sample_R10_TAGCTT_L005.sort.clip.call.CG.CGmap.pos -o control_ApeKI.CG.intersection.txt --type intersection"
qsub -l h_vmem=15g -N setCACHG -b y "python3 setAnalysis.py -i Sample_R06_GCCAAT_L005.sort.clip.call.CHG.CGmap.pos Sample_R07_CAGATC_L003.sort.clip.call.CHG.CGmap.pos Sample_R08_ACTTGA_L005.sort.clip.call.CHG.CGmap.pos Sample_R09_GATCAG_L007.sort.clip.call.CHG.CGmap.pos Sample_R10_TAGCTT_L005.sort.clip.call.CHG.CGmap.pos -o control_ApeKI.CHG.intersection.txt --type intersection"
qsub -l h_vmem=40g -N setCACHH -b y "python3 setAnalysis.py -i Sample_R06_GCCAAT_L005.sort.clip.call.CHH.CGmap.pos Sample_R07_CAGATC_L003.sort.clip.call.CHH.CGmap.pos Sample_R08_ACTTGA_L005.sort.clip.call.CHH.CGmap.pos Sample_R09_GATCAG_L007.sort.clip.call.CHH.CGmap.pos Sample_R10_TAGCTT_L005.sort.clip.call.CHH.CGmap.pos -o control_ApeKI.CHH.intersection.txt --type intersection"

#LR5007 ApeKI
qsub -l h_vmem=15g -N setLACG -b y "python3 setAnalysis.py -i ICI001A_CGATGT_L001.sort.clip.call.CG.CGmap.pos ICI001B_TGACCA_L001.sort.clip.call.CG.CGmap.pos ICI001C_ACAGTG_L001.sort.clip.call.CG.CGmap.pos ICI002A_ATCACG_L002.sort.clip.call.CG.CGmap.pos ICI002B_TTAGGC_L002.sort.clip.call.CG.CGmap.pos -o LR5007_ApeKI.CG.intersection.txt --type intersection"
qsub -l h_vmem=15g -N setLACHG -b y "python3 setAnalysis.py -i ICI001A_CGATGT_L001.sort.clip.call.CHG.CGmap.pos ICI001B_TGACCA_L001.sort.clip.call.CHG.CGmap.pos ICI001C_ACAGTG_L001.sort.clip.call.CHG.CGmap.pos ICI002A_ATCACG_L002.sort.clip.call.CHG.CGmap.pos ICI002B_TTAGGC_L002.sort.clip.call.CHG.CGmap.pos -o LR5007_ApeKI.CHG.intersection.txt --type intersection"
qsub -l h_vmem=40g -N setLACHH -b y "python3 setAnalysis.py -i ICI001A_CGATGT_L001.sort.clip.call.CHH.CGmap.pos ICI001B_TGACCA_L001.sort.clip.call.CHH.CGmap.pos ICI001C_ACAGTG_L001.sort.clip.call.CHH.CGmap.pos ICI002A_ATCACG_L002.sort.clip.call.CHH.CGmap.pos ICI002B_TTAGGC_L002.sort.clip.call.CHH.CGmap.pos -o LR5007_ApeKI.CHH.intersection.txt --type intersection"

