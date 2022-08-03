#!/usr/bin/env perl
use strict;
use warnings;

use Bio::SeqIO;
my $length = 1000;
my $in = Bio::SeqIO->new(-format => 'fasta', -file => shift);
my $out = Bio::SeqIO->new(-format => 'fasta', -fh => \*STDOUT);
while( my $seq = $in->next_seq ) {
	next if $seq->length < $length;
	$out->write_seq($seq);
}
