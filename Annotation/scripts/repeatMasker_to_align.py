#!/usr/bin/env python3
import re, csv, sys, os, argparse, gzip, bz2
from pyfaidx import Fasta
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord
from Bio.Seq import Seq

parser = argparse.ArgumentParser(prog="repeatMasker_to_align.py",description='repeatMasker results to align')
parser.add_argument('-g','--genome', help='genome file database')
parser.add_argument('-i','--input', help='outfile input from RepeatMasker')
parser.add_argument('-o','--outdir', help='output directory',default="repeat_families")
args = parser.parse_args()
if not os.path.isdir(args.outdir):
    os.mkdir(args.outdir)
if not os.path.isdir(os.path.join(args.outdir,'singletons')):
    os.mkdir(os.path.join(args.outdir,'singletons'))

genome = Fasta(args.genome)
pat = re.compile(r'Target\s+\"Motif:([^\"]+)\"\s+(\d+)\s+(\d+)')
skip = re.compile(r'^Low_complexity|Simple_')

families = {}
skipline = re.compile(r'^\s*(SW|score)')
with bz2.open(args.input, mode='rt') as rmout:
    for line in rmout:
        if line.startswith('#'):
            continue
        elif skipline.match(line):
            continue
        else:
            line = re.sub("^\s+","",line)
            if len(line) == 0:
                continue

            row = re.split(r'\s+',line)
            score   = row[0]
            chrom     = row[4]
            start = int(row[5])
            end   = int(row[6])

            strand= row[8]
            reverseComplement = False
            if strand == "C":
                reverseComplement = True
            motif = re.sub(r'\/','_',row[9])
            motif = motif.upper()
            fam   = row[10]
#            print("strand is {} and RC={} motif={} fam={} start..end={}..{}".format(strand,reverseComplement,motif,fam,start,end))
            mskip = skip.search(fam)
            if mskip:
                continue
                #print(chr,start,end,strand,motif)

            if motif in families:
                families[motif].append([chrom,start,end,reverseComplement,fam])
            else:
                families[motif] = [ [chrom,start,end,reverseComplement,fam] ]

for motif in families:
    if len(families[motif]) > 1:
        fastafile = os.path.join(args.outdir,motif + ".fas")
    else:
        fastafile = os.path.join(args.outdir,'singletons',motif + ".fas")
    seqs = []
    for location in families[motif]:
        chrom       = location[0]
        loc_start   = location[1]
        loc_end     = location[2]
        revcomp     = location[3]
        fam         = location[4]
        locus_name = "%s_%s_%d_%d"%(motif,chrom,loc_start,loc_end)
        rec = genome[chrom][loc_start:loc_end]
        if revcomp:
            rec = rec.complement
#        print(motif,locus_name, rec, rec.seq)
        seqs.append(SeqRecord(Seq(rec.seq),id=locus_name,description="Repeat=%s Class=%s"%(motif,fam)))

    SeqIO.write(seqs, fastafile, "fasta")
