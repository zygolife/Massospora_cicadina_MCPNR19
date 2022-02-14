#!/usr/bin/env python3

from Bio import SeqIO

infile='Massospora_cicadina_MCPNR19.v2-families.fa'
out='Massospora_cicadina_MCPNR19.v2-families_edit.fa'
ignore='exclude.txt'
dropthese = set({})
with open(ignore,'r') as infh:
    for ct in infh:
        dropthese.add(ct.strip())

with open(infile,'r') as handle, open(out, "w") as output_handle:
    for record in SeqIO.parse(handle, "fasta"):
        idclean = record.id.split('#')[0]
        if idclean not in dropthese:
            SeqIO.write(record, output_handle, "fasta")
