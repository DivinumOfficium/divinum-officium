# use strict;
# use warnings;
use utf8;

sub psalmi {
  my $lang = shift;
  our $psalmnum1 = 0;
  our $psalmnum2 = 0;
  our ($hora, $version, $duplex);

  if ($hora eq 'Matutinum') {
    psalmi_matutinum($lang);
  } else {
    my $duplexf = $version =~ /196/;
    my $psalmi;

    if ($hora =~ /^(?:Laudes|Vespera)$/i) {
      $psalmi = psalmi_major($lang);
      $duplexf ||= $duplex > 2 && $winner !~ /C12/;
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
  our (
    $version, $hora, $dayofweek, $winner, %winner, @dayname, $rule,
    $communerule, $rank, $laudes, $day, $year, %winner2, $label,
  );
  my %psalmi = %{setupstring($lang, 'Psalterium/Psalmi/Psalmi minor.txt')};
  my (@psalmi, $ant, $psalms, $prefix);
  my $psalmTone;    # GABC: for selection of PsalmTone

  if ($version =~ /Monastic/) {
    @psalmi = split("\n", $psalmi{Monastic});
    my $i =
        $hora eq 'Prima' ? $dayofweek
      : $hora eq 'Tertia' ? 8
      : $hora eq 'Sexta' ? 11
      : $hora eq 'Nona' ? 14
      : 17;

    if ($hora !~ /^(?:Prima|Completorium)$/) {
      if ($dayofweek > 0) { $i++; }
      if ($dayofweek > 1) { $i++; }
    }
    $psalmi[$i] =~ s/\=/\;\;/;
    my @a = split(';;', $psalmi[$i]);
    $ant = chompd($a[1]);
    $psalms = chompd($a[2]);
    if ($lang =~ /gabc/i) { $psalmTone = chompd($a[3]); }    # GABC: retrieve Psalm Tone
  } elsif ($version =~ /trident/i) {
    my $daytype = $dayofweek ? 'Feria' : 'Dominica';
    my %psalmlines = split(/\n|=/, $psalmi{Tridentinum});
    my $psalmkey;

    if ($hora eq 'Prima') {
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
      $psalmkey = $hora eq 'Completorium' ? 'Completorium' : "$hora $daytype";
    }
    my @a = split(';;', $psalmlines{$psalmkey});
    $ant = chompd($a[0]);
    $psalms = chompd($a[1]);
    if ($lang =~ /gabc/i) { $psalmTone = chompd($a[2]); }    # GABC: retrieve Psalm Tone
  } else {
    @psalmi = split("\n", $psalmi{$hora});
    my $i = 2 * $dayofweek;

    if ($hora eq 'Completorium' && $dayofweek == 6 && $winner{Rank} =~ /Dominica/i && $dayname[0] !~ /Nat/) {
      $i = 12;
    }

    if ( $rule =~ /Psalmi\s*(minores)*\s*Dominica/i
      || $communerule =~ /Psalmi\s*(minores)*\s*Dominica/i && $rule !~ /Psalmi\s*(?:minores)*\s*ex Psalterio/i)
    {
      $i = 0;
    }

    if (
      $version =~ /19(?:55|60|62)/
      && (
           $rule =~ /horas1960 feria/i
        || ($winner =~ /Sancti/i && $rank < 5)
        || ( ($winner =~ /sancti/i || $winner =~ /Nat[23]/i)
          && $rank < 6
          && $hora ne 'Completorium')
      )
    ) {
      $i = 2 * $dayofweek;
    }

    if ($hora eq 'Completorium' && $dayofweek == 6 && $winner{Rank} =~ /Dominica/i && $dayname[0] !~ /Nat/) {
      $i = 12;
    }
    $ant = chompd($psalmi[$i]);
    $psalms = chompd($psalmi[$i + 1]);
    if (($version =~ /1960/ && $psalms =~ /117/ && $laudes == 2) || $rule =~ /Prima=53/i) { $psalms =~ s/117/53/; }
  }
  setbuild('Psalterium/Psalmi/Psalmi minor', "$hora Day$dayofweek", 'Psalmi ord');
  my $comment = 0;

  if ($hora eq 'Completorium' && $version !~ /Trident|Monastic/) {
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

    my %w = columnsel($lang) ? %winner : %winner2;
    $ant = $w{"Ant Completorium$vespera"} || $ant;
  }

  if ($winner =~ /tempora/i || $dayname[0] =~ /pasc/i) {

    my $ind =
        $hora eq 'Prima' ? ($version =~ /cist/i ? 1 : 0)
      : $hora eq 'Tertia' ? ($version =~ /cist/i ? 2 : 1)
      : $hora eq 'Sexta' ? ($version =~ /cist/i ? 3 : 2)
      : $hora eq 'Nona' ? 4
      : -1;
    my $name = gettempora('Psalmi minor');

    if ($name eq 'Adv') {
      $name = $dayname[0];

      if ($day > 16 && $day < 24 && $dayofweek && $version !~ /cist/i) {
        my $i = $dayofweek + 1;

        if ($dayofweek == 6 && $version =~ /trident|monastic.*divino/i) {    # take ants from feria occuring Dec 21st
          $i = get_stThomas_feria($year) + 1;
          if ($day == 23) { $i = ""; }                                       # use Sundays ant
        }
        $name = "Adv4$i";
      }

      $name =~ s/\d+$/OP/ if $version =~ /praedicatorum/i;
    }

    if ($name eq 'Pasch' && $lang =~ /gabc/i && $version =~ /monastic/i) {

      # GABC: Tone of Alleluja antiphone changes per Hour
      $ind =
          ($hora =~ /prima/i) ? 0
        : ($hora =~ /tertia/i) ? 2
        : ($hora =~ /sexta/i) ? 5
        : ($hora =~ /nona/i) ? 8
        : 11;

      if ($hora !~ /completorium/i) {
        if ($dayofweek > 0) { $ind++; }
        if ($hora !~ /prima/i && $dayofweek > 1) { $ind++; }
      }
    } elsif ($name eq 'Pasch' && $lang =~ /gabc/i && $ind < 0) {
      $ind = 5;    # for Roman Completorium has a Paschal tone for the whole week
    } elsif ($name eq 'Pasch' && ($dayname[0] !~ /Pasc7/i || $hora =~ /Completorium/i)) {
      $ind = $lang !~ /gabc/i ? 0 : $ind;    # ensure Antiphone is changed next
    }

    if ($name && $ind >= 0) {
      my @ant = split("\n", $psalmi{$name});

      if ($lang =~ /gabc/) {
        @ant = split(";;", $ant[$ind]);
        $ant = chompd($ant[0]);
        $psalmTone = chompd($ant[1]);
      } else {
        $ant = chompd($ant[$ind]);
      }

      # add fourth alleluja
      $ant =~ s/(\S+)\.$/$1, $1./ if ($version =~ /trident|monastic/i && $name eq 'Pasch' && $lang !~ /gabc/);
      $comment = 1;
      setbuild("Psalterium/Psalmi/Psalmi minor", $name, "subst Antiphonas");
    }
  }

  my %w = columnsel($lang) ? %winner : %winner2;
  $ant =~ s/^.*?=\s*//;
  my $feastflag = 0;

  #look for special from proprium the tempore of sancti
  if ($hora ne 'Completorium') {
    my ($w, $c) = getproprium("Ant $hora", $lang, 0);

    if (!$w
      && $rule !~ /Psalmi\s*(?:minores)*\s*ex Psalterio/i
      && !($version =~ /1955|1960/ && $rank < 6 && $dayofweek > 0))
    {
      #
      # Cum nostra hac ætate limited the proper Antiphones from Prime to None to Duplex I. cl.
      ($w, $c) = getanthoras($lang);
    }

    if ($w) {
      $ant = chompd($w);
      $comment = $c;
    }

    if ( ($rule =~ /Psalmi\s*(?:minores)*\s*Dominica/i || $communerule =~ /Psalmi\s*(?:minores)*\s*Dominica/i)
      && $version !~ /Trident/i
      && $rule !~ /Psalmi\s*(?:minores)*\s*ex Psalterio/i
      && !($version =~ /1955|196/ && $rank < 6 && $dayofweek > 0))
    {
      $feastflag = 1;
    }
    if ($version =~ /1955|1960/ && $rank < 6) { $feastflag = 0; }
    if ($winner{Rank} =~ /Dominica/i && $dayname[0] !~ /Nat|Pasc6/i) { $feastflag = 0; }

    if ($feastflag) {
      $prefix = translate("Psalmi Dominica, antiphonae", $lang) . ' ';
      setbuild2('Psalmi dominica');
    }
  } else {
    $ant = '' if $version =~ /^Monastic/;
  }

  $comment = -1 if $hora eq 'Completorium' && $version =~ /^(?:Trident|Monastic)/;
  setcomment($label, 'Source', $comment, $lang, $prefix);

  if ($w{Rule} =~ /Minores sine Antiphona/i || $hora eq 'Completorium' && $version =~ /^Monastic/) {

    # GABC: Psalms without Antiphone get their PsalmTone here
    $ant = '';
    $psalmTone = 'in-dir';
    setbuild2('Sine antiphonae');
  } elsif ($lang =~ /gabc/i) {    # retrieve Psalm Tone
    if ($ant =~ s/;;(.*);;(.*)/;;$1/) {    # strip from antiphone
      $psalmTone = $2;
      $ant =~ s/;;\s*$//;
    }
  }

  if ($ant =~ /(.*?)\;\;/s) { $ant = $1; }

  if ($hora eq 'Prima') {    # Prima has additional psalm in brackets
    if ($laudes != 2 || $version =~ /1960/) {
      $psalms =~ s/,?\[\d+\]//g;
    } else {
      $psalms =~ s/[\[\]]//g;
    }
  }

  my @psalm = split(',', $psalms);

  # The rules for determining the psalmody at Prime in the Tridentine
  # rubrics are somewhat simpler.
  unless ($version =~ /Trident|Monastic/) {

    #prima psalm set for feasts
    if ($hora eq 'Prima' && $feastflag) {
      $psalm[0] = 53;
      setbuild2('First psalm #53');
    }

    # prima psalm set for laudes 2 sunday
    if ($hora eq 'Prima' && $laudes == 2 && $dayname[1] =~ /Dominica/i && $version !~ /1960/) {
      $psalm[0] = 99;
      unshift(@psalm, 92);
      setbuild2("First psalms #99 and  #92");
    }
  }

  #quicumque
  if (
       ($version !~ /1955|196/ || $dayname[0] =~ /Pent01/i)
    && $hora eq 'Prima'
    && ($dayname[0] =~ /(Epi|Pent)/i || $version !~ /Divino/i)
    && $dayofweek == 0
    && ($dayname[0] !~ /Epi1/i && $version =~ /cist/i)
    && ( $dayname[0] =~ /(Adv|Pent01)/i
      || checksuffragium()
      || ($dayname[0] =~ /Adv|Epi|Quad|Pasc|Pent/i && $version =~ /cist/i))
    && ($winner =~ /Tempora/i || $version !~ /cist/i)
  ) {
    push(@psalm, 234);
    setbuild2('Quicumque');
  }

  if ($lang =~ /gabc/i && $psalmTone) {
    foreach my $p (@psalm) {
      $p = "\'$p,$psalmTone\'";    # GABC format: 'Psalmnumber,PsalmTone'
    }
  }
  @psalmi = ($ant . ";;" . join(';', @psalm));

  \@psalmi;
}

#*** psalmi_major($lang)
# collects and return the psalms for laudes and vespera
sub psalmi_major {
  my $lang = shift;

  our (
    $version, $hora, $rule, $psalmnum1, $psalmnum2, $laudes,
    $rank, $winner, $dayofweek, $vespera, @dayname, $duplex,
    $commune, %winner, $month, $day, $year, %winner2,
    $communetype, $antecapitulum, $antecapitulum2, %commune, $votive, $label,
  );
  if ($version =~ /monastic/i && $hora eq 'Laudes' && $rule !~ /matutinum romanum/i) { $psalmnum1 = $psalmnum2 = -1; }
  my %psalmi = %{setupstring($lang, 'Psalterium/Psalmi/Psalmi major.txt')};
  my $name = $hora;
  if ($hora eq 'Laudes') { $name .= $laudes; }
  my (@psalmi, $prefix, $comment);
  my @psalmTones;

  if ($version =~ /Monastic/ && !($hora eq 'Laudes' && $rule =~ /Matutinum romanum/i)) {    # Triduum like Roman
    my $head = $version =~ /cist/i ? 'Cistercian' : 'Monastic';

    if ($hora eq 'Laudes') {
      if (
        $rule =~ /Psalmi Dominica/
        || ($rule !~ /Psalmi Feria/i
          && ($winner =~ /Sancti/i && $rank >= ($version =~ /cist/i ? 2.2 : 4) && $dayname[1] !~ /vigil/i))
      ) {
        $head = $version =~ /cist/i ? 'DaycF' : 'DaymF';
      } elsif (($dayofweek == 0 || $version =~ /trident/i) && $dayname[0] =~ /Pasc/i && $version !~ /cisterciensis/i) {
        $head = 'DaymP';
      }
    }
    @psalmi = split("\n", $psalmi{"$head $hora"});
    setbuild("Psalterium/Psalmi/Psalmi major", "$head $hora", 'Psalmi ord');

    if ($hora eq 'Laudes' && $head =~ /Monastic/) {
      unless ($dayofweek == 0
        || $version =~ /Trident/
        || (($dayname[0] =~ /Adv|Quadp/) && ($duplex < 3) && ($commune !~ /C10/))
        || (($dayname[0] =~ /Quad\d/) && ($dayname[1] =~ /Feria/))
        || ($dayname[1] =~ /Quattuor Temporum Septembris/)
        || (($dayname[0] =~ /Pent/) && ($dayname[1] =~ /Vigil/)))
      {
        if ($dayofweek == 6) {
          @psalmi = split("\n", $psalmi{'Daym6F Laudes'});
        } else {
          my @canticles = split("\n", $psalmi{'DaymF Canticles'});
          $psalmi[-2] = $canticles[$dayofweek];
        }
      }
    }
  } elsif ($version =~ /trident/i) {
    my $dow =
      ($hora eq 'Laudes' && $dayname[0] =~ /Pasc/i) ? 'P'
      : (  $hora eq 'Laudes'
        && ($winner =~ /Sancti/ || exists($winner{'Ant Laudes'}))
        && $rule !~ /Feria/i) ? 'C'
      : $dayofweek;
    @psalmi = split("\n", $psalmi{"Daya$dow $name"});
    setbuild('Psalterium/Psalmi/Psalmi major', "Daya$dow $name", 'Psalmi ord');
  } else {
    @psalmi = split("\n", $psalmi{"Day$dayofweek $name"});
    setbuild('Psalterium/Psalmi/Psalmi major', "Day$dayofweek $name", 'Psalmi ord');
  }
  $comment = 0;
  $prefix = translate('Psalmi et antiphonae', $lang) . ' ';

  my @antiphones;

  if ( ($hora eq 'Laudes' || ($hora eq 'Vespera' && $version =~ /1963/))
    && $month == 12
    && $day > 16
    && $day < 24
    && $dayofweek > 0)
  {
    # TODO: is this really the case in Monastic 1963 Vespers throughout the week?
    @antiphones = split("\n", $psalmi{"Day$dayofweek Laudes3"});

    if ($dayofweek == 6 && $version =~ /Trident|Monastic/) {
      my $expectetur = $antiphones[3];    # save Expectetur

      if ($version =~ /trident|monastic.*divino/i) {    # take ants from feria occuring Dec 21st
        @antiphones = split("\n", $psalmi{'Day' . get_stThomas_feria($year) . ' Laudes3'});

        if ($day == 23 && $version !~ /divino/i) {      # use Sundays ants
          my %w = %{setupstring($lang, subdirname('Tempora', $version) . 'Adv4-0.txt')};
          @antiphones = split("\n", $w{'Ant Laudes'});
        }
      }

      if ($version =~ /Monastic/) {
        $antiphones[2] = $expectetur;
        $antiphones[3] = $lang =~ /gabc/ ? ';;;;4-alt-Astar' : '';
      } else {
        $antiphones[3] = $expectetur;
      }
    }

    setbuild2('Special Laudes antiphonas for week before vigil of Christmas');
  }

  #look for de tempore or Sancti
  my ($w, $c);
  my %w = columnsel($lang) ? %winner : %winner2;

  if ($hora eq 'Vespera' && $vespera == 3) {
    if (exists($w{'Ant Vespera 3'})) {
      $w = $w{'Ant Vespera 3'};
      $c = $winner =~ /Tempora/ ? 2 : 3;
    } elsif (!exists($w{'Ant Vespera'})
      && ($communetype =~ /ex/ || ($version =~ /Trident/i && $winner =~ /Sancti/i)))
    {
      ($w, $c) = getproprium('Ant Vespera 3', $lang, 1);
      setbuild2("Antiphona $commune") if $w;
    }
  }

  if (!$w && exists($w{"Ant $hora"})) {
    $w = $w{"Ant $hora"};
    $c = $winner =~ /Tempora/ ? 2 : 3;
  }

  if ($antecapitulum) {
    $w = columnsel($lang) ? $antecapitulum : $antecapitulum2;
    setbuild2('Antiphonas ante Capitulum de praecedenti');
  } elsif ($w) {
    setbuild2("Antiphonas $winner");
  } elsif (($communetype && $communetype =~ /ex/)
    || ($version =~ /Trident/i && $hora eq 'Laudes' && $winner =~ /Sancti/))
  {
    ($w, $c) = getproprium("Ant $hora", $lang, 1);
    setbuild2("Antiphona $commune") if $w;
  }
  if ($w) { @antiphones = split("\n", $w); $comment = $c; }

  if ($lang =~ /gabc/ && @antiphones) {

    # strip Psalm Tones from Antiphones
    foreach my $myant (@antiphones) {
      if ($myant =~ s/;;(.*);;(.*)/;;$1/) {
        push(@psalmTones, $2);
        $myant =~ s/;;\s*$//;
      } else {
        push(@psalmTones, '');
      }
    }
  }
  my @p;

  #Psalmi de dominica
  if (
    (
         $rule =~ /Psalmi Dominica/i
      || ($version =~ /cist/i && $rank >= 2.2)
      || ($commune{Rule} && $commune{Rule} =~ /Psalmi Dominica/i)
    )
    && ($antiphones[0] !~ /\;\;\s*[0-9]+/)
    && ($rule !~ /Psalmi Feria/i)
  ) {
    $prefix = translate("Psalmi, antiphonae", $lang) . ' ';
    my $h = $hora;
    $h .= '1' if $hora eq 'Laudes' && $version !~ /Monastic/;
    @p = split("\n", $psalmi{"Day0 $h"});

    if ($version =~ /Monastic/ && $hora eq 'Laudes') {
      @p = split("\n", $psalmi{'DaymF Laudes'});
    } elsif ($version =~ /Trident/ && $hora eq 'Laudes') {
      @p = split("\n", $psalmi{'DayaC Laudes'});
    }
    setbuild2('Psalmi dominica');
  } else {
    @p = @psalmi;

    # Cist: to get Sunday Psalms if "Psalmi Feria" rule is used,
    # e.g. on Sundays in Octaves.
    if ( $dayofweek == 0
      && $rule =~ /Psalmi Feria/i
      && $version =~ /monastic/i
      && $hora eq 'Laudes')
    {
      @p = split("\n", $psalmi{'DayaC Laudes2'});
      $p[2] = ";;62";
    }
  }
  my $lim = 5;

  if ( $version =~ /Monastic/
    && $hora eq 'Vespera'
    && ($winner !~ /C9/)
    && ($winner !~ /C12/ || $version =~ /cist/i)
    && ($commune !~ /C9/)
    && ($dayname[0] !~ /Quad6/ || $dayofweek < 4))
  {
    $lim = 4;

    # Ex 5 Antiphonæ et Psalmi fiunt 4
    if ($antiphones[4]) {
      if ($month == 12 && $day >= 25 && $day < 31) {

        # On Dec 25, 27, and 29, we take the 4th Roman Ant. and Psalm (i.e. Apud Dmn; 129)
        # On Dec 26, 28, and 30, we take the 5th Roman Ant. and Psalm (i.e. De fructu; 131)
        $antiphones[3] = $antiphones[4] if $day !~ /2[579]/;
      } else {
        my ($a1, $p1) = split(/;;/, $antiphones[3]);               # split no. 4
        my ($a2, $p2) = split(/;;/, $antiphones[4]);               # spilt no. 5
        $antiphones[3] = "$a2;;$p1";                               # and say antiphone 5 with psalm no. 4
        if (@psalmTones) { $psalmTones[3] = "$psalmTones[4]"; }    # and use the Tone of the 5th antiphone
      }
    }
  }

  if ($version =~ /^Ordo Praedicatorum/ && @antiphones == 1) {    #  psalmi ad Vesperam sub una antiphopna
    $lim = 1;
    @psalmi = ();
  }

  if (@antiphones) {
    for (my $i = 0; $i < $lim; $i++) {
      my $aflag = 0;
      my $p = $p[$i] =~ /;;(.*)/s ? $1 : 'missing';

      # For 5th (last) Psalm in Vespers we check the rules if we have to change it
      # In 2nd Vespers (vespera=3) we first check for a "Psalm5 Vespera3" rule
      # Otherwise (both vespers) we check for a "Psalm5 Vespera" rule
      # In the case of "Vespera a capitulum de sequenti", we check the 'hi-jacked' 6th line instead
      if (
           $i == 4
        && $hora eq 'Vespera'
        && $rule !~ /no Psalm5/i
        && (
          (
            !$antecapitulum
            && (
              $vespera == 3 && ($rule =~ /Psalm5 (Vespera3)=([0-9]+)/i
                || ($commune{Rule} =~ /Psalm5 (Vespera3)=([0-9]+)/i && $c eq 4))
              || ($rule =~ /Psalm5 (Vespera)=([0-9]+)/i
                || ($commune{Rule} =~ /Psalm5 (Vespera)=([0-9]+)/i && $c eq 4))
            )
          )
          || $antecapitulum =~ /Psalm5 (VesperaAnte)=([0-9]+)/i
        )
      ) {
        $p = $2;
        setbuild2("subst: Psalm5 $1 = $p");
        $aflag = 1;
      }

      if ($lang =~ /gabc/i) {

        # recombine antiphones with psalms and psalmtones according to antiphone
        $p =~ s/;;.*//;    # Strip Psalterium tone
        $p = ($p =~ /\'(.*),/s) ? $1 : $p;

        $p = ($antiphones[$i] =~ s/\;\;([0-9\;\n]+)// && !$aflag) ? $1 : $p;
        my @p = split(';', $p);

        foreach $p1 (@p) {
          $p1 = "\'$p1,$psalmTones[$i]\'";
        }
        $p = join(';', @p);
        $psalmi[$i] = ($antiphones[$i] =~ /(.*?);;/s) ? "$1;;$p" : "$antiphones[$i];;$p";
      } else {
        $psalmi[$i] =
            ($antiphones[$i] =~ /\;\;[0-9\;\n]+/ && !$aflag) ? $antiphones[$i]
          : ($antiphones[$i] =~ /(.*?);;/s) ? "$1;;$p"
          : "$antiphones[$i];;$p";
      }
    }
  } elsif ($lang =~ /gabc/i) {
    foreach $mypsalm (@psalmi) {
      if ($mypsalm =~ s/;;(.*);;(.*)//) {
        my $psalmTone = $2;
        my @p = split(';', $1);

        foreach $p1 (@p) {
          $p1 = "\'$p1,$psalmTone\'";
        }
        $p = join(';', @p);
        $mypsalm .= ";;$p";
      }
    }
  }

  if ( alleluia_required($dayname[0], $votive)
    && $lang !~ /gabc/i
    && (!exists($winner{"Ant $hora"}) || $commune =~ /C10/)
    && $communetype !~ /ex/i
    && ($version !~ /Trident/ || $hora eq 'Vespera')
    && ($version !~ /Monastic/ || $hora ne 'Laudes' || $winner{Rank} !~ /Dominica/i))
  {
    $psalmi[0] =~ s/.*(?=;;)/ alleluia_ant($lang) /e;
    $psalmi[1] =~ s/.*(?=;;)//;
    $psalmi[2] =~ s/.*(?=;;)//;
    $psalmi[-1] =~ s/.*(?=;;)//;

    if ($version =~ /Monastic(?! Cist)/ && $hora eq 'Laudes') {
      $psalmi[-1] =~ s/.*(?=;;)/ alleluia_ant($lang) /e;
    } else {
      $psalmi[3] =~ s/.*(?=;;)//;
    }
  } elsif ($version =~ /cist/i && $hora =~ /laudes/i && $rule !~ /matutinum romanum/i) {

    # Cistercien Lauds under single Antiphone except for Triduum and Officium Defunctorum
    $psalmi[$_] =~ s/.*(?=;;)// foreach (1 .. 4);
  }

  if (($dayname[0] =~ /Adv|Quad/ || emberday()) && $hora eq 'Laudes' && $version !~ /Trident/) {
    $prefix = "Laudes:$laudes $prefix";
  }
  setcomment($label, 'Source', $comment, $lang, $prefix);

  \@psalmi;
}

#*** antetpsalm($psalmi_ref, $duplexf, $lang)
# outputs (to @s) psalms with antiphonas
sub antetpsalm {
  my ($psalmi_ref, $duplexf, $lang) = @_;

  our (@s);
  my $lastant;

  for (my $i = 0; $i < @$psalmi_ref; $i++) {
    my ($ant, $psalms) = split(';;', $psalmi_ref->[$i], 2);

    if ($ant) {
      if ($lastant) { pop(@s); push(@s, "Ant. $lastant", "\n"); }
      $ant =~ s/~?\n/ /g;
      postprocess_ant($ant, $lang);
      my $antp = $ant;

      unless ($duplexf && $version !~ /cist/i) {
        $antp =~ s/\s+\*.*//;

        if ($lang =~ /gabc/i && $ant =~ /\{.*\}/) {
          $antp =~ s/(.*)(\(.*?\))\s*$/$1\.$2 (::)\}/;    # proper closure of GABC antiphone
          $antp =~ s/\,\.\(/.(/;
        } else {
          $antp =~ s/\,$/./;
          if ($version =~ /cist/i) { $antp .= ' ' . rubric('Antiphona', $lang); }
        }
      }
      push(@s, "Ant. $antp");
      $lastant = ($ant =~ s/\* //r);
    }

    my @p = split(';', $psalms);

    for (my $i = 0; $i < @p; $i++) {
      my $p = $p[$i];
      $p =~ s/(\(.*?\-.*?\))(.*\')$/$2$1/;    # GABC: pull Verse numbers out of Tone
      $p =~ s/[\(\-]/\,/g;
      $p =~ s/\)//;
      if ($i < (@p - 1)) { $p = '-' . $p; }
      $p =~ s/\-\'/\'\-/;                     # ensure dash behind apostrophe to be passed through to psalm script
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
