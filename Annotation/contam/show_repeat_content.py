#!/usr/bin/env python3

import csv
from Bio import SeqIO
import os

infile='bacteria_candidate_contigs.fa'
TEpercent = {}
for record in SeqIO.parse(infile, "fasta"):
    lowercount = sum(c.islower() for c in record.seq)
    print("%s\t%.2f"%(record.id, 100 * lowercount / len(record)))
