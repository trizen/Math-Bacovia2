#!/usr/bin/perl

# Fraction() sum example.

use utf8;
use 5.014;

use lib qw(../lib);
use ntheory qw(factorial);
use Math::Bacovia qw(:all);

my $sum = Fraction(0, 1);
foreach my $n (0 .. 7) {
    $sum += Fraction(1, factorial($n));
    say $sum;
}

say '';
say "Pretty  : ", $sum->pretty;
say "Numeric : ", $sum->numeric->as_dec;
