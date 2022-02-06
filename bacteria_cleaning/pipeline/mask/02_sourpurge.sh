#!/bin/bash
#SBATCH -p short --ntasks 8 --nodes 1 --mem 32G --out logs/sourpurge.%a.log -a 1


CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

INDIR=data
OUTDIR=data
MINLEN=1000
ASMDIR=data
SAMPFILE=$ASMDIR/assembly_names.txt
module load workspace/scratch
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
LEFT=data/Massospora_2019-06_R1.fq.gz
RIGHT=Massospora_2019-06_R2.fq.gz
PHYLUM=Zoopagomycota
#file with PREFIX and then the assembly names if you have multiple assemblies
IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read PREFIX
do
    if [ ! -f $OUTDIR/$PREFIX.sourpurge.fasta ]; then
	module load AAFTF
	AAFTF sourpurge -i $OUTDIR/${PREFIX}.masked.fasta -o $OUTDIR/${PREFIX}.sourpurge.fasta \
		--cpus $CPU --phylum $PHYLUM --tmpdir $SCRATCH
	#--left $LEFT  --right $RIGHT 
    fi
    #AAFTF sort -i $OUTDIR/${PREFIX}.vecscreen.fasta -o $OUTDIR/${PREFIX}.sorted.fasta --minlen $MINLEN
    
done
