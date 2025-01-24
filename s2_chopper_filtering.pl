#!/usr/bin/perl -w
use warnings;
#Usage: 
#perl .pl <IN manifest> <-l value> <-q value> <--threads value>

($fq_list, $l, $q, $cpu) = @ARGV;

open OU2, ">./chopper_com";
open OU1, ">./manifest_filtering";
print OU2 "mkdir chopper_fq\n";

$curr_path = $ENV{'PWD'};
open IN2, "$fq_list";
$header = <IN2>;
print OU1 "$header";
while(<IN2>){
	chomp;
	$id = (split /\t/,$_)[0];
	$PE1 = (split /\t/,$_)[1];
	print OU1 "$id\t$curr_path\/chopper_fq/$id.gz\n";
	print OU2 "chopper -l $l -q $q --threads $cpu -i $PE1 | gzip > ./chopper_fq/$id.gz\n";
}
close IN2;

close OU1;
close OU2;

system ("bash chopper_com");
