#!/bin/bash

echo "fastqc"
module load fastqc
date
mkdir fastqc
srun --cpus-per-task=8 --time=00:10:00 xargs -I{} -a hong_run_accessions.txt fastqc --outdir ./fastqc/ \
--threads 8 --noextract ../data/sra_fastq/{}_1.fastq.gz ../data/sra_fastq/{}_2.fastq.gz
echo "script end."