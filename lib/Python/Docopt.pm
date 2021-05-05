package Python::Docopt ;
use warnings ;
use strict ;

use Scalar::Util qw(blessed) ;

require Exporter ;
our @ISA       = qw(Exporter) ;
our @EXPORT    = qw(docopt) ;
our @EXPORT_OK = qw(get_synopsis) ;

use Inline Python => <<'EOF';
from docopt import docopt as py_docopt
from contextlib import redirect_stdout
import io

def wrap_docopt(doc, argv=None, help=True, version=None, options_first=False):
    with io.StringIO() as buf, redirect_stdout(buf):
        try:
            opts = py_docopt(doc, argv, help, version, options_first)
            return dict(opts)
        except SystemExit as e:
            print("SYSEXIT")
            print(e)
            return buf.getvalue()

EOF

sub docopt {
    my ( $doc, %args ) = @_ ;
    $args{help} //= 1 ;
    $args{options_first} ||= '' ;
    $args{argv}          ||= \@ARGV ;

    my $opts = wrap_docopt( $doc, @args{qw(argv help version options_first)} ) ;

    if ( !ref($opts) ) {    # it's a message
        if ( $opts =~ s/^SYSEXIT\n// ) {    # if starts with SYSEXIT, there's an error
            print STDERR $opts ;
            exit(1) ;
            }
        elsif ( $opts =~ s/SYSEXIT\n\n$// ) {    # if ends with SYSEXIT, not an error (-v or -h)
            print $opts ;
            exit(0) ;
            }
        }

    foreach my $k ( keys $opts->%* ) {

        # Convert Inline::Python::Boolean objects into Perlish booleans.
        $opts->{$k} += 0 if blessed( $opts->{$k} ) ;

        # I believe the angle-brackets should not be preserved.
        next if $args{preserve_angle_brackets} ;
        if ( $k =~ /^<(.+)>$/ ) {
            my $new_k = $1 ;
            $opts->{$new_k} = delete $opts->{$k} ;
            }
        }

    return $opts ;
    }

sub get_synopsis () {
    require Pod::Usage ;

    my $parser = Pod::Usage->new( USAGE_OPTIONS => +{} ) ;
    $parser->select('(?:SYNOPSIS|USAGE)\s*') ;
    $parser->output_string( \my $doc ) ;
    $parser->parse_file($0) ;

    $doc =~ s/Usage:// ;    # Pod::Usage adds this
    return $doc ;
    }

1 ;

=head1 SYNOPSIS

    use Python::Docopt ;
    use Encode qw(decode_utf8) ;

    @ARGV = map { decode_utf8( $_, 1 ) } @ARGV ;

    my $usage = decode_utf8( usage() ) ;

    my $opts = docopt( $usage ) ;

    warn 'Too fast' if $opts->{'--speed'} > 20 ;


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
