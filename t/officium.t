# Executes officium.pl over a bunch of input parameters to make sure that it
# doesn't fall over.

use strict;
use warnings;

use Test::More;
use Test::Cmd;

use DivinumOfficium::Time qw(ordinal_date next_date_mdy);

my @versions = ('Divino Afflatu', 'Rubrics 1960');
my @hours = ('Vespera');

my @start_date_mdy = (1, 1, 2000);  # Inclusive
my @end_date_mdy = (1, 1, 2004);    # Exclusive
my $days_count = ordinal_date(@end_date_mdy) - ordinal_date(@start_date_mdy);

my $test = Test::Cmd->new(prog => $^X, workdir => '') or
  die 'Failed to create Test::Cmd object';
my @common_args = (
  '-I web/cgi-bin/',
  'web/cgi-bin/horas/officium.pl',
);

foreach my $version (@versions)
{
  my @args = (@common_args, "version='$version'");
  for(
    my $day_idx = 0, my @date_mdy = @start_date_mdy;
    $day_idx < $days_count;
    $day_idx++, @date_mdy = next_date_mdy(@date_mdy)
  )
  {
    push @args, 'date=' . join('-', @date_mdy);
    foreach my $hour (@hours)
    {
      push @args, "command=pray$hour";
      $test->run(args => join(' ', @args));
      ok($? == 0, 'args = ' . join(', ', @args));
      pop @args;
    }
    pop @args;
  }
}

done_testing();

