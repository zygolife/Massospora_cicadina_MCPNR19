#!/bin/bash
#SBATCH -p short --ntasks 8 --nodes 1 --mem 32G --out logs/vecscreen.%a.log

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

INDIR=data
OUTDIR=data
MINLEN=1000
ASMDIR=data
SAMPFILE=$ASMDIR/assembly_names.txt

N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=$(wc -l $SAMPFILE | awk '{print $1}')
if [ $N -gt $(expr $MAX) ]; then
    MAXSMALL=$(expr $MAX)
    echo "$N is too big, only $MAXSMALL lines in $SAMPFILE"
    exit
fi

#file with PREFIX and then the assembly names if you have multiple assemblies
IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read PREFIX
do
    if [ ! -f $INDIR/$PREFIX.fasta ]; then
	echo "Cannot find $name in $INDIR - may not have been run yet"
	exit
    fi
    
    if [ ! -f $OUTDIR/$PREFIX.vecscreen.fasta ]; then
	module load AAFTF
	if [ ! -f $OUTDIR/$PREFIX.vecscreen.fasta ]; then
	    AAFTF vecscreen -i $OUTDIR/${PREFIX}.fasta -o $OUTDIR/${PREFIX}.vecscreen.fasta --cpus $CPU
	fi
	#AAFTF sort -i $OUTDIR/${PREFIX}.vecscreen.fasta -o $OUTDIR/${PREFIX}.sorted.fasta --minlen $MINLEN
    fi
done
