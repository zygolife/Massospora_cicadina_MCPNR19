#!/usr/bin/env perl
use strict;
use warnings;

use Bio::SeqIO;
my $skip = shift || die "need a list of seqs to skip";
open(my $ifh => $skip) || die "Cannot open $skip: $!";
my %skipseq;
while(<$ifh>) {
	my ($id) = split;
	$skipseq{$id}++;
}
my $in = Bio::SeqIO->new(-format => 'fasta', -file => shift);
my $out = Bio::SeqIO->new(-format => 'fasta', -fh => \*STDOUT);
while( my $seq = $in->next_seq ) {
	next if exists $skipseq{$seq->display_id};
	$out->write_seq($seq);
}
