#!/bin/bash

# This sub script will treat each sample. 

fastqf=$1
adapter=$2
blastdbpath=$3
threads=$4
echo $(pwd)
echo "treat file: "$fastqf
echo "remove adapter sequence"
cutadapt -n 3 -m 30 -b $adapter -o trimmed_$fastqf $fastqf > logcutadapt

echo "de novo assembly by SPades ..."
spades.py -t $threads  --iontorrent -s trimmed_$fastqf  -o ./spades_assembly --careful --cov-cutoff auto > log_spades
echo "align scaffold on reference with blast ..."
blastn -db $blastdbpath -query $(pwd)/spades_assembly/scaffolds.fasta -outfmt 6 -out blast_assembly_on_ref.txt -num_threads $threads > log_blast


