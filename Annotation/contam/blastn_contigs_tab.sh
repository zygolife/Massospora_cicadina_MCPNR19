#!/usr/bin/bash -l
#SBATCH -p intel,batch -N 1 -n 8 --mem 64gb --out blastn.%A.log

module load ncbi-blast/2.9.0+
CPU=8

blastn -task dc-megablast -db /srv/projects/db/ncbi/preformatted/20220131/ref_prok_rep_genomes -query bacteria_candidate_contigs.fa -out bacteria_candidate_contigs.refprok.blastn.tab -evalue 1e-3 -num_threads $CPU  -outfmt 6
