#!/bin/bash

## assignment 10.1-10.2
echo "script start: make data directory"
date
mkdir ../data/sra_fastq
echo "2. get acession"
date
sqlite3 -batch -noheader -csv /shared/projects/form_2022_19/pascal/central_database/sample_collab.db \
"select run_accession from sample_annot spl left join sample2bioinformatician s2b using(patient_code) where username='hong';" > hong_run_accessions.txt
echo "3. download sra file with sra-tools"
date
module load sra-tools
srun --cpus-per-task=8 --time=00:30:00 xargs -a hong_run_accessions.txt fastq-dump --readids --gzip \
--outdir ../data/sra_fastq/ --disable-multithreading --split-e
echo "4. count reads, the following numbers divided by 4"
date
wc -l ../data/sra_fastq/* > line_counts.txt
echo "5. quality scores encoding using python script"
date
echo "unzip example file"
gunzip ../data/sra_fastq/ERR6913253_1.fastq.gz
echo "check encoding"
module load python
python ../scripts/hong_encoding.py ../data/sra_fastq/ERR6913253_1.fastq
echo "gzip example file"
gzip ../data/sra_fastq/ERR6913253_1.fastq

## assignment 10.3
module load seqkit
echo "#reads by seqkit"
date
srun --cpus-per-task=8 --time=00:30:00 seqkit stats -j 8 -a ../data/sra_fastq/* -o fastq_stats_all.txt
echo "stats in sql"
date
sqlite3 -batch /shared/projects/form_2022_19/pascal/central_database/sample_collab.db \
"select run_accession, total_reads, read_count, base_count from sample_annot spl left join sample2bioinformatician s2b using(patient_code) where username='hong';" > stats_sql.txt
# echo "make fastq file names list"
# date
# ls ../data/sra_fastq/ > file_names.txt
echo "dedup with seqkit"
date
for f in ../data/sra_fastq/*; do srun --cpus-per-task=8 --time=0:30:00 zcat $f | seqkit rmdup -s -i -j 8 -o dedup/clean.$f -D duplicated.$f.detail.txt; done
echo "dedup with seqkit"
date
for f in ../data/sra_fastq/*; do srun --cpus-per-task=8 --time=0:30:00 zcat $f | seqkit rmdup -s -i -j 8 -o dedup/clean.${file##*/} -D duplicated.${file##*/}.detail.txt; done
echo "grep adapters with seqkit"
date
mkdir adapter
for f in ../data/sra_fastq/*_1.fastq.gz; do srun --cpus-per-task=8 --time=0:30:00 zcat $f | seqkit grep -s -i -p AGATCGGAAGAGCACACGTCTGAACTCCAGTCA| seqkit stats > adapter/${file##*/}_adapter_stat.txt; done

## assignment 10.4
echo "fastqc"
module load fastqc
date
mkdir fastqc
srun --cpus-per-task=8 --time=00:10:00 xargs -I{} -a hong_run_accessions.txt fastqc --outdir ./fastqc/ \
--threads 8 --noextract ../data/sra_fastq/{}_1.fastq.gz ../data/sra_fastq/{}_2.fastq.gz

## assignment 10.7
echo "merge paird fastqs"
module load flash2
mkdir ../data/merged_pairs
mkdir logs
date
srun --cpus-per-task=8 --time=00:30:00 xargs -a hong_run_accessions.txt -n 1 -I{} flash2 --threads=8 -z \
--output-directory=../data/merged_pairs/ --output-prefix={}.flash ../data/sra_fastq/{}_1.fastq.gz ../data/sra_fastq/{}_2.fastq.gz 2>&1 | tee logs/{}_fash2_merge.log
echo "check stats"
date
srun --cpus-per-task=8 --time=00:30:00 seqkit stats -j 8 ../data/merged_pairs/*.flash.extendedFrags.fastq.gz > merged_stats.txt

## assignment 10.8
mkdir ../data/reference_seqs
efetch -db nuccore -id NC_001422 -format fasta > ../data/reference_seqs/PhiX_NC_001422.fna

mkdir ../data/bowtie2_DBs
srun bowtie2-build -f ../data/reference_seqs/PhiX_NC_001422.fna ../data/bowtie2_DBs/PhiX_bowtie2_DB

mkdir bowtie
srun --cpus-per-task=8 bowtie2 -x ../data/bowtie2_DBs/PhiX_bowtie2_DB -U ../data/merged_pairs/ERR*.extendedFrags.fastq.gz \
 -S bowtie/hong_merged2PhiX.sam --threads 8 --no-unal 2>&1 | tee logs/hong_bowtie_merged2PhiX.log

efetch -db nuccore -id NC_045512 -format fasta > ../data/reference_seqs/SC2_NC_045512.fna
srun bowtie2-build -f ../data/reference_seqs/SC2_NC_045512.fna ../data/bowtie2_DBs/SC2_bowtie2_DB
srun --cpus-per-task=8 bowtie2 -x ../data/bowtie2_DBs/SC2_bowtie2_DB -U ../data/merged_pairs/ERR*.extendedFrags.fastq.gz \
 -S bowtie/hong_merged2SC2.sam --threads 8 --no-unal 2>&1 | tee logs/hong_bowtie_merged2SC2.log

 ## assignment 10.9
 module load multiqc
echo "qc"
date
srun multiqc --force --title "hong sample sub-set" ../data/merged_pairs/ ./fastqc/ logs/ bowtie/
echo "script end."