use Modern::Perl;
use Test::More;

use List::Convolve qw/convolve/;

is_deeply convolve({ -1 => 1, 0 => 3, 1 => 1 }, [0..5]), [1,5,10,15,20,19];

is_deeply convolve({ -1 => 1, 0 => 3, 1 => 1 }, [0..5],
    mapper  => sub { $_[0] + $_[1] },
    reducer => sub { $_[0] * $_[1] },
), [6, 12, 40, 90, 168, 40];

is_deeply convolve({}, [0..5]), [];
is_deeply convolve({ -1 => 1, 0 => 3, 1 => 1 }, []), [];
is_deeply convolve({}, []), [];

done_testing 5
