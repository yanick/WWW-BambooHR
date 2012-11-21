package WWW::BambooHR::XMLWriter;

use strict;
use warnings;

use base 'XML::Writer';

use overload '""' => \&to_string;

sub new {
    my $output;
    my $self = XML::Writer->new( OUTPUT => \$output, @_ );
    $self->{output_stream} = \$output;
    return bless $self, 'WWW::BambooHR::XMLWriter';
};

sub to_string {
    my $self = shift;

    $self->end;
    return ${$self->{output_stream}};
}

1;
