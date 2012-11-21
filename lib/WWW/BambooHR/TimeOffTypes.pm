package WWW::BambooHR::TimeOffTypes;

use strict;
use warnings;

use XML::Rabbit::Root;

has_xpath_object_list 'types' => '//timeOffType', {
    timeOffType => 'WWW::BambooHR::TimeOffType',
};

__PACKAGE__->meta->make_immutable;

1;



