#!/usr/bin/bash
#SBATCH -p intel,batch
#SBATCH -o logs/04_blob.create.log
#SBATCH -e logs/04_blob.create.log
#SBATCH --nodes=1
#SBATCH --ntasks=16 # Number of cores
#SBATCH --mem=32G # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH -J Masso_blob2_create


module unload miniconda2
module load miniconda3

module load db-ncbi
module load db-uniprot

#activate blobtools2 environment
source activate btk_env

export PATH=$PATH:/rhome/cassande/bigdata/software/blobtoolkit/blobtools2

TAXFOLDER=taxonomy
COV=coverage
OUTPUT=blobtools
READDIR=input
ASMDIR=data

SAMPFILE=data/assembly_names.txt


#here we will just use the short reads, but could have used long-reads
TYPE=Short


IFS=
tail -n +2 $SAMPFILE | sed -n ${N}p | while read PREFIX
do
	
	ASSEMBLY=${ASMDIR}/$PREFIX.fasta
	BAM=${OUTPUT}/${COV}/$PREFIX.$TYPE.remap.bam
	PROTTAX=${OUTPUT}/${TAXFOLDER}/$PREFIX.diamond.tab.taxified.out
	BLASTTAX=${OUTPUT}/${TAXFOLDER}/$PREFIX.nt.blastn.tab.taxified.out
	
	#create blob
	blobtools create --fasta $ASSEMBLY --replace ${OUTPUT}/$PREFIX 

	blobtools add --cov $BAM --threads 16 --replace ${OUTPUT}/$PREFIX

	blobtools add --hits $PROTTAX --hits $BLASTTAX --taxrule bestsumorder --taxdump /rhome/cassande/bigdata/software/blobtoolkit/taxdump/ --replace ${OUTPUT}/$PREFIX
	

done





