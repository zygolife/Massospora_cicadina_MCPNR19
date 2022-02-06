#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 4 --mem 128gb --out logs/bwa_index.log

module load bwa-mem2
module load workspace/scratch
N=${SLURM_ARRAY_TASK_ID}
if [ ! -z $N ]; then
    N=$1
    if [ ! -z $N ]; then
	echo "No input N either by --array or cmdline"
	exit
    fi
fi

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
    CPU=1
fi

ASMDIR=data
SAMPFILE=$ASMDIR/assembly_names.txt
IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read PREFIX
do
	GENOME=data/$PREFIX.sourpurge.fasta
  bwa-mem2 index $GENOME
done
