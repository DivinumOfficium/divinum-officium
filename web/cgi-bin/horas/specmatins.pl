#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office Matins subroutines
use FindBin qw($Bin);
use lib "$Bin/..";

# Defines ScriptFunc and ScriptShortFunc attributes.
use horas::Scripting;
$a = 4;

#*** invitatorium($lang)
# collects and returns psalm 94 with the antipones
sub invitatorium {
  my $lang = shift;
  my %invit = %{setupstring($datafolder, $lang, 'Psalterium/Matutinum Special.txt')};
  my $name =
      ($dayname[0] =~ /Adv[12]/i) ? 'Adv'
    : ($dayname[0] =~ /Adv[34]/i) ? 'Adv3'
    : ($month == 12 && $day == 24) ? 'Nat24'
    : ($dayname[0] =~ /(Quad5|Quad6)/i) ? 'Quad5'
    : ($dayname[0] =~ /Quad/i && $dayname[0] !~ /Quadp/i) ? 'Quad'
    : ($dayname[0] =~ /Pasc/i) ? 'Pasch'
    : '';

  if (
    $version =~ /Trid|Monastic/i
    && (!$name
      || $dayname[0] =~ /Quadp/i
      || ($dayname[0] =~ /Quad/i && $dayofweek != 0))
    )
  {
    $name = 'Trid';
  }

  if ($name) {
    $name = "Invit $name";
    $comment = 1;
  } else {
    $name = 'Invit';
    $comment = 0;
  }
  my $i = ($name =~ /^Invit$/i || $name =~ /Invit Trid/i) ? $dayofweek : 0;
  if ($i == 0 && $name =~ /^Invit$/i && ($month < 4 || ($monthday && $monthday =~ /^1[0-9][0-9]\-/))) { $i = 7; }
  my @invit = split("\n", $invit{$name});
  setbuild('Psalterium/Matutinum Special', $name, 'Invitatorium ord');
  my $ant = chompd($invit[$i]);
  if ($version =~ /Monastic/i && $dayofweek && $winner =~ /Pasc/) {
    $ant = chompd($prayers{$lang}{"Alleluia Duplex"}) . $prayers{$lang}{"Alleluia Simplex"};
    $ant =~ s/\., (.*)/, * \u\1/;
  }

  #look for special from proprium the tempore or sancti
  my ($w, $c) = getproprium("Invit", $lang, $seasonalflag, 1);
  if ($w) { $ant = chompd($w); $comment = $c; }
  setcomment($label, 'Source', $comment, $lang, translate('Antiphona', $lang));
  $ant =~ s/^.*?\=\s*//;
  $ant = chompd($ant);
  $ant = "Ant. $ant";
  if ($dayname[0] =~ /Pasc/i) { ensure_single_alleluia($ant,$lang); } 
  my @ant = split('\*', $ant);
  my $ant2 = "Ant. $ant[1]";
  my $num = "";
  if ($rule =~ /Invit([0-9])/i) { $num = $1; }
  if ($winner =~ /Tempora/i && $dayname[0] =~ /Quad[56]/i && $rule !~ /Gloria responsory/i) { $num = 3; }

  # Per annum Monday special psalm $w = getproprium invitatory
  if (!$w && $dayofweek == 1 && $dayname[0] =~ /(Epi|Pent|Quadp)/i && $winner =~ /Tempora/ && $rank < 2) { $num = 4; }

  if (!$w && $dayofweek == 1 && $dayname[0] =~ /(Epi|Pent)/i && $w{Rank} =~ /Vigil/i && $winner =~ /Sancti/) {
    $num = 4;
  }
  my $invitpath = "Psalterium/Invitatorium$num";
  $invitpath =~ s/Psalterium/PiusXII/ if ($lang eq 'Latin' && $psalmvar);
  $fname = checkfile($lang, "$invitpath.txt");

  if (my @a = do_read($fname)) {
    foreach $item (@a) {
      $item = "$item\n";

      if ($item =~ /\$ant2/i) {
        $item = "$ant2";
      } elsif ($item =~ /\$ant/i) {
        $item = "$ant";
      } else {
        $item =~ s/\(\*(.*?)\*(.*?)\)/setfont($smallfont, "($1) ") . $2/e;
      }

      if ($dayname[0] =~ /Quad[56]/i && $winner !~ /Sancti/i && $rule !~ /Gloria responsory/i) {
        $item =~ s/\&Gloria/\&Gloria2/i;
      }
      push(@s, "$item");
    }
  } else {
    $error .= "$fname cannnot open";
  }
}

#*** hymnus($lang)
# collects and returns the hymn for matutinum
sub hymnus {    #matutinum
  my $lang = shift;
  my %hymn = %{setupstring($datafolder, $lang, 'Psalterium/Matutinum Special.txt')};
  $name =
      ($dayname[0] =~ /adv/i) ? 'Adv'
    : ($dayname[0] =~ /quad5|quad6/i) ? 'Quad5'
    : ($dayname[0] =~ /quad[0-9]/i) ? 'Quad'
    : ($dayname[0] =~ /pasc/i) ? 'Pasch'
    : '';
  if ($month == 12 && $day == 24) { $name = 'Adv'; }
  $name = ($name) ? "Hymnus $name" : "Day$dayofweek Hymnus";
  $comment = ($name) ? 1 : 5;
  if ($name =~ /^Day0 Hymnus$/i && ($month < 4 || ($monthday && $monthday =~ /^1[0-9][0-9]\-/))) { $name .= '1'; }
  my $hymn = tryoldhymn(\%hymn, $name);
  setbuild("Psalterium/Matutinum Special", $name, 'Hymnus ord');
  my $hmn =
    (    !exists($winner{'Hymnus Matutinum'})
      && ($version =~ /1955|1960/ || $winner{Rule} =~ /\;mtv/i)
      && $winner{Rule} =~ /(C4|C5)/) ? 'Hymnus1' : 'Hymnus';
  my ($h, $c) = getproprium("$hmn Matutinum", $lang, $seasonalflag, 1);

  if ($h) {
    if ($hymncontract) {
      my $w = (columnsel($lang)) ? $winner : $winner2;
      my $h1 = $w{'Hymnus Vespera'};
      my @h1 = split("\n", $h1);
      while (@h1 && pop(@h1) !~ /\_/) { next; }
      $h1 = '';
      foreach (@h1) { $h1 .= "$_\n"; }
      $h = "$h1$h";
    }
    $hymn = $h;
    $comment = $c;
  }
  $hymn = doxology($hymn, $lang);
  setcomment($label, 'Source', $comment, $lang);
  push(@s, $hymn);
  push(@s, "\n");
}

#*** psalmi_matutinum($lang)
# collects and returns psalms and lections for matutinum
sub psalmi_matutinum {
  $lang = shift;
  if ($version =~ /monastic/i && $winner{Rule} !~ /Matutinum Romanum/i) { return psalmi_matutinum_monastic($lang); }
  my %psalmi = %{setupstring($datafolder, $lang, 'Psalterium/Psalmi matutinum.txt')};
  my $d = ($version =~ /trident/i) ? 'Daya' : 'Day';
  my $dw = $dayofweek;

  #if ($winner{Rank} =~ /Dominica/i) {$dw = 0;}
  my @psalmi = split("\n", $psalmi{"$d$dw"});
  setbuild("Psalterium/Psalmi matutinum", "$d$dw", 'Psalmi ord');
  $comment = 1;
  my $prefix = translate('Antiphonae', $lang);

  if ($dayofweek == 0 && $dayname[0] =~ /Adv/i) {
    if ($version =~ /Trident/i) {
      @psalmi = split("\n", $psalmi{'Adv0'});
    } else {
      @psalmi = split("\n", $psalmi{'Adv 0 Ant Matutinum'});
    }
    setbuild2("Antiphonas Psalmi Dominica special");
  }

  #replace Psalm50 with breaking 49 to three parts
  if ($laudes == 2 && $dayofweek == 3 && $version !~ /trident/i) {
    @psalmi = split("\n", $psalmi{"Day31"});
    setbuild2("Psalm #50 replaced by breaking #49");
  }

  if (
    $version !~ /Trident/i
    && (
      ($winner =~ /tempora/i && $dayname[0] =~ /(Adv|Quad|Pasc)([0-9])/i)
      || (
           $month == 1
        && $version =~ /1960|1955/
        && $winner =~ /Sancti/i
        &&    # TODO: Temporary condition
        (
          ($day < 6 && 'Nat' =~ /(Nat)/) ||    # pending implementation of
          ($day <= 13 && 'Epi' =~ /(Epi)/)
        )                                      # Christmas- and Epiphanytide.
      )
    )
    && $winner{Rule} !~ /Matutinum Romanum/i
    )
  {
    my $name = $1;
    my $i = $2;
    if ($name =~ /Quad/i && $i > 4) { $name = 'Quad5'; }

    if ($dayofweek == 0) {
      my @a = split("\n", $psalmi{"$name 1 Versum"});
      $psalmi[3] = $a[0];
      $psalmi[4] = $a[1];
      my @a = split("\n", $psalmi{"$name 2 Versum"});
      $psalmi[8] = $a[0];
      $psalmi[9] = $a[1];
      my @a = split("\n", $psalmi{"$name 3 Versum"});
      $psalmi[13] = $a[0];
      $psalmi[14] = $a[1];
      if ($version =~ /1960/) { $psalmi[13] = $psalmi[3]; $psalmi[14] = $psalmi[4]; }
    } else {
      $i = $dayofweek;
      my @a = split("\n", $psalmi{"$name $i Versum"});
      $psalmi[13] = $a[0];
      $psalmi[14] = $a[1];
    }
    setbuild2("Subst Matutitunun Versus $name $dayofweek");
  }

  if ($version =~ /Trident/i && $dayofweek == 0 && $dayname[0] =~ /(Adv|Pasc)/i) {
    my @a = split("\n", $psalmi{"$1$dayofweek"});
    my $n;
    foreach $n (3, 4, 8, 9, 13, 14) { $psalmi[$n] = $a[$n]; }
  }
  my ($w, $c) = getproprium('Ant Matutinum', $lang, 0, 1);

  if ($w) {
    @psalmi = split("\n", $w);
    $comment = $c;
    $prefix .= ' ' . translate('et Psalmi', $lang);
  }

  if ($rule =~ /Ant Matutinum ([0-9]+) special/i) {
    my $ind = $1;
    %wa = (columnsel($lang)) ? %winner : %winner2;
    $wa = $wa{"Ant Matutinum $ind"};
    $wa =~ s/\s*$//;

    if ($wa) {
      $psalmi[$ind] =~ s/^.*?;;/$wa;;/;
      if ($ind == 12 && $dayname[0] =~ /Pasc/i) { $psalmi[10] =~ s/^.*?;;/$wa;;/; }
    }
  }

  if ( $version =~ /Trident/i
    && $testmode =~ /seasonal/i
    && $winner =~ /Sancti/i
    && $rank >= 2
    && $rank < 5
    && !exists($winner{'Ant Matutinum'}))
  {
    $comment = 0;
  }
  setcomment($label, 'Source', $comment, $lang, $prefix);

  my %spec = %{setupstring($datafolder, $lang, 'Psalterium/Psalmi matutinum.txt')};
  my @spec = ();
  my $i = 0;
  my %w = (columnsel($lang)) ? %winner : %winner2;
  my $ltype1960 = gettype1960();

  if ($rule =~ /9 lectio/i && !$ltype1960 && $rank >= 2) {
    setbuild2("9 lectiones");

    if ($dayname[0] =~ /Pasc/i && !exists($winner{'Ant Matutinum'}) && $rank < 5) {    #??? ex
      my $dname = ($winner{Rank} =~ /Dominica/i) ? 'Dominica' : 'Feria';
      @spec = split("\n", $spec{"Pasc Ant $dname"});
      my $i;
      foreach $i (3, 4, 8, 9, 13, 14) { $psalmi[$i] = $spec[$i]; }
    } elsif ($winner =~ /tempora/i
      && $dayname[0] =~ /(Adv|Quad|Pasc)/i
      && !exists($winner{'Ant Matutinum'}))
    {
      $tmp = $1;
      if ($dayname[0] =~ /(Quad5|Quad6)/) { $tmp = 'Quad5'; }
      @spec = split("\n", $spec{"$tmp 1 Versum"});
      if (@spec) { $psalmi[3] = $spec[0]; $psalmi[4] = $spec[1]; }
      @spec = split("\n", $spec{"$tmp 2 Versum"});
      if (@spec) { $psalmi[8] = $spec[0]; $psalmi[9] = $spec[1]; }
      @spec = split("\n", $spec{"$tmp 3 Versum"});
      if (@spec) { $psalmi[13] = $spec[0]; $psalmi[14] = $spec[1]; }
      setbuild2("$tmp special versums for nocturns");
    }

    if ( $version =~ /Trident/i
      && $testmode =~ /seasonal/i
      && $winner =~ /Sancti/i
      && $rank >= 2
      && $rank < 5
      && !exists($winner{'Ant Matutinum'}))
    {
      my %psalmi = %{setupstring($datafolder, $lang, 'Psalterium/Psalmi matutinum.txt')};
      @psalmi = split("\n", $psalmi{"Daya$dayofweek"});
      push(@s, '!Nocturn I.');
      foreach $i (0, 1) { antetpsalm($psalmi[$i], $i); }
      push(@s, $psalmi[6]);
      push(@s, $psalmi[7]);
      push(@s, "\n");
      lectiones(1, $lang);
      push(@s, "\n");
      push(@s, '!Nocturn II.');
      foreach $i (2, 3) { antetpsalm($psalmi[$i], $i); }
      push(@s, $psalmi[6]);
      push(@s, $psalmi[7]);
      push(@s, "\n");
      lectiones(2, $lang);
      push(@s, "\n");
      push(@s, '!Nocturn III.');
      foreach $i (4, 5) { antetpsalm($psalmi[$i], $i); }
      push(@s, $psalmi[6]);
      push(@s, $psalmi[7]);
      push(@s, "\n");
      lectiones(3, $lang);
      push(@s, "\n");
      return;
    }
    push(@s, '!Nocturn I.');
    foreach $i (0, 1, 2) { antetpsalm($psalmi[$i], $i); }
    push(@s, $psalmi[3]);
    push(@s, $psalmi[4]);
    push(@s, "\n");
    lectiones(1, $lang);
    push(@s, "\n");
    push(@s, '!Nocturn II.');
    foreach $i (5, 6, 7) { antetpsalm($psalmi[$i], $i); }
    push(@s, $psalmi[8]);
    push(@s, $psalmi[9]);
    push(@s, "\n");
    lectiones(2, $lang);
    push(@s, "\n");
    push(@s, '!Nocturn III.');
    foreach $i (10, 11, 12) { antetpsalm($psalmi[$i], $i); }
    push(@s, $psalmi[13]);
    push(@s, $psalmi[14]);
    push(@s, "\n");
    lectiones(3, $lang);
    push(@s, "\n");
    return;
  }

  # Here we begin the logic for an office of three lessons. On nine-lesson days
  # we've already returned.
  if ($dayname[0] =~ /Pasc[1-6]/i && $version !~ /Trident/i) {    #??? ex
    my $tde =
      ($version =~ /1960/ && ($dayname[0] =~ /Pasc6/i || ($dayname[0] =~ /Pasc5/i && $dayofweek > 3))) ? '1' : '';
    my $i;

    if ($tde) {
      my %r = %{setupstring($datafolder, $lang, 'Tempora/Pasc5-4.txt')};
      @spec = split("\n", $r{'Ant Matutinum'});
    } else {
      @spec = split("\n", $spec{"Pasc Ant Dominica"});
    }
    foreach $i (3, 4, 8, 9, 13, 14) { $psalmi[$i] = $spec[$i]; }
    if ($dayofweek == 0 || $dayofweek == 1 || $dayofweek == 4) { $psalmi[13] = $psalmi[3]; $psalmi[14] = $psalmi[4]; }
    if ($dayofweek == 2 || $dayofweek == 5) { $psalmi[13] = $psalmi[8]; $psalmi[14] = $psalmi[9]; }
  }
  if ($rule =~ /votive nocturn/i) { return votivenocturn($lang); }

  if (@psalmi > 9 && $rule !~ /1 Nocturn/i) {
    setbuild1("3 lectiones");
  } else {
    setbuild1("One nocturn");
  }
  push(@s, '!Nocturn I');
  push(@s, "\n");

  # In the office of the BVM on Saturday under the Tridentine rubrics, Psalm 99
  # is replaced by Psalm 91, as the former is said at Lauds.
  my @psalm_indices = (
    $version =~ /Trident/i &&    # Tridentine rubrics, necessarily 3 lessons;
      $dayofweek == 6 &&         # on a Saturday;
      $rule =~ /ex C10/i
    )
    ?                            # not in the octaves of Easter or Pentecost:
    (0, 8, 2)
    :                            # Replace Ps. 91 by Ps. 99;
    (0, 1, 2);                   # otherwise, don't mess about.
  foreach my $i (@psalm_indices) { antetpsalm($psalmi[$i], $i); }

  if ($version =~ /trident/i) {
    if ($rule !~ /1 nocturn/i) {
      foreach $i (3, 4, 5) { antetpsalm($psalmi[$i], $i); }
    }
    $spec[0] = $psalmi[6];
    $spec[1] = $psalmi[7];
    
    if ($dayofweek == 6 && $rule =~ /ex C10/i) {
      my @a = split("\n", $psalmi{"BMV Versum"});
      $spec[0] = $a[0];
      $spec[1] = $a[1];
    }

    if ($dayname[0] =~ /(Adv|Quad|Pasc)([0-9])/i) {
      my $name = $1;
      my $i = $2;
      if ($name =~ /Quad/i && $i > 4) { $name = 'Quad5'; }
      $i = $dayofweek;
      my @a = split("\n", $psalmi{"$name $i Versum"});
      $spec[0] = $a[0];
      $spec[1] = $a[1];
    }
  }

  if (@psalmi > 9) {
    foreach $i (5, 6, 7) { antetpsalm($psalmi[$i], $i); }
    foreach $i (10, 11, 12) { antetpsalm($psalmi[$i], $i); }

    # Versum for 3 lectiones is variable
    $spec[0] = $psalmi[13];
    $spec[1] = $psalmi[14];
    setbuild2('Ord Versus per annum');
    $comment = 5;
  }

  if ($month == 12 && $day == 24) {
    @spec = split("\n", $spec{"Nat24 Versum"});
    setbuild2('Subst Versus Nat24');
    $comment = 1;
  }

  if ($dayname[0] =~ /Pasc[07]/i) {
    $spec[0] = $psalmi[3];
    $spec[1] = $psalmi[4];
    setbuild2('Subst Versus for de tempore');
    $comment = 2;
  }
  push(@s, $spec[0]);
  push(@s, $spec[1]);
  lectiones(0, $lang);
  push(@s, "\n");
  return;
}

#*** votivenocturn($lang)
# 3 psalm 3 lectiones for votive
sub votivenocturn {
  my $lang = shift;
  setbuild1("3 psalms 3 lectiones");
  my %w = (columnsel($lang)) ? %winner : %winner2;
  my @psalms = split('\n', $w{'Ant Matutinum'});
  push(@s, '!Nocturn I');
  push(@s, "\n");
  my $i0 = 1;

  if ($dayofweek == 2 || $dayofweek == 5) {
    for ($i = 0; $i < 5; $i++) { $psalms[$i] = $psalms[5 + $i]; }
    $i0 = 4;
  }

  if ($dayofweek == 3 || $dayofweek == 6) {
    for ($i = 0; $i < 5; $i++) { $psalms[$i] = $psalms[10 + $i]; }
    $i0 = 7;
  }
  foreach $i (0, 1, 2) { antetpsalm($psalms[$i], $i); }
  push(@s, $psalms[3]);
  push(@s, $psalms[4]);
  push(@s, "\n");

  if ($rule !~ /Limit.*?Benedictio/i) {
    push(@s, "\&pater_noster");
  } else {
    push(@s, "\$Pater noster");
  }

  if ($winner !~ /C12/i) {
    for ($i = $i0; $i < $i0 + 3; $i++) {
      push(@s, "\&lectio($i)");
      push(@s, "\n");
    }
  } else {
    %mariae = %{setupstring($datafolder, $lang, "$communename/C10.txt")};
    @a = split("\n", $mariae{Benedictio});
    setbuild2('Special benedictio');
    push(@s, "Absolutio. $a[0]");
    push(@s, "\n");

    for ($i = 1; $i < 4; $i++) {
      push(@s, "V. $a[1]");
      push(@s, "Benedictio. $a[1+$i]");
      push(@s, "\&lectio($i)");
      push(@s, "\n");
    }
  }
  push(@s, "\n");
  return;
}

#*** lectiones($number, $language)
#input: the index number for the nocturn, 0 for 3 lectiones only and the language
#collects and prints the the Benedictio, and set the call for the lectiones/responsory
sub lectiones {
  my $num = shift;
  my $lang = shift;
  my $evan_regexp = translate('Evangelist', $lang);

  # some vernaculars have no translated parts, so add English and Latin
  # cannot use translate('Evangelist', 'English') as it is anavailable
  $evan_regexp .= '|Matt|Marc|Luc|Joannes' if ($lang !~ /Latin/);
  $evan_regexp .= '|Matt|Mark|Luke|John' if ($lang !~ /English/);
  $evan_regexp = '!(?:' . $evan_regexp . ')\s+\d+';
  $evan_regexp = qr/$evan_regexp/;
  push(@s, "\n");

  if ($rule !~ /Limit.*?Benedictio/i) {
    push(@s, "\&pater_noster");
  } else {
    push(@s, "\$Pater noster");
  }
  my %benedictio = %{setupstring($datafolder, $lang, 'Psalterium/Benedictions.txt')};
  my $i = $num;
  
  my $j0 = 0;
  my $j1 = 1 + (($num == 0) ? 0 : 2 * ($rule =~ /12 lectio/ ? 4 : 3));

  #if ($dayname[0] =~ /Pasc0/i) {$i = 3;}
  if ($num == 0) {
    $i =
        ($dayofweek == 1 || $dayofweek == 4) ? 1
      : ($dayofweek == 2 || $dayofweek == 5) ? 2
      : ($dayofweek == 3 || $dayofweek == 6) ? 3
      : 1;
    my $w = lectio(1, $lang);

    if ($w =~ $evan_regexp) {
      $j0 = $i;
      $i = 3;
    }
  } else {
    $i = $num;
  }
  my @a = split("\n", $benedictio{"Nocturn $i"});

  if ($j0) {
    my @a1 = split("\n", $benedictio{"Nocturn $j0"});
    $a[0] = $a1[0];
  }

  if ($rule =~ /Special Benedictio/) {
    %mariae = %{setupstring($datafolder, $lang, "$communename/C10.txt")};
    @a = split("\n", $mariae{Benedictio});
    setbuild2('Special benedictio');
  }

  if ($rule =~ /Special Evangelii Benedictio/i && $num == 3) {
    my %w = (columnsel($lang)) ? %winner : %winner2;
    @a = split("\n", $w{Benedictio3});
    setbuild2('Special Evangelii Benedictio');
  }

  #absolutiones
  if ($rule !~ /Limit.*?Benedictio/i) {
    push(@s, "Absolutio. $a[0]");
    push(@s, "\n");
  }
  my $ltype1960 = gettype1960();
  if ($ltype1960) { return lect1960($lang, $evan_regexp); }

  if ($winner =~ /sancti/i && $rule !~ /Special Evangelii Benedictio/i) {
    $i = ($num > 0) ? $num : 3;
    @a = split("\n", $benedictio{"Nocturn $i"});
  }
  my $divaux = ($rule =~ /Divinum auxilim/i || $commune{Rule} =~ /Divinum auxilium/i) ? 1 : 0;
  if ($i == 3 && $winner{Rank} =~ /Mari.* Virgin/i && !$divaux) { $a[3] = $a[10]; }

  #benedictiones for nocturn III
  if ($i == 3 && $rule !~ /ex C1[02]/ && $rule !~ /Special Evangelii Benedictio/i) {
    ($a[3], $a[4], $a[5]) = ($a[5], $a[3], $a[4]) if ($version =~ /Monastic/i);

    my $w = lectio($j1, $lang);

    if ($w =~ $evan_regexp) {
      $a[2] = $benedictio{Evangelica};
    } elsif ($a[2] =~ /(evang|Gospel)/i) {
      $a[2] = $a[5];
    }
    setbuild2("B$j1. : " . beginwith($a[2]));

    if ($winner =~ /sancti/i && ($winner{Rank} =~ /(s\.|ss\.)/i && $winner{Rank} !~ /vigil/i) && !$divaux) {
      my $j = 6;
      if ($winner{Rank} =~ /(virgin|vidua|poenitentis|pœnitentis|C6|C7)/i) { $j += 2; }
      if ($winner{Rank} =~ /ss\./i) { $j++; }
      $a[3] = $a[$j];
    }
    if ($rule =~ /Ipsa Virgo Virginum/i && !$divaux) { $a[3] = $a[10]; }
    if ($rule =~ /Quorum Festum/i && !$divaux) { $a[3] = $a[7]; }
    setbuild2("B" . ($j1+1) . ". : " . beginwith($a[3]));
    $w = lectio($j1+2, $lang);
    if ($w =~ $evan_regexp) { $a[4] = $benedictio{Evangelica9}; }
    setbuild2("B" . ($j1+2) . ". : " . beginwith($a[4]));
  }
  if ($version =~ /1960/ && $lang =~ /Latin/i) { $a[1] = 'Jube, Dómine, benedícere.'; }

  push(@s, "_");

  my $read_per_noct = ($rule =~ /12 lectio/) ? 4 : 3;

  $num = 1 if ($num < 1);

  for my $i (1..$read_per_noct) {
    my $l = ($num - 1) * $read_per_noct + $i;
    if ($rule !~ /Limit.*?Benedictio/i) {
      push(@s, "V. $a[1]");
      push(@s, "Benedictio. $a[$i+1]");
    }
    push(@s, "\&lectio($l)");
    push(@s, "\n");
  }
}

sub matins_lectio_responsory_alleluia(\$$) {
  my ($r, $lang) = @_;
  our @dayname;
  return unless $$r;

  if ($dayname[0] =~ /Pasc/i && !officium_defunctorum()) {
    my @resp = split("\n", $$r);
    ensure_single_alleluia($resp[1], $lang);
    ensure_single_alleluia($resp[3], $lang);
    ensure_single_alleluia($resp[-1], $lang);
    $$r = join("\n", @resp);
  }
}
#
#*** getC10readingname
sub getC10readingname {
  return "Lectio M101" if ($version !~ /1960|Monastic/i && $month == 9 && $day > 8 && $day < 15);
  my $satnum = floor(($day - 1) / 7 + 1);
  $satnum = 4 if ($satnum == 5);
  return sprintf("Lectio M%02i%s", $month, ($version =~ /Monastic/i) ? $satnum : '');
}

#*** lectio($num, $lang)
# input $num=index number for the lectio(1-9 or 1-3) and language
# print the appropriate lectio collected from the winner or commune
# handles the commemoratio as last
sub lectio : ScriptFunc {
  my $num = shift;
  my $lang = shift;
  $ltype1960 = gettype1960();
  if ($winner =~ /C12/i) { $ltype1960 = 0; }

  if ($ltype1960 == 2 && $num == 3) {
    $num = 7;
  } elsif (
    ($ltype1960 == 3 && $num == 3 && $votive !~ /(C9|Defunctorum)/i)
    || (
         $version !~ /1960/
      && $rule !~ /1 et 2 lectiones/i
      && $num == 3
      && $winner =~ /Sancti/i
      && $rank < 2
      && $winner{Rank} !~ /vigil/i
      && ( $version !~ /monastic/i
        || $dayname[0] !~ /Nat|Epi1/i)
    )
    )
  {
    $num = 4;
  }
  my %w = (columnsel($lang)) ? %winner : %winner2;

  #Nat1-0 special rule
  # TODO: Get rid of this special case by separating the temporal and sanctoral
  # parts of Christmas, thus allowing occurring Scripture to be defined.
  if ($num <= 3 && $rule =~ /Lectio1 Sancti/i && $winner =~ /tempora/i && $day >= 29) {
    my $c;

    if ($rule =~ /no commemoratio/i) {

      # XXX: The commemoration has been suppressed, so we hardcode a path to
      # the sanctoral part.
      $c = officestring($datafolder, $lang, "Sancti/12-$day.txt");
      $c->{'Lectio2'} .= $c->{'Lectio3'} if (contract_scripture(2));
    } else {
      $c = (columnsel($lang)) ? \%commemoratio : \%commemoratio2;
    }
    $w{"Lectio$num"} = $c->{"Lectio$num"};
    $w{"Responsory$num"} = $c->{"Responsory$num"};
  }

  if ((($winner eq 'TemporaM/Nat2-0.txt') || ($winner eq 'SanctiM/01-13.txt')) && $num <= 4) {
    $c = officestring($datafolder, $lang, 
      $winner =~ /Tempora/ ? sprintf("SanctiM/01-%02d.txt",$day) : "TemporaM/Epi1-$dayofweek.txt");
    $w{"Lectio$num"} = $c->{"LectioM$num"} || $c->{"Lectio$num"};
  }

  #Lectio1 tempora
  if ($num <= 3 && $rule =~ /Lectio1 tempora/i && exists($scriptura{"Lectio$num"})) {
    my %c = (columnsel($lang)) ? %scriptura : %scriptura2;
    $w{"Lectio$num"} = $c{"Lectio$num"};

    if ($version =~ /Trident/i && exists($w{"ResponsoryT$num"})) {
      $w{"Responsory$num"} = $c{"Responsory$num"};
    } else {
      $w{"Responsory$num"} = $c{"Responsory$num"};
    }
  }
  
  if($version =~ /(1570|1910|Divino)/i && $month == 12 && $day == 14 && $dayofweek !~ 3){ $w{"Lectio$num"} = $c{"Lectio$num"};}

  #scriptura1960
  if ( $num < 3
    && $version =~ /1960/
    && $rule =~ /scriptura1960/i
    && exists($scriptura{"Lectio$num"}))
  {
    my %c = (columnsel($lang)) ? %scriptura : %scriptura2;
    $w{"Lectio$num"} = $c{"Lectio$num"};

    if ($num == 2 && $votive !~ /(C9|Defunctorum)/i && ($dayname[1] !~ /feria/i || $commemoratio)) {
      if ($w{Lectio2} =~ /(.*?)\_/s) { $w{Lectio2} = $1; }
      my $w1 = $c{"Lectio3"};
      $w{Lectio2} .= $w1;
    }
  }

  #** handle initia table (Str$ver$year)
  my $file = initiarule($month, $day, $year);
  if ($file) { %w = resolveitable(\%w, $file, $lang); }

  #StJamesRule
  if ($num < 4 && $rule =~ /StJamesRule=([a-z,]+)\s/i)    #was also: && $version !~ /1961/
  {
    %w = StJamesRule(\%w, $lang, $num, $1);
  }

  #Sancta Maria Sabbato special rule
  if ($winner =~ /C12/i) {
    if (($version =~ /1960/ || ($winner =~ /Sancti/i && $rank < 2)) && $num == 4) { $num = 3; }
    $num = $num % 3;
    if ($num == 0) { $num = 3; }
  }
  my $w = $w{"Lectio$num"};
  if ($num < 4 && $rule =~ /Lectio1 Quad/i && $dayname[0] !~ /Quad/i) { $w = ''; }
  if ($num < 4 && $commemoratio{Rank} =~ /Quattuor/i && $month == 9) { $w = ''; }

  if ($w && $num % 3 == 1) {
    my @n = split('/', $winner);
    setbuild2("Lectio$num ex $n[0]");
  }

  #prepares for case of homily instead of scripture
  my $homilyflag = (exists($commemoratio{Lectio1})
      && $commemoratio{Lectio1} =~ /\!(Matt|Mark|Marc|Luke|Luc|Joannes|John)\s+[0-9]+\:[0-9]+\-[0-9]+/i) ? 1 : 0;

  if (
    !$w
    && (
      ($communetype =~ /^ex/i && $commune !~ /Sancti/i && $rank > 3)
      || ( $num < 4
        && $homilyflag
        && exists($commune{"Lectio$num"}))
    )
    )
  {
    %w = (columnsel($lang)) ? %commune : %commune2;
    $w = $w{"Lectio$num"};
    if ($w && $num == 1) { setbuild2("Lectio1-3 from Tempora/$file replacing homily"); }
  }

  if (!$w
    && $num < 4
    && exists($scriptura{"Lectio$num"})
    && ($version !~ /trident/i || $rank < 5))
  {
    %w = (columnsel($lang)) ? %scriptura : %scriptura2;
    $w = $w{"Lectio$num"};
    if ($w && $num == 1) { setbuild2("Lectio1 ex scriptura"); }
  } elsif (!$w && $num == 4 && exists($commemoratio{"Lectio$num"}) && ($version =~ /1960/i)) {
    %w = (columnsel($lang)) ? %commemoratio : %commemoratio2;
    $w = $w{"Lectio$num"};
    if ($w && $num == 4) { setbuild2("Lectio3 ex commemoratio"); }
  }

  if (contract_scripture($num)) {
    if ($w =~ /(.*?)\_/s) { $w = $1; }
    my $w1 = $w{'Lectio3'};

    #$w1 =~ s/^\!.*?\n//;
    $w .= $w1;
  }
  if ($version =~ /monastic/i && $num == 3) { $w = monastic_lectio3($w, $lang); }

  #look for commune if sancti and ex or wide
  if (!$w && $winner =~ /sancti/i && $rule =~ /(ex\s*C|vide\s*C)/i) {
    my %com = (columnsel($lang)) ? %commune : %commune2;

    if (exists($com{"Lectio$num"})) {
      $w = $com{"Lectio$num"};
      if ($w && $num % 3 == 1) { setbuild2("Lectio$num ex $commune{Name}"); }
    }
  }

  if (!$w && exists($commune{"Lectio$num"})) {
    my %c = (columnsel($lang)) ? %commune : %commune2;
    $w = $c{"Lectio$num"};

    if ($num == 2 && $version =~ /1960/) {
      my $w1 = $c{'Lectio3'};
      $w .= $w1;
    }
  }

  if ($commune{Rule} =~ /Special Lectio $num/) {
    %mariae = %{setupstring($datafolder, $lang, "$communename/C10.txt")};
    my $name = getC10readingname();
    $w = $mariae{$name};
    setbuild2("Mariae $name");
  }

  # Combine lessons 8 and 9 if there's a commemoration to be read in place of
  # lesson 9, and if the office of the day requires it. In fact the rubrics
  # always *permit* such a contraction, but we don't support that yet.
  if ( $version !~ /1960/
    && $num == 8
    && $rule =~ /Contract8/i
    && (exists($winner{Lectio93}) || exists($commemoratio{Lectio7})))
  {
    %w = (columnsel($lang)) ? %winner : %winner2;
    $w = $w{Lectio8} . $w{Lectio9};
    $w =~ s/\&teDeum//;
  }
  my $wo = $w;

  #look for commemoratio 9
  #if ($rule =~ /9 lectio/i && $rank < 2) {$rule =~ s/9 lectio//i;}
  if ( $version !~ /1960|Monastic/i
    && $commune !~ /C10/
    && $rule !~ /no93/i
    && $winner{Rank} !~ /Octav.*(Epi|Corp)/i
    && ($dayofweek != 0 || $winner =~ /Sancti/i || $winner =~ /Nat2/i)
    && (($rule =~ /9 lectio/i && $num == 9) || ($rule !~ /9 lectio/i && $num == 3 && $winner !~ /Tempora/i))
    || ($rank < 2 && $winner =~ /Sancti/i && $num == 4))
  {
    %w = (columnsel($lang)) ? %winner : %winner2;

    if (($w{Rank} =~ /Simplex/i || ($version =~ /1955/ && $rank == 1.5)) && exists($w{'Lectio94'})) {
      $w = $w{'Lectio94'};
    } elsif (exists($w{'Lectio93'})) {
      $w = $w{'Lectio93'};
    }

    if (
         ($commemoratio =~ /tempora/i || $commemoratio =~ /01\-05/)
      && ($homilyflag || exists($commemoratio{Lectio7}))
      && $comrank > 1
      && ( $rank > 4
        || ($rank >= 3 && $version =~ /Trident/i)
        || $homilyflag
        || exists($winner{Lectio1}))
      )
    {
      %w = (columnsel($lang)) ? %commemoratio : %commemoratio2;
      $wc = $w{"Lectio7"};
      $wc ||= $w{"Lectio1"};

      if ($wc) {
        setbuild2("Last lectio Commemoratio ex Tempore #1");
        my %comm = %{setupstring($datafolder, $lang, 'Psalterium/Comment.txt')};
        my @comm = split("\n", $comm{'Lectio'});
        $comment = ($commemoratio{Rank} =~ /Feria/) ? $comm[0] : ($commemoratio =~ /01\-05/) ? $comm[3] : $comm[1];
        $w = setfont($redfont, $comment) . "\n$wc";
      }
    }

    if ($transfervigil) {
      if (!(-e "$datafolder/$lang/$transfervigil")) { $transfervigil =~ s/v\.txt/\.txt/; }
      my %tro = %{setupstring($datafolder, $lang, $transfervigil)};
      if (exists($tro{'Lectio Vigilia'})) { $w = $tro{'Lectio Vigilia'}; }
    }
    my $cflag = 1;    #*************  03-30-10
    if ($winner{Rule} =~ /9 lectiones/i && exists($winner{Responsory9})) { $cflag = 0; }
    if ($winner{Rule} !~ /9 lectiones/i && exists($winner{Responsory3})) { $cflag = 0; }

    if ( $commemoratio =~ /sancti/i
      && $commemoratio{Rank} =~ /S\. /i
      && ($winner !~ /tempora/i || $winner{Rank} < 5)
      && ($version !~ /1955/ || $comrank > 4)
      && $cflag)
    {
      %w = (columnsel($lang)) ? %commemoratio : %commemoratio2;
      my $ji = 94;
      $wc = $w{"Lectio$ji"};

      if (!$wc && $w{Rank} !~ /infra octav/i) {
        $wc = '';

        for ($ji = 4; $ji < 7; $ji++) {
          my $w1 = $w{"Lectio$ji"};
          if (!$w1 || ($ji > 4 && $w1 =~ /\!/)) { last; }
          if ($wc =~ /(.*?)\_/s) { $wc = $1; }
          $wc .= $w1;
        }
      }
      $wc ||= $w{"Lectio93"};

      if ($wc) {
        setbuild2("Last lectio: Commemoratio from Sancti #$ji");
        my %comm = %{setupstring($datafolder, $lang, 'Psalterium/Comment.txt')};
        my @comm = split("\n", $comm{'Lectio'});
        $comment = $comm[2];
        $w = setfont($redfont, $comment) . "\n$wc";
      }
    }
    if ($winner{Rank} =~ /Octav.*(Epi|Corp)/i && $w !~ /!.*Vigil/i) { $w = $wo; }
    ;    #*** if removed from top
    if (exists($w{'Lectio Vigilia'})) { $w = $w{'Lectio Vigilia'}; }
    if ($w =~ /!.*?Octav/i || $w{Rank} =~ /Octav/i) { $w = $wo; }
    $w = addtedeum($w);
  }

  if ($ltype1960 == 3 && $num == 4) {
    if (exists($w{'Lectio94'})) {
      $w = $w{'Lectio94'};
    }    #contracted legend for commemoratio
    else {
      my $w1 = %w;
      if ($version =~ /newcal/i && !exists($w{Lectio5})) { %w = (columnsel($lang)) ? %commune : %commune2; }
      my $i = 5;

      while ($i < 7) {
        my $w1 = $w{"Lectio$i"};
        if (!$w1 || $w1 =~ /\!/) { last; }
        if ($w =~ /(.*?)\_/s) { $w = $1; }
        $w .= $w1;
        $i++;
      }
      %w = %w1;
    }
  }
  if (($ltype1960 || ($winner =~ /Sancti/i && $rank < 2)) && $num > 2) { $num = 3; $w = addtedeum($w); }
  if ($version =~ /monastic/i) { $w =~ s/\&teDeum//g; }
  if ($num == 3 && $winner =~ /Tempora/ && $rule !~ /9 lectiones/i && $rule =~ /Feria Te Deum/i) { $w = addtedeum($w); }

  #get item from [Responsory$num] if no responsory
  if ($w && $w !~ /\nR\./ && $w !~ /\&teDeum/i) {
    my $s = '';
    $na = $num;

    if ($version =~ /1960/ && $winner =~ /tempora/i && $dayofweek == 0 && $dayname[0] =~ /(Adv|Quad)/i && $na == 3) {
      $na = 9;
    }
    if (contract_scripture($num) && $version !~ /Monastic/i) { $na = 3; }

    if ($version =~ /1955|1960/ && exists($w{"Responsory$na 1960"})) {
      $s = $w{"Responsory$na 1960"};
    } elsif ($rule =~ /Responsory Feria/i) {
      if (exists($scriptura{"Responsory$na"})) {
        $s = (columnsel($lang)) ? $scriptura{"Responsory$na"} : $scriptura2{"Responsory$na"};
      } else {
        $s = (columnsel($lang)) ? $scriptura{"Lectio$na"} : $scriptura2{"Lectio$na"};

        if ($s =~ /\n\_(.*?)/s) {
          $s = "_$1";
        } else {
          $s = '';
        }
      }

      if (!$s && $version =~ /1960/ && exists($scriptura{"Responsory$na 1960"})) {
        $s = (columnsel($lang)) ? $scriptura{"Responsory$na 1960"} : $scriptura2{"Responsory$na 1960"};
      }
    } else {
      if ($version eq "Monastic" && $dayofweek != 0 && $month == 1 && $day > 6 && $day < 13) {
        $na += 4 if ($dayofweek == 2 || $dayofweek == 5) ;
        if ($dayofweek == 3) { # Saturday dont work due C10 || $dayofweek == 6 ) {
          $na += 1 if ($na > 1);
          $na += 8;
        }
      }
      if (exists($w{"Responsory$na"})) {
        $s = $w{"Responsory$na"};
      } elsif ($version =~ /1960/ && exists($commune{"Responsory$na"})) {
        my %c = (columnsel($lang)) ? %commune : %commune2;
        $s = $c{"Responsory$na"};
      }
      if (exists($winner{"Responsory$na"})) { $s = ''; }

      #$$$ watch initia rule
    }

    if (!$s) {
      my %w = (columnsel($lang)) ? %winner : %winner2;
      if (exists($w{"Responsory$na"})) { $s = $w{"Responsory$na"}; }

      if (!$s) {
        %w = (columnsel($lang)) ? %commune : %commune2;
        if (exists($w{"Responsory$na"})) { $s = $w{"Responsory$na"}; }
      }
    }
    matins_lectio_responsory_alleluia($s, $lang);
    $w =~ s/\s*$/\n\_\n$s/;
  }
  $w = responsory_gloria($w, $num);

  #add Tu autem before responsory
  if ($expand =~ /all/) {
    our %prayers;
    $tuautem = $prayers{$lang}->{'Tu autem'};
  } else {
    $tuautem = '$Tu autem';
  }
  $w =~ s/^\_//;

  if ($rule !~ /Limit.*?Benedictio/i) {
    my $before = '';
    my $rest = $w;
    $rest =~ s/[\n\_ ]*$//gs;
    while ($rest =~ /(.*?)_(.*)/s) { $before .= "$1_"; $rest = $2; }
    if (!$before) { $before = $w; $rest = ''; }
    $before =~ s/[\n\_ ~]*$//gs;

    if ($before =~ /(.*?)\&teDeum/s) {
      $before = $1;
      $rest = "&teDeum\n";
    } elsif ($rest =~ /(.*?)\&teDeum/s) {
      $before .= "\n_\n$1";
      $rest = "&teDeum\n";
    }
    $w = "$before" . "\n$tuautem\n_\n$rest";
  }

  #handle verse numbers for passages
  my $item = 'Lectio';
  if (exists($translate{$lang}{$item})) { $item = $translate{$lang}{$item}; }
  $item =~ s/\s*$//;
  $w = "_\n" . setfont($largefont, "$item $num") . "\n$w";
  my @w = split("\n", $w);
  $w = "";

  foreach $item (@w) {
    if ($item =~ /^([0-9]+)\s+(.*)/s) {
      my $rest = $2;
      my $num = $1;
      if ($rest =~ /^\s*([a-z])(.*)/is) { $rest = uc($1) . $2; }
      $item = setfont($smallfont, $num) . " $rest";
    }
    $w .= "$item\n";
  }

  if ($dayname[0] !~ /Pasc/i) {
    $w =~ s/\(Allel[uú][ij]a.*?\)//isg;
  } else {
    $w =~ s/\((Allel[uú][ij]a.*?)\)/$1/isg;
  }
  if ($dayname[0] =~ /Quad/i) { $w =~ s/[(]*allel[uú][ij]a[\.\,]*[)]*//ig; }

  #handle parentheses in non Latin
  if ($lang !~ /Latin/i) {
    $w =~ s/\((.*?[.,].*?)\)/parenthesised_text($1)/eg;
  }
  $w = replaceNdot($w, $lang);
  return $w;
}

sub parenthesised_text {
  my $text = shift;
  return setfont(our $smallfont, $text)
    if (length($text) < 20 || $text =~ /[0-9][.,]/);
  return "($text)";
}

#Te Deum instead of responsory
sub addtedeum {
  my $w = shift;

  if ($rule =~ /no Te Deum/i
    || ($winner =~ /(Tempora|C12)/i && $dayname[0] =~ /(Adv|Quad)/i) && $winner{Rank} !~ /Septem dolorum/i)
  {
    $w =~ s/\&teDeum//;
  }

  if ($w =~ /teDeum/i || $winner =~ /C12/i || ($rule =~ /no Te Deum/i && ($winner !~ /12-28/ || $dayofweek > 0))) {
    return $w;
  }
  if ($votive =~ /(C9|Defunctorum)/i) { return ($w); }
  if ($winner =~ /Tempora/i && $dayname[0] =~ /(Adv|Quad)/i && $winner !~ /C10/i) { return $w; }
  if ($month == 12 && $day == 24) { return $w; }

  if ( ($rank >= 2 && $dayname[1] !~ /(feria|vigilia)/i && $rule !~ /Responsory9/i)
    || ($rule =~ /Feria Te Deum/i || $winner =~ /Sancti/i || $winner =~ /C10/i))
  {
    my $before = ($w =~ /(.*?)(\nR. |\n\@)/s) ? $1 : $w;
    $before =~ s/\_$//;
    $before =~ s/\n*$//;
    $w = "$before" . "\n\&teDeum\n";
  }
  return $w;
}

#*** beginwith($str)
# formats the benediction for building script output
sub beginwith {
  my $str = shift;
  my @str = split(" ", $str);
  $str = "$str[0] $str[1]";
  $str =~ s/\n/ /g;
  return $str;
}

#*** lect1960($lang)
# sets the benedictiones and sub calls for the 1960 version 3 lection
sub lect1960 {

  my $lang = shift;
  my $evan_regexp = shift;
  my %w = (columnsel($lang)) ? %winner : %winner2;
  my %s = (columnsel($lang)) ? %scriptura : %scriptura2;
  my %benedictio = %{setupstring($datafolder, $lang, 'Psalterium/Benedictions.txt')};
  my $i = 3;

  if ($rank < 2 || $winner{Rank} =~ /Feria/) {
    $i = ($dayofweek % 3);
    if ($i == 0) { $i = 3; }
  }
  my $w = lectio(1, $lang);
  if ($w =~ $evan_regexp) { $i = 3; }
  my @a = split("\n", $benedictio{"Nocturn $i"});

  if ($rule =~ /ex C10/) {
    my %m = (columnsel($lang)) ? %commune : %commune2;
    @a = split("\n", $m{Benedictio});
    setbuild2('Special benedictio');
  }
  my $divaux = ($rule =~ /Divinum auxilium/i || $commune{Rule} =~ /Divinum auxilium/i) ? 1 : 0;

  if ($winner =~ /sancti/i && $rank >= 2 && ($winner{Rank} =~ /(s\.|ss\.)/i && $winner{Rank} !~ /vigil/i) && !$divaux) {
    my $j = 6;
    if ($winner{Rank} =~ /(virgin|vidu|víduæ|poenitentis|pœnitentis)/i) { $j += 2; }
    if ($winner{Rank} =~ /ss\./i) { $j++; }
    $a[3] = $a[$j];
  }
  if ($rule =~ /Ipsa Virgo Virginum/i || $winner{Rank} =~ /Mari\w*\b\s*Virgin/i) { $a[3] = $a[10]; }
  if ($rule =~ /Quorum Festum/i && !$divaux) { $a[3] = $a[7]; }
  if ($rule =~ /Quarum Festum/i && !$divaux) { $a[3] = $a[9]; }
  $w = $w{'Lectio1'};
  if (!$w) { $w = $s{'Lectio1'}; }

  if ($w =~ $evan_regexp) {
    $a[2] = $benedictio{Evangelica};
  } else {
    if (exists($a[6])) { $a[2] = $a[5]; }
    if ($winner{Rank} =~ /dominica/i) { $a[4] = $benedictio{Evangelica9}; }
  }
  setbuild2("B3 : " . beginwith($a[4]));
  if ($version =~ /1960/ && $lang =~ /Latin/i) { $a[1] = 'Jube, Dómine, benedícere.'; }
  push(@s, "_");

  if ($rule !~ /Limit.*?Benedictio/i) {
    push(@s, "V. $a[1]");
    push(@s, "Benedictio. $a[2]");
  }
  push(@s, "\&lectio(1)");
  push(@s, "\n");

  if ($rule !~ /Limit.*?Benedictio/i) {
    push(@s, "V. $a[1]");
    push(@s, "Benedictio. $a[3]");
  }
  push(@s, "\&lectio(2)");
  push(@s, "\n");

  if ($rule !~ /Limit.*?Benedictio/i) {
    push(@s, "V. $a[1]");
    push(@s, "Benedictio. $a[4]");
  }
  push(@s, "\&lectio(3)");
  push(@s, "\n");
}
use constant {
  LT1960_DEFAULT => 0,
  LT1960_FERIAL => 1,
  LT1960_SUNDAY => 2,
  LT1960_SANCTORAL => 3,
  LT1960_OCTAVEII => 4
};

#*** gettype1960
#returns for 1960 version
#  1 for ferial office
#  2 for Sunday office
#  3 for saint's office
#  4 for office within II. cl. octave
# 0 for the other versions or if there are 9 lectiones
sub gettype1960 {
  my $type = LT1960_DEFAULT;

  if ($version =~ /1960|Monastic|Newcal/i && $votive !~ /(C9|Defunctorum)/i) {
    if ($dayname[1] =~ /post Nativitatem/i) {
      $type = LT1960_OCTAVEII;
    } elsif ($rank < 2 || $dayname[1] =~ /(feria|vigilia|die)/i) {
      $type = LT1960_FERIAL;
    } elsif ($version !~ /Monastic/i && ($dayname[1] =~ /dominica.*?semiduplex/i || $winner =~ /Pasc1\-0/i)) {
      $type = LT1960_SUNDAY;
    } elsif ($rank < 5) {
      $type = LT1960_SANCTORAL;
    }
    if ($rule =~ /9 lectiones 1960|12 lectiones/i) { $type = LT1960_DEFAULT; }
  }
  return $type;
}

#*** responsory_gloria($lectio_text, $num)
# adds or removes \&gloria to lection
# return the modified lectio text
#
sub responsory_gloria {
  my $w = shift;
  my $num = shift;
  $w =~ s/\&Gloria1?/\&Gloria1/g;
  $prev = $w;
  if ($w =~ /(.*?)\&Gloria/is) { $prev = $1; }
  $prev =~ s/\s*$//gm;

  if ($w =~ /\&teDeum/i || ($num == 1 && $dayname[0] =~ /Adv1|Pasc0/i && $dayofweek == 0) || $rule =~ /requiem Gloria/i)
  {
    return $w;
  }
  if ($num == 2 && $version =~ /1960/ && $dayname[0] =~ /(Adv|Quad)/i && $winner =~ /Tempora/i) { return $prev; }

  if ($num == 8 && $winner =~ /12-28/ && $dayofweek == 0) {
    delete($winner{Responsory9});
    delete($winner2{Responsory9});
  }
  if ($num == 8 && exists($winner{Responsory9}) && ($rule !~ /12 lectio/)) { return $w; }
  if ($version =~ /Monastic/i && $num == 2) { return $prev; }
  my $flag = 0;

  my $read_per_noct = ($rule =~ /12 lectio/) ? 4 : 3;
  if (
       ($num % $read_per_noct == 0)
    || ($rule =~ /9 lectiones/i && ($winner !~ /tempora/i || $dayname[0] !~ /(Adv|Quad)/i) && $num == 8)
    || ( $version =~ /1960/
      && $rule =~ /9 lectiones/i
      && $rule =~ /Feria Te Deum/i
      && $num == 2
      && ($dayname[0] !~ /quad/i))
    || (gettype1960() > 1 && $num == 2 && $winner !~ /C12/)
    || ($rank < 2 && $num == 2 && $winner =~ /(Sancti)/)
    || ($num == 2 && $winner =~ /C10/)
    || ($num == 2 && ($rule =~ /Feria Te Deum/i || $dayname[0] =~ /Pasc[07]/i) && $rule !~ /9 lectiones/i)
    )
  {
    if ($w !~ /\&Gloria/i) {
      $w =~ s/[\s_]*$//gs;
      $line = ($w =~ /(R\..*?$)/) ? $1 : '';
      $w .= "\n\&Gloria1\n$line";
    }
    return $w;
  }
  return $prev;
}

#*** ant matutinum($ant1, $ant, $ind)
# changes $ant $ant1 for Eastertime
# - 1 nocturn rule (Pasch0 Pent0 week)
# weekdays (Alleluia)
# Sundays special antiphonas
# only one antiphon for a nocturn
sub ant_matutinum {
  my $ant1 = shift;
  my $ant = shift;
  my $ind = shift;

  if ( $version =~ /1960/
    && ($dayname[0] =~ /Pasc6/i || ($dayname[0] =~ /Pasc5/i && $dayofweek > 3))
    && ($rank < 5 || $winner{Rank} =~ /Dominica/i))
  {
    if ($ind == 0) { return (Alleluia_ant($lang, 1, 1), ''); }
    if ($ind == 12) { return ('', Alleluia_ant($lang, 1, 1)); }
    return ('', '');
  }

  #Pasc0 Pent0 week
  if ($rule =~ /1 nocturn/i) {
    my %w = (columnsel($lang)) ? %winner : %winner2;
    if (!exists($w{'Ant Matutinum'}) && $winner{Rank} =~ /ex/i) { %w = (columnsel($lang)) ? %commune : %commune2; }
    my @ant = split("\n", $w{'Ant Matutinum'});
    $ant = $ant1 = $ant[$ind];
    @ant = split('\*', $ant);
    if ($duplex < 3 && $version !~ /1960/) { $ant1 = $ant[0]; }
    return ($ant, $ant);
  }
  if ($winner =~ /Pasc5-4/i || $winner{Rank} =~ /ex tempora\/Pasc5\-4/i) { return ($ant1, $ant); }

  # special Ant Matutinum, used for Eastertime 1st and 2nd class feasts
  my @spec = splice(@spec, @spec);

  if (exists($winner{'Ant Matutinum'}) || $winner{Rank} =~ /\;\;ex /) {
    %spec = (columnsel($lang)) ? %winner : %winner2;
    @spec = split("\n", $spec{'Ant Matutinum'});

    if (!@spec) {
      %spec = %{officestring($datafolder, $lang, $commune)};
      @spec = split("\n", $spec{'Ant Matutinum'});
    }
  }

  #Rule Ant Matutinum n special
  if ($rule =~ /Ant Matutinum ([0-9]+) special/i) {
    my $ind = $1;
    %wa = (columnsel($lang)) ? %winner : %winner2;
    $wa = $wa{"Ant Matutinum $ind"};
    $wa =~ s/\s*$//;

    if ($wa) {
      $spec[$ind] =~ s/^.*?;;/$wa;;/;
      if ($ind == 12 && $dayname[0] =~ /Pasc/i) { $spec[10] =~ s/^.*?;;/$wa;;/; }
    }
  }

  #weekday psalter returns  $ant1, $ant
  if ($dayofweek > 0 && (!@spec || $winner =~ /\/C10/)) {
    if ($rule !~ /9 lectio/i || ($version =~ /1960/ && $rank < 5)) {
      if ($ind == 0) {
        $ant1 = Alleluia_ant($lang, 0);
        $ant = '';
      } elsif ($version =~ /Trident/i && $ind == 5) {
        $ant1 = '';
        $ant = Alleluia_ant($lang, 1);
      } elsif ($ind == 12) {
        $ant1 = '';
        $ant = Alleluia_ant($lang, 1);
      } else {
        $ant1 = $ant = '';
      }
    } else {    #3 nocturns
      if ($ind == 0 || $ind == 5 || $ind == 10) {
        $ant1 = Alleluia_ant($lang, 0);
        $ant = '';
      } elsif ($ind == 2 || $ind == 7 || $ind == 12) {
        $ant1 = '';
        $ant = Alleluia_ant($lang, 1);
      } else {
        $ant1 = $ant = '';
      }
    }
    return ($ant1, $ant);
  }

  #Sunday psalter prepares @spec
  if ($winner{Rank} =~ /Dominica/i) {
    %spec = %{setupstring($datafolder, $lang, 'Psalterium/Psalmi matutinum.txt')};
    @spec = split("\n", $spec{'Pasc Ant Dominica'});
  }

  #one antiphon for a nocturn
  if ($rule !~ /9 lectio/i || ($version =~ /1960/ && ($rank < 5 || $winner{Rank} =~ /Dominica/i))) {
    if ($ind == 0) {
      $ant1 = $spec[0];
      $ant = '';
    } elsif ($ind == 12) {
      $ant1 = '';
      $ant = $spec[0];
    } else {
      $ant1 = $ant = '';
    }
  } elsif ($ind == 0) {
    $ant1 = $spec[0];
    $psalmi[3] = $spec[3];
    $psalmi[4] = $spec[4];
    $ant = '';
  } elsif ($ind == 5) {
    $ant1 = $spec[5];
    $psalmi[8] = $spec[8];
    $psalmi[9] = $spec[9];
    $ant = '';
  } elsif ($ind == 10) {
    $ant1 = $spec[10];
    $psalmi[13] = $spec[12];
    $psalmi[14] = $spec[14];
    $ant = '';
  } elsif ($ind == 2) {
    $ant1 = '';
    $ant = $spec[0];
  } elsif ($ind == 7) {
    $ant1 = '';
    $ant = $spec[5];
  } elsif ($ind == 12) {
    $ant1 = '';
    $ant = $spec[10];
  } else {
    $ant1 = $ant = '';
  }

  if ($ant1 && $duplex < 3 && ($ind == 0 || $ind == 5 || $ind == 10) && $version !~ /1960/) {
    @ant = split('\*', $ant1);
    $ant1 = $ant[0];
  }
  return ($ant1, $ant);
}

#*** initiarule($month, $day, $year)
# returns the key from the proper Str$ver$year table for the date
sub initiarule {

  my $month = shift;
  my $day = shift;
  my $year = shift;
  my $ver =
      ($version =~ /monastic/i) ? 'M'
    : ($version =~ /1570/i) ? '1570'
    : ($version =~ /Trid/) ? '1910'
    : ($version =~ /1960/) ? '1960'
    : 'DA';
  my @lines;

  if ($num < 4 && $version !~ /monastic/i && (@lines = do_read("$datafolder/Latin/Tabulae/Str$ver$year.txt"))) {
    my $str = join('', @lines);
    $str =~ s/\=/\;\;/g;
    my %str = split(';;', $str);
    my $key = sprintf("%02i-%02i", $month, $day);
    if (exists($str{$key})) { return $str{$key}; }
  }
  return '';
}

#*** resolveitable(\%w, $file, $lang)
# input %w = winner hash; $file = Str$ver$year table actual line
# returns the winner hash
sub resolveitable {

  my $w = shift;
  my $file = shift;
  my $lang = shift;
  my %w = %$w;
  my (%winit, @file, $lim, $start, $i);

  if ($file !~ /\~B$/ || !$initia) {
    $file =~ s/~[AB]$//;
    @file = split('~', $file);
    $lim = 3;
    $start = 1;

    if ($initia) {
      $start = (@file < 2) ? 3 : 2;
      if ($rule !~ /(9|12) lectiones/i && $winner =~ /Sancti/i) { $lim = 1; $start = 1; }
    }
    $i = 1;

    while (@file && $i <= $lim) {
      $file = shift(@file);
      %winit = %{setupstring($datafolder, $lang, "$temporaname/$file.txt")};

      #$w{"Lectio$start"} = $winit{"Lectio$i"};
      #if (exists($winit{"Responsory$i"})) {$w{"Responsory$start"} = $winit{"Responsory$i"};}
      %w = tferifile(\%w, \%winit, $start, 1, $lang);
      $i++;
      $start++;
    }

    while ($start <= 3) {

      #$w{"Lectio$start"} = $winit{"Lectio$i"};
      #if (exists($winit{"Responsory$i"})) {$w{"Responsory$start"} = $winit{"Responsory$i"};}
      %w = tferifile(\%w, \%winit, $start, $i, $lang);
      $i++;
      $start++;
    }
  } else {
    $file =~ s/~[AB]$//;
    @file = split('~', $file);
    $lim = 1;
    $start = 2;
    if (@file > 1 && !($rule !~ /(9|12) lectiones/i && $winner =~ /Sancti/i)) { $lim = 2; $start = 3; }

    if (exists($w{'Lectio2'})) {
      %winit = %w;
    } else {
      %winit = (columnsel($lang)) ? %scriptura : %scriptura2;
    }
    $i = 1;

    while ($start < 4) {

      #$w{"Lectio$start"} = $winit{"Lectio$i"};
      #if (exists($winit{"Responsory$i"})) {$w{"Responsory$start"} = $winit{"Responsory$i"};}
      %w = tferifile(\%w, \%winit, $start, $i, $lang);
      $i++;
      $start++;
    }
    $i = 1;
    $start = 1;

    while (@file && $i <= $lim) {
      $file = shift(@file);
      %winit = %{setupstring($datafolder, $lang, "$temporaname/$file.txt")};

      #$w{"Lectio$start"} = $winit{"Lectio$i"};
      #if (exists($winit{"Responsory$i"})) {$w{"Responsory$start"} = $winit{"Responsory$i"};}
      %w = tferifile(\%w, \%winit, $start, 1, $lang);
      $i++;
      $start++;
    }
  }
  return %w;
}

#*** sub tferifile(/$w, /$winit, $start, $i, $lang)
# fill $w{Lectio$start} and conditionally $w{Responsory$start} from %winit office
sub tferifile {
  my ($w, $winit, $start, $i, $lang) = @_;
  my %w = %$w;
  my %winit = %$winit;
  $w{"Lectio$start"} = $winit{"Lectio$i"};

  if (($winit{Rule} =~ /Initia cum Responsory/i || $winit{Rank} =~ /Dominica/i) && exists($winit{"Responsory$i"})) {
    $w{"Responsory$start"} = $winit{"Responsory$i"};
  } elsif (!exists($w{"Responsory$start"})) {
    my %s = (columnsel($lang)) ? %scriptura : %scriptura2;
    $w{"Responsory$start"} = $s{"Responsory$i"};
  }
  return %w;
}

#*** STJamesRule(\%w, $lang, $num, $book);
# returns the modified hash
sub StJamesRule {

  my $w = shift;
  my $lang = shift;
  my $num = shift;
  my $s = shift;
  my %w = %$w;
  my %w1 = undef;
  my $key;

  if ($w{Rank} =~ /Dominica/i && prevdayl1($s)) {
    my $kd = "$dayname[0]-1";
    if ($ordostatus =~ /Ordo/i) { return $kd; }
    %w1 = %{setupstring($datafolder, $lang, "$temporaname/$kd.txt");};
  }

  if ($w{Rank} =~ /Jacobi/ && $scriptura{Lectio1} =~ /!.*?($s) /i) {
    if ($ordostatus =~ /Ordo/) { $s = $scriptura; $s =~ s/(Tempora\/|\.txt)//gi; return $s; }
    %w1 = columnsel($lang) ? %scriptura : %scriptura2;
  }
  if (!exists($w1{"Lectio$num"})) { return %w; }
  $w{"Lectio$num"} = $w1{"Lectio$num"};
  return %w;
}

sub prevdayl1 {
  my @monthtab = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31.30, 31);
  if (leapyear($year)) { $month[1] = 29; }
  my $s = shift;
  my @s = split(',', $s);
  $s = $s[0];
  my $d = $day - 1;
  my $m = $month;
  if ($day = 0) { $m--; $d = $monthtab[$m - 1]; }
  my $kd = sprintf("%02i-%02i", $m, $d);
  my %w1 = %{setupstring($datafolder, $lang, "$sanctiname/$kd.txt")};
  my $l = $w1{Lectio1};
  if ($l =~ /!.*?$s 1:/i) { return 1; }
  return 0;
}

#*** contract_scripture($num)
# returns 1 if lesson 2 and 3 is to be contracted
sub contract_scripture {
  my $num = shift;
  if ($num != 2 || $votive =~ /(C9|Defunctorum)/i) { return 0; }
  if ($version !~ /1960|Monastic/i) { return 0; }
  if ($commune =~ /C10/i) { return 1; }

  if ( ($ltype1960 == LT1960_SANCTORAL || $ltype1960 == LT1960_SUNDAY)
    && $rule !~ /scriptura1960/i
    && ($dayname[1] !~ /feria/i || $commemoratio))
  {
    return 1;
  }
  return 0;
}
