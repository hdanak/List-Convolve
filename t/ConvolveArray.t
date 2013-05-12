use Modern::Perl;
use Test::More;

use List::Convolve qw/convolve/;

is_deeply convolve([1,3,1], [0..5]), [1,5,10,15,20,19];
ok not eval { convolve([1,3,1,0], [0..5]) };
is_deeply convolve([0,1,3,1], [0..5], center => 2), [1,5,10,15,20,19];

is_deeply convolve([1,3,1], [0..5],
    mapper  => sub { $_[0] + $_[1] },
    reducer => sub { $_[0] * $_[1] },
#   wrap    => 'cycle',
), [6, 12, 40, 90, 168, 40];

ok not eval { convolve([1,3,1], []) };

done_testing 5
