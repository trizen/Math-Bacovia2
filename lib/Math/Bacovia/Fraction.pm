package Math::Bacovia::Fraction;

use 5.014;
use warnings;

use Class::Multimethods;
use parent qw(Math::Bacovia);

sub new {
    my ($class, $numerator, $denominator) = @_;

    if (defined($numerator)) {
        Math::Bacovia::Utils::check_type(\$numerator);
    }
    else {
        $numerator = $Math::Bacovia::ZERO;
    }

    if (defined($denominator)) {
        Math::Bacovia::Utils::check_type(\$denominator);
    }
    else {
        $denominator = $Math::Bacovia::ONE;
    }

    bless {
           num => $numerator,
           den => $denominator,
          }, $class;
}

sub inside {
    my ($x) = @_;
    ($x->{num}, $x->{den});
}

#
## Operations
#

Class::Multimethods::multimethod add => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
#<<<
    __PACKAGE__->new(
        $x->{num} * $y->{den} + $y->{num} * $x->{den},
        $x->{den} * $y->{den}
    );
#>>>
};

Class::Multimethods::multimethod add => (__PACKAGE__, 'Math::Bacovia::Number') => sub {
    my ($x, $y) = @_;
#<<<
    __PACKAGE__->new(
        $x->{num} + $x->{den} * $y,
        $x->{den}
    );
#>>>
};

Class::Multimethods::multimethod add => (__PACKAGE__, 'Math::Bacovia::Difference') => sub {
    my ($x, $y) = @_;
#<<<
    __PACKAGE__->new(
        $x->{num} + $x->{den} * $y,
        $x->{den}
    );
#>>>
};

Class::Multimethods::multimethod sub => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
#<<<
    __PACKAGE__->new(
        $x->{num} * $y->{den} - $y->{num} * $x->{den},
        $x->{den} * $y->{den}
    );
#>>>
};

Class::Multimethods::multimethod sub => (__PACKAGE__, 'Math::Bacovia::Number') => sub {
    my ($x, $y) = @_;
#<<<
    __PACKAGE__->new(
        $x->{num} - $x->{den} * $y,
        $x->{den}
    );
#>>>
};

Class::Multimethods::multimethod sub => (__PACKAGE__, 'Math::Bacovia::Difference') => sub {
    my ($x, $y) = @_;
#<<<
    __PACKAGE__->new(
        $x->{num} - $x->{den} * $y,
        $x->{den}
    );
#>>>
};

Class::Multimethods::multimethod mul => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{num} * $y->{num}, $x->{den} * $y->{den});
};

Class::Multimethods::multimethod mul => (__PACKAGE__, 'Math::Bacovia::Number') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{num} * $y, $x->{den});
};

Class::Multimethods::multimethod mul => (__PACKAGE__, 'Math::Bacovia::Difference') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{num} * $y, $x->{den});
};

Class::Multimethods::multimethod div => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{num} * $y->{den}, $x->{den} * $y->{num});
};

Class::Multimethods::multimethod div => (__PACKAGE__, 'Math::Bacovia::Number') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{num}, $x->{den} * $y);
};

Class::Multimethods::multimethod div => (__PACKAGE__, 'Math::Bacovia::Difference') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{num}, $x->{den} * $y);
};

sub inv {
    my ($x) = @_;
    __PACKAGE__->new($x->{den}, $x->{num});
}

#
## Equality
#

Class::Multimethods::multimethod eq => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;

    ($x->{num} == $y->{num})
      && ($x->{den} == $y->{den});
};

Class::Multimethods::multimethod eq => (__PACKAGE__, '*') => sub {
    !1;
};

#
## Transformations
#

sub numeric {
    my ($x) = @_;
    $x->{num}->numeric / $x->{den}->numeric;
}

sub pretty {
    my ($x) = @_;

    my $num = $x->{num}->pretty();
    my $den = $x->{den}->pretty();

    if ($den eq '1') {
        return $num;
    }

    "($num/$den)";
}

sub stringify {
    my ($x) = @_;
    "Fraction(" . $x->{num}->stringify() . ', ' . $x->{den}->stringify() . ")";
}

#
## Alternatives
#

sub alternatives {
    my ($x) = @_;

    my @a_num = $x->{num}->alternatives;
    my @a_den = $x->{den}->alternatives;

    my @alt;
    foreach my $num (@a_num) {
        foreach my $den (@a_den) {
            if ($den == $Math::Bacovia::ONE) {
                push @alt, $num;
            }
            elsif ($num == $Math::Bacovia::ONE) {
                push @alt, $den->inv;
            }
            else {
                my $expr = $num / $den;
                push @alt, $expr;

                if (ref($expr) ne __PACKAGE__) {
                    push @alt, __PACKAGE__->new($num, $den);
                }
            }
        }
    }

    List::UtilsBy::XS::uniq_by { $_->stringify } @alt;
}

1;
