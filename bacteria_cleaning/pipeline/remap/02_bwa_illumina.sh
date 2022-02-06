#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 128 -C ryzen --mem 256gb --out logs/bwa_mem_map.%a.log -a 1-2

module load bwa-mem2
module load samtools
module load workspace/scratch

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
    CPU=1
fi

N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
	echo "No input N either by --array or cmdline"
	exit
    fi
fi

ASMDIR=data
OUTPUT=blobtools
FWD=data/Massospora_2019-06_R1.fq.gz
REV=data/Massospora_2019-06_R2.fq.gz

SAMPFILE=$ASMDIR/assembly_names.txt
IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read PREFIX
do
	GENOME=data/$PREFIX.sourpurge.fasta
	if [ ! -f $GENOME ]; then
                GENOME=data/$PREFIX.sorted.fasta
        fi

	if [ ! -f $GENOME ]; then
		GENOME=data/$PREFIX.fasta
	fi

	if [ ! -f $GENOME.bwt.2bit.64 ]; then
		bwa-mem2 index $GENOME
	fi
	RESULT=$OUTPUT/$PREFIX.Illumina.sort.bam
	if [ ! -f $RESULT ]; then
		bwa-mem2 mem -t $CPU $GENOME $FWD $REV > $SCRATCH/Masso.bwa2.sam

		samtools sort -O bam --threads $CPU -o $RESULT $SCRATCH/Masso.bwa2.sam
		samtools index $RESULT
	fi
done
