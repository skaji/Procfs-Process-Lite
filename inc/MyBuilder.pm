package MyBuilder;
use strict;
use warnings;
use base 'Module::Build';

sub new {
    my ($class, @argv) = @_;
    if (!-d "/proc/$$") {
        print "This distribution requires the procfs. Abort.\n";
        exit 0;
    }
    $class->SUPER::new(@argv);
}

1;
