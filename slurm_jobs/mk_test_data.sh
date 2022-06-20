#!/bin/bash

module load seqkit
in_file=/shared/projects/form_2022_19/hong/sars2copath/data/merged_pairs/ERR6913147.flash.extendedFrags.fastq.gz
fa_file=/shared/projects/form_2022_19/hong/sars2copath/data/blast_db/testquerydata/ERR6913147.flash.extendedFrags.fa.gz
sample_file=/shared/projects/form_2022_19/hong/sars2copath/data/blast_db/testquerydata/ERR6913147.flash.extendedFrags
##fq2fa
#zcat ${in_file} | seqkit fq2fa -j 1 -o ${fa_file}
allns=(10 100 1000)
for n in ${allns[@]}; do
zcat ${fa_file} | seqkit range -r 1:${n} -o ${sample_file}.${n}.fa
done