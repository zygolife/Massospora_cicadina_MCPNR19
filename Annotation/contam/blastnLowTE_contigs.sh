#!/usr/bin/bash -l
#SBATCH -p intel,batch -N 1 -n 12 --mem 64gb --out blastn.%A.log

module load ncbi-blast/2.9.0+
CPU=12

blastn -task dc-megablast -db /srv/projects/db/ncbi/preformatted/20220131/ref_prok_rep_genomes -query low_TE_contigs.fa \
	-out low_TE_contigs.refprok.blastn.tab -evalue 1e-20 -num_threads $CPU  -outfmt 6 -max_target_seqs 5
