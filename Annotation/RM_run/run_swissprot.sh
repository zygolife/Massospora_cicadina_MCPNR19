#!/usr/bin/bash -l
#SBATCH -p short -C xeon -N 1 -n 16 --mem 128gb --out sprot.%A.log

module load diamond
CPU=16
DB=/srv/projects/db/Swissprot/2021_01/uniprot_sprot.dmnd
diamond blastx -p $CPU --db $DB --query Massospora_cicadina_MCPNR19.v2-families.fa -f 6 -o Massospora_cicadina_MCPNR19.v2-families.swprot.tab
