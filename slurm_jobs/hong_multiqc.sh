#!/bin/bash

module load multiqc
echo "qc"
date
srun multiqc --force --title "hong sample sub-set" ../data/merged_pairs/ ./fastqc/ logs/ bowtie/