#!/usr/bin/env perl
# script to convert the CGMap output of bs_seeker2-call_methylation.py to input for MethylKit
use warnings;
use strict;
use Getopt::Long;
my $inputFile = "";
my $outputFile = "";
my $coverageCutoff = 10;
my $includeScaffolds = 0;
my $debug = 0;
my $chromosome = "";
GetOptions ("input|i=s" => \$inputFile, "output|o=s" => \$outputFile, "cutoff|c=s" => \$coverageCutoff, "debug" => \$debug, "scaffolds" => \$includeScaffolds, "chromosome=s" => \$chromosome) or die "Cannot parse arguments: $!";
die "Input needs to be gzipped ($inputFile)\nAborting" if ($inputFile !~ m/gz$/);
open IN, "gunzip -c $inputFile |" or die "Cannot open pipe $inputFile: $!";
open OUT, "> $outputFile" or die "Cannot create $outputFile: $!";
my $counter = 0;
my $linesPrinted = 0;
print OUT "id\tchr\tstart\tstrand\tcoverage\tnumCs\tnumTs\n";
# In one peculiar case F was recognized as FALSE in stead of text, giving a problem when read()
# got to an R. This might be because in the first 100 no R was present. 
# This is not a very nice workaround, but it'll have to do for now
if ($chromosome){
	print OUT "$chromosome.0\t$chromosome\t0\tR\t0\t0\t0\n";
} else {
	print OUT "Chr1.0\tChr1\t0\tR\t0\t0\t0\n";
}
while (<IN>){
	$counter++;
	if ($debug){
		print;
		last if ($counter > 1000);
	}
	chomp;
	my @data = split "\t";
 #       (1) chromosome
 #       (2) nucleotide on Watson (+) strand
 #       (3) position
 #       (4) context (CG/CHG/CHH)
 #       (5) dinucleotide-context (CA/CC/CG/CT)
 #       (6) methylation-level = #_of_C / (#_of_C + #_of_T).
 #       (7) #_of_C (methylated C, the count of reads showing C here)
 #       (8) = #_of_C + #_of_T (all Cytosines, the count of reads showing C or T here)
	my $chr = $data[0];
	if ($chromosome && lc($chr) ne lc($chromosome)){
		next;
	} 
	
	# default only Chr1 to 12 are reported
	if ($chr =~ m/Scaffold/ && !$includeScaffolds){
		next;
	}
	
	my $base = $data[1];
	my $strand = 'F';
	if ($base eq 'G'){
		$strand = 'R';
	} elsif ($base ne 'C'){
		next;
	}
	my $pos  = $data[2];
	my $freqC = $data[5];
	if ($freqC eq 'na'){
		next;
	}
	my $freqT = 1-$data[5];
	my $coverage = $data[7];
	
	next if ($coverage < $coverageCutoff);
	
	my $string = sprintf "%s\t%s\t%d\t%s\t%d\t%.2f\t%.2f\n", "$chr.$pos", $chr, $pos, $strand, $coverage, $freqC*100, $freqT*100;
	print $string if $debug;
	print OUT $string;
	$linesPrinted++;
}
close IN;
close OUT;
printf "%d lines printed out of %d\n", $linesPrinted, $counter;

