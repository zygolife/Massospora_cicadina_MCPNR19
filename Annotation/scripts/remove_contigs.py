#!/usr/bin/env python3

from Bio import SeqIO

infile='genomes/Massospora_cicadina_MCPNR19.v2.sorted.fasta'
out='genomes/Massospora_cicadina_MCPNR19.v2.sorted_contamedit.fasta'
ignore='contam/remove_scf.txt'
dropthese = set({})
with open(ignore,'r') as infh:
    for ct in infh:
        dropthese.add(ct.strip())

with open(infile,'r') as handle, open(out, "w") as output_handle:
    for record in SeqIO.parse(handle, "fasta"):
        if record.id not in dropthese:
            SeqIO.write(record, output_handle, "fasta")
