# simple script which parses the samtools-depth file, and given a predetermined genome-size and minimum read-number, 
# produces the final global coverage for the BAM file.

use strict;
use warnings;

if(scalar(@ARGV) != 4){
	print STDERR "Usage : perl compute_coverage.pl [samtools-depth-file] [file-data-name] [genome-size] [min-depth]\n";
	exit 1;
}

my $input_file			= $ARGV[0];
my $data_name			= $ARGV[1];
my $genome_size			= $ARGV[2];	# genome size of osa indica
my $minimum_depth		= $ARGV[3];	# read-depth cutoff. 

my $ok_positions		= 0;


open(FILE,"<$input_file") or die "Couldnt open file $input_file";
while(my $line=<FILE>){
	chomp($line);
	my @data		= split("\t",$line);
	if(scalar(@data) == 3){
		my $pos_depth	= $data[2];
		if($pos_depth >= $minimum_depth){
			$ok_positions++;
		}
	}
}
close(FILE);


my $coverage			= $ok_positions*100/$genome_size;
my $base_name			= `basename $input_file .depth`;
chomp($base_name);

print STDOUT $data_name."\t".$base_name."\t".$coverage."\t".$ok_positions."\n";
