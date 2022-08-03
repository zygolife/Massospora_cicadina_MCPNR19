#!/bin/bash -l
#-p batch,intel --time 60:00:00 -n 32 -N 1 --mem 96gb -out logs/mask_repeatMasker_report.%a.%A.log -a 2
#SBATCH -p short --time 2:00:00 --ntasks 128 --nodes 1 --mem 64G --out logs/mask_repeatMasker_report.%a.%A.log 

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
  CPU=$SLURM_CPUS_ON_NODE
fi
PA=$(expr $CPU / 4)

module load RepeatMasker
module load workspace/scratch

INDIR=$(realpath genomes)
OUTDIR=$(realpath repeatmasker_reports)
SAMPFILE=samples.csv
mkdir -p $OUTDIR

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
    
    if [ -f repeat_library/${name}.repeatmodeler-library.fasta ]; then
    	LIBRARY=$(realpath repeat_library/${name}.repeatmodeler-library.fasta)
    else 
	echo "no LIBRARY repeat_library/${name}.repeatmodeler-library.fasta previously created"
    fi
    
    mkdir -p $OUTDIR/${name}.RM
    if [ ! -f $OUTDIR/${name}.RM/${name}.sorted.fasta.tbl ]; then
	pushd $SCRATCH
	ln -s $INDIR/${name}.sorted.fasta
	RepeatMasker -s -pa $PA -excln -e rmblast -a -lcambig -source -poly -small -html -gff -dir $OUTDIR/${name}.RM -s -lib $LIBRARY ${name}.sorted.fasta > $OUTDIR/${name}.RM/${name}.RepeatMasker.out
    else
	echo "Skipping ${name} as masked already"
    fi
done
