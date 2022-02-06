#!/usr/bin/bash -l

#SBATCH -p short -N 1 -n 96 --mem 96gb -C xeon --out logs/minimap2_ONT.%a.log -a 1

module load minimap2/2.24
module load samtools
module load workspace/scratch
N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
	echo "No input N either by --array or cmdline"
	exit
    fi
fi

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
    CPU=1
fi

FASTQ=data/5FC.guppy6_0_1.fastq.gz
ASMDIR=data
OUTPUT=blobtools
SAMPFILE=$ASMDIR/assembly_names.txt
IFS=,
echo "SAMPFILE $SAMPFILE and N is $N"
tail -n +2 $SAMPFILE | sed -n ${N}p | while read PREFIX
do
	GENOME=data/$PREFIX.sourpurge.fasta
	if [ ! -f $GENOME ]; then
                GENOME=data/$PREFIX.sorted.fasta
        fi
	if [ ! -f $GENOME ]; then
		GENOME=data/$PREFIX.fasta
	fi
	RESULT=$OUTPUT/$PREFIX.ONT.sort.bam
	echo "testing to run minimap $RESULT from $GENOME and $FASTQ"
	echo "using $PREFIX $GENOME and creating $RESULT"
	if [ ! -f $RESULT ]; then
		minimap2 -t $CPU -ax map-ont $GENOME $FASTQ > $SCRATCH/Masso.minimap2.sam
		samtools sort -O bam -o $RESULT --threads $CPU $SCRATCH/Masso.minimap2.sam
		samtools index $RESULT
	fi
done
