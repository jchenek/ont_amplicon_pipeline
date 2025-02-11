ONT amplicon analysis pipeline in Liu lab. (Jan. 24, 2025 updated)
=======

### Step 1. Quality Control
---------------
- Installation
```sh
conda create -n nanoplot -y
conda activate nanoplot
mamba install -c bioconda nanoplot -y
```
- Command
```sh
NanoPlot --fastq *.gz -t 70 --maxlength 40000 --plots hex dot kde -o nanoplot
```


### Step 2. Sequence filtering
---------------
- Installation
```sh
conda create -n chopper -y
conda activate chopper
mamba install -c bioconda chopper -y
```
- Command
```sh
#chopper -l 1000 -q 10 --threads 70 -i <IN .gz> | gzip > <OU .gz>
perl s2_chopper_filtering.pl manifest 1000 10 70
```
=======

### Step 3. Generate draft rep-seqs
- Install QIIME2 in advance (v2024.2.0 is tested, https://docs.qiime2.org/2024.2/)
- s3.1 Generate a single-end-demux.qza
```sh
qiime tools import --type 'SampleData[SequencesWithQuality]' --input-path manifest_filtering --output-path single-end-demux.qza --input-format SingleEndFastqManifestPhred33V2
```
- s3.2 Dereplicate sequence data and create a feature table and feature representative sequences.
- https://docs.qiime2.org/2024.10/plugins/available/vsearch/dereplicate-sequences/
```sh
qiime vsearch dereplicate-sequences --i-sequences single-end-demux.qza --p-no-derep-prefix --o-dereplicated-table table.qza --o-dereplicated-sequences rep-seqs.qza
```
- s3.3 Generate draft OTUs
- https://docs.qiime2.org/2024.10/plugins/available/vsearch/cluster-features-de-novo/
```
qiime vsearch cluster-features-de-novo --i-table table.qza --i-sequences rep-seqs.qza --p-perc-identity 0.97 --o-clustered-table table-97.qza --o-clustered-sequences rep-seqs-97.qza --p-threads 70
```
- UNOISE algorithm is not needed since it is designed for Illumina reads.
- https://drive5.com/usearch/manual/unoise_algo.html
- s3.4 Remove chimeric feature sequences.
- https://docs.qiime2.org/2024.10/plugins/available/vsearch/uchime-denovo/
```sh
qiime vsearch uchime-denovo --i-table table-97.qza --i-sequences rep-seqs-97.qza --output-dir uchime-denovo-out
```
=======

### Step 4. Polishing and de-redundancy
- Using racon polish the rep-seqs for 4 times
- https://training.galaxyproject.org/training-material/topics/assembly/tutorials/largegenome/tutorial.html#which-assembly-tool-and-approach-to-use
- Installation
- https://github.com/lbcb-sci/racon
```sh
conda create -n racon -y
conda activate racon
mamba install -c bioconda minimap2 racon -y
```
- s4.1 Decompresse rep-seqs-97-nonchimeras.qza to fa
- s4.2 Concatenate all fq reads in dir chopper_fq
```sh
cat ./chopper_fq/*gz > fq_for_racon.fq.gz
```
- s4.3 run racon scripts
```sh
perl s4.3_racon_polisher_ont.pl dna-sequences.fasta fq_for_racon.fq.gz 70
```
- s4.4 cd-hit de-redundancy
- Installation
```sh
conda create -n cdhit -y
conda activate cdhit
mamba install bioconda::cd-hit -y
```
- command
```sh
cd-hit-est -o final-rep-seq-97otu-raw.fa -i racon_ont_r4.fa -d 0 -c 1 -n 10 -M 60000 -T 70
```
- s4.5 reformat final-rep-seq-97otu-raw.fa
```sh
perl s4.5_fa_reformat.pl final-rep-seq-97otu-raw.fa > final-rep-seq-97otu.fa
```
=======

### Step 5. Generate OTU table

- Installation
```sh
conda create -n coverm -y
conda activate coverm
mamba install coverm -y
```
- command
```sh
perl s5.coverm_contig_counts.pl 70 ../manifest_filtering final-rep-seq-97otu.fa
```
=======

### The final output of this pipeline:
- 1. representative sequences: final-rep-seq-97otu.fa (from s4.5)
- 2. otu table: otu-table.tsv (from s5)
