#!usr/bin/perl
use warnings;
#usage: perl .pl <IN original.fa> > <OU reformated.fa>
($file) = @ARGV ;

$name_1 = (split /\//,$file)[-1];
$name_2 = (split /\./,$name_1)[0];
$name_2 =~ s/[\W]//g;

open IN, "$file";
open OU1, ">./tem.$name_2";
while(<IN>){
	s/\r//g;
	chomp;
	if(m/>/){
	s/>//;
	my$ID = (split /\s+/,$_)[0];
	print OU1 ">$ID";
	print OU1 "cjwfengecjw\n";
	}else{
	s/ //g;
	print OU1 "$_\n";
	}
}
close IN;
close OU1;

open IN, "./tem.$name_2";
$/=">";<IN>;
while (<IN>) {
	chomp;
	s/\n//g;
	$id=(split /cjwfengecjw/,$_)[0];
	$seq=(split /cjwfengecjw/,$_)[1]; #<------adjust to get seq
	$seq=~s/\*$//;
	print ">$id\n$seq\n";
}
system("rm tem.$name_2");
close IN;

