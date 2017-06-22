#!/usr/bin/perl

use strict;
use warnings;

use DateTime;
use List::MoreUtils qw(zip);

while (<>)
{
  # Strip comments and ignore blank lines.
  s/#.*//;
  next unless $_;

  # Expand date ranges.
  s/^(\d+-\d+-\d+)$/$1:$1/;
  s/(\d+)-(\d+)-(\d+):(\d+)-(\d+)-(\d+)/expand_dates($1, $2, $3, $4, $5, $6)/e;

  print;
}

sub expand_dates
{
  my @keys = ('month', 'day', 'year');
  my @start_mdy = @_[0..2];
  my @end_mdy   = @_[3..5];
  my $rover = DateTime->new(zip(@keys, @start_mdy));
  my $end   = DateTime->new(zip(@keys, @end_mdy));

  my @dates;

  while ($rover <= $end)
  {
    push @dates, $rover->mdy('-');
    $rover->add(days => 1);
  }

  return join("\n", @dates);
}
