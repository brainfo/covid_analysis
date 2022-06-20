#!/bin/bash

#echo "merge paird fastqs"
#module load flash2
#mkdir ../data/merged_pairs
# mkdir logs
# date
# srun --cpus-per-task=8 --time=00:30:00 xargs -a hong_run_accessions.txt -n 1 -I{} flash2 --threads=8 -z \
# --output-directory=../data/merged_pairs/ --output-prefix={}.flash ../data/sra_fastq/{}_1.fastq.gz ../data/sra_fastq/{}_2.fastq.gz 2>&1 | tee logs/{}_fash2_merge.log
echo "check stats"
date
srun --cpus-per-task=8 --time=00:30:00 seqkit stats -j 8 ../data/merged_pairs/*.flash.extendedFrags.fastq.gz > merged_stats.txt
echo "script end."