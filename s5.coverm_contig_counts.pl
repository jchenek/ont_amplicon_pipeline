#!/usr/bin/perl -w
use warnings;
#Usage: 
#perl .pl <IN number_of_threads> <IN manifest_filtering> <IN rep-seqs.fa>

($cpu, $fq_list, $ref) = @ARGV;

open OU2, ">./coverm_contig_com";
print OU2 "#!/bin/bash\n";
print OU2 "source ~/miniconda3/etc/profile.d/conda.sh\n";
print OU2 "conda activate coverm\n";

$path1 = "";
open IN2, "$fq_list";
<IN2>;
while(<IN2>){
#	print"$_";
	chomp;
	$PE1 = (split /\t/,$_)[1];
	$path1 = "$path1 $PE1";
}
close IN2;
print OU2 "coverm contig --single $path1 --reference $ref --methods count --output-file otu-table.tsv --min-read-percent-identity 97 --min-read-aligned-percent 90 --threads $cpu 2> coverm_2_out\n";

close OU2;

system ("bash coverm_contig_com");
