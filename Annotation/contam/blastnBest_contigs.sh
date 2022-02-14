#!/usr/bin/bash -l
#SBATCH -p intel,batch -N 1 -n 12 --mem 64gb --out blastn.%A.log

module load ncbi-blast/2.9.0+
CPU=12

blastn -task dc-megablast -db /srv/projects/db/ncbi/preformatted/20220131/ref_prok_rep_genomes -query bacteria_candidate_contigs.likely.fa \
	-out bacteria_candidate_contigs.likely.refprok.blastn.tab -evalue 1e-5 -num_threads $CPU  -outfmt 6
