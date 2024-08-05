sub psalmi {
  my $lang = shift;
  our $psalmnum1 = 0;
  our $psalmnum2 = 0;

  if ($hora =~ /matutinum/i) {
    psalmi_matutinum($lang);
  } else {
    my $duplexf = $version =~ /196/;
    my $psalmi;

    if ($hora =~ /(laudes|vespera)/i) {
      $psalmi = psalmi_major($lang);
      $duplexf ||= $duplex > 2;
    } else {
      $psalmi = psalmi_minor($lang);
    }
    antetpsalm($psalmi, $duplexf, $lang);
  }
}

#*** psalmi_minor($lang)
#collects and returns psalms for prim, tertia, sexta, none, completorium
sub psalmi_minor {
  my $lang = shift;
  my %psalmi = %{setupstring($lang, 'Psalterium/Psalmi minor.txt')};
  my (@psalmi, $ant, $psalms);

  if ($version =~ /monastic/i) {
    @psalmi = split("\n", $psalmi{Monastic});
    my $i =
        ($hora =~ /prima/i) ? $dayofweek
      : ($hora =~ /tertia/i) ? 8
      : ($hora =~ /sexta/i) ? 11
      : ($hora =~ /nona/i) ? 14
      : 17;

    if ($hora !~ /(prima|completorium)/i) {
      if ($dayofweek > 0) { $i++; }
      if ($dayofweek > 1) { $i++; }
    }
    $psalmi[$i] =~ s/\=/\;\;/;
    my @a = split(';;', $psalmi[$i]);
    $ant = chompd($a[1]);
    $psalms = chompd($a[2]);
  } elsif ($version =~ /trident/i) {
    my $daytype = ($dayofweek == 0) ? 'Dominica' : 'Feria';
    my %psalmlines = split(/\n|=/, $psalmi{Tridentinum});
    my $psalmkey;

    if ($hora =~ /Prima/i) {
      my @days = ('Dominica', 'Feria II', 'Feria III', 'Feria IV', 'Feria V', 'Feria VI', 'Sabbato');

      # Prime has one form for each day of the week in the temporal
      # office, and another for feasts and Paschaltide.
      $psalmkey = 'Prima '
        . (
          (($winner =~ /Sancti/i && $winner{'Rank'} !~ /Vigil/i) || $winner =~ /Pasc|Quad6-[45]|Nat1-0/i)
          ? 'Festis'
          : $days[$dayofweek]
        );

      # Sunday Prime has a slightly different form from Septuagesima
      # until Easter.
      if ($dayofweek == 0 && $dayname[0] =~ /Quad/i) {
        $psalmkey .= ' SQP';
      }
    } else {

      # Psalmody at the hours is invariable. The antiphon at Terce,
      # Sext and None is different on Sundays.
      $psalmkey = ($hora =~ /Completorium/i) ? 'Completorium' : "$hora $daytype";
    }
    ($ant, $psalms) = split(';;', $psalmlines{$psalmkey});
    $ant = chompd($ant);
    $psalms = chompd($psalms);
  } else {
    @psalmi = split("\n", $psalmi{$hora});
    my $i = 2 * $dayofweek;

    if ($hora =~ /Completorium/i && $dayofweek == 6 && $winner{Rank} =~ /Dominica/i && $dayname[0] !~ /Nat/) {
      $i = 12;
    }
    if ($rule =~ /Psalmi\s*(minores)*\s*Dominica/i || $communerule =~ /Psalmi\s*(minores)*\s*Dominica/i) { $i = 0; }
    if ($version =~ /1955|1960/ && $rule =~ /horas1960 feria/i) { $i = 2 * $dayofweek; }
    if ($version =~ /1955|1960/ && $winner =~ /Sancti/i && $rank < 5) { $i = 2 * $dayofweek; }

    #if ($winner =~ /tempora/i && $dayofweek > 0 && $winner{Rank} =~ /Dominica/i && $rank < 6
    #  && $dayname[0] !~ /Nat/i) {$i = 2 * $dayofweek;}  #anticipated Sunday
    if ( $version =~ /19(?:55|60)/
      && ($winner =~ /sancti/i || $winner =~ /Nat[23]/i)
      && $rank < 6
      && $hora !~ /completorium/i)
    {
      $i = 2 * $dayofweek;
    }

    if ($hora =~ /Completorium/i && $dayofweek == 6 && $winner{Rank} =~ /Dominica/i && $dayname[0] !~ /Nat/) {
      $i = 12;
    }
    $ant = chompd($psalmi[$i]);
    $psalms = chompd($psalmi[$i + 1]);
    if (($version =~ /1960/ && $psalms =~ /117/ && $laudes == 2) || $rule =~ /Prima=53/i) { $psalms =~ s/117/53/; }
  }
  setbuild("Psalterium/Psalmi minor", "$hora Day$dayofweek", 'Psalmi ord');
  $comment = 0;

  if ($hora =~ /completorium/i && $version !~ /trident|monastic/i) {
    if ($winner =~ /tempora/i && $dayofweek > 0 && $winner{Rank} =~ /Dominica/i && $rank < 6) {
      ;
    }

    #psalmi dominica rule for completorium
    elsif (($rule =~ /Psalmi\s*(minores)*\s*Dominica/i || $communerule =~ /Psalmi\s*(minores)*\s*Dominica/i)
      && ($version !~ /1960/ || $rank >= 6))
    {
      $ant = chompd($psalmi[0]);
      $psalms = chompd($psalmi[1]);
      $prefix = '';
      $comment = 6;
    }
  }

  if ($winner =~ /tempora/i || $testmode =~ /seasonal/i || $dayname[0] =~ /pasc/i) {

    my $ind =
        ($hora =~ /Prima/i) ? 0
      : ($hora =~ /Tertia/i) ? 1
      : ($hora =~ /Sexta/i) ? 2
      : ($hora =~ /Nona/i) ? 4
      : -1;
    my $name = gettempora('Psalmi minor');

    if ($name eq 'Adv') {
      $name = $dayname[0];

      if ($day > 16 && $day < 24 && $dayofweek) {
        my $i = $dayofweek + 1;

        if ($dayofweek == 6 && $version =~ /trident|monastic.*divino/i) {    # take ants from feria occuring Dec 21st
          $i = get_stThomas_feria($year) + 1;
          if ($day == 23) { $i = ""; }                                       # use Sundays ant
        }
        $name = "Adv4$i";
      }
    }

    $ind = 0 if ($hora eq 'Completorium' && $name eq 'Pasch');

    if ($name && $ind >= 0) {
      my @ant = split("\n", $psalmi{$name});
      $ant = chompd($ant[$ind]);

      # add fourth alleluja
      $ant =~ s/(\S+)\.$/\1, \1./ if ($version =~ /monastic/i && $name eq 'Pasch');
      $comment = 1;
      setbuild("Psalterium/Psalmi minor", $name, "subst Antiphonas");
    }
  }

  my %w = (columnsel($lang)) ? %winner : %winner2;
  $ant =~ s/^.*?=\s*//;
  $feastflag = 0;

  #look for special from proprium the tempore of sancti
  if ($hora !~ /completorium/i) {
    my ($w, $c) = getproprium("Ant $hora", $lang, 0, 1);

    if (!$w) {
      ($w, $c) = getanthoras($lang);
    }

    if ($w) {
      $ant = chompd($w);
      $comment = $c;
    }

    if (($rule =~ /Psalmi\s*(minores)*\s*Dominica/i || $communerule =~ /Psalmi\s*(minores)*\s*Dominica/i)
      && $version !~ /Trident/i)
    {
      $feastflag = 1;
    }
    if ($version =~ /1960/ && $rank < 6) { $feastflag = 0; }
    if ($winner{Rank} =~ /Dominica/i && $dayname[0] !~ /Nat|Pasc6/i) { $feastflag = 0; }

    if ($feastflag) {
      $prefix = translate("Psalmi Dominica, antiphonae", $lang) . ' ';
      setbuild2('Psalmi dominica');
    }
  } else {
    $ant = '' if $version =~ /Monastic/;
  }

  if ($hora eq 'Completorium' && $version =~ /^(?:Trident|Monastic)/) {
    push(@s, '#' . translate('Psalmi', $lang));
  } else {
    setcomment($label, 'Source', $comment, $lang, $prefix);
  }

  if ($w{Rule} =~ /Minores sine Antiphona/i) {
    $ant = '';
    setbuild2('Sine antiphonae');
  }
  if ($ant =~ /(.*?)\;\;/s) { $ant = $1; }

  if ($hora eq 'Prima') {    # Prima has additional psalm in brackets
    if ($laudes != 2 || $version =~ /1960/) {
      $psalms =~ s/,?\[\d+\]//g;
    } else {
      $psalms =~ s/[\[\]]//g;
    }
  }

  @psalm = split(',', $psalms);

  # The rules for determining the psalmody at Prime in the Tridentine
  # rubrics are somewhat simpler.
  unless ($version =~ /Trident|monastic/i) {

    #prima psalm set for feasts
    if ($hora =~ /prima/i && $feastflag) {
      $psalm[0] = 53;
      setbuild2('First psalm #53');
    }

    # prima psalm set for laudes 2 sunday
    if ($hora =~ /prima/i && $laudes == 2 && $dayname[1] =~ /Dominica/i && $version !~ /1960/) {
      $psalm[0] = 99;
      unshift(@psalm, 92);
      setbuild2("First psalms #99 and  #92");
    }
  }

  #quicumque
  if ( ($version !~ /1955|196/ || $dayname[0] =~ /Pent01/i)
    && $hora =~ /prima/i
    && ($dayname[0] =~ /(Epi|Pent)/i || $version !~ /Divino/i)
    && $dayofweek == 0
    && ($dayname[0] =~ /(Adv|Pent01)/i || checksuffragium()))
  {
    push(@psalm, 234);
    setbuild2('Quicumque');
  }

  my @psalmi = ($ant . ";;" . join(';', @psalm));

  \@psalmi;
}

#*** psalmi_major($lang)
# collects and return the psalms for laudes and vespera
sub psalmi_major {
  my $lang = shift;
  if ($version =~ /monastic/i && $hora =~ /Laudes/i && $rule !~ /matutinum romanum/i) { $psalmnum1 = $psalmnum2 = -1; }
  my %psalmi = %{setupstring($lang, 'Psalterium/Psalmi major.txt')};
  my $name = $hora;
  if ($hora =~ /Laudes/) { $name .= $laudes; }
  my @psalmi;

  if ($version =~ /monastic/i && !($hora =~ /Laudes/i && $rule =~ /Matutinum romanum/i)) {    # Triduum like Roman
    my $head = "Daym$dayofweek";

    if ($hora =~ /Laudes/i) {
      if ($rule =~ /Psalmi Dominica/ || ($winner =~ /Sancti/i && $rank >= 4 && $dayname[1] !~ /vigil/i)) {
        $head = 'DaymF';
      }
      if ($dayname[0] =~ /Pasc/i && $head =~ /Daym0/i) { $head = 'DaymP'; }
    }
    @psalmi = split("\n", $psalmi{"$head $hora"});
    setbuild("Psalterium/Psalmi major", "$head $hora", 'Psalmi ord');

    if ($hora =~ /Laudes/i && $head =~ /Daym[1-6]/) {
      unless ($version =~ /trident/i
        || (($dayname[0] =~ /Adv|Quadp/) && ($duplex < 3) && ($commune !~ /C10/))
        || (($dayname[0] =~ /Quad\d/) && ($dayname[1] =~ /Feria/))
        || ($dayname[1] =~ /Quattuor Temporum Septembris/)
        || (($dayname[0] =~ /Pent/) && ($dayname[1] =~ /Vigil/)))
      {
        my @canticles = split("\n", $psalmi{'DaymF Canticles'});
        if ($dayofweek == 6) { $psalmi[1] .= '(1-7)'; $psalmi[2] = ';;142(8-12)'; }
        $psalmi[-2] = $canticles[$dayofweek];
      }
    }
  } elsif ($version =~ /Trident/i
    && $testmode =~ /seasonal/i
    && $winner =~ /Sancti/i
    && $rank >= 2
    && $rank < 5
    && !exists($winner{'Ant Laudes'}))
  {    #ferial office
    @psalmi = split("\n", $psalmi{"Daya$dayofweek $name"});
    setbuild("Psalterium/Psalmi major", "Daya$dayofweek $name", 'Psalmi ord');
  } elsif ($version =~ /trident/i) {
    my $dow =
      ($hora =~ /Laudes/i && $dayname[0] =~ /Pasc/i) ? 'P'
      : (  $hora =~ /Laudes/i
        && ($winner =~ /sancti/i || exists($winner{'Ant Laudes'}))
        && $rule !~ /Feria/i) ? 'C'
      : $dayofweek;
    @psalmi = split("\n", $psalmi{"Daya$dow $name"});
    setbuild("Psalterium/Psalmi major", "Daya$dow $name", 'Psalmi ord');
  } else {
    @psalmi = split("\n", $psalmi{"Day$dayofweek $name"});
    setbuild("Psalterium/Psalmi major", "Day$dayofweek $name", 'Psalmi ord');
  }
  $comment = 0;
  $prefix = translate("Psalmi et antiphonae", $lang) . ' ';

  my @antiphones;

  if ( ($hora =~ /Laudes/ || ($hora =~ /Vespera/ && $version =~ /1963/))
    && $month == 12
    && $day > 16
    && $day < 24
    && $dayofweek > 0)
  {
    # TODO: is this really the case in Monastic 1963 Vespers throughout the week?
    my @p1 = split("\n", $psalmi{"Day$dayofweek Laudes3"});

    if ($dayofweek == 6 && $version =~ /trident|monastic/i) {
      my $expectetur = $p1[3];    # save Expectetur

      if ($version =~ /trident|monastic.*divino/i) {    # take ants from feria occuring Dec 21st
        @p1 = split("\n", $psalmi{"Day" . get_stThomas_feria($year) . " Laudes3"});

        if ($day == 23 && $version !~ /divino/i) {      # use Sundays ants
          my %w = %{setupstring($lang, subdirname('Tempora', $version) . "Adv4-0.txt")};
          @p1 = split("\n", $w{"Ant Laudes"});
        }
      }

      if ($version =~ /monastic/i) {
        $p1[2] = $expectetur;
        $p1[3] = '';
      } else {
        $p1[3] = $expectetur;
      }
    }

    for (my $i = 0; $i < @p1; $i++) {
      my @p2 = split(';;', $psalmi[$i]);
      $antiphones[$i] = "$p1[$i];;$p2[1]";
    }
    setbuild2("Special Laudes antiphonas for week before vigil of Christmas");
  }

  #look for de tempore or Sancti
  my $w = '';
  my $c = 0;
  my %w = (columnsel($lang)) ? %winner : %winner2;

  if ($hora =~ /Vespera/i && $vespera == 3) {
    if (exists($w{"Ant Vespera 3"})) {
      $w = $w{"Ant Vespera 3"};
      $c = ($winner =~ /tempora/i) ? 2 : 3;
    } elsif (!exists($w{'Ant Vespera'})
      && ($communetype =~ /ex/ || ($version =~ /Trident/i && $winner =~ /Sancti/i)))
    {
      ($w, $c) = getproprium("Ant Vespera 3", $lang, 1, 1);
      setbuild2("Antiphona $commune");
    }
  }

  if (!$w && exists($w{"Ant $hora"}) && $winner !~ /M\/C10/) {
    $w = $w{"Ant $hora"};
    $c = ($winner =~ /tempora/i) ? 2 : 3;
  }

  if ($w) {
    setbuild2("Antiphonas $winner");
  } elsif ($communetype =~ /ex/
    || ($version =~ /Trident/i && $hora =~ /Laudes/i && $winner =~ /Sancti/i))
  {
    ($w, $c) = getproprium("Ant $hora", $lang, 1, 1);
    setbuild2("Antiphona $commune");
  }
  if ($antecapitulum) { $w = (columnsel($lang)) ? $antecapitulum : $antecapitulum2; }
  if ($w) { @antiphones = split("\n", $w); $comment = $c; }

  #Psalmi de dominica
  if ( $version =~ /Trident/i
    && $testmode =~ /seasonal/i
    && $winner =~ /Sancti/i
    && $rank >= 2
    && $rank < 5
    && !exists($winner{'Ant Laudes'}))
  {
    @p = @psalmi;
  } elsif (($rule =~ /Psalmi Dominica/i || $commune{Rule} =~ /Psalmi Dominica/i)
    && ($antiphones[0] !~ /\;\;\s*[0-9]+/))
  {
    $prefix = translate("Psalmi, antiphonae", $lang) . ' ';
    my $h = ($hora =~ /laudes/i && $version !~ /monastic/i) ? "$hora" . '1' : "$hora";
    @p = split("\n", $psalmi{"Day0 $h"});

    if ($version =~ /monastic/i && $hora =~ /laudes/i) {
      @p = split("\n", $psalmi{"DaymF Laudes"});
    } elsif ($version =~ /Trident/i && $hora =~ /laudes/i) {
      @p = split("\n", $psalmi{"DayaC Laudes"});
    }
    setbuild2('Psalmi dominica');
  } else {
    @p = @psalmi;
  }
  my $lim = 5;

  if ( $version =~ /monastic/i
    && $hora =~ /Vespera/i
    && ($winner !~ /C(?:9|12)/)
    && ($commune !~ /C9/)
    && ($dayname[0] !~ /Quad6/ || $dayofweek < 4))
  {
    $lim = 4;

    if ($antiphones[4]) {    # if 5 psalms and antiphones are given
      local ($a1, $p1) = split(/;;/, $antiphones[3]);    # split no. 4
      local ($a2, $p2) = split(/;;/, $antiphones[4]);    # spilt no. 5
      $antiphones[3] = "$a2;;$p1"                        # and say antiphone 5 with psalm no. 4
    }
  }

  if ($version =~ /^Ordo Praedicatorum/ && @antiphones == 1) {    #  psalmi ad Vesperam sub una antiphopna
    $lim = 1;
    @psalmi = ();
  }

  if (@antiphones) {
    for ($i = 0; $i < $lim; $i++) {
      my $aflag = 0;
      $p = ($p[$i] =~ /;;(.*)/s) ? $1 : 'missing';

      if ( $i == 4
        && $hora =~ /vespera/i
        && !$antecapitulum
        && $rule !~ /no Psalm5/i
        && ($rule =~ /Psalm5 Vespera=([0-9]+)/i || $commune{Rule} =~ /Psalm5 Vespera=([0-9]+)/i))
      {
        $p = $1;

        if ($rule =~ /Psalm5 Vespera3=([0-9]+)/i || $commune{Rule} =~ /Psalm5 Vespera3=([0-9]+)/i) {
          my $p1 = $1;
          if ($vespera == 3 || ($rank < 6 && $dayofweek == 5)) { $p = $p1; }
        }
        setbuild2("Psalm5 = $p");
        $aflag = 1;
      }
      $psalmi[$i] =
          ($antiphones[$i] =~ /\;\;[0-9\;\n]+/ && !$aflag) ? $antiphones[$i]
        : ($antiphones[$i] =~ /(.*?);;/s) ? "$1;;$p"
        : "$antiphones[$i];;$p";
    }
  }

  if ( alleluia_required($dayname[0], $votive)
    && (!exists($winner{"Ant $hora"}) || $commune =~ /C10/)
    && $communetype !~ /ex/i
    && ($version !~ /trident/i || $hora =~ /vespera/i)
    && ($version !~ /monastic/i || $hora !~ /laudes/i || $winner{Rank} !~ /Dominica/i))
  {
    $psalmi[0] =~ s/.*(?=;;)/ alleluia_ant($lang) /e;
    $psalmi[1] =~ s/.*(?=;;)//;
    $psalmi[2] =~ s/.*(?=;;)//;
    $psalmi[-1] =~ s/.*(?=;;)//;

    if ($version =~ /monastic/i && $hora =~ /laudes/i) {
      $psalmi[-1] =~ s/.*(?=;;)/ alleluia_ant($lang) /e;
    } else {
      $psalmi[3] =~ s/.*(?=;;)//;
    }
  }

  if (($dayname[0] =~ /(Adv|Quad)/i || emberday()) && $hora =~ /laudes/i && $version !~ /trident/i) {
    $prefix = "Laudes:$laudes $prefix";
  }
  setcomment($label, 'Source', $comment, $lang, $prefix);

  \@psalmi;
}

#*** antetpsalm($psalmi_ref, $duplexf, $lang)
# outputs (to @s) psalms with antiphonas
sub antetpsalm {
  my ($psalmi_ref, $duplexf, $lang) = @_;
  my $lastant;

  for ($i = 0; $i < @$psalmi_ref; $i++) {
    my ($ant, $psalms) = split(';;', $psalmi_ref->[$i], 2);

    if ($ant) {
      if ($lastant) { pop(@s); push(@s, "Ant. $lastant", "\n"); }
      postprocess_ant($ant, $lang);
      my $antp = $ant;

      unless ($duplexf) {
        $antp =~ s/\s*\*.*//;
        $antp =~ s/\,$/./;
      }
      push(@s, "Ant. $antp");
      $lastant = ($ant =~ s/\* //r);
    }

    my @p = split(';', $psalms);

    for (my $i = 0; $i < @p; $i++) {
      $p = $p[$i];
      $p =~ s/[\(\-]/\,/g;
      $p =~ s/\)//;
      if ($i < (@p - 1)) { $p = '-' . $p; }
      push(@s, "\&psalm($p)", "\n");
    }
  }

  $s[-1] = "Ant. $lastant" if $lastant;
}

#*** get_stThomas_feria($year)
# used in trident psalmi_{major,minor}
sub get_stThomas_feria {
  my ($year) = shift;
  my ($sec_, $min_, $hour_, $mday_, $mon_, $year_, $wday, $yday_, $isdst_) =
    localtime(timelocal(0, 0, 0, 21, 11, $year));
  $wday ? $wday : 1;    # on Sunday transfer stThomas to Feria II
}

1;
