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

  if ($brevis =~ /\(ef\.\.\)/) {

    # GABC: All Lectio Prima are either input in Tonus Capitulum or links to Capitulum Nona
    # Therefore: Transform Tonus Capitulum (Nona) into Tonus Lectio brevis here
    map {
      s/(.*)\(f/$1(h./g;
      s/er\)/dr\)/g;
      s/\(ef\.\.\)/(d.)/g;
    } $brevis;

    # Shorter pause at Flexa in Ant. Monasticum compared to Ant. Romanum
    $brevis =~ s/†\(\;\)/†(,)/g if $version =~ /monastic/i;
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
      && $version !~ /196[03]/
      && $winner{Rank} =~ /Feria|Vigilia/i
      && $winner{Rank} !~ /Vigilia Epi/i
      && !($winner{Rank} =~ /in.*Oct/i && $version =~ /Cist/i)
      && (!$commune || $commune !~ /C10/)
      && ($rank < 3 || $dayname[0] =~ /Quad6/ || $winner =~ /Quadp3-3/)
      && $dayname[0] !~ /Pasc/i) ? 'Feria' : 'Dominica';

  my $capit = $brevis{$key} . "\n\$Deo gratias\n_\n";
  setbuild1('Capitulum', "Psalterium $key");

  # Shorter pause at Flexa in Ant. Monasticum compared to Ant. Romanum
  $capit =~ s/†\(\;\)/†(,)/g if $lang eq 'Latin-gabc' && $version =~ /monastic/i;

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

    if ($primaresponsory) {
      if ($lang =~ /gabc/i) {
        $resp[0] = $primaresponsory;    # GABC: Take whole Responsorium from [Versum Prima]
      } else {
        $resp[2] = "V. $primaresponsory";
      }
    }
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

  my $dir = 'Martyrologium';
  $dir .= '1570' if $version =~ /1570/;
  $dir .= '1960' if $version =~ /1960|Newcal/;
  $dir .= '1955R' if $version =~ /1955/;
  $dir = substr($dir, 0, 13) unless -e "$datafolder/$lang/$dir";

  my $mobile = do {
    my $a = getweek($day, $month, $year, 1) . "-" . (($dayofweek + 1) % 7);
    $a = '10-DU' if ($version !~ /1570|1617|1888|1910/ && $month == 10 && $dayofweek == 6 && $day > 23 && $day < 31);
    $a = 'Defuncti' if $winner{Rank} =~ /ex C9/i;
    $a = 'DefunctiM' if ($month == 11 && $day == 14 && $version =~ /Monastic/);
    my %a = %{setupstring($lang, "$dir/Mobile.txt")};
    $a{$a};
  };

  my ($m, $d) = split('-', nextday($month, $day, $year));
  my $fname = "$datafolder/$lang/$dir/$m-$d.txt";
  $fname = checkfile($lang, "Martyrologium/$m-$d.txt") unless -e $fname;

  my $output;

  if (my @a = do_read($fname)) {
    my $luna = _luna($m, $d, $m == 1 && $d == 1 ? $year + 1 : $year, $lang);

    if ($lang =~ /Latin/i) {
      $a[0] .= " $luna";
    } else {
    FINDDATE:
      {
        foreach (@a) {
          last FINDDATE if s/^Upon the \d+ ?.. day of \S+/$luna /i;                                          # English
          last FINDDATE if s/^Dnia \d+-go \S+ (.)/${luna}r. \u$1/;                                           # Polski
          last FINDDATE if s/^\d+\. (?:\(\d+.\) )?\S+/${luna}/;                                              # Bohemice
          last FINDDATE if s/^(Le(?: même)? \d+ .*?\,)/$1 \l$luna, /i;                                       # French 1
          last FINDDATE if s/^((?:Le \d+ des|La veille des|Aux) (?:ides|calendes|nones).*)/$1, \l$luna/i;    # French 2
          last if /^\s*\_\s*/;
        }

        # Put $luna at the start if and only if we didn't find a
        # suitable substitution in the loop above.
        unshift(@a, $luna, "_\n");
      }
    }

    $output = join("\n", map { length($_) > 4 && !/^\/:/ ? "r. $_" : $_ } @a) . "\n";
    $output =~ s/^r/v/;
    $output =~ s/\_/"r. $mobile"/e if $mobile;
    $output =~ s/\_\n//g;

    $output = join("\n", @a) . "\n" if $lang eq 'Latin-gabc';
  }

  $output . prayer('Conclmart', $lang);
}

sub _luna_table {

  # return luna day for year day and letter as in tables printed in Martyrolgia
  # a  b  c  d  e  f  g  h  i  k  l  m  n  p  q  r  s  t  u   A  B  C  D  E  R  F  G  H  M  N  P # R is F black
  # 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20, 21,22,23,24,25,26,26,27,28,29,30, 1 # Die  1 ianuarii
  # 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21, 22,23,24,25,26,27,27,28,29,30, 1, 2 # Die  2 ianuarii
  # ...
  #12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,  1, 2, 3, 4, 5, 6, 6, 7, 8, 9,10,11 # Die 31 decembris

  my ($yday, $letter) = @_;

  my $all_martyrologium_letters = 'abcdefghiklmnpqrstuABCDERFGHMNP';
  my $letter_position = index($all_martyrologium_letters, $letter) + 1;
  my $m = $yday < 36 ? 30 : (($yday - 35) % 59 || 59) < 29 ? 29 : 30;
  my $i = $yday % 59 < 36 ? $letter_position : $letter_position - 1;

  if ($yday % 59 < 36) {
    $i -= 1 if $letter_position > 25;
    $i += 1 if ($letter_position == 25 && $yday % 59 == 35);
  } else {
    $i -= 2 if $letter_position > 25;
  }

  if ($yday > 58) {
    $i -= 1 if ($letter_position > 25 && $yday % 59 < 5);
    $i -= 1 if ($letter_position == 26 && $yday % 59 == 5);
  }

  ($i - 1 + ($yday % 59)) % $m + 1;
}

# finds luna day
sub _luna_day {
  my ($month, $day, $year) = @_;

  # Lit. Mart. for Aur. num.
  my $letters4aurea = '';

  if ($year < 1582) {
    main::error('Unreachable');
  } elsif ($year < 1700) {
    $letters4aurea = 'amDdqGgtNkBbnEerHhu';
  } elsif ($year < 1900) {
    $letters4aurea = 'PlCcpFfsMiAamDdqGgt';
  } elsif ($year < 2200) {
    $letters4aurea = 'NkBbnEerHhuPlCcpRfs';
  }    # R is F black
  elsif ($year < 2300) {
    $letters4aurea = 'MiAamDdqGgtNkBbnEer';
  } else {
    main::error('Unreachable');
  }

  my $aur_num = $year % 19 + 1;
  my $letter_for_aurea = substr($letters4aurea, $aur_num - 1, 1);
  my $yday = DivinumOfficium::Date::date_to_ydays($day, $month, $year);
  $yday -= 1 if (leapyear($year) && ($month > 2 || $month == 2 && $day > 23));

  my $luna = _luna_table($yday, $letter_for_aurea);
  $luna -= 1
    if ( $aur_num == 1
      && $month == 1
      && $letter_for_aurea ne 'P'
      && $day + _luna_table(1, $letter_for_aurea) < 32);

  $luna;
}

sub _number_suffix {
  my ($n) = @_;
      ($n > 3 && $n < 21) ? 'th'
    : (($n % 10) == 1) ? 'st'
    : (($n % 10) == 2) ? 'nd'
    : (($n % 10) == 3) ? 'rd'
    : 'th';
}

sub _luna {
  my ($month, $day, $year, $lang) = @_;

  my $lday = _luna_day($month, $day, $year);
  $day += 0;

  if ($lang =~ /Latin/i) {
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

    "Luna $ordinals[$lday-1]. Anno Dómini $year\n";
  } elsif ($lang =~ /Polski/) {
    my @months_pl = (
      'stycznia', 'lutego', 'marca', 'kwietnia', 'maja', 'czerwca',
      'lipca', 'sierpnia', 'września', 'października', 'listopada', 'grudnia',
    );

    "Roku Pańskiego $year, ${day}-go $months_pl[$month - 1], ${lday}-go dnia księżyca.\n_\n";
  } elsif ($lang =~ /Francais/) {
    "Le $lday" . "e jour de la Lune, l’année du Seigneur $year";
  } elsif ($lang =~ /Italiano/) {
    my @months_it = (
      'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre',
    );

    "Anno del Signore $year, $day $months_it[$month - 1], Luna $lday";
  } elsif ($lang =~ /Bohemice/) {
    my @months_cz = (
      'ledna', 'února', 'března', 'dubna', 'května', 'června',
      'července', 'srpna', 'září', 'října', 'listopadu', 'prosince',
    );

    "Léta Páně $year, $day. $months_cz[$month - 1], $lday. dne věku měsíce.";
  } else {
    my @months = (
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    );

    sprintf("$months[$month - 1] $day%s $year, the $lday%s day of the Moon,",
      _number_suffix($day), _number_suffix($lday),);
  }
}

1;
