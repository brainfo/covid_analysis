#!/bin/bash
module load seqkit
# echo "#reads by seqkit"
# date
# srun --cpus-per-task=8 --time=00:30:00 seqkit stats -j 8 -a ../data/sra_fastq/* -o fastq_stats_all.txt
# echo "stats in sql"
# date
# sqlite3 -batch /shared/projects/form_2022_19/pascal/central_database/sample_collab.db \
# "select run_accession, total_reads, read_count, base_count from sample_annot spl left join sample2bioinformatician s2b using(patient_code) where username='hong';" > stats_sql.txt
## echo "make fastq file names list"
## date
## ls ../data/sra_fastq/ > file_names.txt
# echo "dedup with seqkit"
# date
# for f in ../data/sra_fastq/*; do srun --cpus-per-task=8 --time=0:30:00 zcat $f | seqkit rmdup -s -i -j 8 -o dedup/clean.$f -D duplicated.$f.detail.txt; done
# echo "dedup with seqkit"
# date
# for f in ../data/sra_fastq/*; do srun --cpus-per-task=8 --time=0:30:00 zcat $f | seqkit rmdup -s -i -j 8 -o dedup/clean.${file##*/} -D duplicated.${file##*/}.detail.txt; done
echo "grep adapters with seqkit"
date
mkdir adapter
for f in ../data/sra_fastq/*_1.fastq.gz; do srun --cpus-per-task=8 --time=0:30:00 zcat $f | seqkit grep -s -i -p AGATCGGAAGAGCACACGTCTGAACTCCAGTCA| seqkit stats > adapter/${file##*/}_adapter_stat.txt; done
echo "script end."