package WWW::BambooHR::Serializer;

use Scalar::Util qw/ blessed /;

use Moose;

extends 'Role::REST::Client::Serializer';

sub serialize {
    my ( $self, $data ) = @_;

    # XML is too complex for the puny serializing capacities of 
    # XML::Simple. In this case, hand-crafting the answers
    # is the only sane way.
    return blessed $data ? $data->serialize : $data;
}

1;

