#!/bin/bash
##
#SBATCH -p intel,batch
#SBATCH --out logs/02_nt_blastnarray.%a.log
#SBATCH --nodes=1 -a 1-246 -p short
#SBATCH -n 24 # Number of cores
#SBATCH --mem=128gb # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH -J Masblastn

module unload miniconda3 miniconda2 anaconda3
module load workspace/scratch
module load ncbi-blast/2.9.0+
N=1
if [ ! -z $1 ]; then
	N=$1
elif [ ! -z ${SLURM_ARRAY_TASK_ID} ]; then
	N=${SLURM_ARRAY_TASK_ID}
fi
DB=/srv/projects/db/NCBI/preformatted/20220121/nt
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
    CPU=1
fi

ID=1
#change to your options
ASMDIR=data
TAXFOLDER=taxonomy
OUTPUT=blobtools
SAMPFILE=$ASMDIR/assembly_names.txt
#file with PREFIX and then the assembly names if you have multiple assemblies
mkdir -p $OUTPUT/$TAXFOLDER
IFS=,
tail -n +2 $SAMPFILE | sed -n ${ID}p | while read PREFIX 
do 
	ASSEMBLY=$(realpath ${ASMDIR}/$PREFIX.split/$PREFIX.${N}.hardmask)
	if [ -z $ASSEMBLY ]; then
	    echo "No Split $N for split/$PREFIX.fasta.${N}"
	    exit
	fi
	# '6 qseqid staxids bitscore std'
	if [ ! -f $OUTPUT/$TAXFOLDER/$PREFIX.${N}.HM.blastn.finished ]; then
	    blastn \
		-query $ASSEMBLY \
		-db $DB \
		-outfmt '6 qseqid staxids bitscore std' \
		-max_target_seqs 10 \
		-max_hsps 1 -num_threads $CPU -db_hard_mask 30 \
		-evalue 1e-25 -out $OUTPUT/$TAXFOLDER/$PREFIX.nt.blastn.${N}.tab && touch $OUTPUT/$TAXFOLDER/$PREFIX.${N}.HM.blastn.finished
	fi
	
	#	blobtools taxify -f $OUTPUT/$TAXFOLDER/$PREFIX.diamond.tab \
	#		-m $NAMES \
	#		-s 0 -t 2 -o $OUTPUT/$TAXFOLDER/
	
done
