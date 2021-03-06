#!/bin/bash

DEPTH=$1
PERL="perl compute_coverage.pl"
SIZE=427026737
LOC=$2
DPN=$LOC/DpnII/
APE=$LOC/ApeKI/

$PERL "$DPN/Sample_R01_ATCACG_L005.depth" "Control-1 S4" $SIZE $DEPTH
$PERL "$DPN/Sample_R02_CGATGT_L003.depth" "Control-2 S4" $SIZE $DEPTH
$PERL "$DPN/Sample_R03_TTAGGC_L006.depth" "Control-3 S4" $SIZE $DEPTH
$PERL "$DPN/Sample_R04_TGACCA_L003.depth" "Control-4 S4" $SIZE $DEPTH
$PERL "$DPN/Sample_R05_ACAGTG_L007.depth" "Control-5 S4" $SIZE $DEPTH

$PERL "$DPN/Sample_R11_ATCACG_L007.depth" "LR2-1 S4" $SIZE $DEPTH
$PERL "$DPN/Sample_R12_CGATGT_L006.depth" "LR2-2 S4" $SIZE $DEPTH
$PERL "$DPN/Sample_R13_TTAGGC_L007.depth" "LR2-3 S4" $SIZE $DEPTH
$PERL "$DPN/Sample_R14_TGACCA_L006.depth" "LR2-4 S4" $SIZE $DEPTH
$PERL "$DPN/Sample_R15_ACAGTG_L006.depth" "LR2-5 S4" $SIZE $DEPTH

$PERL "$APE/Sample_R06_GCCAAT_L005.depth" "Control-6 S4" $SIZE $DEPTH
$PERL "$APE/Sample_R07_CAGATC_L003.depth" "Control-7 S4" $SIZE $DEPTH
$PERL "$APE/Sample_R08_ACTTGA_L005.depth" "Control-8 S4" $SIZE $DEPTH
$PERL "$APE/Sample_R09_GATCAG_L007.depth" "Control-9 S4" $SIZE $DEPTH
$PERL "$APE/Sample_R10_TAGCTT_L005.depth" "Control-10 S4" $SIZE $DEPTH

$PERL "$APE/ICI002A_ATCACG_L002.depth" "LR2-6 S4" $SIZE $DEPTH
$PERL "$APE/ICI001A_CGATGT_L001.depth" "LR2-7 S4" $SIZE $DEPTH
$PERL "$APE/ICI002B_TTAGGC_L002.depth" "LR2-8 S4" $SIZE $DEPTH
$PERL "$APE/ICI001B_TGACCA_L001.depth" "LR2-9 S4" $SIZE $DEPTH
$PERL "$APE/ICI001C_ACAGTG_L001.depth" "LR2-10 S4" $SIZE $DEPTH
