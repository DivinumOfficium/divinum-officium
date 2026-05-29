# required by kalendar.pl when display Ordinarium
use utf8;

# prepare one day entry in ordo
sub ordo_entry {
  my ($date, $ver, $dioe, $compare, $winneronly) = @_;

  our $version = $ver;
  our $dioecesis = $dioe;
  our ($day, $month, $year, $dayname, %scriptura, @commemoentries);

  # Speeding up Ordo by calling occurrence and concurrence directly instead of precedence:
  our ($winner, $commemoratio, $commemoratio1, $commune, $scriptura);
  our (%winner, %commemoratio, %commemoratio1, %commune, %scriptura);
  our ($C10, $chantTone);

  ($month, $day, $year) = split('-', $date);
  our $dayofweek = day_of_week($day, $month, $year);
  @dayname = (getweek($day, $month, $year, 0, 0), '', '');
  $C10 = 'C10';

  occurrence($day, $month, $year, $version, $dioecesis, 0);    # Replacing precedence()
  %winner = %{officestring($lang1, $winner, 0)};
  setChantTone() if ($lang1 =~ /gabc/i);    # GABC: set ChantTone depending on the solemnity of the day

  my ($h1, $h2) = split(/\s*~\s*/, setheadline());
  return "$h1, $h2" if $winneronly =~ /winneronly/;    # finish here for ical
  return "$h1 ($h2)" if $winneronly =~ /winnerupd/;    # finish here for ical_comm

  my ($c1, $c2);
  $c1 = "<B>" . setfont(liturgical_color($h1), $h1) . "</B>" . setfont('1 maroon', "&ensp;$h2");
  $c1 =~ s/Hebdomadam/Hebd/i;
  $c1 =~ s/Quadragesima/Quadr/i;

  $c2 = $dayname[2];

  ($h1, $h2) = split(/: /, $c2, 2);
  $h2 =~ s/(\(Scriptura ut in\: .*\))//;
  my $scripturaUt = $1;
  ($c2, $h1, $h2) = ('', '', $h1) unless $h2;
  $c2 = setfont($smallblack, "$h1:") if $h1;
  $c2 .= "<I>" . setfont(liturgical_color($h2), " $h2") . "</I>" if $h2;
  $c2 .= "<I>" . setfont($smallblack, " $scripturaUt") . "</I>" if $scripturaUt;

  if ($c2 && @commemoentries > ($winner =~ /Tempora/i && $commemoentries[0] !~ /Tempora/ ? 0 : 1)) {
    for my $ind (($winner =~ /Tempora/i && $commemoentries[0] !~ /Tempora/ ? 0 : 1) .. @commemoentries - 1) {
      my %com = %{setupstring('Latin', "$commemoentries[$ind].txt")};
      my @comRank = split(';;', $com{Rank});

      # 1960: No Commemoration of Festum Domini on Festum Domini and Vigil of Peter and Paul on Sunday
      last
        if (
          $version =~ /196/
          && ( ($winner{Rule} =~ /Festum Domini/ && $commemoratio{Rule} =~ /Festum Domini/i)
            || (($commemoratio =~ /06-28r?/i || $winner{Rule} =~ /No Sunday commemoratio/i) && $dayofweek == 0))
        );

      # No Commemoration of Common Octaves on feasts Duplex I. or II. classis
      next if ($comRank[2] < 2.1 && $comRank[0] =~ /Infra Octav/i && $rank >= 5 && $winner =~ /Sancti/i);

      $c2 .= " <I>&amp; " . setfont(liturgical_color($comRank[0]), " $comRank[0]") . "</I>" if $comRank[0];

      # Under the 1960 rubrics, on II. cl and higher days, allow at most one commemoration.
      last if ($version =~ /1960/ && $rank >= 5 || ($rank >= 4 && $winner{Rank} =~ /Feria|Sabbato/i));
    }
  }

  return "$c2" if $winneronly =~ /comm/i;    # finish here for ical_comm - comm

  $c2 =~ s/Hebdomadam/Hebd/i;
  $c2 =~ s/Quadragesima/Quadr/i;

  if (
       $version !~ /196/
    && $winner =~ /Sancti/
    && (
      (
           exists($winner{Lectio1})
        && $winner{Lectio1} !~ /\@Commune/i
        && $winner{Lectio1} !~ /\!(Matt|Marc|Luc|Joannes)\s+[0-9]+\:[0-9]+\-[0-9]+/i
      )
      || $winner{Rule} =~ /In 1 nocturno lectiones ex C/i
    )
    && !($winner{Rule} =~ /Lectio1 Quad/i && $dayname[0] !~ /Quad(\d|p3\-[3456])/i)
  ) {
    $c1 .= setfont($smallfont, " *L1*");
  }

  if (substr($date, 0, 5) lt '12-24' && substr($date, 0, 5) gt '01-13') {

    # outside Nat put Sancti winner in right column
    ($c2, $c1) = ($c1, $c2) if $winner =~ /sancti/i;
  } else {

    # inside Nat clear right column unless it is commemoratio of saint or scriptura
    $c2 = '' unless $c2 =~ /Commemoratio|Scriptura/;
  }

  if (dirge($version, 'Laudes', $day, $month, $year, $dioecesis)) { $c1 .= setfont($smallblack, ' dirge'); }
  if ($version !~ /1960/ && $initia) { $c1 .= setfont($smallfont, ' *I*'); }

  if ($version !~ /1955|196/ && $winner{Rule} =~ /\;mtv/i) {
    $c2 .= setfont($smallblack, ' m.t.v.');
  }

  our $hora;
  my $temphora = $hora;
  $hora = 'Vespera';
  concurrence($day, $month, $year, $version, $dioecesis);    # Replacing precedence()
  $hora = $temphora;
  my $cv = $dayname[2];
  $cv =~ s/.*?(Vespera|A capitulo|$)/$1/;

  if ($compare) {
    $c2 ||= '_';
    $cv ||= '_';
  }
  return ($c1, $c2, $cv);
}

# prepare row
sub table_row {
  my ($date) = shift;
  our ($version1, $compare, $version2, $dayofweek, $dioecesis);

  my $d = substr($date, 3, 2) + 0;
  my ($c1, $c2, $cv) = ordo_entry($date, $version1, $dioecesis, $compare);

  if ($compare) {
    my ($c21, $c22, $cv2) = ordo_entry($date, $version2, $dioecesis, $compare);
    $c1 .= "<br/>$c21";
    $c2 .= "<br/>$c22";
    $cv .= "<br/>$cv2";
  }
  (
    qq(<A HREF=# onclick="callbrevi('$date');">$d</A>),
    $c1, $c2,
    qq(<FONT SIZE="-2">$cv</FONT>),
    @{[(DAYNAMES)[$dayofweek]]},
  );
}

# html_header_ordo
sub html_header {
  htmlHead("Ordo: @{[(MONTHNAMES)[$kmonth]]} $kyear");

  my $vers = $version1;
  $vers .= ' / ' . $version2 if $compare;

  my $output = <<"PrintTag";
<H1>
<FONT COLOR="MAROON" SIZE="+1"><B><I>Divinum Officium</I></B></FONT>&nbsp;
<FONT COLOR="RED" SIZE="+1">$vers</FONT>
</H1>
<P ALIGN="CENTER">
<A HREF=# onclick="setkm(15)">Kalendarium</A>&ensp;
<FONT COLOR="MAROON" SIZE="+1"><B><I>Ordo @{[(MONTHNAMES)[$kmonth]]} A. D.</I></B></FONT>&nbsp;
<LABEL FOR="kyear" CLASS="offscreen">Year</LABEL>
<INPUT TYPE="TEXT" ID="kyear" NAME="kyear" VALUE="$kyear" SIZE=4>
<A HREF=# onclick="prevnext(-1)">&darr;</A>
<INPUT TYPE="submit" NAME="SUBMIT" VALUE=" " onclick="document.forms[0].submit();">
<A HREF=# onclick="prevnext(1)">&uarr;</A>
&ensp;<A HREF=# onclick="setkm(14)">Totus</A>
</P><P ALIGN="CENTER">
PrintTag

  my @mmenu;
  push(@mmenu, "<A HREF=# onclick=\"setkm(-1)\">«</A>\n") if $kmonth == 1;

  foreach my $i (1 .. 12) {
    my $mn = substr((MONTHNAMES)[$i], 0, 3);
    $mn = "<A HREF=# onclick=\"setkm($i)\">$mn</A>\n" unless $i == $kmonth;
    push(@mmenu, $mn);
  }
  push(@mmenu, "<A HREF=# onclick=\"setkm(13)\">»</A>\n") if $kmonth == 12;

  $output . join('&nbsp;' x 3, @mmenu) . '</P>';
}

1;

