package WWW::BambooHR::Employees;

use strict;
use warnings;

use XML::Rabbit::Root;

has_xpath_object_list 'employees' => '//employee', {
    employee => 'WWW::BambooHR::Employee',
};

__PACKAGE__->meta->make_immutable;

1;



