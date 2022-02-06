#!/bin/bash
#SBATCH -p intel,batch --time 2-0:00:00 --ntasks 8 --nodes 1 --mem 24G --out logs/mask.%a.log

CPU=1
if [ $SLURM_CPUS_ON_NODE ]; then
    CPU=$SLURM_CPUS_ON_NODE
fi

module load workspace/scratch

INDIR=$(realpath data)
OUTDIR=$(realpath data)
LOGS=$(realpath logs)
RL=$(realpath lib)
SAMPFILE=$INDIR/assembly_names.txt
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
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
tail -n +2 $SAMPFILE | sed -n ${N}p | while read PREFIX
do
  name=$PREFIX
  if [ ! -f $INDIR/${name}.vecscreen.fasta ]; then
     echo "Cannot find $name in $INDIR - may not have been run yet"
     exit
  fi
  echo "$name"
  
  if [ ! -f $OUTDIR/${name}.masked.fasta ]; then
     module unload perl python
     module unload miniconda2 anaconda3 miniconda3
     module load funannotate
     export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)
     LIBRARY=$RL/Massospora_cicadina_RS.v_flye.repeatmodeler-library.fasta

     if [ ! -z $LIBRARY ]; then
     	 echo "LIBRARY is $LIBRARY"
    	 funannotate mask --cpus $CPU -i $INDIR/${name}.vecscreen.fasta -o $OUTDIR/${name}.masked.fasta -l $LIBRARY --method repeatmodeler
     else
	     echo "no library to mask with ($LIBRARY)"
     fi
  else
     echo "Skipping ${name} as masked already"
  fi
done
