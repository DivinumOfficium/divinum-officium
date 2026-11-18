# required by kalendar.pl when display Ordinarium
use utf8;

# prepare one day entry in ordo
sub ordo_entry {
  my ($date, $ver, $dioe, $compare, $winneronly) = @_;

  our $version = $ver;
  our $dioecesis = $dioe;
  our ($day, $month, $year, $dayname, @commemoentries);

  # Speeding up Ordo by calling occurrence and concurrence directly instead of precedence:
  our ($winner, $commemoratio, $commemoratio1, $commune, $scriptura) = ('') x 5;
  our (%winner, %commemoratio, %commemoratio1, %commune, %scriptura) = () x 5;
  our ($C10, $chantTone) = ('') x 2;

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

  my ($c1, $c2, $c3, $cv, $scripturaUt);
  $c1 = "<B>" . setfont(liturgical_color($h1), $h1) . "</B>" . setfont('1 maroon', "&ensp;$h2");
  $c1 =~ s/Hebdomadam/Hebd/i;
  $c1 =~ s/Quadragesima/Quadr/i;

  # Genuine Commemoratio information only
  $c2 = $dayname[2];
  $c2 =~ s/Hebdomadam/Hebd/gi;
  $c2 =~ s/Quadragesima/Quadr/gi;
  ($h1, $h2) = split(/: /, $c2, 2);

  if ($h2 =~ s/\(Scriptura ut in\: (.*)\)//) {
    $scripturaUt = setfont('1 maroon', "Scriptura ut in") . setfont(liturgical_color($2), " $2");
  }
  ($c2, $h1, $h2) = ('', '', $h1) unless $h2;
  $c2 = setfont($smallblack, "$h1:") if $h1;
  $c2 .= "<I>" . setfont(liturgical_color($h2), " $h2") . "</I>" if $h2;

  # Extract and format Scriptura information
  $c3 = $dayname[3];
  $c3 =~ s/Hebdomadam/Hebd/i;
  $c3 =~ s/Quadragesima/Quadr/i;

  while ($c3 =~ s/([LlRr]+\d+(?: Inc[ií]pit| Inc[ií]piunt| propria| Homilia)?)(.*?(?: ex? | ut in |$))(.*)//m) {
    $scripturaUt .= setfont($smallfont, "*$1* ") . setfont('1 maroon', "$2") . setfont(liturgical_color($3), "$3<br/>");
  }
  $scripturaUt =~ s/Hebdomadam/Hebd/i;
  $scripturaUt =~ s/Quadragesima/Quadr/i;
  $scripturaUt =~ s/(.+)<br\/>/$1/s;

  ($h1, $h2) = split(/: /, $c3, 2);
  ($c3, $h1, $h2) = ('', '', $h1) unless $h2;
  $c3 = setfont($smallblack, "$h1:") if $h1;
  $c3 .= "<I>" . setfont(liturgical_color($h2), " $h2") . "</I>" if $h2;

  # Gather further Commemorations
  my $extraComm;

  if (@commemoentries > ($winner =~ /Tempora/i && $commemoentries[0] !~ /Tempora/ ? 0 : 1)) {
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

      $extraComm .=
        " <I>" . setfont($smallblack, "&amp;") . setfont(liturgical_color($comRank[0]), " $comRank[0]") . "</I>"
        if $comRank[0];

      # Under the 1960 rubrics, on II. cl and higher days, allow at most one commemoration.
      last if ($version =~ /1960/ && $rank >= 5 || ($rank >= 4 && $winner{Rank} =~ /Feria|Sabbato/i));
    }
  }

  return "$c2 $extraComm" if $winneronly =~ /comm/i;    # finish here for ical_comm - comm

  if ($version !~ /1955|196/ && $winner{Rule} =~ /\;mtv/i) {
    $c1 .= setfont('1 black', ' m.t.v.');
  }

  my @wRank = split(';;', $winner{Rank});

  if (substr($date, 0, 5) lt '12-24' && substr($date, 0, 5) gt '01-13') {

    if ($winner =~ /sancti/i) {

      # Outside Tempora Nativitatis aut Epihaniae
      # We put Sancti winner from left in right column
      # If the left column is now empty or the first Commemoration is from a Saint, we put the Temporal information left
      # and append all the gathered Commemorations into the second column with the Sancti winner
      ($c2, $c1) = ($c1, $c2);
      ($c3, $c1) = ($c1, $c3) if !$c1 || $c1 =~ /Commemoratio/i && $commemoentries[0] !~ /Tempora/;
      $extraComm =~ s/^ <I>(.*?)&amp;<\/FONT>/$1Commemoratio:<\/FONT><I>/ unless $c3;
      $extraComm = $c3 . $extraComm;
    }
    $c2 .= "<br /> $extraComm" if $extraComm;

  } else {

    # Inside Tempora Nativitatis we clear right column unless it is commemoratio of saint
    # and put scripture information into the last column below
    $c2 = '' unless $c2 =~ /Commemoratio/;
    $scripturaUt = setfont('1 maroon', $1) . $c3 if $c3 =~ s/<FONT SIZE='-1' >(Scriptura:)<\/FONT>//;
    $c3 = '';
  }

  if (dirge($version, 'Laudes', $day, $month, $year, $dioecesis)) { $c1 .= setfont($smallblack, ' dirge'); }

  if ($version !~ /1960/ && $initia) {

    # We mark days that would have an Incipit even if superseded so we can spot and transfer the readings
    $c1 .= setfont($smallfont, ' *I*');
  }

  # Gather Vesper information
  our $hora;
  my $temphora = $hora;
  $hora = 'Vespera';
  concurrence($day, $month, $year, $version, $dioecesis);    # Replacing precedence()
  $hora = $temphora;
  my $cv = $dayname[3];
  $cv =~ s/.*?(A capitulo)/Vespera \l$1/;
  $cv =~ s/.*?(Vespera|$)/$1/;
  $cv =~ s/(era|itulo|uenti|memoratio|edenti|urente|ore|icio)\.?/./gs;
  $cv = setfont('1 maroon', $cv) if $cv;

  # Add Lectiones in primo Nocturno Information
  $cv = "$scripturaUt<br/>$cv" if $scripturaUt;

  if ($compare) {
    $c1 ||= '&mdash;';
    $c2 ||= '&mdash;';
    $cv ||= '&mdash;';
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
    $c1 .= "<br/><DIV style=\"padding-left:1em\">$c21</DIV>";
    $c2 .= "<br/><DIV style=\"padding-left:1em\">$c22</DIV>";
    $cv .= "<br/><DIV style=\"padding-left:1em\">$cv2</DIV>";
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

