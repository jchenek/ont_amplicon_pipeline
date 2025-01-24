#!/usr/bin/perl -w
use warnings;
#Usage: 
#perl .pl <IN rep-seq.fa> <IN ont_seq> <IN number_of_threads>
#README:
#this script cannot run using nohup
#this script needs racon env (conda cerate -n racon)

($assembly, $ont_seq, $cpu) = @ARGV;

#conda activate racon
open OU2, ">./racon_polish_ont_com";
print OU2 "#!/bin/bash\n";
print OU2 "source ~/miniconda3/etc/profile.d/conda.sh\n";
print OU2 "conda activate racon\n";

#round-1 polish
print OU2 "echo \"########minimap2 module########\"\n";
print OU2 "echo \"########running round-1 minimap2########\"\n";
print OU2 "minimap2 -t $cpu -ax map-ont $assembly $ont_seq > minimap2_ont_r1.sam\n";
print OU2 "echo \"########racon module########\"\n";
print OU2 "echo \"########running round-1 racon########\"\n";
print OU2 "racon -t $cpu $ont_seq minimap2_ont_r1.sam $assembly > racon_ont_r1.fa\n";

#round-2 polish
print OU2 "echo \"########minimap2 module########\"\n";
print OU2 "echo \"########running round-2 minimap2########\"\n";
print OU2 "minimap2 -t $cpu -ax map-ont racon_ont_r1.fa $ont_seq > minimap2_ont_r2.sam\n";
print OU2 "echo \"########racon module########\"\n";
print OU2 "echo \"########running round-2 racon########\"\n";
print OU2 "racon -t $cpu $ont_seq minimap2_ont_r2.sam racon_ont_r1.fa > racon_ont_r2.fa\n";

#round-3 polish
print OU2 "echo \"########minimap2 module########\"\n";
print OU2 "echo \"########running round-3 minimap2########\"\n";
print OU2 "minimap2 -t $cpu -ax map-ont racon_ont_r2.fa $ont_seq > minimap2_ont_r3.sam\n";
print OU2 "echo \"########racon module########\"\n";
print OU2 "echo \"########running round-3 racon########\"\n";
print OU2 "racon -t $cpu $ont_seq minimap2_ont_r3.sam racon_ont_r2.fa > racon_ont_r3.fa\n";

#round-4 polish
print OU2 "echo \"########minimap2 module########\"\n";
print OU2 "echo \"########running round-4 minimap2########\"\n";
print OU2 "minimap2 -t $cpu -ax map-ont racon_ont_r3.fa $ont_seq > minimap2_ont_r4.sam\n";
print OU2 "echo \"########racon module########\"\n";
print OU2 "echo \"########running round-4 racon########\"\n";
print OU2 "racon -t $cpu $ont_seq minimap2_ont_r4.sam racon_ont_r3.fa > racon_ont_r4.fa\n";

close OU2;
system ("bash racon_polish_ont_com");
