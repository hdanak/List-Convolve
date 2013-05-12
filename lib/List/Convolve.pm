package List::Convolve;
our $VERSION = v0.0.1;

use Modern::Perl;
use Carp;

=head1 SYNOPSIS

    ...

=cut

use parent 'Exporter';
our @EXPORT = ('convolve');

sub convolve {
    my ($kern) = @_;
    for (ref $kern) {
        return &convolve_array when 'ARRAY';
        return &convolve_hash  when 'HASH';
        croak 'Convolution kernel must be either an odd-sized array or hash';
    }
}
sub convolve_array {
    my ($window, $list, %opts) = @_;
    return [] unless @$window;
    croak "Window cannot be larger than list" if @$window > @$list;
    croak "Window size must be odd, or a center must be specified. "
            . "Try inserting 0 to the beginning or end"
        unless @$window % 2 or exists $opts{center};

    convolve_hash({map {$_ => $$window[$_]} 0..$#$window}, $list, %opts);

    my $mapper  = $opts{mapper}  // sub { $_[0] * $_[1]};
    my $reducer = $opts{reducer} // sub { $_[0] + $_[1] };
    my $center  = $opts{center}  // @$window/2;

    my @out = ([]) x @$list;
    for my $i(0 .. $center - 1) {
        push @{$out[$i]}, map {
            &$mapper($$window[$center + $_], $$list[$i + $_])
        } (-$i .. $#$window - $center)
    }
    for my $i($center .. $#$list + $center - $#$window) {
        push @{$out[$i]}, map {
            &$mapper($$window[$center + $_], $$list[$i + $_])
        } (-$center .. $#$window - $center)
    }
    for my $i(1 + $#$list + $center - $#$window .. $#$list) {
        push @{$out[$i]}, map {
            &$mapper($$window[$center + $_], $$list[$i + $_])
        } (-$center .. $#$list - $i)
    }
    [ map {
        my $prev = shift @$_;
        for (@$_) {
            $prev = &$reducer($prev, $_)
        }
        $prev
    } @out ]
}
sub convolve_hash {
    my ($kern, $list, %opts) = @_;
    my $mapper  = $opts{mapper}  // sub { $_[0] * $_[1]};
    my $reducer = $opts{reducer} // sub { $_[0] + $_[1]};

    my @keys = sort keys %$kern;
    [ map {
        my $i = $_;

        my @xs = map { &$mapper($$kern{$_}, $$list[$i + $_]) }
                grep { $i + $_ > 0 and $i + $_ <= $#$list } @keys;

        use Data::Dumper;
        say Dumper \@xs;
        my $prev = shift @xs;
        $prev = &$reducer($prev, $_) for @xs;
        $prev
    } 0..$#$list ]
}

1
