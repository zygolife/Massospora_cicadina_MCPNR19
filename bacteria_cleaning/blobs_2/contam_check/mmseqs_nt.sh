#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 128 -C ryzen --out mmseqs.nt.%A.log --mem 512gb

module load MMseqs2
module load workspace/scratch

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
    CPU=1
fi
DB=/srv/projects/db/ncbi/mmseqs/nt
for file in $(ls *.fa)
do
	b=$(basename $file .fa)
	if [ ! -s $b.$(basename $DB)_tophit_report ]; then
	    mmseqs easy-taxonomy $file $DB $b.$(basename $DB) $SCRATCH --threads $CPU --tax-lineage 1 --lca-ranks superkingdom,phylum --search-type 2
	fi
	if [ ! -s $b.mask.$(basename $DB)_tophit_report ]; then
	    mmseqs easy-taxonomy $b.mask $DB $b.mask.$(basename $DB) $SCRATCH --threads $CPU --tax-lineage 1 --lca-ranks superkingdom,phylum 
	fi
done
