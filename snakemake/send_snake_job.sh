#!/bin/bash
#SBATCH --partition=fast             # long, fast, etc.
#SBATCH --ntasks=1                   # nb of *tasks* to be run in // (usually 1), this task can be multithreaded (see cpus-per-task)
#SBATCH --nodes=1                    # nb of nodes to reserve for each task (usually 1)
#SBATCH --cpus-per-task=4            # nb of cpu (in fact cores) to reserve for each task /!\ job killed if commands below use more cores
#SBATCH --mem=80G                  # amount of RAM to reserve for the tasks /!\ job killed if commands below use more RAM
#SBATCH --time=0-010:00               # maximal wall clock duration (D-HH:MM) /!\ job killed if commands below take more time than reservation
#SBATCH -o /shared/projects/form_2022_19/hong/sars2copath/snakemake/logs/snakemake.%A.%a.out   # standard output (STDOUT) redirected to these files (with Job ID and array ID in file names)
#SBATCH -e /shared/projects/form_2022_19/hong/sars2copath/snakemake/logs/snakemake.%A.%a.err  # standard error  (STDERR) redirected to these files (with Job ID and array ID in file names)
#/!\ Note that the ./outputs/ dir above needs to exist in the dir where script is submitted **prior** to submitting this script
##SBATCH --array=1-8                # 1-N: clone this script in an array of N tasks: $SLURM_ARRAY_TASK_ID will take the value of 1,2,...,N
#SBATCH --job-name=snakemake_test_multi_shell_hong        # name of the task as displayed in squeue & sacc, also encouraged as srun optional parameter
#SBATCH --mail-type END              # when to send an email notiification (END = when the whole sbatch array is finished)
#SBATCH --mail-user scilavisher@gmail.com
module load snakemake fastqc flash2 kraken2 bracken r
conda init bash
source /shared/home/hong/.bashrc
conda activate snakemake_hong
snakemake -s Snakefile -j 8 --cluster-config cluster.yaml --cluster "sbatch -t {cluster.time} -p {cluster.partition} -n {cluster.n} --mem {cluster.mem} --cpus-per-task {cluster.cpu}"