#!/bin/bash
#SBATCH --nodes 1 --ntasks 8 --mem 16G --out logs/antismash.%a.log -J antismash

module unload miniconda2
module unload miniconda3
module unload anaconda3
module load antismash/6.0.0
module load antismash/6.0.0
which perl
which antismash
hostname
CPU=1
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi
OUTDIR=annotate
SAMPFILE=samples.csv
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

INPUTFOLDER=update_results

IFS=,
tail -n +2 $SAMPFILE | sed -n ${N}p | while read SPECIES STRAIN VERSION PHYLUM BIOSAMPLE BIOPROJECT LOCUSTAG
do
  BASE=$(echo -n ${SPECIES}_${STRAIN}.${VERSION} | perl -p -e 's/\s+/_/g')
  name=$BASE
  STRAIN_NOSPACE=$(echo -n "$STRAIN" | perl -p -e 's/\s+/_/g')
  echo "$BASE"
  MASKED=$(realpath $INDIR/$BASE.masked.fasta)

  if [ ! -d $OUTDIR/$name ]; then
    echo "No annotation dir for ${name}"
    exit
  fi
  echo "processing $OUTDIR/$name"
  if [[ ! -d $OUTDIR/$name/antismash_local && ! -s $OUTDIR/$name/antismash_local/index.html ]]; then
	  GBK=$(ls $OUTDIR/$name/$INPUTFOLDER/*.gbk)
	  if [ -z $GBK ]; then
		GBK=$(ls $OUTDIR/$name/predict_results/*.gbk)
	  fi
	  if [ -z $GBK ]; then
		  echo "no genbank file for $OUTDIR/$name/predict_results or $OUTDIR/$name/$INPUTFOLDER"
		  exit
	  fi

    #	antismash --taxon fungi --output-dir $OUTDIR/$name/antismash_local  --genefinding-tool none \
      #    --asf --fullhmmer --cassis --clusterhmmer --asf --cb-general --pfam2go --cb-subclusters --cb-knownclusters -c $CPU \
      #    $OUTDIR/$name/$INPUTFOLDER/*.gbk
    time antismash --taxon fungi --output-dir $OUTDIR/$name/antismash_local \
      --genefinding-tool none --fullhmmer --clusterhmmer --cb-general  --cassis --asf --cb-subclusters --cb-knownclusters \
      --pfam2go -c $CPU $GBK
  fi
done
