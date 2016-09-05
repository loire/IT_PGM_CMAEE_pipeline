#!/bin/bash

# Commande:
# >bash Treat_IonTorrent.sh path_to_barcode_file.fasta adapter_sequence  path_to_multiplexed_file.fastq  path_to_reference.fasta threads

#  exemple of commande with files in pipeline directory:

# bash Treat_IonTorrent.sh Data/barcode_ndv_exp.fasta CATCACATAGGCGTCCGCTG Data/multiplexed_ndv_data.fastq Data/ref_genome.fasta 16

# Arguments descriptions:
# fasta file with sample names and barcode sequence (fasta)
barcodef=$1
# Sequence of adapter sequences for removal (up to 5 times from both end) (string)
adapterseq=$2
# path to file containing multiplexed sequences (fastq)
multifastq=$3
# path to reference sequence (fasta)
refseq=$4
# number of threads to use during assembly / blast / (mapping) 
threads=$5



# exemple of barcode_file.fasta:
#
#>n503
#TAGCGAGT 
#>n504
#CTGCGTGT 
#>n505
#TCATCGAG 
#>n506
#CGTGAGTG 
#>n507
#GGATATCT 
#>n508
#GACACCGT 
#>n509
#CTACTATA 
#>n510
#CGTTACTA 
#>n511
#AGAGTCAC 
#
# Results: 
# 1/ demultiplexed file will be placed in a directory with the name of samples
# 2/ in each directory, for each sample we launch spades to produce a de novo assembly
# 3/ each scaffold is then blast against a reference 
# TODO : map reads on scaffolds that produce an alignement with the reference (or all of them ?) 
# TODO : SNP calling with samtools 

# -----------------------------------------------------
# Dependencies
# -----------------------------------------------------
# On the CIRAD cluster I will load the needed programs through the  module load utility
# Otherwise, the following executables need to be in the path:
# cutadapt (demultiplexing and reads filtering) -> https://github.com/marcelm/cutadapt
# SPades (de novo assembly of genomes) -> http://bioinf.spbau.ru/spades
# blast+ ialign contigs on reference genome) -> https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download
# TMAP (mapping reads on de novo assembly contigs)  -> https://github.com/iontorrent/TMAP
# samtools (treat mapping files (bam files) and variant calling) ->  (http://samtools.sourceforge.net/)

# -----------------------------------------------------
# CIRAD Cluster specific
# -----------------------------------------------------
echo "Module loading ...."


module load system/python/2.7.9
module load compiler/gcc/4.9.2
module load bioinfo/cutadapt/1.8.1
module load bioinfo/SPAdes/3.6.2
module load bioinfo/ncbi-blast/2.2.30

# -----------------------------------------------------

echo "Demultiplexing fastq file ..."

# demultiplexing:
cutadapt -b file:$barcodef  --untrimmed-o unknow.fastq -o {name}.fastq $multifastq > log_cutadapt_demultiplexing


echo "Create blast database from reference"

# Create blast database from reference
if [ ! -f "$refseq".nin ]
	then makeblastdb -dbtype nucl -in $refseq -logfile log_makeblastdb.txt
fi


# get libraries name for fasta file
grep '^>' $1 | awk '{print substr($0,2)}' > list_libraries_$(basename $1).txt
# create subdirectories move data files and work and each dataset sequentially (TODO: parallelized) 
for i in $(cat "list_libraries_"$(basename $1)".txt")
do 
	echo "treat sample: "$i
	mkdir -p $i
	mv $i.fastq $i
	# move in subdirectory to clean and assemble data
	cd $i
	qsub -q normal.q -pe parallel_smp $threads -V -N $i -cwd -b y bash ../treat_sample.sh $i.fastq $adapterseq $(pwd)/../$refseq $threads 
	cd ..
done










