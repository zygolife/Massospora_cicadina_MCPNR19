#!/bin/bash -l
#SBATCH --nodes 1 --ntasks 32 -p batch,intel --mem 128G --out logs/busco.%a.log  -a 1 -J busco

# for augustus training
#export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config
# set to a local dir to avoid permission issues and pollution in global
export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)

CPU=${SLURM_CPUS_ON_NODE}
if [ ! $CPU ]; then
     CPU=2
fi

module unload miniconda3 miniconda2 anaconda3
module load workspace/scratch
N=1
if [ ! -z $1 ]; then
	N=$1
elif [ ! -z ${SLURM_ARRAY_TASK_ID} ]; then
	N=${SLURM_ARRAY_TASK_ID}
fi

#change to your options
ASMDIR=data
COV=coverage
TAXFOLDER=taxonomy
BUSCO=busco
OUTPUT=blobtools
SAMPFILE=$ASMDIR/assembly_names.txt
LINEAGE=fungi_odb10
SEED_SPECIES=massospora_cicadina_rs
#file with PREFIX and then the assembly names if you have multiple assemblies
mkdir -p $OUTPUT/$BUSCO
module load busco/5.2.2
IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read PREFIX
do
	ASSEMBLY=""
	if [ -f ${ASMDIR}/$PREFIX.sourpurge.fasta ]; then
		ASSEMBLY=$(realpath ${ASMDIR}/$PREFIX.sourpurge.fasta)
		PREFIX=$PREFIX.sourpurge
	else
		ASSEMBLY=$(realpath ${ASMDIR}/$PREFIX.fasta)
	fi
	which busco
	busco -m genome -l $LINEAGE -c $CPU -o ${PREFIX} --out_path ${OUTPUT}/${BUSCO} --offline --augustus_species $SEED_SPECIES \
	  --in $ASSEMBLY --download_path $BUSCO_LINEAGES 
done
