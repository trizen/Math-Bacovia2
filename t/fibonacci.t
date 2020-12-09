#!perl -T

use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 13;

use Math::Bacovia qw(pi Power Symbol Fraction);

my $S = Power(5, '1/2');

sub fibonacci {
    my ($n) = @_;
    Fraction(Fraction($S + 1, 2)**$n - (Fraction(2, $S + 1)**$n * cos(pi * $n)), $S);
}

my @fibs = qw(0 1 1 2 3 5 8 13 21 34);

foreach my $n (0 .. 9) {
    is(fibonacci($n)->simple->numeric, shift(@fibs));
}

my $expr = fibonacci(Symbol('n', 12));

is($expr->simple->numeric->round(-30), 144);
is($expr->expand->numeric->round(-30), 144);

my $f = $expr->simple(full=>1)->pretty;
is($f, '((((5^(1/2) + 1)/2)^n - ((2/(5^(1/2) + 1))^n * ((exp((-i * ((log(-1) * -i) * n))) + exp((i * ((log(-1) * -i) * n))))/2)))/5^(1/2))');
