#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office Matins subroutines
use FindBin qw($Bin);
use lib "$Bin/..";
use DivinumOfficium::Directorium qw(get_stransfer hymnmerge hymnshift);

# Defines ScriptFunc and ScriptShortFunc attributes.
use DivinumOfficium::Scripting;
$a = 4;

use constant {
  LT1960_DEFAULT => 0,
  LT1960_FERIAL => 1,
  LT1960_SUNDAY => 2,
  LT1960_SANCTORAL => 3,
  LT1960_OCTAVEII => 4,
  LT1960_OCTAVE => 5,
};

#*** invitatorium($lang)
# collects and returns psalm 94 with the antipones
sub invitatorium {
  my $lang = shift;
  my %invit = %{setupstring($lang, 'Psalterium/Special/Matutinum Special.txt')};
  my $name = gettempora('Invitatorium');

  if ($version =~ /Trid|Monastic/i && (!$name || ($name eq 'Quad' && $dayofweek != 0))) {
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
  setbuild('Psalterium/Special/Matutinum Special', $name, 'Invitatorium ord');
  my $ant = chompd($invit[$i]);
  my ($w, $c);

  if ( $version =~ /Monastic/i
    && $dayofweek
    && $winner =~ /Pasc/
    && $winner !~ /Pasc[07]/
    && $winner !~ /Pasc5-4/
    && !($version =~ /trident|divino/i && $dayname[1] =~ /ascensio|pent|joseph/i))
  {
    $ant = prayer("Alleluia Duplex", $lang);
    $ant =~ s/(\S+), (\S+)\./$1, $2, * $1/;
  } else {

    #look for special from proprium the tempore or sancti
    ($w, $c) = getproprium("Invit", $lang, $seasonalflag, 1);
    if ($w) { $ant = chompd($w); $comment = $c; }
    setcomment($label, 'Source', $comment, $lang, translate('Antiphona', $lang));
  }
  $ant =~ s/^.*?\=\s*//;
  $ant = chompd($ant);
  $ant = "Ant. $ant";
  postprocess_ant($ant, $lang);
  my @ant = split('\*', $ant);
  my $ant2 = "Ant. $ant[1]";
  $lang = 'Latin-Bea' if $lang eq 'Latin' && $psalmvar;
  my $fname = checkfile($lang, 'Psalterium/Invitatorium.txt');

  if (my @a = do_read($fname)) {
    $_ = join("\n", @a);

    if ($rule =~ /Invit2/i) {

      # old Invitatorium2 = Quadp[123]-0
      s/ \*.*//;
    } elsif ($dayname[0] =~ /Quad[56]/i && $winner =~ /tempora/i && $rule !~ /Gloria responsory/i) {

      # old Invitatorium3
      s/&Gloria/\&Gloria2/;
      s/v\. .* \^ (.)/v. \u\1/m;
      s/\$ant2\s*(?=\$)//s;
    } elsif (!$w
      && $dayofweek == 1
      && $winner =~ /Tempora/
      && ($dayname[0] =~ /(Epi|Pent|Quadp)/i || ($dayname[0] =~ /Quad/i && $version =~ /Trident|Monastic/i)))
    {
      # old Invitatorium4
      s/^v\. .* \+ (.)/v. \u\1/m;
    }

    s{[+*^] }{}g;    # clean division marks

    s/\$ant2/$ant2/eg;
    s/\$ant/$ant/eg;

    push(@s, $_);
  } else {
    $error .= "$fname cannnot open";
  }
}

#*** hymnus($lang)
# collects and returns the hymn for matutinum
sub hymnusmatutinum {
  my $lang = shift;
  my $hymn = '';
  my $name = 'Hymnus';
  $name .= checkmtv($version, \%winner) unless (exists($winner{'Hymnus Matutinum'}));
  my ($h, $c) = getproprium("$name Matutinum", $lang, $seasonalflag, 1);

  if ($h) {
    if (hymnshift($version, $day, $month, $year)) {  # if 1st Vesper hymn has been omitted due to concurrent II. Vespers
      my ($h1, $c1) = getproprium("$name Vespera", $lang, $seasonalflag, 1);
      $h = $h1;
      setbuild2("Hymnus shifted");
    } elsif (hymnmerge($version, $day, $month, $year)) {    # if also 2nd Vesper been omitted
      my ($h1, $c1) = getproprium("$name Vespera", $lang, $seasonalflag, 1);
      $h =~ s/^(v. )//;
      $h1 =~ s/\_(?!.*\_).*/\_\n$h/s;    # find the Doxology as last verse since e.g. Venantius(05-18) has a proper one
      $h = $h1;
      setbuild2("Hymnus merged");
    }
    $hymn = $h;
    $comment = $c;
  } else {
    my %hymn = %{setupstring($lang, 'Psalterium/Special/Matutinum Special.txt')};
    $name = gettempora('Hymnus matutinum');
    $name = ($name) ? "Hymnus $name" : "Day$dayofweek Hymnus";
    $comment = ($name) ? 1 : 5;
    if ($name =~ /^Day0 Hymnus$/i && ($month < 4 || ($monthday && $monthday =~ /^1[0-9][0-9]\-/))) { $name .= '1'; }
    setbuild("Psalterium/Special/Matutinum Special", $name, 'Hymnus ord');

  }
  setcomment($label, 'Source', $comment, $lang);
  ($hymn, $name);
}

sub nocturn {
  my ($num, $lang, $psalmi, @select) = @_;
  our ($version);

  push(@s, '!' . translate('Nocturn', $lang) . ' ' . ('I' x $num) . '.');

  my @psalmi_n = map { $psalmi->[$select[$_]] } 0 .. @select - 3;
  my $duplexf = $version =~ /196/ || ($duplex > 2 && $rule !~ /Matins simplex/);
  antetpsalm(\@psalmi_n, $duplexf, $lang);

  # versus can be text or reference (number)
  my (@vs) = ($select[-1] =~ /^\d+$/ ? (@{$psalmi}[$select[-2]], @{$psalmi}[$select[-1]]) : ($select[-2], $select[-1]));
  push(@s, "\n", @vs, "\n");
}

#*** psalmi_matutinum($lang)
# collects and returns psalms and lections for matutinum
sub psalmi_matutinum {
  $lang = shift;
  if ($version =~ /monastic/i && $winner{Rule} !~ /Matutinum Romanum/i) { return psalmi_matutinum_monastic($lang); }
  my %psalmi = %{setupstring($lang, 'Psalterium/Psalmi/Psalmi matutinum.txt')};
  my $d = ($version =~ /trident/i) ? 'Daya' : 'Day';
  my $dw = $dayofweek;

  #if ($winner{Rank} =~ /Dominica/i) {$dw = 0;}
  my @psalmi = split("\n", $psalmi{"$d$dw"});
  setbuild("Psalterium/Psalmi/Psalmi matutinum", "$d$dw", 'Psalmi ord');
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

  my $name = gettempora('Psalmi Matutinum');

  if ($name && $version !~ /Trident/i && ($winner =~ /tempora/i || $name eq 'Nat' || $name eq 'Epi')) {
    if ($dayofweek == 0) {
      foreach my $i (1 .. 3) {
        ($psalmi[($i - 1) * 5 + 3], $psalmi[($i - 1) * 5 + 4]) = split("\n", $psalmi{"$name $i Versum"}, 2);
      }
      if ($version =~ /1960/) { ($psalmi[13], $psalmi[14]) = ($psalmi[3], $psalmi[4]); }
    } else {
      my $i = $dayofweek;
      $i -= 3 if $i > 3;
      ($psalmi[13], $psalmi[14]) = split("\n", $psalmi{"$name $i Versum"}, 2);
    }
    setbuild2("Subst Matutitunun Versus $name $dayofweek");
  }

  my ($w, $c) = getantmatutinum($lang);

  if ($w) {
    @psalmi = split("\n", $w);
    $comment = $c;
    $prefix .= ' ' . translate('et Psalmi', $lang);
  }

  if ($dayname[0] =~ /Pasc[1-6]/i && $votive !~ /C9/) {
    @psalmi = ant_matutinum_paschal(\@psalmi, $lang, length($w));
  }

  if ($rule =~ /Ant Matutinum ([0-9]+) special/i) {
    my $ind = $1;
    my %wa = (columnsel($lang)) ? %winner : %winner2;
    my $wa = $wa{"Ant Matutinum $ind"};
    $wa =~ s/\s*$//;

    if ($wa) {
      if ($ind == 12 && $dayname[0] =~ /Pasc/i) {
        $psalmi[10] =~ s/^.*?;;/$wa;;/;
      } else {
        $psalmi[$ind] =~ s/^.*?;;/$wa;;/;
      }
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

  # Trident rubrics: Anticipated Sundays are "Simplex", i.e., 1 nocturn with 3 lessions (of the Gospel Homily!)
  if ( $rule =~ /9 lectio/i
    && !gettype1960()
    && $rank >= 2
    && !($version =~ /trident/i && $winner{Rank} =~ /Dominica/i && $dayofweek > 0))
  {
    setbuild2("9 lectiones");

    unless (exists($winner{'Ant Matutinum'})) {
      if ( ($name eq 'Pasch' || $name eq 'Asc')
        && $version !~ /trident/i
        && $rank < 5
        && $winner{'Rank'} !~ /(?:in|post).*octava.*Ascensio/i)
      {
        my $dname = ($winner{Rank} =~ /Dominica/i) ? 'Dominica' : 'Feria';
        my @spec = split("\n", $psalmi{"Pasch Ant $dname"});
        foreach my $i (3, 4, 8, 9, 13, 14) { $psalmi[$i] = $spec[$i]; }
        setbuild2("Pasch Ant $dname special versums for nocturns");
      } elsif ($winner =~ /tempora/i
        && $name =~ /^(?:Adv|Quad|Pasch)$/i)
      {
        foreach my $i (1 .. 3) {
          ($psalmi[($i - 1) * 5 + 3], $psalmi[($i - 1) * 5 + 4]) = split("\n", $psalmi{"$name $i Versum"}, 2);
        }
        setbuild2("$name special versums for nocturns");
      }
    }

    #  if ( $version =~ /Trident/i
    #   && $testmode =~ /seasonal/i
    #   && $winner =~ /Sancti/i
    #   && $rank >= 2
    #   && $rank < 5
    #   && !exists($winner{'Ant Matutinum'}))
    # {
    #   my %psalmi = %{setupstring($lang, 'Psalterium/Psalmi/Psalmi matutinum.txt')};
    #   @psalmi = split("\n", $psalmi{"Daya$dayofweek"});
    #   nocturn(1, $lang, \@psalmi, (0, 1, 6, 7));
    #   lectiones(1, $lang);
    #   nocturn(2, $lang, \@psalmi, (2, 3, 6, 7));
    #   lectiones(2, $lang);
    #   nocturn(3, $lang, \@psalmi, (4, 5, 6, 7));
    #   lectiones(3, $lang);
    #   return;
    # }

    for (1 .. 3) {
      nocturn($_, $lang, \@psalmi, ((($_ - 1) * 5) .. ($_ * 5 - 1)));
      lectiones($_, $lang);
    }

    push(@s, "\n");
    return;
  }

  # Here we begin the logic for an office of three lessons. On nine-lesson days
  # we've already returned.
  my @spec;

  if ($dayname[0] =~ /Pasc[1-6]/i && $version !~ /Trident/i) {    #??? ex
    if ($version =~ /196/ && $name eq 'Asc') {
      my %r = %{setupstring($lang, 'Tempora/Pasc5-4.txt')};

      #@spec = split("\n", $r{'Ant Matutinum'});
      @spec = split("\n", $r{'Nocturn 1 Versum'});
      unshift(@spec, '') for 1 .. 3;
      push(@spec, '') for 1 .. 3;
      push(@spec, split("\n", $r{'Nocturn 2 Versum'}));
      push(@spec, '') for 1 .. 3;
      push(@spec, split("\n", $r{'Nocturn 3 Versum'}));
    } else {
      @spec = split("\n", $psalmi{"Pasch Ant Dominica"});
    }
    foreach my $i (3, 4, 8, 9, 13, 14) { $psalmi[$i] = $spec[$i]; }

    if ((my $i = dayofweek2i()) == 1) {
      ($psalmi[13], $psalmi[14]) = ($psalmi[3], $psalmi[4]);
    } elsif ($i == 2) {
      ($psalmi[13], $psalmi[14]) = ($psalmi[8], $psalmi[9]);
    }
  }

  if (@psalmi > 9 && $rule !~ /1 Nocturn/i) {
    setbuild1("3 lectiones");
  } else {
    setbuild1("One nocturn");
  }

  my @psalm_indices = (0, 1, 2);

  if ($version =~ /trident/i) {
    if ($rule !~ /1 nocturn/i) {
      push(@psalm_indices, 3, 4, 5);
    }
    @spec = ($psalmi[6], $psalmi[7]);

    if ($dayofweek == 6 && $rule =~ /ex C10/i) {
      @spec = split("\n", $psalmi{"BMV Versum"});

      # In the office of the BVM on Saturday under the Tridentine rubrics, Psalm 99
      # is replaced by Psalm 91, as the former is said at Lauds.
      $psalm_indices[1] = 8;
    }

    if ($name =~ /^(?:Adv|Quad5?|Pasch)$/) {
      my $i = $dayofweek;
      $i -= 3 if $i > 3;
      @spec = split("\n", $psalmi{"$name $i Versum"});
    }
  }

  if (@psalmi > 9) {
    push(@psalm_indices, 5, 6, 7, 10, 11, 12);

    # Versum for 3 lectiones is variable
    @spec = ($psalmi[13], $psalmi[14]);
    setbuild2('Ord Versus per annum');
    $comment = 5;
  }

  if ($month == 12 && $day == 24) {
    @spec = split("\n", $psalmi{"Nat24 Versum"});
    setbuild2('Subst Versus Nat24');
    $comment = 1;
  }

  if ($dayname[0] =~ /Pasc[07]/i) {
    @spec = ($psalmi[3], $psalmi[4]);
    setbuild2('Subst Versus for de tempore');
    $comment = 2;
  }

  if ($rule =~ /votive nocturn/i) {    # FIXMEMB: in true only C12
    my $i = dayofweek2i();
    $i--;
    $i *= 5;

    @psalm_indices = ($i .. ($i + 2));
    setbuild1("3 psalms 3 lectiones");
  }

  push(@psalm_indices, @spec[0, 1]);

  nocturn(1, $lang, \@psalmi, @psalm_indices);
  lectiones(0, $lang);
  return;
}

#*** dayofweek2i
# returns  for
#   1    Monday, Thursday, Sunday
#   2    Tuesday, Friday
#   3    Wednesday, Saturday
sub dayofweek2i {
  my $i = our $dayofweek || 1;
  $i -= 3 if $i > 3;
  $i;
}

#*** cujus_q
# return shift from Cujus festum
sub cujus_q {
  return 1 if our $rule =~ /Quorum Festum/;               # "Quorum by rule"
  return 4 if our $commune =~ /C11|08-15|09-08|12-08/;    # fest. BMV + 8es

  local ($_) = shift;

  return -2 if /basilic/i;                                # no change for 11-09 11-18r
  return 5 if /S. P. N. Benedicti/;

  my $j = 0;                                                          # "Cujus …, ipse"
  if (/(virgin|vidua|poenitentis|pœnitentis|C6|C7)/i) { $j += 2; }    # "Cujus …, ipsa"
  if (/(?:ss\.|sanctorum|sociorum)/i) { $j++; }                       # "Quorum / Quarum"

  $j;
}

#*** get_absolutio_et_benedictiones
sub get_absolutio_et_benedictiones {

  my $num = shift;
  my $lang = shift;
  our ($rule, $version, $commune, $winner);

  my %ben = %{setupstring($lang, 'Psalterium/Benedictions.txt')};
  my @abs = split(/\n/, $ben{Absolutiones});
  my @eva = split(/\n/, $ben{Evangelica});
  my @ben;

  ## 9/12 lectiones
  if ($num && ($rule =~ /9 lectiones/i && ($version !~ /Monastic/) || $rule =~ /12 lectiones/)) {
    my $rpn = ($rule =~ /12 lectio/) ? 3 : 2;    # readings per nocturn - 1
    @ben = split(/\n/, $ben{"Nocturn $num"});

    if ($num == 3 && $winner =~ /Sancti|Quad5-5/) {
      if ($winner =~ /12-25/) {
        @ben = split(/\n/, $ben{"Nocturn 3 12-25"});
        setbuild2('Special Evangelii Benedictio');

        # Replace Benediction 8 (or 11 for Monastic)
      } elsif (
        $winner{Rank} =~ /(?:\bss?\.|sanctorum)/i    # sancti
        || $commune =~ /C11|08-15|09-08|12-08/       # + fest. BMV + 8es
      ) {
        $ben[1] = $ben[3 + cujus_q($winner{Rank})];
        setbuild2("3rd Noct. B${rpn}. : " . beginwith($ben[1]));
      }
    }

    if ($num == 3 && $winner !~ /12-25/) {    # 'Evangelica lectio' - first
      if ($version =~ /Monastic/) {
        unshift @ben, $eva[0];
      } else {
        $ben[0] = $eva[0];
      }
    }

    # check if last lectio if from ev.
    if ($num == 3 && $winner !~ /12-25/) {
      my $w = lectio($version =~ /Monastic/ ? 12 : 9, 'Latin');

      if ($w =~ /!(?:Matt|Marc|Luc|Joannes)/) {    # update last benedictio if so
        my @ev9 = split(/\n/, $ben{Evangelica9});
        $ben[$rpn] = $ev9[0];
        setbuild2("3rd Noct. B" . ($rpn + 1) . ". : " . beginwith($ev9[0]));
      }
    }

    unshift @ben, $abs[$num - 1];

    ## BMV special cases
  } elsif ($winner =~ /C1[02]/) {
    my %mariae = %{setupstring($lang, subdirname('Commune', $version) . "C10.txt")};
    @ben = split("\n", $mariae{Benedictio});
    setbuild2('Special benedictio');

    ## 3 lectiones
  } else {
    @ben = split(/\n/, $ben{'Nocturn 3'});    #  will modify for tempora

    # first with homily from evang.
    if ( $winner{Rank} =~ /vigil|quatt|ciner/i
      || $winner =~ /Quad[1-5]-[^0]|Quad6-1|Pasc5-1|Pasc[07]/
      || ($winner =~ /Nat(?:29|3[01])/ && $version !~ /196[02]/))
    {
      $ben[0] = $eva[0];

      # then Sunday in 1960 with 3 readings
    } elsif ($winner{Rank} =~ /dominica/i) {
      my @ev9 = split(/\n/, $ben{Evangelica9});
      $ben[2] = $ev9[0];

      # then Sancti & BMV
    } elsif (($winner =~ /Sancti/ && $winner{Rank} =~ /\bss?\./i)
      || $commune =~ /C11/)
    {
      $ben[1] = $ben[3 + cujus_q($winner{Rank})];
      setbuild2("B2. : " . beginwith($ben[1]));

      # then tempora
    } else {
      my $i = dayofweek2i();
      @ben = split(/\n/, $ben{"Nocturn $i"});
    }

    unshift @ben, $abs[dayofweek2i() - 1];
  }

  @ben;
}

#*** lectiones($number, $language)
#input: the index number for the nocturn, 0 for 3 lectiones only and the language
#collects and prints the the Benedictio, and set the call for the lectiones/responsory
sub lectiones {
  my $num = shift;
  my $lang = shift;
  our (@s, $version, $rule);

  my @a = get_absolutio_et_benedictiones($num, $lang);

  if ($rule !~ /Limit.*?Benedictio/i) {
    push(@s, "\$rubrica Pater secreto");
    push(@s, "\$Pater noster Et");
    push(@s, "Absolutio. $a[0]", '$Amen') unless $version =~ /^Ordo Praedicatorum/;
  } else {
    push(@s, "\$Pater totum secreto");
  }
  push(@s, "\n");

  my $rpn = ($rule =~ /12 lectio/) ? 4 : 3;    # readings per nocturn
  $num ||= 1;

  for my $i (1 .. $rpn) {                      # push all the lectios
    my $l = ($num - 1) * $rpn + $i;

    if ($rule !~ /Limit.*?Benedictio/i) {
      push(@s, prayer('Jube domne', $lang));
      push(@s, "Benedictio. $a[$i]", '$Amen');
    }
    push(@s, "\&lectio($l)", "\n");    # the lesson is going to be added by the subroutine below at a later time
  }
}

sub matins_lectio_responsory_alleluia(\$$) {
  my ($r, $lang) = @_;

  $$r =~ s/\s*~\s*/ /gs;

  my @resp = split("\n", $$r);
  ensure_single_alleluia(\$resp[1], $lang);
  ensure_single_alleluia(\$resp[3], $lang);
  ensure_single_alleluia(\$resp[-1], $lang);
  $$r = join("\n", @resp);
}

#
#*** getC10readingname
sub getC10readingname {
  return "Lectio M101" if ($version !~ /196/ && $month == 9 && $day > 8 && $day < 15);
  my $satnum = floor(($day - 1) / 7 + 1);
  $satnum = 4 if ($satnum == 5);
  return sprintf("Lectio M%02i%s", $month, ($version =~ /1963/i) ? $satnum : '');
}

#*** lectio($num, $lang)
# input $num=index number for the lectio(1-9 or 1-3) and language
# print the appropriate lectio collected from the winner or commune
# handles the commemoratio as last
sub lectio : ScriptFunc {
  my $num = shift;
  my $lang = shift;
  $ltype1960 = gettype1960();
  if ($winner =~ /C12/i) { $ltype1960 = LT1960_DEFAULT; }    # Officium parvum B.M.V.

  if ($ltype1960 == LT1960_SUNDAY && $num == 3) {            # 3rd reading in a Sunday office
    $num = 7;                                                # diverge to Gospel / Homily
    setbuild("L3: Diverged to Homily");
  } elsif (
    (    $ltype1960 == LT1960_SANCTORAL
      && $num == 3
      && $votive !~ /(C9|Defunctorum)/i)                     # 3rd reading in sanctoral office of 3 readings
    || ( $version !~ /196/
      && $rule !~ /1 et 2 lectiones/i
      && $num == 3
      && $winner =~ /Sancti/i
      && $winner !~ /09-sab-oct/
      && $rank < 2
      && $winner{Rank} !~ /vigil/i
      && !($version =~ /1963/i && $dayname[0] != /Nat|Epi1/i))
    )
  { # sanctoral simplex feast (unless monastic in Nativitytide and Epiphany => prevent the former Octave days of Stephanus, Joannes, Innocents)
    $num = 4;    # diverge to legend
    setbuild2("L3: Diverged to Legend");
  }
  my %w = (columnsel($lang)) ? %winner : %winner2;

  if ($num < 4 && $version =~ /trident/i && $winner{Rank} =~ /Dominica/i && $month != 12 && $dayofweek > 0) {
    my $inum = $num + 6;
    $w{"Lectio$num"} = $w{"Lectio$inum"};

    if ($num == 1) {
      setbuild2("Lectio de Homilia Dominicæ anticipiata");
    }
  }

  # Save the Nocturn of the Lectio requested:
  my $nocturn = int(($num - 1) / ($rule =~ /12 lectiones/i ? 4 : 3)) + 1;

  #Nat1-0 special rule
  # TODO: Get rid of this special case by separating the temporal and sanctoral parts of Christmas, thus allowing occurring Scripture to be defined.
  if ($nocturn == 1 && $rule =~ /Lectio1 (Oct|Temp)Nat/i) {
    my %c;

    if ($1 =~ /Temp/i) {

      # Monastic: Dominica Secunda Nativitatis
      my %scrip = %{setupstring($lang, subdirname('Sancti', $version) . "$month-$day.txt")};

      $c{"Lectio$_"} = lectiones_ex3_fiunt4(\%scrip, $_) foreach (1 .. 4);
      $c{"Responsory$num"} = $w{"Responsory$num"};
    } elsif ($day < 29) {

      # GitHub3539: in 1960 rubrics, Scripture on Sunday (26-28) comes from Nativity
      %c = %{officestring($lang, subdirname('Sancti', $version) . "12-25.txt")};
    } else {

      # the Nat..o.txt files do not exist for Monastic
      my $tfile = subdirname('Tempora', $version) . "Nat$day" . ($version =~ /^Trident/i ? "o.txt" : ".txt");
      %c = %{officestring($lang, $tfile)};
    }
    $c{'Lectio2'} .= $c{'Lectio3'} if (contract_scripture(2));

    $w{"Lectio$num"} = $c{"Lectio$num"};
    $w{"Responsory$num"} = $c{"Responsory$num"};
    setbuild2("Lectiones I Nocturno ex Tempora Nativitatis") if $num == 1;
  }

  #Lectio1 tempora: special rule for Octave of Epiphany
  if ($nocturn == 1 && $rule =~ /Lectio1 tempora/i && exists($scriptura{"Lectio1"})) {
    my %scrip = (columnsel($lang)) ? %scriptura : %scriptura2;

    if ($version =~ /monastic/i && $rule =~ /12 lectiones/i) {
      $w{"Lectio$num"} = lectiones_ex3_fiunt4(\%scrip, $num);
    } else {
      $w{"Lectio$num"} = $scrip{"Lectio$num"};

      if ($version =~ /Trident/i && exists($w{"ResponsoryT$num"})) {
        $w{"Responsory$num"} = $scrip{"Responsory$num"};
      } else {
        $w{"Responsory$num"} = $scrip{"Responsory$num"};
      }
    }
    setbuild2("subst: Lectio$num tempora");
  }

  #scriptura1960
  if ( $num < 3
    && $version =~ /196/
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
    setbuild2("subst: Lectio$num de scriptura (rubrics 1960)");
  }

  #** handle initia table (Str$ver$year)
  if ($nocturn == 1 && $version !~ /monastic/i) {
    my $file = initiarule($month, $day, $year);
    if ($file) { %w = resolveitable(\%w, $file, $lang); }
  }

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

  if ($nocturn == 1 && $rule =~ /Lectio1 Quad/i && $dayname[0] !~ /Quad/i) {
    $w = '';
  }    # some saints in April when after easter

  if ($nocturn == 1 && $commemoratio{Rank} =~ /Quattuor/i && $month == 9) {
    $w = '';
  }    # Q.T. Septembris...

  if ( $rule =~ /12 lectiones/i
    && $rule !~ /Lectio1 (Oct|Temp)(Nat|ora)/i
    && (($num == 4 && !exists($w{Lectio1})) || ($num == 9 && !exists($w{Lectio10}))))
  {
    $w = '';
  }    # accidental Lectio4 or Lectio9 from Roman version

  if ($w && $num % ($rule =~ /12 lectiones/i ? 4 : 3) == 1) {
    my @n = split('/', $winner);
    setbuild2("Lectio$num ex $n[0]");
  }

  #prepares for case of homily instead of scripture
  my $homilyflag = (exists($commemoratio{Lectio1})
      && $commemoratio{Lectio1} =~ /\!(Matt|Mark|Marc|Luke|Luc|Joannes|John)\s+[0-9]+\:[0-9]+\-[0-9]+/i) ? 1 : 0;

  if ($homilyflag && $commemoratio{Rank} =~ /vigilia/i) {
    $homilyflag = 9;
  }

  if (
    !$w    # we don't have a lectio yet
    && (
      (    $communetype =~ /^ex/i
        && $commune =~ /Tempora/i
        && $rank > 3)    # either we have 'ex Tempora' on Duplex majus or higher
      || (
        (
          $nocturn == 1                        # or we are in the first nocturn
          && $homilyflag == 1                  # and there is a homily to be commemorated
          && exists($commune{"Lectio$num"})    # which has not been superseded by the sanctoral
        )
      )
    )
  ) {
    %w = (columnsel($lang)) ? %commune : %commune2;
    $w = $w{"Lectio$num"};
    if ($w && $num == 1) { setbuild2("Lectio1-3 from Tempora/$file replacing homily"); }
  }

  #look for commune if sancti and 'ex commune' (for Trident also "vide")
  if (
      !$w
    && $winner =~ /sancti/i
    && $commune =~ /^C/
    && ( ($communetype =~ /^ex/i && $rank > 3)
      || ($rule =~ /in (\d) Nocturno Lectiones ex/i && $1 eq $nocturn))
  ) {
    my %com = (columnsel($lang)) ? %commune : %commune2;
    my $lecnum = "Lectio$num";

    if ($rule =~ qr/in $nocturn Nocturno Lectiones ex Commune in (\d+) loco/i) {
      my $loco = $1;
      $lecnum .= " in $loco loco" if $loco > 1;
      $w = $com{$lecnum};

      if ($w && $num % ($rule =~ /12 lectiones/i ? 4 : 3) == 1) {
        setbuild2("Lectio$num in $loco loco ex $commune{Name}");
      }
    } elsif (exists($com{$lecnum})) {
      $w = $com{$lecnum};
      if ($w && $num % ($rule =~ /12 lectiones/i ? 4 : 3) == 1) { setbuild2("Lectio$num ex $commune{Name}"); }
    }

    if ($w && contract_scripture($num)) {
      $lecnum =~ s/Lectio2/Lectio3/;
      $w .= $com{$lecnum};
      setbuild2("Contract scripture from Commune for Rubrics 1960");
    }
  }

  # fill with Scriptura for 1st nocturn if possible
  if (
    !$w    # we still don't have a lectio yet as there is no homily
    && (
      ($num < 4 && exists($scriptura{"Lectio$num"}))    # for the first nocturn, if their is scripture available
      || ($num == 4 && $rule =~ /12 lect/i && exists($scriptura{"Lectio3"}))
    )                                                   # or for Monastic if we have to split the lessons at the ¶ mark
    && ($version !~ /trident/i || $rank < 5)
    )
  {                                                     # but not in Tridentinum Duplex II. vel I. classis
    %w = (columnsel($lang)) ? %scriptura : %scriptura2;
    $w = $w{"Lectio$num"};

    if ($version =~ /monastic/i && $rule =~ /12 lectiones/i && ($version !~ /1963/ || $rule =~ /Lectio1 tempora/i)) {
      $w = lectiones_ex3_fiunt4(\%w, $num);
    }

    if ($version =~ /Trident/ && $winner =~ /Sancti/ && $rank < 2) {

      # dirty hack to fix 3932
      $w{Responsory1} = $w{Responsory2} = '';
    }
    if ($w && $num == 1) { setbuild2("Lectio1 ex scriptura"); }
  } elsif (!$w && $num == 4 && exists($commemoratio{"Lectio$num"}) && ($version =~ /1960/i))
  {    # handle diverged 3rd lesson in 1960
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

  if (!$w && exists($commune{"Lectio$num"})) {
    my %c = (columnsel($lang)) ? %commune : %commune2;
    $w = $c{"Lectio$num"};

    if (contract_scripture($num)) {
      my $w1 = $c{'Lectio3'};
      $w .= $w1;
    }
  }

  if ($commune{Rule} =~ /Special Lectio $num/) {
    %mariae = %{setupstring($lang, subdirname('Commune', $version) . "C10.txt")};
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
  }
  my $wo = $w;

  #look for commemoratio 9
  #if ($rule =~ /9 lectio/i && $rank < 2) {$rule =~ s/9 lectio//i;}
  if (
       $version !~ /196/
    && $commune !~ /C10/
    && $rule !~ /no93/i
    && $winner{Rank} !~ /Octav.*(Epi|Corp)/i
    && (
      (
           $rule =~ /9 lectio/i
        && $num == 9
        && !(exists($winner{Responsory9}) || ($winner{Rank} =~ /Dominica/i && $version !~ /Trid/i))
      )
      || ($rule !~ /(9|12) lectio/i && $num == 3 && $winner !~ /Tempora/i && !exists($winner{Responsory3}))
      || ( $rule =~ /12 lectio/i
        && $num == 12
        && !(($rank > 5.5 && $dayofweek && !homilyflag) || ($winner{Rank} =~ /Dominica/i && $rank > 3)))
    )
    || (($ltype1960 == LT1960_SANCTORAL || $rank < 2) && $winner =~ /Sancti/i && $num == 4)
    )
  {    # 9th lesson diverged to Legend of Commemorated Saint
    %w = (columnsel($lang)) ? %winner : %winner2;

    if (($w{Rank} =~ /Simplex/i || ($version =~ /1955/ && $rank == 1.5)) && exists($w{'Lectio94'})) {
      setbuild2("Last lectio Commemoratio ex Legenda historica (#94)");
      $w = $w{'Lectio94'};
    } elsif (exists($w{'Lectio93'})) {
      setbuild2("Last lectio Commemoratio ex Sanctorum (#93)");
      $w = $w{'Lectio93'};
    }

    $j0 = ($num == 12) ? 9 : 7;    # where to look for Homily

    if ( ($commemoratio =~ /tempora/i && $commemoratio !~ /Nat(29|30|31)/i || $commemoratio =~ /01\-05/)
      && ($homilyflag == 1 || exists($commemoratio{"Lectio$j0"}))
      && $comrank > 1
      && ($rank > 4 || ($rank >= 3 && $version =~ /Trident/i) || $homilyflag == 1 || exists($commemoratio{Lectio1})))
    {
      %w = (columnsel($lang)) ? %commemoratio : %commemoratio2;
      $wc = $w{"Lectio$j0"};

      if ($wc && $version =~ /monastic/i && exists($w{"Responsory$j0"}) || exists($w{"Responsory12C"})) {

        # In M1930, the assigned responsory when a Homily is commemorated only is sometimes different
        $winner{"Responsory$num"} = $w{"Responsory12C"} || $w{"Responsory$j0"};
        $winner2{"Responsory$num"} = $w{"Responsory12C"} || $w{"Responsory$j0"};
      } elsif (!$wc) {
        $wc = $w{"Lectio1"};

        if ($wc && $version =~ /monastic/i && exists($w{"Responsory1"}) || exists($w{"Responsory12C"})) {

          # In M1930, the assigned responsory when a Homily is commemorated only is sometimes different
          $winner{"Responsory$num"} = $w{"Responsory12C"} || $w{"Responsory1"};
          $winner2{"Responsory$num"} = $w{"Responsory12C"} || $w{"Responsory1"};
        }
      }

      if ($wc) {
        setbuild2("Last lectio Commemoratio ex Tempore #1");
        my %comm = %{setupstring($lang, 'Psalterium/Comment.txt')};
        my @comm = split("\n", $comm{'Lectio'});
        $comment = ($commemoratio{Rank} =~ /Feria/) ? $comm[0] : ($commemoratio =~ /01\-05/) ? $comm[3] : $comm[1];
        $w = setfont($redfont, $comment) . "\n$wc";
      }
    }

    if ($transfervigil) {
      if (!(-e "$datafolder/$lang/$transfervigil")) { $transfervigil =~ s/v\.txt/\.txt/; }
      my %tro = %{setupstring($lang, $transfervigil)};
      if (exists($tro{'Lectio Vigilia'})) { $w = $tro{'Lectio Vigilia'}; }
    } elsif ($homilyflag == 9) {
      my %tro = (columnsel($lang)) ? %commemoratio : %commemoratio2;

      if (exists($tro{'Lectio1'})) {
        my $trorank = $tro{Rank};
        $trorank =~ s/;;.*//;
        $w = '!' . translate('Commemoratio', $lang) . ": $trorank\n" . $tro{'Lectio1'};
      }
    }
    my $cflag = 1;    #*************  03-30-10
                      #if ($winner{Rule} =~ /9 lectiones/i && exists($winner{Responsory9})) { $cflag = 0; }
                      #if ($winner{Rule} !~ /9 lectiones/i && exists($winner{Responsory3})) { $cflag = 0; }

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

      if (!$wc && $w{Rank} =~ /infra octav/i) {
        if (my $commemo1 = $commemoentries[1]) {
          %w = %{setupstring($lang, $commemo1 . ".txt")};
          $wc = $w{Lectio94} || ($w{Lectio4} . $w{Lectio5} . $w{Lectio6}) || $w{Lectio93};
          setbuild2("entered $commemo1");
        }
      }

      if ($wc) {
        setbuild2("Last lectio: Commemoratio from Sancti #$ji");

        if ($wc !~ /\!/) {    # add Commemoratio comment if not there already
          if (exists($w{Rank})) {
            my @wcr = split(';;', $w{Rank});
            $w = '!' . translate('Commemoratio', $lang) . ": $wcr[0]\n" . $wc;
          } else {
            my %comm = %{setupstring($lang, 'Psalterium/Comment.txt')};
            my @comm = split("\n", $comm{'Lectio'});
            $comment = $comm[2];
            $w = setfont($redfont, $comment) . "\n$wc";
          }
        } else {
          $w = $wc;
        }
      }
    }
    if ($winner{Rank} =~ /Octav.*(Epi|Corp)/i && $w !~ /!.*Vigil/i) { $w = $wo; }
    ;    #*** if removed from top
    if (exists($w{'Lectio Vigilia'})) { $w = $w{'Lectio Vigilia'}; }

    #if ($w =~ /!.*?Octav/i || $w{Rank} =~ /Octav/i) { $w = $wo; setbuild2("transfervigil deleted");}
  }

  if ($ltype1960 == LT1960_SANCTORAL && $num == 4) {
    if (exists($winner{'Lectio94'})) {
      %w = (columnsel($lang)) ? %winner : %winner2;
      $w = $w{'Lectio94'};
      setbuild2('Last lectio Commemoratio ex Legenda historica (#94/1960)');
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
  if (($ltype1960 || ($winner =~ /Sancti/i && $rank < 2)) && $num > 2) { $num = 3; }

  $w =~ s/¶//;               # remove ¶ mark if any
  $w =~ s/\&teDeum\n*//g;    # remove tedeum, will add if needed later

  if ($rule !~ /Limit.*?Benedictio/i) {

    #add Tu autem before responsory
    my $tuautem = $expand =~ /all/ ? prayer('Tu autem', $lang) : '$Tu autem';
    $w .= "\n$tuautem\n";
  }

  # add responsory
  if (!tedeum_required($num) || $version =~ /^(?:Monastic|Ordo Praedicatorum)/) {
    my $s;
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
      if ($version =~ /monastic/i && $dayofweek != 0 && $month == 1 && $day > 6 && $day < 13) {
        $na += 4 if ($dayofweek == 2 || $dayofweek == 5);

        if ($dayofweek == 3) {    # Saturday dont work due C10 || $dayofweek == 6 ) {
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
      if ($winner =~ /C9/ && $na == 9) { $na = 91; }
      if (exists($w{"Responsory$na"})) { $s = $w{"Responsory$na"}; }

      if (!$s) {
        %w = (columnsel($lang)) ? %commune : %commune2;
        if (exists($w{"Responsory$na"})) { $s = $w{"Responsory$na"}; }
      }
    }
    matins_lectio_responsory_alleluia($s, $lang) if alleluia_required($dayname[0], $votive);
    $s = responsory_gloria($s, $num);
    $w =~ s/\s*$/\n\_\n$s/;
  }

  $w =~ s/^\_//;

  # add initial to text
  if ($w !~ /^!/m) {
    $w =~ s/^(?=\p{Letter})/v. /;
  } elsif ($w !~ /^\d/m) {
    $w =~ s/^!.*?\n(?=\p{Letter})/$&v. /gm;
  }

  #handle verse numbers for passages
  my $item = translate('Lectio', $lang);
  $item .= " %s" unless ($item =~ /%s/);
  $w = ($rule !~ /Limit.*?Benedictio/i ? "_\n" : '') . setfont($largefont, sprintf($item, $num)) . "\n$w";
  my @w = split("\n+", $w);
  $w = "";

  my $initial = $nonumbers;

  foreach (@w) {
    if (/^([0-9]+)\s+(.*)/s) {
      my $rest = $2;
      my $num = "\n" . setfont($smallfont, $1);
      $rest =~ s/^./\u$&/ unless ($nonumbers);

      if ($initial) {
        $num = "\nv. ";
        $initial = 0;
      } elsif ($nonumbers) {
        $num = '';
      }
      $_ = "$num $rest";
    } else {
      $initial = 1 if (/^!/ && $nonumbers);
      $_ = "\n$_";
    }
    $w .= "$_";
  }

  #handle parentheses in non Latin
  if ($lang !~ /Latin/i) {
    process_inline_alleluias(\$w, $dayname[0] =~ /Pasc/);
    $w =~ s/\((.*?[.,\d].*?)\)/parenthesised_text($1)/eg;
  }

  $w = replaceNdot($w, $lang);
  $w .= "\n_\n\&teDeum\n" if tedeum_required($num);

  $w;
}

sub lectiones_ex3_fiunt4 {
  my $scrip = shift;
  my %scrip = %$scrip;
  my $num = shift;

  # split 3 lessons into 4
  my @scrips = ();

  for my $l0 (1 .. 3) {
    if ($scrip{"Lectio$l0"} !~ /¶/) {
      my $cc = $scrip{"Lectio$l0"};
      push(@scrips, $cc);
    } else {
      my @splits = split("¶\n", $scrip{"Lectio$l0"});
      push(@scrips, @splits);
    }
  }
  setbuild2("Lectiones ex 3 fiunt 4") if $num == 1;
  return $scrips[$num - 1];
}

sub parenthesised_text {
  my $text = shift;
  return setfont(our $smallfont, $text)
    if (length($text) < 20 || $text =~ /[0-9][.,]/);
  return "($text)";
}

sub tedeum_required {
  my $num = shift;
  our ($rule, $version, $winner, $commune, @dayname, $dayofweek, $duplex);

  return $num == 12 if $version =~ /^Monastic/;

  (    # last lectio?
    ($num == 9 && $rule =~ /9 lectiones/i)
      || (
        $num == 3
        && (
          $rule !~ /9 lectiones/i

          # 2 below conditions can be ommited if [Rule] '9 lectiones' wont be false
          || $duplex == 1
          || ($version =~ /19(?:55|60)/ && gettype1960() != LT1960_DEFAULT)
        )
      )
    )
    && $rule !~ /no Te Deum/
    && $commune !~ /C9/
    && ($winner !~ /(?:Adv|Quad)/ || $version =~ /^Monastic/)
    && (
         (!$dayofweek && $dayname[1] !~ /(Vigilia)/)
      || ($winner =~ /Sancti|Commune/i && $dayname[1] !~ /(Vigilia)/)           # Commune = Votive
      || $rule =~ /Feria Te Deum/i
      || $winner =~ /Pasc|Nat|C10/
      || ($winner =~ /^Tempora/ && $rank > 5 && $dayofweek)
      || ($version !~ /19(?:55|6)/ && $winner =~ /Pent01-[56]|Pent02-[1-4]/)    # Octave CC
      || ($version =~ /Divino/ && $winner =~ /Pent02-6|Pent03-[1-5]/)           # Octave SSCord
    );
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

#*** gettype1960
#returns for 1960 version
#  1 for ferial office
#  2 for Sunday office
#  3 for saint's office
#  4 for office within II. cl. octave
#  0 for the other versions or if there are 9 lectiones
sub gettype1960 {
  my $type = LT1960_DEFAULT;

  if ($version =~ /196/ && $votive !~ /(C9|Defunctorum)/i) {
    if ($dayname[1] =~ /post Nativitatem/i) {
      $type = LT1960_OCTAVEII;
    } elsif ($rank < 2 || $dayname[1] =~ /(feria|vigilia|die)/i) {
      $type = LT1960_FERIAL;
    } elsif ($version !~ /Monastic/i && ($dayname[1] =~ /dominica.*?semiduplex/i || $winner =~ /Pasc1\-0/i)) {
      $type = LT1960_SUNDAY;
    } elsif ($rank < 5) {
      $type = LT1960_SANCTORAL;
    }
  } elsif ($version =~ /monastic/i && $votive !~ /(C9|Defunctorum)/i) {
    if ($rank < 2 || ($dayname[1] =~ /(feria|vigilia|die)/i && $dayname[1] !~ /infra octavam/i)) {
      $type = LT1960_FERIAL;
    } elsif ($dayname[1] =~ /infra octavam/i) {
      $type = LT1960_OCTAVE;
    } elsif ($version !~ /trident/i && $rank < 4) {
      $type = LT1960_SANCTORAL;
    }
  }
  if ($rule =~ /9 lectiones 1960|12 lectiones/i) { $type = LT1960_DEFAULT; }

  return $type;
}

#*** responsory_gloria($lectio_text, $num)
# adds or removes \&gloria to responsory
# return the modified responsory
#
sub responsory_gloria {
  my $w = shift;
  $w =~ s/\&Gloria1?/\&Gloria1/g;
  my $num = shift;

  return $w
    if (($num == 1 && $winner =~ /(?:Adv1|Pasc0)-0/i) || $rule =~ /requiem Gloria/i);

  my $rpn = ($rule =~ /12 lectio/) ? 4 : 3;    # readings per nocturn

  if (
    ($num % $rpn == 0)                         # responsory after last lectio in nocturn
    ||                                         # or
    (
      $version !~ /^Monastic/                  # for non Monastic
      && $num % $rpn == ($rpn - 1)             # before last
      && tedeum_required($num + 1)             # when there is Te Deum after last
    )
  ) {

    if ($w !~ /\&Gloria/i) {
      $w =~ s/[\s_]*$//gs;
      $w =~ s/(R\..*?)$/$1\n\&Gloria1\n$1/;
    }
  } else {
    $w =~ s/.\&Gloria.*//s;
  }
  $w;
}

#*** ant matutinum_paschal(@_ref, $lang)
# sets matutinum antiphonas in pascal tide
sub ant_matutinum_paschal {
  my ($psalmi_ref, $lang, $proper) = @_;
  my @psalmi = @$psalmi_ref;
  our (@dayname, $version, $winner);

  if ($dayofweek || ($dayname[0] =~ /Pasc6/ && $version =~ /196/)) {
    if (!$proper || $winner =~ /\/C10/) {
      @psalmi = map {s/.*?(?=;;)//r} @psalmi;
      $psalmi[0] = alleluia_ant($lang) . $psalmi[0];

      if ($dayofweek && $rule =~ /9 lectio/i && ($version !~ /196/ || $rank > 3) && $rank >= 2) {    #3 nocturns
        $psalmi[5] = alleluia_ant($lang) . $psalmi[5];
        $psalmi[10] = alleluia_ant($lang) . $psalmi[10];
      }
    } elsif ($winner !~ /tempora/i) {    # each nocturn under single antiphonas apart Ascension
      foreach my $i (0 .. 3) {
        $psalmi[$i * 5 + 1] =~ s/.*;;/;;/;
        $psalmi[$i * 5 + 2] =~ s/.*;;/;;/;
      }
    }
  } else {
    if ($dayname[0] =~ /Pasc[1-5]/i && $dayname[1] =~ /Dominica/) {
      my %psalmi = %{setupstring($lang, 'Psalterium/Psalmi/Psalmi matutinum.txt')};
      my @a = split("\n", $psalmi{Pasch0});

      for (my $i = 0; $i < @psalmi; $i++) {
        $psalmi[$i] =~ s/.*;;/$a[$i]/;
      }

      if ($version =~ /196/) {    # one nocturn under single antiophona
        for (my $i = 1; $i < @psalmi; $i++) {
          $psalmi[$i] =~ s/.*;;/;;/;
        }
      }
    }
  }
  @psalmi;
}

#*** initiarule($month, $day, $year)
# returns the key from the proper Str$ver$year table for the date
sub initiarule {
  my $month = shift;
  my $day = shift;
  my $year = shift;

  my $key = sprintf("%02i-%02i", $month, $day);

  return get_stransfer($year, $version, $key);
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

  if ($file !~ /\~B$/ || !$initia) {  # ==> !( ~B && $initia ); unless there is a conflict between a B rule and a initia
    $file =~ s/~[AB]$//;              # remove ~A or ~B from the end of the string
    @file = split('~', $file);        # gather the transfered intias
    $lim = 3;                         # in general, allow up to 3 transferals
    $start = 1;                       # in general, start at 1

    if ($initia) {                    # if we have a inita on the day already (so we put the transferred afterwards)
      $start = (@file < 2) ? 3 : 2;    # if we have one transferred place it no. at 3; otherwise at 2&3

      if ($rule !~ /(9|12) lectiones/i && $winner =~ /Sancti/i) {
        $lim = 1;
        $start = 1;
      }    # in a sanctoral of 3 lessons, only one transfer is allowed; and placed at the beginning
    }
    $i = 1;

    while (@file && $i <= $lim) {    # while we have more transferals and stay in the limit
      $file = shift(@file);
      %winit = %{setupstring($lang, subdirname('Tempora', $version) . "$file.txt")};

      #$w{"Lectio$start"} = $winit{"Lectio$i"};
      #if (exists($winit{"Responsory$i"})) {$w{"Responsory$start"} = $winit{"Responsory$i"};}
      %w = tferifile(\%w, \%winit, $start, 1, $lang);
      $i++;
      $start++;
    }

    while ($start <= 3)
    { # only in case we put transfers "before", also transfer the remaining parts of the last initia (apparently this can only happen with a single transfer as well, so we can use $i equal to $start ???)

      #$w{"Lectio$start"} = $winit{"Lectio$i"};
      #if (exists($winit{"Responsory$i"})) {$w{"Responsory$start"} = $winit{"Responsory$i"};}
      %w = tferifile(\%w, \%winit, $start, $i, $lang);
      $i++;
      $start++;
    }
  } else {    # when there is a conflict of a ~B transfer and an inita itself
    $file =~ s/~[AB]$//;
    @file = split('~', $file);
    $lim = 1;      # in general allow 1 transfer and
    $start = 2;    # put the actual days in second place

    if (@file > 1 && !($rule !~ /(9|12) lectiones/i && $winner =~ /Sancti/i)) {
      $lim = 2;
      $start = 3;
    } # if there is more than 1 transferal which is not impeded by a Sanctoral office of 3 lections, allow 2 and put the actual day inita at 3

    if (exists($w{'Lectio2'})) {
      %winit = %w;
    } else {
      %winit = (columnsel($lang)) ? %scriptura : %scriptura2;
    }
    $i = 1;

    while ($start < 4) {    # first fill the actual day's inita at their appropriate place

      #$w{"Lectio$start"} = $winit{"Lectio$i"};
      #if (exists($winit{"Responsory$i"})) {$w{"Responsory$start"} = $winit{"Responsory$i"};}
      %w = tferifile(\%w, \%winit, $start, $i, $lang);
      $i++;
      $start++;
    }
    $i = 1;
    $start = 1;

    while (@file && $i <= $lim) {    # second, fill the transfers beforehand
      $file = shift(@file);
      %winit = %{setupstring($lang, subdirname('Tempora', $version) . "$file.txt")};

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
  my %w1 = {};
  my $key;

  if ($w{Rank} =~ /Dominica/i && prevdayl1($s)) {
    my $kd = "$dayname[0]-1";
    if ($ordostatus =~ /Ordo/i) { return $kd; }
    %w1 = %{setupstring($lang, subdirname('Tempora', $version) . "$kd.txt");};
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
  my %w1 = %{setupstring($lang, subdirname('Sancti', $version) . "$kd.txt")};
  my $l = $w1{Lectio1};
  if ($l =~ /!.*?$s 1:/i) { return 1; }
  return 0;
}

#*** contract_scripture($num)
# returns 1 if lesson 2 and 3 is to be contracted
sub contract_scripture {
  my $num = shift;
  if ($num != 2 || $votive =~ /(C9|Defunctorum)/i) { return 0; }
  if ($version !~ /196/) { return 0; }
  if ($commune =~ /C10/i) { return 1; }

  if ( ($ltype1960 == LT1960_SANCTORAL || $ltype1960 == LT1960_SUNDAY)
    && $rule !~ /scriptura1960/i
    && ($dayname[1] !~ /feria/i || $commemoratio))
  {
    return 1;
  }
  return 0;
}

#*** getantmatutinum($lang)
# Retrieve proper AntMatutinum (also from Commune if day requires so
# and, if necessary, intersperse the Versicles for Nocturns
# Backwards compatibility is ensured by checking if [AntMatutinum] already has the target lenght
# Roman 9 lesson: 3 Nocturns à 3 Antiphones, Versicle and Response for a total of 15 lines
# Monastic 12 lesson: 2 Nocturns à 6 Ant., V. & R. + 1 Ant. V. & R. for 3rd N. (total of 19 lines)
# Monastic infra 8vam: 1 Nocturn à 6 Ant., V. & R. + 6 Ant. for 2nd Noct. (total of 14 lines)
sub getantmatutinum {

  my $lang = shift;

  my @nocturns = (1, 2, 3);    # Versicles from Nocturns
  my $ppN = 3;                 # Psalms per Nocturn (Roman default)
  my $target = 15;             # Target lines (Roman default)
  my $flag = 0;                # If we have to look for Commune even when "vide"

  if ($version =~ /monastic/i && $winner{Rule} !~ /Matutinum Romanum/i) {
    $flag = $version !~ /1963/;    # for Trid. und Divino also look in Commune
    $ppN = 6;                      # Psalms per Nocturn (Monastic default)
    $target = 19;                  # Target lines (Monastic default)

    if ($winner{Rule} =~ /3 lectio/i) {    # in Monastic infra Octavam (with Ferial psalms)
      my $i = $dayofweek;
      $i -= 3 if $i > 3;
      @nocturns = ($i, 0);                 # Versicle for 1st Nocturn dep. on $dayofweek; No V&R for 2nd Noct.
      $target = 14;
    }
  }

  # Look up proper AntMatutinum and return if none
  my ($wprop, $cprop) = getproprium('Ant Matutinum', $lang, $flag, 1);
  return unless $wprop;

  my $w = $wprop;    # for Backwards compatibility pass through if target is met
  my @wprop = split("\n", $wprop);
  my @w = ();

  if (@wprop < $target) {
    foreach my $noc (@nocturns) {
      $ppN = @wprop if @wprop < $ppN;           # limit psalm lines in if exceeded
      push(@w, shift(@wprop)) for 1 .. $ppN;    # pass-through psalm lines for nocturn if they exist
      last unless $noc;                         # for 3 lectio, no versicle to be appended;

      my ($vers, $cvers) = getproprium("Nocturn $noc Versum", $lang, 1, 1);
      my @vers = split("\n", $vers);
      push(@w, @vers);                          # add "interspersed" Versicle
    }
    $w = join("\n", @w);
  }
  return ($w, $cprop);
}
