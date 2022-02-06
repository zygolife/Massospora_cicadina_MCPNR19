#!/bin/bash
#SBATCH --nodes 1 --ntasks 8 --mem 16G -p short --out logs/busco_pep.%a.log -J buscopep
module load workspace/scratch

# for augustus training
#export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config
# set to a local dir to avoid permission issues and pollution in global
export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)

CPU=${SLURM_CPUS_ON_NODE}
N=${SLURM_ARRAY_TASK_ID}
if [ ! $CPU ]; then
     CPU=2
fi

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "Need an array id or cmdline val for the job"
        exit
    fi
fi
ANNOTFOLDER=annotate
LINEAGE=fungi_odb10
OUTFOLDER=BUSCO_pep
TEMP=$SCRATCH

mkdir -p $BUSCO
SAMPLEFILE=samples.csv
SEED_SPECIES=entomophthora_muscae_ucb
IFS=,
tail -n +2 $SAMPLEFILE | sed -n ${N}p | while read SPECIES STRAIN VERSION PHYLUM BIOSAMPLE BIOPROJECT LOCUSTAG
do
	BASE=$(echo -n ${SPECIES}_${STRAIN}.${VERSION} | perl -p -e 's/\s+/_/g')
	SPECIESSTRAIN=$(echo -n ${SPECIES}_${STRAIN} | perl -p -e 's/\s+/_/g')
	for type in predict update
	do
	    INPEP=$ANNOTFOLDER/${BASE}/${type}_results/${SPECIESSTRAIN}.proteins.fa
	    if [ ! -s $INPEP ]; then
		echo "No Proteins from prediction run yet"
		echo "missing $INPEP"
		continue
	    fi

	    if [ -d "$OUTFOLDER/${BASE}_${type}_proteins" ];  then
	    	echo "Already have run ${BASE}_proteins in folder busco - do you need to delete it to rerun?"
	    	continue
	    else
		module load busco/5.1.2
		busco -m prot -l $LINEAGE -c $CPU -o ${BASE}_${type}_proteins --out_path ${OUTFOLDER} --offline  \
		    --in $INPEP --download_path $BUSCO_LINEAGES
	    fi
	done
done
