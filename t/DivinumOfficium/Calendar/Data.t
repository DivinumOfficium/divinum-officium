use strict;
use warnings;

# The modules expect to be loaded in the global package in order to pull in
# existing global stuff.
package horas;

use DivinumOfficium::Calendar::Definitions;
use DivinumOfficium::Calendar::Data qw(load_calendar_file);
use DivinumOfficium::Test qw(mock_office_descriptor);

use Test::More;

$horas::version = 'Divino afflatu';

my $calendar_ref = load_calendar_file('', '/dev/fd/' . fileno(DATA));

my $num_calpoints = keys(%{$calendar_ref->{calpoints}});
my $num_offices   = keys(%{$calendar_ref->{offices}});

ok($num_calpoints == 3, 'number of calpoints');
ok($num_offices   == 4, 'number of offices');

my $circumcision_id = $calendar_ref->{calpoints}{'01-01'}[0];
my $circumcision_ref = $calendar_ref->{offices}{$circumcision_id};
ok($circumcision_ref->{filename} eq 'Sancti/01-01', 'implicit Sancti filename');

my $pent14_id = $calendar_ref->{calpoints}{'Pent14-0'}[0];
my $pent14_ref = $calendar_ref->{offices}{$pent14_id};
ok($pent14_ref->{filename} eq 'Tempora/Pent14-0', 'implicit Tempora filename');

my $test_calpoints_ref = $calendar_ref->{calpoints}{'test'};
ok(@$test_calpoints_ref == 2, 'two offices under one calpoint');
my @test_offices = map {$calendar_ref->{offices}{$_}} @$test_calpoints_ref;
ok($test_offices[0]{title} eq 'Test Feast',         'title 1');
ok($test_offices[0]{rite}  == DOUBLE_RITE,          'rite 1');
ok($test_offices[1]{title} eq 'Another Test Feast', 'title 2');
ok($test_offices[1]{rite}  == SIMPLE_RITE,          'rite 2');

done_testing();

__DATA__

[01-01]
Circumcision
Festum duplex II. classis

[Pent14-0]
14th Sunday after Pentecost
Dominica semiduplex

[test]
Test Feast
Festum duplex
filename=abc

Another Test Feast
Festum simplex
filename=def

