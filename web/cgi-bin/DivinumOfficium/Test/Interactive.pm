# This module is designed to be used with the Perl debugger to bootstrap
# enough stuff to allow interactive testing.

package horas;
use DivinumOfficium::Calendar::Definitions;
BEGIN
{
  require 'horas/horascommon.pl';
  require 'horas/do_io.pl';
  require 'horas/dialogcommon.pl';
}

our $version //= 'Divino afflatu';

package DivinumOfficium::Test::Interactive;

use strict;
use warnings;

use DivinumOfficium::Calendar::Definitions;
use DivinumOfficium::Calendar::Data qw(load_calendar_file);
use DivinumOfficium::Main qw(initialise_hour);

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT = qw(cal initialise_hour);
}

our $cal = load_calendar_file('web/www/horas', 'Kalendaria/generalis.txt');

1;

