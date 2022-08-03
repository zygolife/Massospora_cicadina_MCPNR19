#!/bin/bash
##
#SBATCH -p intel,batch
#SBATCH -o logs/01_diamond.%a.log
#SBATCH -e logs/01_diamond.%a.log
#SBATCH --nodes=1 -a 1
#SBATCH --ntasks=32 # Number of cores
#SBATCH --mem=96G # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH -J Masso_blob_diamond

module unload miniconda3 miniconda2 anaconda3
module load workspace/scratch
module load diamond/2.0.13
module load blobtools/2.6.4
source activate blobtools-2
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
SAMPFILE=$ASMDIR/assembly_names.txt
#file with PREFIX and then the assembly names if you have multiple assemblies
mkdir -p $OUTPUT/$TAXFOLDER
IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read PREFIX 
do 
	ASSEMBLY=$(realpath ${ASMDIR}/$PREFIX.fasta)
# '6 qseqid staxids bitscore std'
	diamond blastx \
	--query $ASSEMBLY \
	--db $DB -c1 --tmpdir $SCRATCH \
	--outfmt 6 --sensitive \
	--max-target-seqs 10 \
	--evalue 1e-25 --threads $CPU \
	--out $OUTPUT/$TAXFOLDER/$PREFIX.diamond.tab

	blobtools taxify -f $OUTPUT/$TAXFOLDER/$PREFIX.diamond.tab \
		-m $NAMES \
		-s 0 -t 2 -o $OUTPUT/$TAXFOLDER/

done
