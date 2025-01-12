use utf8;

# required by kalendar.pl when ouput ical

# prepare ical output
sub ical_output {
  my ($output) = <<"EOH";
Content-Type: text/calendar; charset=utf-8
Content-Disposition: attachment; filename="$version1 - $kyear.ics"

BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//divinumofficium.com//
CALSCALE:GREGORIAN
SOURCE:https://divinumofficium.com/cgi-bin/horas/kalendar.pl
EOH

  my ($to) = 365 + leapyear($kyear);
  my (@date) = reverse((localtime(time()))[0 .. 5]);
  $date[0] += 1900;
  $date[1]++;
  my ($dtstamp) = sprintf("%04i%02i%02iT%02i%02i%02i", @date);

  for my $cday (1 .. $to) {
    my ($yday, $ymonth, $yyear) = ydays_to_date($cday, $kyear);
    my ($dtstart) = sprintf("%04i%02i%02i", $yyear, $ymonth, $yday);
    my $day = sprintf("%02i-%02i-%04i", $ymonth, $yday, $yyear);
    my ($e) = ordo_entry($day, $version1, '', 'winneronly');
    $e = abbreviate_entry($e);
    $output .= <<"EOE";
BEGIN:VEVENT
UID:$cday
DTSTAMP:$dtstamp
SUMMARY:$e
DTSTART;VALUE=DATE:$dtstart
END:VEVENT
EOE
  }
  print "${output}END:VCALENDAR\n";
}

# abbreviate entries for ical
sub abbreviate_entry {
  $_ = shift;
  s/Duplex majus/dxm/;
  s/Duplex/dx/;
  s/Semiduplex/sdx/;
  s/Simplex/splx/;
  s/classis/cl./;
  s/ Domini Nostri Jesu Christi/ D.N.J.C./;
  s/Beatæ Mariæ Virginis/B.M.V./;
  s/Abbatis/Abb./;
  s/Apostoli/Ap./;
  s/Apostolorum/App./;
  s/Confessor\w+/Conf./g;
  s/Doctoris/Doct./;
  s/Ecclesiæ/Eccl./;
  s/Episcopi/Ep./;
  s/Episcoporum/Epp./;
  s/Evangelistæ/Evang./;
  s/Martyris/M./g;
  s/Martyrum/Mm./g;
  s/Papæ/P./g;
  s/Viduæ/Vid./;
  s/Virgin\w+/Vir./;
  s/Hebdomadam/Hebd./i;
  s/Quadragesim./Quad./i;
  s/Secunda/II/;
  s/Tertia/III/;
  s/Quarta/IV/;
  s/Quinta/V/;
  s/Sexta/VI/;
  s/Dominica minor/Dom. min./;
  s/ Ferial//;
  s/Feria major/Fer. maj./;
  s/Feria privilegiata/Fer. priv./;
  s/post Octavam/post Oct./;
  s/Augusti/Aug./;
  s/(Septem|Octo|Novem|Decem)bris/${1}b./;
  $_;
}

1;
