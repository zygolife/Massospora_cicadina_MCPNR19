#!/bin/bash
##
#SBATCH -p short -a 1
#SBATCH -o logs/01_diamond_search.2.%a.log
#SBATCH -e logs/01_diamond_search.2.%a.elog
#SBATCH --mem=192gb
#SBATCH --nodes=1 -C ryzen -n 96
#SBATCH -J Masso_blob_diamond
#--ntasks-per-node=4

module unload miniconda3 miniconda2 anaconda3
module load workspace/scratch
module load diamond/2.0.13
#source activate blobtools-2
N=1
if [ ! -z $1 ]; then
	N=$1
elif [ ! -z ${SLURM_ARRAY_TASK_ID} ]; then
	N=${SLURM_ARRAY_TASK_ID}
fi
DB=/srv/projects/db/blobPlotDB/2021_04/reference_proteomes.dmnd
NAMES=$(echo -n $DB | perl -p -e 's/.dmnd/.taxid_map/')
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
    CPU=1
fi

#change to your options
ASMDIR=data
COV=coverage
TAXFOLDER=taxonomy
OUTPUT=blobtools
#file with PREFIX and then the assembly names if you have multiple assemblies
TMPDIR=/scratch
mkdir -p $OUTPUT/$TAXFOLDER
PREFIX=Bacteria
ASSEMBLY=Bacteria/contam_sourpurge.fa
PTMPDIR=tmp_$PREFIX

	export SLURM_HINT=multithread

	diamond blastx \
        --query $ASSEMBLY \
        --db $DB -c1 --tmpdir $SCRATCH \
        --outfmt 6 --sensitive \
        --max-target-seqs 10 \
        --evalue 1e-25 --threads $CPU \
        --out $OUTPUT/$TAXFOLDER/$PREFIX.2.diamond.tab


	module load blobtools/2.6.4
	blobtools taxify -f $OUTPUT/$TAXFOLDER/$PREFIX.diamond.tab \
		-m $NAMES \
		-s 0 -t 2 -o $OUTPUT/$TAXFOLDER/$PREFIX.2.diamond.names.txt

