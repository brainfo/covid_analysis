#!/bin/bash
#
#SBATCH --partition=fast             # long, fast, etc.
#SBATCH --ntasks=1                   # nb of *tasks* to be run in // (usually 1), this task can be multithreaded (see cpus-per-task)
#SBATCH --nodes=1                    # nb of nodes to reserve for each task (usually 1)
#SBATCH --cpus-per-task=1            # nb of cpu (in fact cores) to reserve for each task /!\ job killed if commands below use more cores
#SBATCH --mem=80GB                  # amount of RAM to reserve for the tasks /!\ job killed if commands below use more RAM
#SBATCH --time=0-00:15               # maximal wall clock duration (D-HH:MM) /!\ job killed if commands below take more time than reservation
#SBATCH -o ../analyses/kraken2/logs/blastn.%A.%a.out   # standard output (STDOUT) redirected to these files (with Job ID and array ID in file names)
#SBATCH -e ../analyses/kraken2/logs/blastn.%A.%a.err  # standard error  (STDERR) redirected to these files (with Job ID and array ID in file names)
##/!\ Note that the ./outputs/ dir above needs to exist in the dir where script is submitted **prior** to submitting this script
##SBATCH --array=1-100                # 1-N: clone this script in an array of N tasks: $SLURM_ARRAY_TASK_ID will take the value of 1,2,...,N
#SBATCH --job-name=kraken_single        # name of the task as displayed in squeue & sacc, also encouraged as srun optional parameter
#SBATCH --mail-type END              # when to send an email notiification (END = when the whole sbatch array is finished)
#SBATCH --mail-user scilavisher@gmail.com

#################################################################
# Preparing work (cd to working dir, get hold of input data, convert/un-compress input data when needed etc.)
workdir="/shared/projects/form_2022_19/hong/sars2copath/"
db="/shared/projects/form_2022_19/kraken2/arch_bact_vir_hum_protoz_fung"
datadir="${workdir}data/sra_fastq/"
outdir="${workdir}data/kraken_results/"
#accnum_file="/shared/projects/form_2022_19/myname/file_of_acc_nums.txt" ## comment when just small sampling trial

echo START: `date`

module load kraken2 #as required

mkdir -p ${workdir}      # -p because it creates all required dir levels **and** doesn't throw an error if the dir exists :)
cd ${workdir}

# this extracts the item number $SLURM_ARRAY_TASK_ID from the file of accnums
#accnum=$(sed -n "$SLURM_ARRAY_TASK_ID"p ${accnum_file})
#input_file="${datadir}/${accnum}.fastq"
acc_num="ERR6913147"
query_fa="${datadir}${acc_num}_1.fastq.gz ${datadir}${acc_num}_2.fastq.gz"
# alternatively, just extract the input file as the item number $SLURM_ARRAY_TASK_ID in the data dir listing
# this alternative is less handy since we don't get hold of the isolated "accnum", which is very handy to name the srun step below :)
# input_file=$(ls "${datadir}/*.fastq.gz" | sed -n ${SLURM_ARRAY_TASK_ID}p)

# if the command below can't cope with compressed input
# srun gunzip "${input_file}.gz"

# because there are mutliple jobs running in // each output file needs to be made unique by post-fixing with $SLURM_ARRAY_TASK_ID and/or $accnum
# *use basename*
output_file="${outdir}/kraken_${acc_num}_results.tab"
report_file="${outdir}/kraken_${acc_num}_reports.tab"
#################################################################
# Start work
srun --job-name=${acc_num} kraken2 --threads ${SLURM_CPUS_PER_TASK} --gzip-compressed --paired --db ${db} ${query_fa} --output ${output_file} --report ${report_file}
#################################################################
# Clean up (eg delete temp files, compress output, recompress input etc)
# srun gzip ${input_file}
# srun gzip ${output_file}
echo END: `date`