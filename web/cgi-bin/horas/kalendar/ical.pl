use utf8;

# required by kalendar.pl when ouput ical
#

sub uuid {
  open my $fh, "/proc/sys/kernel/random/uuid";
  scalar <$fh>;
}

# If uuid() fails due to environment let's produce a standardised UID instead
sub fallbackUID {
  my ($dateString, $ver, $dioe) = @_;
  $ver =~ s/[\s\-]//gi;
  $dateString =~ /(\d{2})\-(\d{2})\-(\d{4})/;
  return "$3$1$2T120000Z-$ver:$dioe\@divinumofficium.com";
}

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
    my ($e) = ordo_entry($day, $version1, $dioecesis, '', 'winneronly');

    $e = abbreviate_entry($e);
    my $uid = uuid() || fallbackUID($day, $version1, $dioecesis);
    $output .= <<"EOE";
BEGIN:VEVENT
UID:$uid
DTSTAMP:$dtstamp
SUMMARY:$e
DTSTART;VALUE=DATE:$dtstart
END:VEVENT
EOE
  }
  print "${output}END:VCALENDAR\n";
}

# prepare ical output with commemorations
sub ical_comm_output {
  my $officium = shift;
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
    my ($e) = ordo_entry($day, $version1, $dioecesis, '', 'winnerupd');
    my ($d) = ordo_entry($day, $version1, $dioecesis, '', 'comm');

    $e = abbreviate_entry($e);
    my $version1_url = $version1 =~ s/ /\%20/gr;
    my $version1_uid = $version1 =~ s/ //gr;
    my $d_html = format_ics_html($d);
    $d = abbreviate_entry($d);
    $output .= <<"EOE";
BEGIN:VEVENT
UID:$day-$version1_uid\@divinumofficium
DTSTAMP:$dtstamp
DTSTART;VALUE=DATE:$dtstart
SUMMARY:$e
DESCRIPTION:$d
$d_html
URL:https://divinumofficium.com/cgi-bin/horas/$officium?date1=$day&version=$version1_url&dioecesis=$dioecesis
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
  s/Vigilia ?privilegiata/Vigil. priv./;
  s/post Octavam/post Oct./;
  s/Augusti/Aug./;
  s/(Septem|Octo|Novem|Decem)bris/${1}b./;
  s/\&amp; /&/g;
  s/\<.*?\>//g;
  $_;
}

# Splits the X-ALT-DESC line to be maximum of 75 characters long (ICS format requirement)
sub format_ics_html {
  my ($html_string) = @_;
  my $full_line = "X-ALT-DESC;FMTTYPE=text/html:" . $html_string;

  #  The first line can be up to 75 characters.
  #  Subsequent lines can only be up to 74 characters + leading space
  my @folded_lines;

  if ($full_line =~ s/^(.{1,75})//) {
    push @folded_lines, $1;
  }

  while ($full_line =~ s/^(.{1,74})//) {
    push @folded_lines, " " . $1;
  }

  return join("\r\n", @folded_lines);
}

1;
