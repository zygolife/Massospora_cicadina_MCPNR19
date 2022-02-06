#!/usr/bin/bash
#SBATCH -p intel -N 1 -n 2 --mem 4gb
#SBATCH -J Masso_download

module load aspera

KEY=/rhome/cassande/private.openssh.pub

#download reads from NCBI
/bigdata/stajichlab/shared/bin/sra_download.pl --ascp --id $ASPERAKEY download.txt


