package WWW::BambooHR;

use Carp;
use XML::Writer;

use WWW::BambooHR::Employees;
use WWW::BambooHR::Serializer;
use WWW::BambooHR::XMLWriter;
use WWW::BambooHR::TimeOffTypes;

use Moose;

with 'Role::REST::Client';

has '+type' => (
    default => 'application/xml',
);

has 'company' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has '+server' => (
    lazy => 1,
    default => sub {
        sprintf 'https://api.bamboohr.com/api/gateway.php/%s/v1', $_[0]->company;
    },
);

has '+serializer_class' => (
    default => 'WWW::BambooHR::Serializer',
);

has user_key => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has _time_off_types => (
    traits => [ 'Hash' ],
    isa => 'HashRef',
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        my $res = $self->get('/meta/time_off/types');
        croak "couldn't retrieve time off types: ", $res->code
            unless $res->code == 200;

        return { map { $_->name => $_ } @{ 
            WWW::BambooHR::TimeOffTypes->new( xml => $res->response->content)->types 
        }};
    },
    handles => {
        time_off_types => 'keys',
        time_off_type => 'get'
    },
);

sub _build_user_agent {
    my $self = shift;

    my $agent = WWW::BambooHR::UserAgent->new;
    $agent->{api_key} = $self->user_key;
    return $agent;
};

=head2 get_employees_directory

    my $directory = $bamboo->get_employees_directory

Upon success, returns a L<WWW::BambooHR::Employees> object containing
all users.

=cut

sub get_employees_directory {
    my $self = shift;

    my $res = $self->get('/employees/directory');

    croak "couldn't get employees directory: ", $res->error
        unless $res->code == 200;

    return WWW::BambooHR::Employees->new( xml =>
        $res->response->content 
    );
}

=head2 update_employee( $emp_id => \%attributes )

=cut

sub update_employee {
    my( $self, $emp_id, $changes ) = @_;

    my $doc = WWW::BambooHR::XMLWriter->new;
    $doc->startTag('employee');
    while(my($key,$value) = each %$changes ) {
        $doc->dataElement( field => $value, id => $key );
    }
    $doc->endTag;

    my $res = $self->post( "/employees/$emp_id", $doc->to_string );

    croak "update failed: ", $res->code unless $res->code == 200;
}

=head2 request_time_off( $emp_id => \%args )

=cut

sub request_time_off {
    my( $self, $emp_id, $args ) = @_;

    $args->{status} ||= 'requested';
    $args->{timeOffTypeId} = $self->time_off_type($args->{timeOffTypeId})->id
        if $args->{timeOffTypeId} and $args->{timeOffTypeId} !~ /^\d+$/;

    my $doc = WWW::BambooHR::XMLWriter->new;
    $doc->startTag('request');
    for my $e ( qw/ status start end timeOffTypeId amount previousRequest / ) {
        $doc->dataElement( $e => $args->{$e} ) if defined $args->{$e}; 
    }
    if ( grep { /^note_from/ } keys %$args ) {
        $doc->startTag('notes');
        $doc->dataElement( note => $args->{note_from_manager}, 
            from => 'manager' ) if $args->{note_from_manager};
        $doc->dataElement( note => $args->{note_from_employee}, 
            from => 'employee' ) if $args->{note_from_employee};
        $doc->endTag;
    }
    $doc->endTag;

    my $res = $self->put("/employees/$emp_id/time_off/request" =>
        $doc->to_string );

    croak "time off request failed: ", $res->code unless $res->code == 201;

}

__PACKAGE__->meta->make_immutable;

1;

package WWW::BambooHR::UserAgent;

use HTTP::Request::Common;

use parent 'LWP::UserAgent';

sub request {
    my $self = shift;

    return $self->SUPER::request(shift) if ref $_[0];

    my( $method, $url, $args ) = @_;
    return $self->SUPER::request( HTTP::Request::Common::_simple_req(
        $method => $url, %$args
    ));
}

sub get_basic_credentials {
    my $self = shift;
    return( $self->{api_key}, 'dummy' );
}

