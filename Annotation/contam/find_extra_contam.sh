#!/usr/bin/bash -l
grep Bacteria pseudomonas_hits_all_lca.tsv | cut -f1 | sort | uniq > bacteria_candidate_peps.txt

for pep in $(cat bacteria_candidate_peps.txt); do grep $pep ../annotate/Massospora_cicadina_MCPNR19.v2/annotate_results/Massospora_cicadina_MCPNR19.gff3 | cut -f1 | sort | uniq ; done > bacteria_candidate_contigs.txt
