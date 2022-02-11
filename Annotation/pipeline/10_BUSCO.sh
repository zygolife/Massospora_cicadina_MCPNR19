#!/bin/bash
#SBATCH --nodes 1 --ntasks 8 --mem 16G -p short --out logs/busco.%a.log -J busco

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
if [ -z ${SLURM_ARRAY_JOB_ID} ]; then
	SLURM_ARRAY_JOB_ID=$$
fi
GENOMEFOLDER=genomes
EXT=sorted.fasta
LINEAGE=fungi_odb10
OUTFOLDER=BUSCO
TEMP=/scratch/${SLURM_ARRAY_JOB_ID}_${N}
mkdir -p $TEMP $BUSCO
SAMPLEFILE=samples.csv
SEED_SPECIES=massospora_cicadina_rs
IFS=,
tail -n +2 $SAMPLEFILE | sed -n ${N}p | while read SPECIES STRAIN VERSION PHYLUM BIOSAMPLE BIOPROJECT LOCUSTAG
do
	BASE=$(echo -n ${SPECIES}_${STRAIN}.${VERSION} | perl -p -e 's/\s+/_/g')
	echo "BASE is $BASE"
	GENOMEFILE=$(realpath $GENOMEFOLDER/$BASE.$EXT)
	
	if [ -d "$OUTFOLDER/${BASE}" ];  then
	    echo "Already have run $NAME in folder busco - do you need to delete it to rerun?"
	    exit
	else
	    module load busco/5.1.2
	    busco -m genome -l $LINEAGE -c $CPU -o ${BASE} --out_path ${OUTFOLDER} --offline --augustus_species $SEED_SPECIES \
	  --in $GENOMEFILE --download_path $BUSCO_LINEAGES
	fi
	#    run_BUSCO.py -i $GENOMEFILE -l $LINEAGE -o $NAME -m geno --cpu $CPU --tmp $TEMP --long -sp $SEED_SPECIES
	#    popd
	#fi
done
rm -rf $TEMP
