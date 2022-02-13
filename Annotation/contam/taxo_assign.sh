#!/usr/bin/bash -l

#SBATCH -p short -C xeon -N 1 -n 64 --mem 400gb

module load MMseqs2
module load workspace/scratch
CPU=64
mmseqs easy-taxonomy --threads 64 --tax-lineage 1  --lca-ranks kingdom,phylum pseudo_hits.fa /srv/projects/db/ncbi/mmseqs/uniref90 pseudomonas_hits_all $SCRATCH
