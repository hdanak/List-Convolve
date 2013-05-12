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
            . "Try inserting 0 at the beginning or end"
        unless @$window % 2 or exists $opts{center};

    my $center  = $opts{center}  // int(@$window/2);
    convolve_hash({map {$_ - $center => $$window[$_]} 0..$#$window}, $list, %opts);
}
sub convolve_hash {
    my ($kern, $list, %opts) = @_;
    my $mapper  = $opts{mapper}  // sub { $_[0] * $_[1]};
    my $reducer = $opts{reducer} // sub { $_[0] + $_[1]};
    my $default = $opts{default};

    my @keys = sort keys %$kern;
    return [] unless @keys;
    [ map {
        my $i = $_;
        my @xs = map { &$mapper($$kern{$_}, $$list[$i + $_]) }
                grep { $i + $_ >= 0 and $i + $_ <= $#$list } @keys;

        my $prev = shift @xs // $default;
        $prev = &$reducer($prev, $_) for @xs;
        $prev
    } 0..$#$list ]
}

1
