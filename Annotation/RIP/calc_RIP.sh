#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 2 --mem 64gb --out RIP_run.log
module load anaconda # need bioperl
perl RIP_index_calculation.pl  -i ../genomes/Massospora_cicadina_MCPNR19.v3.sorted.fasta -r bed -o Massospora_cicadina_MCPNR19.v3.RIP.bed
