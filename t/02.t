#!/usr/bin/env perl
use v5.30 ;
use warnings ;

# use strict ;

# easyish Unicode
use utf8 ;
use warnings qw(FATAL utf8) ;
use open qw(:std :utf8) ;
use Encode qw(decode_utf8) ;
@ARGV = map { decode_utf8( $_, 1 ) } @ARGV ;

use feature qw(signatures) ;
no warnings qw(experimental::signatures) ;

# use standard;
# ---------------------------------------
use lib '/home/dave/code/python-docopt/lib' ;
use Python::Docopt ;
use Encode qw(decode_utf8) ;

use Data::Dumper ;
use Data::Printer ;
use YAML ;
use JSON ;

my $usage = decode_utf8 usage() ;
undef($usage) ;

my $opts = docopt( $usage, version => decode_utf8('Naval Fate 2.0') ) ;

say to_json( $opts, { pretty => 1 } ) ;

say Dump($opts) ;

say Dumper($opts) ;

p $opts ;

sub usage () {
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

sub usage2 () {
    return <<EOF;

Usage:
    my_program [-hso FILE] [(--quiet | --verbose)] [INPUT ...]

    -h --help    show this
    -s --sorted  sorted output
    -o FILE      specify output file [default: ./test.txt]
    --quiet      print less text
    --verbose    print more text

EOF

    }


=head1 SYNOPSIS


    my_program [-hso FILE] [(--quiet | --verbose)] [INPUT ...]
    my_program -h

    -h --help    show this
    -s --sorted  sorted output
    -o FILE      specify output file [default: ./test.txt]
    --quiet      print less text
    --verbose    print more text

=cut
