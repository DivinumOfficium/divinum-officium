#!/usr/bin/env perl
use strict;
use warnings;
use JSON::PP;
use Storable qw(nstore);
use File::Basename qw(dirname);

my $base = dirname(__FILE__);

open(my $fh, '<:raw', "$base/latin_lexicon.json") or die "Cannot open latin_lexicon.json: $!";
my $json = do { local $/; <$fh> };
my %lex = %{decode_json($json)};

open($fh, '<:raw', "$base/lexicon_overrides.json") or die "Cannot open lexicon_overrides.json: $!";
$json = do { local $/; <$fh> };
my $overrides = decode_json($json);

for my $k (keys %$overrides) {
  if ($overrides->{$k} eq '') {
    delete $lex{$k};
  } else {
    $lex{$k} = $overrides->{$k};
  }
}

nstore(\%lex, "$base/latin_lexicon.storable");
printf "Written: %s (%d entries)\n", "$base/latin_lexicon.storable", scalar keys %lex;
