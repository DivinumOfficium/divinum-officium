# use warnings;
# use strict;
use utf8;

sub lectio_brevis_prima {

  my $lang = shift;

  our ($version, %winner, %winner2, %commune, %commune2, $winner, $commune);

  my %brevis = %{setupstring($lang, 'Psalterium/Special/Prima Special.txt')};
  my $name = gettempora("Lectio brevis Prima");
  my $brevis = $brevis{$name};
  my $comment = $name =~ /per annum/i ? 5 : 1;

  setbuild('Psalterium/Special/Prima Special', $name, 'Lectio brevis ord');

  #look for [Lectio Prima]
  if ($version !~ /1955|196|cist/i) {
    my $b;

    if (exists($winner{'Lectio Prima'})) {
      $b = columnsel($lang) ? $winner{'Lectio Prima'} : $winner2{'Lectio Prima'};
      setbuild2("Subst Lectio Prima $winner");
      $comment = 3;
    } elsif (exists($commune{'Lectio Prima'})) {
      $b = columnsel($lang) ? $commune{'Lectio Prima'} : $commune2{'Lectio Prima'};
      setbuild2("Subst Lectio Prima $commune");
      $comment = 4;
    }

    $brevis = $b || $brevis;
  }

  $brevis = "\$benedictio Prima\n$brevis" unless $version =~ /^Monastic/;
  $brevis .= "\n\$Tu autem";

  ($brevis, $comment);
}

sub capitulum_prima {

  my $lang = shift;
  my $withresponsory = shift;

  our ($dayofweek, $version, %winner, $commune, $rank, @dayname, $label, %winner2);

  my %brevis = %{setupstring($lang, 'Psalterium/Special/Prima Special.txt')};

  my $key =
    (    $dayofweek > 0
      && $version !~ /196/
      && $winner{Rank} =~ /Feria|Vigilia/i
      && $winner{Rank} !~ /Vigilia Epi/i
      && (!$commune || $commune !~ /C10/)
      && ($rank < 3 || $dayname[0] =~ /Quad6/)
      && $dayname[0] !~ /Pasc/i) ? 'Feria' : 'Dominica';

  my $capit = $brevis{$key} . "\n\$Deo gratias\n_\n";
  setbuild1('Capitulum', "Psalterium $key");

  if ($version =~ /1963/) {
    $capit = "$label\n" . $capit;
  } else {
    setcomment($label, 'Source', $key eq 'Feria', $lang);
  }

  my @resp;

  if ($withresponsory) {
    @resp = split("\n", $brevis{'Responsory'});
    my $primaresponsory = get_prima_responsory($lang);
    my %wpr = columnsel($lang) ? %winner : %winner2;
    if (exists($wpr{'Versum Prima'})) { $primaresponsory = $wpr{'Versum Prima'}; }
    if ($primaresponsory) { $resp[2] = "V. $primaresponsory"; }
    push(@resp, "_");
  }

  push(@resp, split("\n", $brevis{Versum}));

  postprocess_short_resp(@resp, $lang);

  $capit . join("\n", @resp);
}

sub get_prima_responsory {
  my $lang = shift;

  our ($version, $month, $day, %commemoratio, $rule);

  my $key = gettempora('Prima responsory');

  if ( $rule =~ /Doxology=(Nat|Epi|Pasch|Asc|Corp|Heart)/i
    || $commemoratio{Rule} =~ /Doxology=(Nat|Epi|Pasch|Asc|Corp|Heart)/i)
  {
    $key = $1;
  } elsif ($version !~ /196/ && $month == 8 && $day > 15 && $day < 23) {
    $key = 'Nat';
  }

  if ($version =~ /196/ && $month == 12 && $day > 8 && $day < 16 && $version !~ /Newcal/ && $day !~ 12) {
    $key = 'Adv';
  }

  if ($version =~ /196/ && $key =~ /Corp|Heart/) { $key = ''; }
  return '' unless $key;

  my %t = %{setupstring($lang, 'Psalterium/Special/Prima Special.txt')};
  return $t{"Responsory $key"};
}

#*** martyrologium($lang)
#returns the text of the martyrologium for the day
sub martyrologium {

  my $lang = shift;

  our ($version, $year, $month, $day, $dayofweek);

  my $t = '';    # Title and Comment is now set in specials.pl for #Martyrolgium

  my $a = getweek($day, $month, $year, 1) . "-" . (($dayofweek + 1) % 7);
  my %a = %{setupstring($lang, "Martyrologium/Mobile.txt")};

  if ($version =~ /1570/ && $lang =~ /Latin/i) {
    %a = %{setupstring($lang, "Martyrologium1570/Mobile.txt")};
  }

  if ($version =~ /1960|Newcal/ && $lang =~ /Latin/i) {
    %a = %{setupstring($lang, "Martyrologium1960/Mobile.txt")};
  }

  if ($version =~ /1955/ && $lang =~ /Latin/i) {
    %a = %{setupstring($lang, "Martyrologium1955R/Mobile.txt")};
  }
  my $mobile = '';
  my $hd = 0;
  if (exists($a{$a})) { $mobile = "$a{$a}\n"; }
  if ($month == 10 && $dayofweek == 6 && $day > 23 && $day < 31 && exists($a{'10-DU'})) { $mobile = $m{'10-DU'}; }
  if ($a =~ /Pasc0\-1/i) { $hd = 1; }
  if ($winner{Rank} =~ /ex C9/i && exists($a{'Defuncti'})) { $mobile = $a{'Defuncti'}; $hd = 1; }
  if ($month == 11 && $day == 14 && $version =~ /Monastic/i) { $mobile = $a{'DefunctiM'}; $hd = 1; }

  #if ($month == 12 && $day == 25 && exists($a{'Nativity'})) {$mobile = $a{'Nativity'}; $hd = 1;}
  if ($hd == 1) { $t = "v. $mobile" . "_\n$t"; $mobile = ''; }
  my $fname = nextday($month, $day, $year);
  my ($m, $d) = split('-', $fname);
  my $y = ($m == 1 && $d == 1) ? $year + 1 : $year;

  if ($version =~ /1570/ && $lang =~ /Latin/i && (-e "$datafolder/Latin/Martyrologium1570/$fname.txt")) {
    $fname = "$datafolder/Latin/Martyrologium1570/$fname.txt";
  } elsif ($version =~ /1960|Newcal/ && $lang =~ /Latin/i && (-e "$datafolder/Latin/Martyrologium1960/$fname.txt")) {
    $fname = "$datafolder/Latin/Martyrologium1960/$fname.txt";
  } elsif ($version =~ /1955/ && $lang =~ /Latin/i && (-e "$datafolder/Latin/Martyrologium1955R/$fname.txt")) {
    $fname = "$datafolder/Latin/Martyrologium1955R/$fname.txt";
  } else {
    $fname = checkfile($lang, "Martyrologium/$fname.txt");
  }

  if (my @a = do_read($fname)) {
    my ($luna, $mo) =
      ($year >= 1900 && $year < 2200)
      ? gregor($m, $d, $y, $lang)
      : luna($m, $d, $y, $lang);

    if ($lang =~ /Latin/i) {
      $a[0] .= " $luna";
    } else {
    FINDDATE:
      {
        foreach (@a) {
          last FINDDATE if s/^U[p]+on.*?$mo[, ]*/$luna /i;
        }

        # Put $luna at the start if and only if we didn't find a
        # suitable substitution in the loop above.
        unshift(@a, $luna, "_\n");
      }
    }
    my $prefix = "v. ";

    # In Czech Martyrology, first two lines in each file are superfluous, therefore deleting.
    my $line_c = 0;

    foreach my $line (@a) {
      if (length($line) > 3 && $line !~ /^\/\:/) {    # allowing /:rubrics:/ in Martyrology
        $t .= "$prefix$line\n" unless $lang =~ /Bohemice/i && $line_c < 3 && $line_c != 0;
      } else {
        $t .= "$line\n" unless $lang =~ /Bohemice/i && $line_c < 3;
      }
      $prefix = "r. ";
      $line_c++;

      if ($mobile && $line =~ /\_/) {
        $t .= "$prefix$mobile";
        $mobile = '';
      }
    }
  }
  $t .= prayer('Conclmart', $lang);
  return $t;
}

sub luna {

  my ($month, $day, $year, $lang) = @_;
  my $epact2008 = 23;
  my $edays = date_to_days(1, 0, 2008);
  my $lunarmonth = 29.53059;
  my @months = (
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  );
  my @months_it = (
    'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
    'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre',
  );
  my @months_cz = (
    'ledna', 'února', 'března', 'dubna', 'května', 'června',
    'července', 'srpna', 'září', 'října', 'listopadu', 'prosince',
  );
  my @ordinals = (
    'prima', 'secúnda', 'tértia', 'quarta',
    'quinta', 'sexta', 'séptima', 'octáva',
    'nona', 'décima', 'undécima', 'duodécima',
    'tértia décima', 'quarta décima', 'quinta décima', 'sexta décima',
    'décima séptima', 'duodevicésima', 'undevicésima', 'vicésima',
    'vicésima prima', 'vicésima secúnda', 'vicésima tértia', 'vicésima quarta',
    'vicésima quinta', 'vicésima sexta', 'vicésima séptima', 'vicésima octáva',
    'vicésima nona', 'tricésima',
  );
  my $sfx1 = (($day % 10) == 1) ? 'st' : (($day % 10) == 2) ? 'nd' : (($day % 10) == 3) ? 'rd' : 'th';
  my $t = (date_to_days($day, $month - 1, $year) - $edays + $epact2008);

  $mult = floor($t / $lunarmonth);
  $dist = floor($t - $mult * $lunarmonth - .25);
  if ($dist <= 0) { $dist = 30 + $dist; }
  my $sfx2 = (($dist % 10) == 1) ? 'st' : (($dist % 10) == 2) ? 'nd' : (($dist % 10) == 3) ? 'rd' : 'th';
  $day = $day + 0;

  if ($lang =~ /Latin/i) {
    return ("Luna $ordinals[$dist-1]. Anno $year\n", ' ');
  } elsif ($lang =~ /Italiano/i) {
    return ("$day $months_it[$month - 1] $year, Luna $gday");
  } elsif ($lang =~ /Česky/i) {
    return ("Dne $day $months_cz[$month - 1] $year, $gday. dne stáří měsíce.");
  } else {
    return ("$months[$month - 1] $day$sfx1 $year. The $dist$sfx2 day of the Moon.", $months[$month - 1]);
  }
}

sub gregor {

  my ($month, $day, $year, $lang) = @_;
  my $golden = $year % 19;
  my @epact = (29, 10, 21, 2, 13, 24, 5, 16, 27, 8, 19, 30, 11, 22, 3, 14, 25, 6, 17);
  my @om = (30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 100);
  my @firstmonth = (2, 21, 10, 29, 18, 7, 26, 15, 4, 23, 12, 1, 20, 9, 28, 17, 6, 25, 14);
  my $leapday;    # only set in the last days of February in a leap year

  if ($golden == 18) {
    $om[12] = 29;
  } else {
    $om[12] = 30;
  }
  if (leapyear($year) && ($month > 2)) { $om[1] = 30; }    # || ($month == 2 && $day > 24)
  if ($golden == 0) { unshift(@om, 30); }
  if ($golden == 8 || $golden == 11) { unshift(@om, 30); }

  if (leapyear($year) && $month == 2 && $day >= 24) {
    $leapday = ($day + 1) % 30;                            #  24->25, 25->26, "29"->0
    if ($day == 29) { $day = 24; }
  }

  my $t = date_to_days($day, $month - 1, $year);
  my @d = days_to_date($t);
  my $yday = $d[7];
  my $num = -$epact[$golden] - 1;
  my $i = 0;

  while ($num < $yday) {
    $num += $om[$i];
    $i++;
  }
  my $gday;
  $num -= $om[$i - 1];
  $gday = $yday - $num;
  my @ordinals = (
    'prima', 'secúnda', 'tértia', 'quarta',
    'quinta', 'sexta', 'séptima', 'octáva',
    'nona', 'décima', 'undécima', 'duodécima',
    'tértia décima', 'quarta décima', 'quinta décima', 'sexta décima',
    'décima séptima', 'duodevicésima', 'undevicésima', 'vicésima',
    'vicésima prima', 'vicésima secúnda', 'vicésima tértia', 'vicésima quarta',
    'vicésima quinta', 'vicésima sexta', 'vicésima séptima', 'vicésima octáva',
    'vicésima nona', 'tricésima',
  );
  my @months = (
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  );
  my @months_it = (
    'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
    'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre',
  );
  my @months_cz = (
    'ledna', 'února', 'března', 'dubna', 'května', 'června',
    'července', 'srpna', 'září', 'října', 'listopadu', 'prosince',
  );
  $day = $leapday || $day;    # recover English date in Leap Years
  my $sfx1 =
      ($day > 3 && $day < 21) ? 'th'
    : (($day % 10) == 1) ? 'st'
    : (($day % 10) == 2) ? 'nd'
    : (($day % 10) == 3) ? 'rd'
    : 'th';
  my $sfx2 =
      ($gday > 3 && $gday < 21) ? 'th'
    : (($gday % 10) == 1) ? 'st'
    : (($gday % 10) == 2) ? 'nd'
    : (($gday % 10) == 3) ? 'rd'
    : 'th';
  $day = $day + 0;

  if ($lang =~ /Latin/i) {
    return ("Luna $ordinals[$gday-1] Anno Dómini $year\n", ' ');
  } elsif ($lang =~ /Polski/i) {
    return ("Roku Pańskiego $year");
  } elsif ($lang =~ /Francais/i) {
    return ("L'année du Seigneur $year, le $gday$sfx2 jour de la Lune");
  } elsif ($lang =~ /Italiano/i) {
    return ("Anno del Signore $year, $day $months_it[$month - 1], Luna $gday");
  } elsif ($lang =~ /Bohemice/i) {
    return ("Léta Páně $year, $day. $months_cz[$month - 1], $gday. dne věku měsíce.");
  } else {
    return ("$months[$month - 1] $day$sfx1 $year, the $gday$sfx2 day of the Moon,", $months[$month - 1]);
  }

  #return sprintf("%02i", $gday);
}

1;
