#!/bin/bash
##
#SBATCH -p short -a 1
#SBATCH -o logs/01_diamond_search.%a.log
#SBATCH -e logs/01_diamond_search.%a.elog
#SBATCH --mem=192gb
#SBATCH --nodes=4 -C ryzen
#SBATCH --ntasks-per-node=12
#SBATCH --ntasks-per-core=1
#SBATCH --cpus-per-task=4
#SBATCH -J Masso_blob_diamond
#--ntasks-per-node=4

module unload miniconda3 miniconda2 anaconda3
module load workspace/scratch
module load diamond/2.0.13
#source activate blobtools-2
N=${SLURM_ARRAY_TASK_ID}
if [ ! -z $N ]; then
    N=$1
    if [ ! -z $N ]; then
	echo "No input N either by --array or cmdline"
	exit
    fi
fi
DB=/srv/projects/db/blobPlotDB/2021_04/reference_proteomes.dmnd
DB=/srv/projects/db/ncbi/swissprot/20220129/swissprot.dmnd
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
TMPDIR=/scratch
mkdir -p $OUTPUT/$TAXFOLDER
IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read PREFIX 
do 
	ASSEMBLY=$(realpath ${ASMDIR}/$PREFIX.sourpurge.fasta)
        PTMPDIR=tmp_$PREFIX

	export SLURM_HINT=multithread

	srun diamond blastx --multiprocessing \
	--query $ASSEMBLY \
	--outfmt 6 qseqid staxids bitscore qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore \
        --ultra-sensitive \
        --max-target-seqs 5  --mp-recover \
	--db $DB -c1 --tmpdir $TMPDIR \
	--evalue 1e-15 --parallel-tmpdir $PTMPDIR \
	--out $OUTPUT/$TAXFOLDER/$PREFIX.sp.diamond.tab

	#module unload miniconda2 miniconda3 anaconda3
	#module load blobtools/2.6.4
	#source activate blobtools-2

	#blobtools taxify -f $OUTPUT/$TAXFOLDER/$PREFIX.diamond.tab \
	#	-m $NAMES \
	#	-s 0 -t 2 -o $OUTPUT/$TAXFOLDER/

done
