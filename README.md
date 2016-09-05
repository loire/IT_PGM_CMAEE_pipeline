# IT_PGM_CMAEE_pipeline

## How to launch: (currently configured for cc2-login cluster in CIRAD)  

>bash Treat_IonTorrent.sh path_to_barcode_file.fasta adapter_sequence  path_to_multiplexed_file.fastq  path_to_reference.fasta threads

exemple of commande with files in pipeline directory:

>bash Treat_IonTorrent.sh Data/barcode_ndv_exp.fasta CATCACATAGGCGTCCGCTG Data/multiplexed_ndv_data.fastq Data/ref_genome.fasta 16

Arguments descriptions:

barcodef: fasta file with sample names and barcode sequence (fasta)

adapterseq: Sequence of adapter sequences for removal (up to 5 times from both end) (string)

multifastq: path to file containing multiplexed sequences (fastq)

refseq: path to reference sequence (fasta)

threads: number of threads to use during assembly/blast/mapping

