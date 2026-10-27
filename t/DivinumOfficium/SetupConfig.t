use strict;
use warnings;
use Test2::V0;

# The Options page and the settings cookie depend on the parameter tables in
# {horas,missa}.dialog and {horas,missa}.setup staying consistent (see
# set_runtime_options/getsetupvalue in web/cgi-bin/DivinumOfficium, and
# getcookies in webdia.pl). A dialog entry's slot is its declared position
# (or the next implicit number), and that slot of the setup file must carry
# the same variable: that is where the initial default value is read from.
# The "parameterscheck" string is the cookie fingerprint its length must
# equal the slot count, or returning visitors silently lose their settings.

sub read_section {
  my ($file, $section) = @_;
  open(my $fh, '<', $file) or die "cannot read $file: $!";
  my ($in, @lines) = (0);
  while (my $line = <$fh>) {
    chomp $line;
    if ($line =~ /^\s*\[([^\]]+)\]/) { $in = ($1 eq $section); next; }
    push @lines, $line if $in && $line !~ /^\s*$/;
  }
  close $fh;
  return \@lines;
}

my @configs = (
  { dialog => 'web/www/horas/horas.dialog', setup => 'web/www/horas/horas.setup' },
  { dialog => 'web/www/missa/missa.dialog', setup => 'web/www/missa/missa.setup' },
);

for my $cfg (@configs) {
  my $name = ($cfg->{dialog} =~ s{.*/(.*)\.dialog$}{$1}r);

  # dialog [parameters]: label~>$var~>mode~>par~>pos ... ';;'-joined.
  # Positions follow set_runtime_options: an explicit numeric pos wins,
  # otherwise the next implicit counter (which only counts implicit entries).
  my $dialog = join(';;', @{ read_section($cfg->{dialog}, 'parameters') });
  my @params;
  my $implicit = 1;
  for my $item (split(/;;/, $dialog)) {
    my (undef, $var, $mode, undef, $pos) = split(/~>/, $item);
    next unless defined $var && $var =~ /^\$\w+$/;
    $pos = $implicit++ if !defined($pos) || $pos !~ /^\d+$/;
    push @params, { var => $var, pos => $pos };
  }
  ok(@params >= 1, "$name: dialog [parameters] parsed") or BAIL_OUT("$name: dialog unreadable");

  my @values = grep { /\S/ } split(/;;/, join(';;', @{ read_section($cfg->{setup}, 'parameters') }));

  is(scalar(@params), scalar(@values), "$name: dialog and setup slot counts match")
    or note('dialog: ' . join(',', map { "$_->{var}@$_->{pos}" } @params));

  my $check = join('', @{ read_section($cfg->{setup}, 'parameterscheck') });
  $check =~ s/\s//g;
  is(length($check), scalar(@params), "$name: check string length == slot count");

  # slot p (1-based position declared in the dialog) must name the same variable
  for my $p (@params) {
    my $slot = $values[ $p->{pos} - 1 ];
    ok(defined $slot, "$name: setup has slot $p->{pos} (for $p->{var})") or next;
    like($slot, qr/^\Q$p->{var}\E='/, "$name: setup slot $p->{pos} is $p->{var}");
  }

  # no two dialog entries may share a slot
  my %seen;
  for my $p (@params) {
    is($seen{ $p->{pos} }++, 0, "$name: slot $p->{pos} declared only once");
  }
}

done_testing;
