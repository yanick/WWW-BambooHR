package WWW::BambooHR::Employee;

use strict;
use warnings;

use XML::Rabbit;

has_xpath_value 'bamboo_id'   => './@id';

has_xpath_value $_ => "./field[\@id='$_']"
    for qw/
        displayName
        firstName
        lastName
        jobTitle
        workPhone
        workPhoneExtension
        mobilePhone
        workEmail
        department
        location
        division
        photoUploaded
        photoUrl
        /;


__PACKAGE__->meta->make_immutable;

1;



