#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-25-04
# dialog/setup related subs
$a = 4;
require "$Bin/../DivinumOfficium/SetupString.pl";

#*** getini(file)
# loads and interprets .ini file
# the file consists of $var='value' lines
sub getini {
  my $file = shift;
  eval for do_read("$Bin/$file.ini");
}

#*** chompd($str)
# removes the newline characters from the end of the string
# returns the modified string
sub chompd {
  my $a = shift;
  chomp($a);
  $a =~ s/\r//g;
  return $a;
}

local %_dialog;

#*** getdialog($name, $sep, $col)
# returns the array of the $col-th column from $dialog{$name} hash element
# the hash value is cleared from newline characters and is split
# into and string array where the elements are separated by , comma
# Each string is split by $sep separator, and the $col-th element
# of this split is collected onto the returned array.
sub getdialog {
  my ($name) = @_;

  if (!$_dialog{'loaded'}) {
    $datafolder =~ /(missa|horas)$/;
    %_dialog = %{setupstring('', "$1.dialog")};
    foreach (keys %_dialog) { chomp($_dialog{$_}) }
    $_dialog{'loaded'} = 1;
  }
  chomp($_dialog{$name});

  if (wantarray) {
    return split(',', $_dialog{$name});
  } else {
    return $_dialog{$name};
  }
}

sub gethoras {
  my ($C9f) = @_;
  my @horas = getdialog('horas');
  @horas = @horas[0, 1, 6] if ($C9f);
  $horas[-1] =~ s/\s*$//;
  @horas;
}

sub set_runtime_options {
  my ($name) = @_;
  my @parameters = split(/;;\r?\n/, getdialog($name));

  # pop(@parameters);
  my @setupt = split(/;;/, getsetup($name));

  # pop(@setupt);
  my $p = undef;
  my $i = 1;

  foreach (@parameters) {
    my ($parname, $parvalue, $parmode, $parpar, $parpos, $parfunc, $parhelp) = split('~>');

    if ($parpos !~ /^\d+$/) {
      $parpos = $i;
      $i++;
    }
    $parvalue = substr($parvalue, 1);

    if ($p = strictparam($parvalue)) {
      setsetupvalue($name, $parpos - 1, $p);
    } else {
      $p = substr($setupt[$parpos - 1], index($setupt[$parpos - 1], '=') + 2, -1);
    }
    $$parvalue = $p;
  }
  $blackfont =~ s/black//;    # can't use black in contrast mode
  $smallblack =~ s/black//;
}

#*** version_displayname
# outputs version name for display (part before '/')
sub version_displayname {
  my $version = shift;
  my $s = getdialog('versions');
  my $i = index($s, $version) - 1;

  if ($i == -1 || (substr($s, $i, 1) eq ',')) {
    $version;
  } else {
    my $k = rindex(substr($s, 0, $i - 1), ',') + 1;
    substr($s, $k, $i - $k);
  }
}

1;
