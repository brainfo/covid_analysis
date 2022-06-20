#!/bin/bash

# mkdir ../data/reference_seqs
# efetch -db nuccore -id NC_001422 -format fasta > ../data/reference_seqs/PhiX_NC_001422.fna

# mkdir ../data/bowtie2_DBs
# srun bowtie2-build -f ../data/reference_seqs/PhiX_NC_001422.fna ../data/bowtie2_DBs/PhiX_bowtie2_DB

# mkdir bowtie
# srun --cpus-per-task=8 bowtie2 -x ../data/bowtie2_DBs/PhiX_bowtie2_DB -U ../data/merged_pairs/ERR*.extendedFrags.fastq.gz \
#  -S bowtie/hong_merged2PhiX.sam --threads 8 --no-unal 2>&1 | tee logs/hong_bowtie_merged2PhiX.log

efetch -db nuccore -id NC_045512 -format fasta > ../data/reference_seqs/SC2_NC_045512.fna
srun bowtie2-build -f ../data/reference_seqs/SC2_NC_045512.fna ../data/bowtie2_DBs/SC2_bowtie2_DB
srun --cpus-per-task=8 bowtie2 -x ../data/bowtie2_DBs/SC2_bowtie2_DB -U ../data/merged_pairs/ERR*.extendedFrags.fastq.gz \
 -S bowtie/hong_merged2SC2.sam --threads 8 --no-unal 2>&1 | tee logs/hong_bowtie_merged2SC2.log