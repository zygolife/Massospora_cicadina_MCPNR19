#by cassie ettinger

import sys
import Bio
from Bio import SeqIO

def filter_fasta(input_fasta, output_fasta, contig_ids): 
	seq_records = SeqIO.parse(input_fasta, format='fasta') #parses the fasta file
	

	with open(contig_ids) as f:
		contig_ids_list = f.read().splitlines() #parse the contamination file which is each line as a scaffold id 
	#print(contig_ids_list)	

	OutputFile = open(output_fasta, 'w') #opens new file to write to
	
	for record in seq_records: 
		if record.id in contig_ids_list: 
			OutputFile.write('>'+ record.id +'\n') #writes the scaffold to the file (or assession) 
			OutputFile.write(str(record.seq)+'\n') #writes the seq to the file
			
	OutputFile.close()




#filter_fasta("../../../Masso_5FC.consensus_round2.sourpurge.fasta", "proteobacteria.fa", "prot_contigs.txt")
#filter_fasta("../../../Masso_5FC.consensus_round2.sourpurge.fasta", "proteobacteria_gc_less_than_45.fa", "proteobacteria_gc_less_than_45_contigs.txt")
#filter_fasta("../../../Masso_5FC.consensus_round2.sourpurge.fasta", "firmicutes.fa", "firmicutes.contigs.txt")
#filter_fasta("../../../Masso_5FC.consensus_round2.sourpurge.fasta", "viruses.fa", "viral_contigs.txt")
filter_fasta("../../../Masso_5FC.consensus_round2.sourpurge.fasta", "remaining_contam.fa", "remaining_contam.txt")

