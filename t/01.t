#!/usr/bin/env perl
use v5.30 ;
use warnings ;

# easyish Unicode
# use utf8 ;
# use warnings qw(FATAL utf8) ;
# use open qw(:std :utf8) ;
# use Encode qw(decode_utf8) ;
# @ARGV = map { decode_utf8( $_, 1 ) } @ARGV ;

use feature qw(signatures) ;
no warnings qw(experimental::signatures) ;

# use standard;
# ---------------------------------------
use lib '/home/dave/code/python-docopt/lib' ;
use Python::Docopt ;
use YAML ;
use Data::Dumper;
use Encode qw(decode_utf8) ;

# my $docstr = &Python::Docopt::get_synopsis() ;
# warn $docstr ;
# exit 0 ;

my $OPTS = docopt( syn().'', \@ARGV, version => 'Naval Fate 2.0' ); # version => 'Naval Fate 2.0') ;

# say keys %$OPTS;

# say Dumper($OPTS->__data__) ;
say Dumper($OPTS) ;

say $OPTS->items() ;

say '';

say $OPTS->keys ;

say '' ;

say $OPTS->ship ;

# my @k = $OPTS->dict_keys ;

# say for @k;

exit ;



sub syn () {
    return decode_utf8 <<EOF;
Naval Fate.

Usage:
    naval_fate ship new <name>...
    naval_fate ship <name> move <x> <y> [--speed=<kn>]
    naval_fate ship shoot <x> <y>
    naval_fate mine (set|remove) <x> <y> [--moored|--drifting]
    naval_fate -h | --help
    naval_fate --version

Options:
    -h --help     Show this screen.
    --version     Show version.
    --speed=<kn>  Speed in knots [default: 10].
    --moored      Moored (anchored) mine.
    --drifting    Drifting mine.
EOF
}

=head1 SYNOPSIS

    Naval Fate.

    Usage:
        naval_fate ship new <name>...
        naval_fate ship <name> move <x> <y> [--speed=<kn>]
        naval_fate ship shoot <x> <y>
        naval_fate mine (set|remove) <x> <y> [--moored|--drifting]
        naval_fate -h | --help
        naval_fate --version

    Options:
        -h --help     Show this screen.
        --version     Show version.
        --speed=<kn>  Speed in knots [default: 10].
        --moored      Moored (anchored) mine.
        --drifting    Drifting mine.

=cut
