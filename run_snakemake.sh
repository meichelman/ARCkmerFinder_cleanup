#!/usr/bin/bash -l


#SBATCH --time=24:00:00
#SBATCH --mem=5g
#SBATCH --cpus-per-task=1

source /projects/standard/hsiehph/shared/bin/initialize_conda.sh
conda activate snakemake


snakemake --jobname "{rulename}.{jobid}" --profile profile --latency-wait 60 --printshellcmds --keep-going
