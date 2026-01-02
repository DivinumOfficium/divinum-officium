use utf8;

# required by kalendar.pl when dispaly Kalendarium

# roman numbers only to 1-29 used by romanday & epactcycle
sub romannumber {
  my $d = $_[0];
  my $o;

  if ($d > 19) { $o = 'x'; $d -= 10; }
  if ($d > 9) { $o .= 'x'; $d -= 10; }

  if ($d == 9) {
    $o .= 'ix';
  } elsif ($d == 4) {
    $o .= 'iv';
  } else {
    if ($d > 4) { $o .= 'v'; $d -= 5 }
    $o .= 'i' x $d;
  }
  $o =~ s/i$/j/ unless $version =~ /196/;
  $o;
}

# romanday for mm-dd
sub romanday {
  my $m = substr($_[0], 0, 2);
  my $d = substr($_[0], 3, 2);
  return '{Kal.}' if $d == 1;
  my $id = $m == 3 || $m == 5 || $m == 7 || $m == 10 ? 15 : 13;
  return '{Idib.}' if $d == $id;
  return '{Prid.}' if $d == (MONTHLENGTH)[$m] || $d == ($id - 1);
  return romannumber((MONTHLENGTH)[$m] - $d + 2) if $d > $id;
  my $no = $id - 8;
  return '{Non.}' if $d == $no;
  return '{Prid.}' if $d == ($no - 1);
  return romannumber($id - $d + 1) if $d > $no;
  romannumber($no - $d + 1);
}

# dominica letter
sub domlet {
  use feature qw(state);
  state $domletc = -1;

  substr('Abcdefg', ++$domletc % 7, 1) =~ s/A/{A}/r;
}

# epact cycle for day of year
sub epactcycle {
  my ($d) = @_;

  use integer;
  use constant STARDAYS => (1, 31, 60, 90, 119, 149, 178, 208, 237, 267, 296, 326, 355, 385);

  return '19 {xx}' if $d == 365;

  my $i = 0;
  while ($d > (STARDAYS)[$i++]) { }

  my $r = (STARDAYS)[$i - 1] - $d;
  return '{*}' unless $r;

  my $o = '';

  if ($i % 2) {
    $r++;
    $o = '25. ' if $r == 26;
    $o = '{xxv.} ' if $r == 25;
    $r-- if $r < 26;
  } else {
    $o = '25. ' if $r == 25;
  }

  "$o\{" . romannumber($r) . '}';
}

# latin uppercase
sub latin_uppercase {
  local ($_) = shift;
  s/.*/\U$&/;
  s/æ/Æ/rg;
}

# findkalentry - read rank from sancti file
sub findkalentry {
  my ($entry, $ver) = @_;
  our $winner = subdirname('Sancti', $ver) . "$entry.txt";
  $version = $ver;
  my %saint = %{setupstring('Latin', "$winner")};

  my @srank = split(";;", $saint{Rank});

  return '' unless $srank[0];

  our $rank = @srank[2];
  my $rankname = rankname('Latin');

  # TODO: get rid of below line when setupstring respects version conditionals
  $rankname =~ s/IV. classis/Memoria/ if $ver =~ /Monastic|Ordo Praedicatorum/;

  (
    setfont(
      liturgical_color($srank[0]),
      $rank > 4 && $srank[0] !~ /octava|vigilia/i ? latin_uppercase($srank[0]) : $srank[0],
    ),
    setfont('1 maroon', ' ' . $rankname),
  );
}

# prepare one day entry in kalendar
sub kalendar_entry {
  my ($date, $ver) = @_;

  $date = substr($date, 0, 5);
  my @kalentries = split('~', get_from_directorium('kalendar', $ver, $date));
  return '' unless @kalentries;

  my $s = shift @kalentries;

  my $output = join(' ', findkalentry($s, $ver));

  $output = '' if $ver =~ /1955|196/ && $date =~ /01-(?:0[7-9]|1[012])/;

  while (my $ke = shift @kalentries) {
    my ($d1, $d2) = findkalentry($ke, $ver);
    $output .= ' Com. ' . $d1;
  }

  $output;
}

# prepare row
sub table_row {
  my ($date, $cday) = @_;
  my ($d) = substr($date, 3, 2) + 0;
  our ($version1, $compare, $version2);

  my ($c) = kalendar_entry($date, $version1);
  $c .= '&nbsp;<br/>' . (kalendar_entry($date, $version2) || '&nbsp;') if $compare;
  (epactcycle($cday, substr($date, 0, 2)), domlet(), romanday($date), $d, $c);
}

# notes for kalendar: bissectal, nigra19
sub note {
  my ($note) = shift;
  my %comm = %{setupstring($lang1, 'Psalterium/Comment.txt')};
  my $output = '<TR><TD COLSPAN="5" ALIGN="LEFT">';
  $output .= setfont('1', $comm{"$note note"}) . '</TD></TR>';
}

# html_header
sub html_header {
  htmlHead('Kalendarium');

  my $vers = $version1;
  $vers .= ' / ' . $version2 if $compare;

  my $output = <<"PrintTag";
<A ID="top"></A>
<H1>
<FONT COLOR="MAROON" SIZE="+1"><B><I>Kalendarium</I></B></FONT>&ensp;
<FONT COLOR="RED" SIZE="+1">$vers</FONT>
</H1>
<P ALIGN="CENTER">
<A HREF="#" onclick="callbrevi();">Divinum Officium</A>&nbsp;&ensp;
<A HREF="#" onclick="callmissa();">Sancta Missa</A>&nbsp;&ensp;
<A HREF="#" onclick="setkm(0);">Ordo</A>
</P><P ALIGN="CENTER">
PrintTag

  foreach my $i (1 .. 12) {
    my $mn = substr((MONTHNAMES)[$i], 0, 3);
    $mn = qq(<A HREF="#$mn">$mn</A>) unless $i == 1;
    $output .= "$mn&nbsp;&ensp;";
  }

  $output .= '</P>';

}

1;
