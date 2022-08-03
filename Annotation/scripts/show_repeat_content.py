#!/usr/bin/env python3

import csv
from Bio import SeqIO
import os, sys

infile=sys.argv[1]
totallower=0
total=0
for record in SeqIO.parse(infile, "fasta"):
    lowercount = sum(c.islower() for c in record.seq)
    totallower += lowercount
    total += len(record)
    print("\t".join([record.id,"%.2f"%( 100 * lowercount / len(record)),"%d"%(len(record))]))

print("%s\t%d,%d"%('total bases',totallower,total))
