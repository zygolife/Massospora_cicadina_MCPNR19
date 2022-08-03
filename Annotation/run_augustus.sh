#!/usr/bin/bash -l
#SBATCH -p short -n 1 --mem 1gb -p short --out logs/augutus_2.%a.log

module load augustus/3.3.3
export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/projects/ZyGoLife/Massospora/Massospora_cicadina_Nanopore/Annotation/annotate/Massospora_cicadina_MCPNR19.v2/predict_misc/ab_initio_parameters/augustus/species/

N=${SLURM_ARRAY_TASK_ID}
if [ -z $N ]; then
    N=$1
    if [ -z $N ]; then
	echo "need an input number"
	exit
    fi
fi
N=$(expr $N + 2000)
echo "N is $N"
CFG=extrinsic.E.XNT.RM.cfg
HINTS=hints.ALL.gff
PREF=masso
INDIR=split_augustus
OUTDIR=out_augustus
CONFIGDIR=augustus_cfg_dir
mkdir -p $OUTDIR
OUT=$OUTDIR/$PREF.$N.out
if [ ! -s $OUT ]; then
	augustus --species=massospora_cicadina_mcpnr19 --extrinsicCfgFile=$CFG --hintsfile=$HINTS --AUGUSTUS_CONFIG_PATH=$CONFIGDIR  --softmasking=1 --gff3=on --UTR=off --stopCodonExcludedFromCDS=False $INDIR/$PREF.$N > $OUT
fi
