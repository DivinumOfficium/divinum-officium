use strict;
no strict 'refs'; # We invoke scalars as subs.
use warnings;

use DivinumOfficium::Output::HTMLFormatter;

use Test::More;
use Test::HTML::Lint;

my %test_methods = (
  formatting_method => 'blue',
  another_method => '+1',
);

my $formatter = DivinumOfficium::Output::HTMLFormatter->new(%test_methods);

# Test dynamic methods.
foreach my $method (keys(%test_methods))
{
  print "# $method\n";
  my $result = $formatter->$method('test');
  ok($result, 'Result evaluates to true');
  html_ok($result);
}

# Make sure we can't create multiple instances.
{
  package DivinumOfficium::Output::HTMLFormatter;
  use Test::Carp;
  does_croak(sub { DivinumOfficium::Output::HTMLFormatter->new() });
}

done_testing();

