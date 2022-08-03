#!/bin/bash
#SBATCH -p short --time 2:00:00 --ntasks 16 --nodes 1 --mem 32G --out logs/mask_tantan.%a.log

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

module load workspace/scratch

INDIR=$(realpath genomes)
OUTDIR=$(realpath genomes)
LOGS=$(realpath logs)

SAMPFILE=samples.csv
N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi
MAX=$(wc -l $SAMPFILE | awk '{print $1}')
if [ $N -gt $(expr $MAX) ]; then
    MAXSMALL=$(expr $MAX)
    echo "$N is too big, only $MAXSMALL lines in $SAMPFILE"
    exit
fi

IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read SPECIES STRAIN VERSION PHYLUM BIOPROJECT BIOSAMPLE LOCUS
do
  name=$(echo -n ${SPECIES}_${STRAIN}.${VERSION} | perl -p -e 's/\s+/_/g')
  if [ ! -f $INDIR/${name}.sorted.fasta ]; then
     echo "Cannot find $name in $INDIR - may not have been run yet"
     exit
  fi
  echo "$name"
  
  if [ ! -f $OUTDIR/${name}.masked_tantan.fasta ]; then
     module unload perl python
     module unload miniconda2 anaconda3 miniconda3
     module load funannotate

     funannotate mask --cpus $CPU -i $INDIR/${name}.sorted.fasta -o $OUTDIR/${name}.masked_tantan.fasta --method tantan
  else
     echo "Skipping ${name} as masked already"
  fi
done
