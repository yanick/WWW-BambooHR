use 5.10.0;

use WWW::BambooHR;

my $bam = WWW::BambooHR->new(
    user_key => 'deadbeedeadbeedeadbeedeadbeedeadbeedeadbe',
    company  => 'mycorp',
);

# request time off for user 11687
$bam->request_time_off( 11687 => {
    start => '2013-01-01',
    end   => '2013-01-05',
    timeOffTypeId => 'Sick',
});

# list all the time off types
say $bam->time_off_types;

# list all the employees
my $dir = $bam->get_employees_directory; 

for my $emp ( @{ $dir->employees } ) {
    say $emp->bamboo_id, " ", $emp->displayName;
}

# update employee info
$bam->update_employee( 11687 => {
    firstName => 'Wilfred',
});

