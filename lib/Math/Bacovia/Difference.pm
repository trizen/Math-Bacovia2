package Math::Bacovia::Difference;

use 5.014;
use warnings;

use Class::Multimethods;
use parent qw(Math::Bacovia);

sub new {
    my ($class, $minuend, $subtrahend) = @_;

    if (defined($minuend)) {
        Math::Bacovia::Utils::check_type(\$minuend);
    }
    else {
        $minuend = $Math::Bacovia::ZERO;
    }

    if (defined($subtrahend)) {
        Math::Bacovia::Utils::check_type(\$subtrahend);
    }
    else {
        $subtrahend = $Math::Bacovia::ZERO;
    }

    bless {
           minuend    => $minuend,
           subtrahend => $subtrahend,
          }, $class;
}

sub inside {
    my ($x) = @_;
    ($x->{minuend}, $x->{subtrahend});
}

#
## Operations
#

#
## (a-b) + (x-y) = (a+x) - (b+y)
#

Class::Multimethods::multimethod add => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
#<<<
    __PACKAGE__->new(
        $x->{minuend}    + $y->{minuend},
        $x->{subtrahend} + $y->{subtrahend}
    );
#>>>
};

Class::Multimethods::multimethod add => (__PACKAGE__, 'Math::Bacovia::Number') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{minuend} + $y, $x->{subtrahend});
};

Class::Multimethods::multimethod add => (__PACKAGE__, 'Math::Bacovia::Fraction') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{minuend} + $y, $x->{subtrahend});
};

#
## (a-b) - (x-y) = (a+y) - (b+x)
#

Class::Multimethods::multimethod sub => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
#<<<
    __PACKAGE__->new(
        $x->{minuend}    + $y->{subtrahend},
        $x->{subtrahend} + $y->{minuend}
    );
#>>>
};

Class::Multimethods::multimethod sub => (__PACKAGE__, 'Math::Bacovia::Number') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{minuend}, $x->{subtrahend} + $y);
};

Class::Multimethods::multimethod sub => (__PACKAGE__, 'Math::Bacovia::Fraction') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{minuend}, $x->{subtrahend} + $y);
};

#
## (a-b) * (x-y) = (a*x + b*y) - (b*x + a*y)
#

Class::Multimethods::multimethod mul => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
#<<<
    __PACKAGE__->new(
        $x->{minuend}    * $y->{minuend} + $x->{subtrahend} * $y->{subtrahend},
        $x->{subtrahend} * $y->{minuend} + $x->{minuend}    * $y->{subtrahend}
    );
#>>>
};

Class::Multimethods::multimethod mul => (__PACKAGE__, 'Math::Bacovia::Number') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{minuend} * $y, $x->{subtrahend} * $y);
};

Class::Multimethods::multimethod mul => (__PACKAGE__, 'Math::Bacovia::Fraction') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{minuend} * $y, $x->{subtrahend} * $y);
};

sub neg {
    my ($x) = @_;
    __PACKAGE__->new($x->{subtrahend}, $x->{minuend});
}

#
## Equality
#

Class::Multimethods::multimethod eq => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;

    ($x->{minuend} == $y->{minuend})
      && ($x->{subtrahend} == $y->{subtrahend});
};

Class::Multimethods::multimethod eq => (__PACKAGE__, '*') => sub {
    !1;
};

#
## Transformations
#

sub numeric {
    my ($x) = @_;
    $x->{minuend}->numeric - $x->{subtrahend}->numeric;
}

sub pretty {
    my ($x) = @_;

    $x->{_pretty} //= do {
        my $minuend    = $x->{minuend}->pretty();
        my $subtrahend = $x->{subtrahend}->pretty();

        if ($minuend eq '0') {
            "(-$subtrahend)";
        }
        elsif ($subtrahend eq '0') {
            $minuend;
        }
        else {
            "($minuend - $subtrahend)";
        }
    };
}

sub stringify {
    my ($x) = @_;
    $x->{_str} //= "Difference(" . $x->{minuend}->stringify() . ', ' . $x->{subtrahend}->stringify() . ")";
}

#
## Alternatives
#

sub alternatives {
    my ($self) = @_;

    $self->{_alt} //= do {
        my @first  = $self->{minuend}->alternatives;
        my @second = $self->{subtrahend}->alternatives;

        my @alt;
        foreach my $minuend (@first) {
            foreach my $subtrahend (@second) {
                if ($subtrahend == $Math::Bacovia::ZERO) {
                    push @alt, $minuend;
                }
                elsif ($minuend == $Math::Bacovia::ZERO) {
                    push @alt, $subtrahend->neg;
                }
                else {
                    push @alt, __PACKAGE__->new($minuend, $subtrahend);
                    ##push @alt, $minuend - $subtrahend;      # better, but slower...
                }
            }
        }

        [List::UtilsBy::uniq_by { $_->stringify } @alt];
    };

    @{$self->{_alt}};
}

1;
