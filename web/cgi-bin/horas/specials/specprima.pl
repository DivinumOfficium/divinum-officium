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
  if ($version !~ /1955|196/) {
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
  setcomment($label, 'Source', $key eq 'Feria', $lang);

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

    foreach my $line (@a) {
      if (length($line) > 3 && $line !~ /^\/\:/) {    # allowing /:rubrics:/ in Martyrology
        $t .= "$prefix$line\n";
      } else {
        $t .= "$line\n";
      }
      $prefix = "r. ";

      if ($mobile && $line =~ /\_/) {
        $t .= "$prefix$mobile";
        $mobile = '';
      }
    }
  }
  $t .= prayer('Conclmart', $lang);
  return $t;
}

1;
