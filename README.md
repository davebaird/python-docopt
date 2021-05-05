
# Python::Docopt

Use the Python `docopt` utility in Perl.

```perl
use Python::Docopt ;
use Encode qw(decode_utf8) ;

@ARGV = map { decode_utf8( $_, 1 ) } @ARGV ;

sub usage {
    return <<EOF;
Naval Fate.

Usage:
    naval_fate ship new <name>...
    naval_fate ship <name> move <x> <y> [--speed=<kn>]
    naval_fate ship shoot <x> <y>
    naval_fate mine (set|remove) <x> <y> [--moored|--drifting]
    naval_fate -h | --help
    naval_fate -v | --version

Options:
    -h --help     Show this screen.
    -v --version  Show version.
    --speed=<kn>  Speed in knots [default: 10].
    --moored      Moored (anchored) mine.
    --drifting    Drifting mine.
EOF
    }

# -----
my $opts = docopt( decode_utf8( usage() ) ;

warn 'Too fast' if $opts->{'--speed'} > 20 ;
```
