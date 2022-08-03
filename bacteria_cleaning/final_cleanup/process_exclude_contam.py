#!/usr/bin/env python3
import csv
from Bio import SeqIO
import os
minlen= 1000
infile = "Masso_5FC.consensus_round2.sourpurge.fasta"
outfile = "Masso_5FC.consensus_round2.sourpurge.blobpurge.fasta"
filter = "filtered_ctgs_by_TE.tsv"

ctgcolname = "id"
filtercontigs = {}
with open(filter,"r") as filterfile:
    rdr = csv.reader(filterfile,delimiter="\t")
    header = next(rdr)
    ctgcol = 0
    i = 0
    for n in header:
        if n == ctgcolname:
            ctgcol = i
            break
        i += 1
    for line in rdr:
        filtercontigs[line[ctgcol]] = line

ctgs_to_write = []
for record in SeqIO.parse(infile, "fasta"):
    if record.id in filtercontigs or len(record) < minlen:
        next
    else:
        ctgs_to_write.append(record)
SeqIO.write(ctgs_to_write, outfile, "fasta")
