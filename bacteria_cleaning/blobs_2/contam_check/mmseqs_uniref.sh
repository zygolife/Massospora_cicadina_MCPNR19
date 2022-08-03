#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 128 -C ryzen --out mmseqs.uniref.%A.log --mem 384gb

module load MMseqs2
module load workspace/scratch

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
    CPU=1
fi
DB=/srv/projects/db/ncbi/mmseqs/uniref50
for file in $(ls *.fa)
do
	b=$(basename $file .fa)
	if [ ! -s $b.$(basename $DB)_tophit_report ]; then
	    mmseqs easy-taxonomy $file $DB $b.$(basename $DB) $SCRATCH --threads $CPU --tax-lineage 1 --lca-ranks superkingdom,phylum -s 7.5 
	fi
	if [ ! -s $b.mask.$(basename $DB)_tophit_report ]; then
	    mmseqs easy-taxonomy $b.mask $DB $b.mask.$(basename $DB) $SCRATCH --threads $CPU --tax-lineage 1 --lca-ranks superkingdom,phylum -s 7.5 
	fi
done
