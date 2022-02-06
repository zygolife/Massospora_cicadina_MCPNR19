#!/usr/bin/bash
#SBATCH -p short -N 1 -n 2 --mem 64gb --out logs/make_blobtools.log

module load blobtools/2
# $BLOBTAX from module blobtools/2
CPU=${SLURM_CPUS_ON_NODE}
if [ ! $CPU ]; then
  CPU=2
fi

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
TAXID=348617
#file with PREFIX and then the assembly names if you have multiple assemblies
mkdir -p $OUTPUT/$BUSCO
module load busco/5.2.2
IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read PREFIX
do
  ASSEMBLY=$(realpath ${ASMDIR}/$PREFIX.sourpurge.fasta)
  META=$(realpath ${ASMDIR}/$PREFIX.yaml)
  TARGET=$OUTPUT/$PREFIX.blobDB

  if [ ! -f $TARGET/gc.json ]; then
    blobtools create \
      --fasta $ASSEMBLY \
      --meta $META \
      --taxid $TAXID \
      --taxdump $BLOBTAX \
      $TARGET
  fi
  blobtools add \
    --hits $OUTPUT/$TAXONOMY/$PREFIX.diamond.sprot.blastx.out \
    --taxrule bestsumorder \
    --taxdump $BLOBTAX \
    $TARGET

  blobtools add \
    --busco $OUTPUT/$BUSCO/$PREFIX/run_$LINEAGE/full_table.tsv \
    $TARGET

  blobtools add \
    --cov $OUTPUT/$PREFIX.ONT.sort.bam=ONT \
    --cov $OUTPUT/$PREFIX.Illumina.sort.bam=Ill \
    --threads $CPU \
    $TARGET
done
