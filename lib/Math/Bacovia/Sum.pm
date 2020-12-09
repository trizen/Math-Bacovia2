package Math::Bacovia::Sum;

use 5.014;
use warnings;

use Class::Multimethods qw();
use parent qw(Math::Bacovia);

our $VERSION = $Math::Bacovia::VERSION;

sub new {
    my ($class, $first, $second) = @_;

    if (defined($first)) {
        Math::Bacovia::_check_type(\$first);
    }
    else {
        $first = $Math::Bacovia::ZERO;
    }

    if (defined($second)) {
        Math::Bacovia::_check_type(\$second);
    }
    else {
        $second = $Math::Bacovia::ZERO;
    }

    bless {
           first  => $first,
           second => $second,
          }, $class;
}

sub inside {
    my ($x) = @_;
    ($x->{first}, $x->{second});
}

#
## Operations
#
Class::Multimethods::multimethod add => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{first} + $y->{first}, $x->{second} + $y->{second});
};

Class::Multimethods::multimethod sub => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{first} - $y->{first}, $x->{second} - $y->{second});
};

Class::Multimethods::multimethod mul => (__PACKAGE__, 'Math::Bacovia') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{first} * $y, $x->{second} * $y);
};

Class::Multimethods::multimethod div => (__PACKAGE__, 'Math::Bacovia') => sub {
    my ($x, $y) = @_;
    __PACKAGE__->new($x->{first} / $y, $x->{second} / $y);
};

#
## Transformations
#

sub numeric {
    my ($x) = @_;
    $x->{_num} //= $x->{first}->numeric + $x->{second}->numeric;
}

sub pretty {
    my ($x) = @_;
    $x->{_pretty} //= '(' . join(' + ', $x->{first}->pretty, $x->{second}->pretty) . ')';
}

sub stringify {
    my ($x) = @_;
    $x->{_str} //= 'Sum(' . join(', ', $x->{first}->stringify, $x->{second}->stringify) . ')';
}

#
## Equality
#

Class::Multimethods::multimethod eq => (__PACKAGE__, __PACKAGE__) => sub {
    my ($x, $y) = @_;

#<<<
         ($x->{first} == $y->{first}  and $x->{second} == $y->{second})
      || ($x->{first} == $y->{second} and $x->{second} == $y->{first});
#>>>
};

Class::Multimethods::multimethod eq => (__PACKAGE__, 'Math::Bacovia') => sub {
    my ($x, $y) = @_;

#<<<
         ($x->{first}  == $Math::Bacovia::ZERO and $x->{second} == $y)
      || ($x->{second} == $Math::Bacovia::ZERO and $x->{first}  == $y);
#>>>
};

#
## Alternatives
#

sub alternatives {
    my ($self, %opt) = @_;

    $self->{_alt} //= do {

        my @first  = $self->{first}->alternatives(%opt);
        my @second = $self->{second}->alternatives(%opt);

        my @alt;
        foreach my $first (@first) {
            foreach my $second (@second) {

                if (ref($first) eq 'Math::Bacovia::Number') {
                    if ($first->{value} == 0) {
                        push @alt, $second;
                        next;
                    }
                }
                elsif (ref($second) eq 'Math::Bacovia::Number') {
                    if ($second->{value} == 0) {
                        push @alt, $first;
                        next;
                    }
                }

                my $expr = $first + $second;
                push @alt, $expr;

                if ($opt{full} and ref($expr) ne __PACKAGE__) {
                    push @alt, __PACKAGE__->new($first, $second);
                }
            }
        }

        [List::UtilsBy::uniq_by { $_->stringify } @alt];
    };

    @{$self->{_alt}};
}

1;
