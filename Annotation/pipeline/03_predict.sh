#!/bin/bash
#SBATCH -p intel,batch --time 3-0:00:00 --ntasks 24 --nodes 1 --mem 96G --out logs/predict.%a.log

module unload miniconda2 miniconda3 anaconda3
module unload perl
module unload python
module load funannotate
module load workspace/scratch
#conda deactivate
#conda activate funannot_test_p2g
which funannotate
#which diamond
diamond version
CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi
ulimit -Sn
ulimit -Hn
ulimit -n 30000

#BUSCO=mucoromycota_odb10
#fungi_odb10 # This could be changed to the core BUSCO set you want to use
BUSCO=fungi_odb10
INDIR=$(realpath genomes)
OUTDIR=$(realpath annotate)
PREDS=$(realpath prediction_support)
mkdir -p $OUTDIR
SAMPFILE=samples.csv
INFORMANT=$(realpath lib/informant_proteins.aa)
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=`wc -l $SAMPFILE | awk '{print $1}'`

if [ $N -gt $MAX ]; then
    echo "$N is too big, only $MAX lines in $SAMPFILE"
    exit
fi

export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)

export FUNANNOTATE_DB=/bigdata/stajichlab/shared/lib/funannotate_db
SEED_SPECIES=massospora_cicadina_rs

IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read SPECIES STRAIN VERSION PHYLUM BIOSAMPLE BIOPROJECT LOCUSTAG
do
    SEQCENTER=UCR
    BASE=$(echo -n ${SPECIES}_${STRAIN}.${VERSION} | perl -p -e 's/\s+/_/g')
    echo "sample is $BASE"
    MASKED=$(realpath $INDIR/$BASE.masked.fasta)
    echo "Maskedis $MASKED"
    augname=$(echo -n ${SPECIES}_${STRAIN} | perl -p -e '$_=lc($_)')
    if [ -d $AUGUSTUS_CONFIG_PATH/species/$augname ]; then
	    SEED_SPECIES=$augname
    fi
    echo "SEED species is $SEED_SPECIES"
    if [ ! -f $MASKED ]; then
      echo "Cannot find $BASE.masked.fasta in $INDIR - may not have been run yet"
      exit
    fi

    if [[ -f $PREDS/$BASE.genemark.gtf ]]; then
	funannotate predict --cpus $CPU --keep_no_stops --SeqCenter $SEQCENTER --busco_db $BUSCO --optimize_augustus \
        --strain $STRAIN --min_training_models 100 --AUGUSTUS_CONFIG_PATH $AUGUSTUS_CONFIG_PATH \
        -i $MASKED --name $LOCUSTAG --protein_evidence $INFORMANT \
        -s "$SPECIES"  -o $OUTDIR/$BASE --busco_seed_species $SEED_SPECIES --tmpdir $SCRATCH --genemark_gtf $PREDS/$BASE.genemark.gtf
    else
	funannotate predict --cpus $CPU --keep_no_stops --SeqCenter $SEQCENTER --busco_db $BUSCO --optimize_augustus \
	--strain $STRAIN --min_training_models 100 --AUGUSTUS_CONFIG_PATH $AUGUSTUS_CONFIG_PATH \
	-i $MASKED --name $LOCUSTAG --protein_evidence $INFORMANT \
	-s "$SPECIES"  -o $OUTDIR/$BASE --busco_seed_species $SEED_SPECIES --tmpdir $SCRATCH
    fi
done
