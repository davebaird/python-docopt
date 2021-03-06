package Python::Docopt ;

use warnings ;
use strict ;

use Scalar::Util qw(blessed) ;
use Encode qw(decode_utf8) ;
use Clone qw(clone) ;

require Exporter ;
our @ISA       = qw(Exporter) ;
our @EXPORT    = qw(docopt) ;
our @EXPORT_OK = qw(get_synopsis) ;

my $ERR_ARGV_PARSING_ERROR = 7 ;

use Inline Python => <<'EOF';
from docopt import docopt as py_docopt
from contextlib import redirect_stdout
import io

def wrapped_docopt(doc, argv=None, help=True, version=None, options_first=False):
    with io.StringIO() as buf, redirect_stdout(buf):
        try:
            opts = py_docopt(doc, argv, help, version, options_first)
            return dict(opts)
        except SystemExit as e:
            print("SYSEXIT")
            print(e)
            return buf.getvalue()

EOF

# https://stackoverflow.com/a/68672920/2334574
BEGIN {
    # Unbuffer Python's output
    $ENV{PYTHONUNBUFFERED} = 1 ;

    # Unbuffer Perl's output
    # select( ( select(STDOUT), $| = 1 )[0] ) ;
    # select( ( select(STDERR), $| = 1 )[0] ) ;
    STDOUT->autoflush ;
    STDERR->autoflush ;
    }


END {
    # Shut down the Python interpreter.
    Inline::Python::py_finalize() ;
    }


sub docopt {
    my ( $doc, %args ) = @_ ;
    $doc //= get_synopsis() ;
    $args{help} //= 1 ;
    $args{options_first} ||= '' ;
    $args{argv}          ||= \@ARGV ;

    my $opts = wrapped_docopt( $doc, @args{qw(argv help version options_first)} ) ;

    if ( !ref($opts) ) {    # it's a message
        if ( $opts =~ s/^SYSEXIT\n// ) {
            print STDERR $opts ;
            exit($ERR_ARGV_PARSING_ERROR) ;
            }

        $opts =~ s/SYSEXIT\n\n$// ;    # not an error (-v or -h)
        print $opts ;
        exit(0) ;
        }

    foreach my $k ( keys $opts->%* ) {
        $opts->{$k} += 0 if blessed( $opts->{$k} ) ;    # convert Inline::Python::Boolean objects into Perlish booleans

        next if $args{preserve_angle_brackets} ;        # IMHO the angle-brackets should not be preserved
        if ( $k =~ /^<(.+)>$/ ) {
            my $new_k = $1 ;
            $opts->{$new_k} = delete $opts->{$k} ;
            }
        }

    return clone($opts) ;
    }


sub get_synopsis () {
    require Pod::Usage ;

    my $parser = Pod::Usage->new( USAGE_OPTIONS => +{} ) ;
    $parser->select('(?:SYNOPSIS|USAGE)\s*') ;
    $parser->output_string( \my $doc ) ;
    $parser->parse_file($0) ;

    # $doc =~ s/Usage:// ;    # Pod::Usage adds this
    return decode_utf8($doc) ;
    }

1 ;
