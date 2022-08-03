#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 96 -C xeon --out mmseqs.uniref.%A.log --mem 384gb

module load MMseqs2
module load workspace/scratch

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
    CPU=1
fi
DB=/srv/projects/db/ncbi/mmseqs/uniref90
mmseqs easy-taxonomy ctg13800.prodigal.aa $DB ctg13800.prodigal $SCRATCH -s 7.5 --threads $CPU --tax-lineage 1 --lca-ranks superkingdom,phylum
