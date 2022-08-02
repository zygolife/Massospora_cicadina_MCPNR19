#!/usr/bin/env perl
use strict;
use warnings;
my ($num,$den)=(0,0);
while (<>) {
    my $cov = chomp;
    $num=$num+$cov;
    $den++;
}
my $cov=$num/$den;
print "Mean Coverage = $cov\n";
