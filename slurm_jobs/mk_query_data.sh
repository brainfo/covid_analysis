#!/bin/bash

workdir="/shared/projects/form_2022_19/hong/sars2copath/analyses/blastn"
#dbdir="/shared/projects/form_2022_19/hong/sars2copath/data/blast_db"
fqdir="/shared/projects/form_2022_19/hong/sars2copath/data/merged_pairs/"
querydir="/shared/projects/form_2022_19/hong/sars2copath/data/query/"
resultdir="/shared/projects/form_2022_19/hong/sars2copath/data/blast_results/"
#accnum_file="/shared/projects/form_2022_19/myname/file_of_acc_nums.txt" ## comment when just small sampling trial

echo START: `date`

module load seqkit #as required

mkdir -p ${workdir}      # -p because it creates all required dir levels **and** doesn't throw an error if the dir exists :)
mkdir -p ${querydir}
mkdir -p ${resultdir}
cd ${workdir}

# this extracts the item number $SLURM_ARRAY_TASK_ID from the file of accnums
#accnum=$(sed -n "$SLURM_ARRAY_TASK_ID"p ${accnum_file})
#input_file="${datadir}/${accnum}.fastq"
#nt="${dbdir}/blast_db"
## ls files
inputs=(${fqdir}/*flash.extendedFrags.fastq.gz)
for input in ${inputs[@]}; do
filename=`basename ${input} | sed s/".fastq.gz"//`
##fq2fa
query_file=${querydir}${filename}.fa
zcat ${input} | seqkit fq2fa -j 1 -o ${query_file}
done