#!/usr/bin/env python3
import re, csv, sys, os, argparse, gzip, bz2
import glob

parser = argparse.ArgumentParser(prog="summarize_repeatmasker_comparative",description='Make a summary table of RM content')
parser.add_argument('-d','--indir',
                    help='directory containing folders with Repeatmasker results',
                    default="repeatmasker_reports")
parser.add_argument('-o','--out',
                    help='output file to print report to',
                    type=argparse.FileType('w'),default=sys.stdout)
parser.add_argument('-op','--outpct',
                    help='output file to print report to',
                    type=argparse.FileType('w'),default=sys.stdout)

parser.add_argument('-g','--genomedir',
                    help='Genome files directory',
                    default="genomes")

args = parser.parse_args()

csv.register_dialect('tsv', delimiter='\t', quoting=csv.QUOTE_NONE)
csv.register_dialect('csvUNIX', delimiter='\t', quoting=csv.QUOTE_NONE)

csvout = csv.writer(args.out,delimiter=",",dialect="csvUNIX")
csvoutpct = csv.writer(args.outpct,delimiter=",",dialect="csvUNIX")

genomesizes = {}
gpath = os.path.join(args.genomedir,"*.sorted.fasta.fai")
for gfile in glob.glob(gpath):
    length = 0
    name = os.path.basename(gfile)
    name = re.sub(r'\.(assembled|sorted)\.fasta\.fai','',name)
    print("genome name is {} from {}".format(name,gfile))
    with open(gfile,"r") as insize:
        for line in insize:
            row =  line.split()
            genomesizes[name] = int(row[2])

pat = re.compile(r'Target\s+\"Motif:([^\"]+)\"\s+(\d+)\s+(\d+)')
skip = re.compile(r'^Low_complexity|Simple_')

skipline = re.compile(r'^\s*(SW|score)')
reportpath = os.path.join(args.indir,"*","*.fasta.out.bz2")
tableRpts = {}
tableRptsLen = {}
header = []
for fname in glob.glob(reportpath):
    print(fname)
    dirname = os.path.basename(os.path.dirname(fname))
    dirname = re.sub(r'\.RM$','',dirname)
    if dirname not in genomesizes:
        continue
    header.append(dirname)
    i = 0
    with bz2.open(fname, mode='rt') as rmout:
        for line in rmout:
            if line.startswith('#') or skipline.match(line):
                continue
            line = re.sub("^\s+","",line)
            if len(line) == 0:
                continue
            i = i+1
#            if i > 5000:
#                break
            row = re.split(r'\s+',line)
            score   = row[0]
            chrom     = row[4]
            start = int(row[5])
            end   = int(row[6])

            strand = row[8]
            reverseComplement = False
            if strand == "C":
                reverseComplement = True
            motif = re.sub(r'\/','_',row[9])
            motif = motif.upper()
            fam   = row[10]
            mskip = skip.search(fam)
            if mskip:
                continue
            rptlen = abs(end - start) + 1
            if fam not in tableRpts:
                tableRpts[fam] = {}
            if dirname not in tableRpts[fam]:
                tableRpts[fam][dirname] = {'count':0, 'total_len':0 }

            tableRpts[fam][dirname]['count'] += 1
            tableRpts[fam][dirname]['total_len'] += rptlen


header = sorted(header)
csvout.writerow(header)
csvoutpct.writerow(header)

for fam in sorted(tableRpts):
    row = [fam]
    for h in header:
        if h in tableRpts[fam]:
            row.append(tableRpts[fam][h]['count'])
        else:
            row.append(0)
    csvout.writerow(row)

for fam in sorted(tableRpts):
    row = [fam]
    for h in header:
        if h in tableRpts[fam]:
            row.append("%.2f"%( 100 * tableRpts[fam][h]['total_len'] / genomesizes[h] ))
        else:
            row.append(0)

    csvoutpct.writerow(row)
