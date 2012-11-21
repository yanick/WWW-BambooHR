package WWW::BambooHR::TimeOffType;

use strict;
use warnings;

use XML::Rabbit;

has_xpath_value id   => './@id';

has_xpath_value name => './name';

__PACKAGE__->meta->make_immutable;

1;



