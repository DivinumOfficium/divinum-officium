# use strict;
# use warnings;
use utf8;

# *** checkcommemoratio \%office
# return the text of [Commemoratio] [Commemoratio n] or an empty string
sub checkcommemoratio {
  my $w = shift;
  my %w = %$w;
  $w{'Commemoratio'} || $w{'Commemoratio 1'} || $w{'Commemoratio 2'} || $w{'Commemoratio 3'} || '';
}

#*** oratio($lang, $month, $day, %params)
# Collects and prints the appropriate oratio and commemorationes. If
# $params{special} is set, the emitted title indicates that the prayers have a
# special form.
sub oratio {

  my $lang = shift;
  my $month = shift;
  my $day = shift;
  my %params = @_;

  our (
    %winner, %winner2, $winner, $hora, $vespera, @dayname,
    $rule, $version, $rank, $dayofweek, %commune, %commune2,
    $commune, $votive, @s, $priest, $octvespera, $transfervigil,
    $datafolder, $cvespera, $precesferiales, $largefont, $redfont, $label,
  );

  our $collectcount = 1;
  my $addconclusio;
  my %w = columnsel($lang) ? %winner : %winner2;
  my $ind = $hora eq 'Vespera' ? $vespera : 2;
  my $w;

  # Output the title.
  setcomment(
    $label, $params{special}
    ? ('Preces', 2)
    : ('Source', $winner =~ /Sancti/ + 2), $lang,
  );

  # Special handling for days during the suppressed octave of the Epiphany.
  # Before the Sunday formerly in the octave, the collect of the Epiphany is
  # said, as in the past; afterwards, the collect of the Sunday is said, in
  # which case we have to override it.
  if ( $dayname[0] =~ /Epi1/i
    && $rule =~ /Infra octavam Epiphaniæ Domini/i
    && $version =~ /1955|196/)
  {
    $rule .= "Oratio Dominica\n";
  }

  if ( ($rule =~ /Oratio Dominica/i && (!exists($winner{Oratio}) || $hora eq 'Vespera'))
    || ($winner{Rank} =~ /Quattuor/i && $dayname[0] !~ /Pasc7/i && $version !~ /196|cist/i && $hora eq 'Vespera'))
  {
    my $name = "$dayname[0]-0";
    if ($name =~ /(?:Epi1|Nat)/i && $version !~ /Monastic/) { $name = 'Epi1-0a'; }
    %w = %{setupstring($lang, subdirname('Tempora', $version) . "$name.txt")};
  }

  if ($dayofweek > 0 && exists($winner{OratioW}) && $rank < 5) {
    $w = $w{OratioW};    # Ferias in 1st week after Pentecost only
    setbuild2('Oratio de Dominica I post Pentecosten');
  } else {
    $w = $w{Oratio};
  }
  if ($hora eq 'Matutinum' && exists($winner{'Oratio Matutinum'})) { $w = $w{'Oratio Matutinum'}; }
  if (!$w) { $w = $w{"Oratio $ind"}; }    # if none yet, look for Oratio of Vespers or Lauds according to ind

  if (!$w) {                              # if none yet, look in commune.
    my %c = columnsel($lang) ? %commune : %commune2;
    my $i = $ind;
    $w = $c{"Oratio $i"};
    if (!$w) { $i = 4 - $i; $w = $c{"Oratio $i"}; }
    if (!$w) { $w = $c{Oratio}; }
  }
  if ($hora ne 'Matutinum') { setbuild($winner, "Oratio $ind", 'Oratio ord'); }
  my $i = $ind;

  if (!$w) {                              # if none yet:
    if ($i == 2) {                        # if Laudes, try 2nd Vespers
      $i = 3;
      $w = $w{"Oratio $i"};
    } else {                              # if Vespers, try Laudes
      $w = $w{'Oratio 2'};
    }
    if (!$w) { $i = 4 - $i; $w = $w{"Oratio $i"}; }    # or, try other Vesper
    if ($w && $hora ne 'Matutinum') { setbuild($winner, "Oratio $i", 'try'); }
  }

  # Special processing for Common of Supreme Pontiffs.
  if ($version !~ /Trident/i && (my ($plural, $class, $name) = papal_rule($w{Rule}))) {
    $w = papal_prayer($lang, $plural, $class, $name);
    if ($w && $hora ne 'Matutinum') { setbuild2("Oratio Gregem tuum"); }
  }

  if (!$w && $commune) {
    my %com = columnsel($lang) ? %commune : %commune2;
    my $ti = '';
    $w = $com{Oratio};

    if (!$w) {
      $ti = " $ind";
      $w = $com{"Oratio $ind"};
    }
    if ($w && $hora ne 'Matutinum') { setbuild2("$commune Oratio$ti"); }
  }

  if ($winner =~ /Tempora/ && !$w) {    # if tempora, default to Sunday Oratio
    my $name = "$dayname[0]-0";
    %w = %{officestring($lang, subdirname('Tempora', $version) . "$name.txt")};
    $w = $w{Oratio};
    if (!$w) { $w = $w{'Oratio 2'}; }
    if ($w) { setbuild2('Oratio Dominica'); }
  }

  if ($w =~ /N\./) {
    my $name;

    if (exists($w{Name})) {
      $name = $w{Name};
    } elsif (my ($plural, $class, $pname) = papal_rule($w{Rule})) {
      $name = $pname;
    }

    if ($name) {
      $w = replaceNdot($w, $lang, $name);
    } else {
      $w =~ s/N\./ setfont($redfont, $&) /ge;
    }
  }

  #* deletes added commemoratio unless in laudes and vespers
  my $comm_regex_str = '!(' . &translate('Commemoratio', $lang) . '|Commemoratio)';

  if (
    ($w =~ /(?<prelude>.*?)$comm_regex_str/is && $hora !~ /(laudes|vespera)/i)
    || ( $hora eq 'Laudes'
      && $w =~ /$comm_regex_str/i
      && $w =~ /(?<prelude>.*?)(precedenti|sequenti)/is)
  ) {
    $w = $+{prelude};
    $w =~ s/\s*_\s*//;
  }
  if (!$w) { $w = 'Oratio missing'; }

  my $horamajor = $hora eq 'Laudes' || $hora eq 'Vespera';

  #* limit oratio
  if ($rule !~ /Limit.*?Oratio/i) {

    # no dominus vobiscum after Te decet
    if ($version !~ /Monastic/ || $hora ne 'Matutinum' || $rule !~ /12 lectiones/) {
      if (
        $version =~ /Monastic/ && ($winner !~ /C12/ || $version !~ /cist/i)
        || ( $version =~ /Ordo Praedicatorum/
          && ($rank < 3 || $dayname[1] =~ /Vigil/)
          && $winner !~ /12-24|Pasc|01-0[2-5]/)
        )
      {    # OP ferial office
        if ($horamajor && $version !~ /Ordo Praedicatorum/) {
          push(@s, '$Kyrie');
          push(@s, '$Pater noster Et', "_") unless $winner =~ /C12/;
        } else {
          push(@s, '$Kyrie', '$pater secreto', "_");
        }
      }

      if ($priest) {
        push(@s, "&Dominus_vobiscum");
      } elsif (!$precesferiales) {
        push(@s, "&Dominus_vobiscum");
      } else {
        my $text = prayer('Dominus', $lang);
        my @text = split("\n", $text);
        push(@s, $text[4]);
        $precesferiales = 0;
      }
    }
    my $oremus = translate('Oremus', $lang);
    push(@s, "v. $oremus");
  }

  if ($horamajor && $winner{Rule} =~ /Sub unica conc/i) {
    if ($version !~ /196/) {
      if ($w =~ /(.*?)(\n\$Per [^\n\r]*?\s*)$/s) { $addconclusio = $2; $w = $1; }
      if ($w =~ /(.*?)(\n\$Qui [^\n\r]*?\s*)$/s) { $addconclusio = $2; $w = $1; }
    } else {
      $w =~ s/\$(Per|Qui) .*?\n//;
    }
  }
  $w =~ s/^(?:v. )?/v. / unless $w =~ /^[\$\&\#]/;
  push(@s, $w);
  if ($rule =~ /omit .*? commemoratio/i) { return; }

  #*** SET COMMEMORATIONS
  our %cc = ();
  our $ccind = 0;
  our $octavcount = 0;
  my $octavestring = '!.*?(O[ckt]ta|' . &translate("Octava", $lang) . ')';
  my $sundaystring = 'Dominic[aæ]|' . &translate("Dominica", $lang);

  %w = columnsel($lang) ? %winner : %winner2;    # prevent "contamination" from Oratio Dominica

  if ($horamajor && $rank < 7) {

    our $cwinner;
    our @commemoentries;
    our @ccommemoentries;

    my $c;
    my %c = ();
    my @cvesp = (2);    # assume laudes unless otherwise

    # add commemorated from winner
    unless (
      # Duplex I. classis: excludes Commemoratio reduced to Simplex
      ($rank >= ($version !~ /cist/i ? 6 : 7) && $dayname[0] !~ /Pasc[07]|Pent01/)
      || ($version =~ /196/ && $winner{Rule} =~ /nocomm1960/i)
    ) {

      if (exists($w{"Commemoratio $vespera"})) {
        $c = getrefs($w{"Commemoratio $vespera"}, $lang, $vespera, $w{Rule});
      } elsif (exists($w{Commemoratio})
        && ($vespera != 3 || $winner =~ /Tempora|C12/i || $w{Commemoratio} =~ /!.*O[ckt]ta/i))
      {
        $c = getrefs($w{Commemoratio}, $lang, $vespera, $w{Rule});
      } else {
        $c = '';
      }

      if ($c && $octvespera && $c =~ /$octavestring/i) {
        setbuild2("Substitute Commemorated Octave to Vesp-$octvespera");
        our $octavam = '';

        if (exists($w{"Commemoratio $octvespera"})) {
          $c = getrefs($w{"Commemoratio $octvespera"}, $lang, $octvespera, $w{Rule});
        } elsif (exists($w{"Commemoratio " . 4 - $octvespera})) {
          $c = getrefs($w{"Commemoratio " . 4 - $octvespera}, $lang, $octvespera, $w{Rule});
        } elsif (exists($w{Commemoratio})) {
          $c = getrefs($w{Commemoratio}, $lang, $octvespera, $w{Rule});
        }
      }

      if ($c) {
        my $redn = setfont($largefont, 'N.');
        $c =~ s/ N\. / $redn /g;
        $c =~ s/\n!/\n!!/g;
        $c =~ s/!!Oratio/!Oratio/gi;
        $c =~ s/\$Oremus\s*\n(v. )?/\$Oremus\nv. /g;
        my @ic = split('!!', $c);

        foreach my $ic (@ic) {
          if (
              !$ic
            || $ic =~ /^\s*$/
            || ($ic =~ /$octavestring|!.*?$sundaystring/i && nooctnat())
            || ( $version =~ /19(?:55|6)/
              && $ic =~ /!.*?Vigil/i
              && $winner =~ /Sancti/i
              && $winner !~ /08\-14|06\-23|06\-28|08\-09/)
          ) {
            next;
          }
          if ($ic !~ /^!/) { $ic = "!$ic"; }
          $ccind++;
          my $key = ($ic =~ /$sundaystring/i)
            ? ($version !~ /trident/i ? 3000 : 7100)    # Sundays are all privilegde commemorations under DA
            : ($ic =~ /$octavestring/i) ? $ccind + 7900
            : $ccind + 9900;
          $cc{$key} = $ic;
          setbuild2("Commemorated from winner: $key");
        }
      }

      if ($transfervigil) {
        if (!(-e "$datafolder/$lang/$transfervigil")) { $transfervigil =~ s/v\.txt/\.txt/; }
        $c = vigilia_commemoratio($transfervigil, $lang);

        if ($c) {
          $ccind++;
          my $key = $ccind + 8500;    # 10000 - 1.5 * 1000
          $cc{$key} = $c;
          setbuild2("Commemorated Vigil: $key");
        }
      }
    }

    if ($hora eq 'Vespera') {

      # add Concurrent Office
      if ($cwinner) {
        setbuild1("Concurrent office Vesp-$cvespera:", "$cwinner");

        my $key = 0;    # let's start with lowest rank
        if (!(-e "$datafolder/$lang/$cwinner") && $cwinner !~ /txt$/i) { $cwinner =~ s/$/\.txt/; }
        $c = getcommemoratio($cwinner, $cvespera, $lang);
        %c = %{officestring($lang, $cwinner, $cvespera == 1 && $cwinner =~ /tempora/i)};

        if ($c && $octvespera && $octvespera != $cvespera && $c =~ /$octavestring/i) {
          setbuild2("Substitute Commemoratio of Octave to Vesp-$octvespera");
          $c = getcommemoratio($cwinner, $octvespera, $lang);
          %c = %{officestring($lang, $cwinner, $octvespera == 1 && $cwinner =~ /tempora/i)};
        }

        if ($c) {
          my @cr = split(";;", $c{Rank});

          if ($version =~ /trident/i && $version !~ /1906/) {
            $key = $cr[0] =~ /Vigilia Epi|$sundaystring/i ? 2900 : $cr[2] * 1000;
          } else {
            $key = 9000;    # concurrent office comes first under DA and also 1906
          }
          $key = 10000 - $key;    # reverse order
          $ccind++;
          $cc{$key} = $c;
          setbuild2("Commemoratio: $key");
        } else {
          setbuild2("nihil");
        }

        # add commemorated from cwinner
        unless (($rank >= ($version !~ /cist/i ? 6 : 7) && $dayname[0] !~ /Pasc[07]|Nat0?6/)
          || $rule =~ /no commemoratio/i
          || ($version =~ /196/ && $c{Rule} =~ /nocomm1960/i))
        {
          if (exists($c{"Commemoratio $cvespera"})) {
            $c = getrefs($c{"Commemoratio $cvespera"}, $lang, $cvespera, $c{Rule});
          } elsif (exists($c{Commemoratio})
            && ($cvespera != 3 || $cwinner =~ /Tempora/i || $c{Commemoratio} =~ /!.*O[ckt]ta/i))
          {
            $c = getrefs($c{Commemoratio}, $lang, $cvespera, $c{Rule});
          } else {
            $c = '';
          }

          if ($c && $octvespera && $c =~ /$octavestring/i) {
            setbuild2("Substitute Commemorated Octave to Vesp-$octvespera");
            our $octavam = '';

            if (exists($c{"Commemoratio $octvespera"})) {
              $c = getrefs($c{"Commemoratio $octvespera"}, $lang, $octvespera, $c{Rule});
            } elsif (exists($c{"Commemoratio " . 4 - $octvespera})) {
              $c = getrefs($c{"Commemoratio " . 4 - $octvespera}, $lang, $octvespera, $c{Rule});
            } elsif (exists($c{Commemoratio})) {
              $c = getrefs($c{Commemoratio}, $lang, $octvespera, $c{Rule});
            }
          }

          my $redn = setfont($largefont, 'N.');
          $c =~ s/ N\. / $redn /g;
          $c =~ s/\n!/\n!!/g;
          $c =~ s/!!Oratio/!Oratio/gi;
          $c =~ s/\$Oremus\s*\n(v. )?/\$Oremus\nv. /g;
          my @ic = split('!!', $c);

          foreach my $ic (@ic) {
            if (
                !$ic
              || $ic =~ /^\s*$/
              || ($ic =~ /$octavestring|!.*?$sundaystring/i && nooctnat())
              || ( $version =~ /19(?:55|6)/
                && $ic =~ /!.*?Vigil/i
                && $cwinner =~ /Sancti/i
                && $cwinner !~ /08\-14|06\-23|06\-28|08\-09/)
            ) {
              next;
            }
            if ($ic !~ /^!/) { $ic = "!$ic"; }
            $ccind++;
            $key =
                ($ic =~ /$sundaystring/i)
              ? ($version !~ /trident/i ? 3000 : 7100)
              : $ccind + 9900;    # Sundays are all privileged commemorations under DA
            $cc{$key} = $ic;
            setbuild2("Commemorated from Concurrent: $key");
          }
        }
      }
      @cvesp = (1, 3);    # since we're in Vespers
    }

    # Add commemorated Offices of (tomorrow and) today
    foreach my $cv (@cvesp) {
      setbuild1("Commemorations", "Vesp-$cv");
      my @centries = $cv == 1 ? @ccommemoentries : @commemoentries;

      foreach my $commemo (@centries) {

        #setbuild2("Comm-$cv: $commemo");

        my $key = 0;    # let's start with lowest rank
        if (!(-e "$datafolder/$lang/$commemo") && $commemo !~ /txt$/i) { $commemo =~ s/$/\.txt/; }
        %c = %{officestring('Latin', $commemo, 0)};

        if ($c{Rank} =~ /in.*octavam/i && $octvespera) {
          $c = getcommemoratio($commemo, $octvespera, $lang);
          setbuild2("Substitute Commemoratio of Octave to $octvespera");
        } else {
          $c = getcommemoratio($commemo, $cv, $lang);
        }
        my $c2 = $cv == 2 ? vigilia_commemoratio($commemo, $lang) : '';
        $c ||= $c2;
        %c = %{officestring($lang, $commemo, 0)} unless $lang eq 'Latin';

        if ($c) {
          my @cr = split(";;", $c{Rank});

          if ($cr[0] =~ /Vigilia Epi|$sundaystring/i) {
            $key =
              ($version !~ /trident/i || ($version =~ /1906/ && $cr[2] > 5))
              ? 7000
              : 2900;    # under DA, all Sundays, in 1906, priviliged Sundays, are all privilegded commemorations
          } else {
            $key = $cr[2] * 1000;    # rank depending on the type of commemoration to be made
          }
          $ccind++;
          $key = 10000 - $key + $ccind;    # reverse order
          $cc{$key} = $c;
          setbuild2("$commemo: $key");
        } else {
          setbuild2("$commemo: nihil");
          next;
        }

        # add commemorated from commemo
        unless (($rank >= ($version !~ /cist/i ? 6 : 7) && $dayname[0] !~ /Pasc[07]/)
          || $rule =~ /no commemoratio/i
          || ($version =~ /196/ && $c{Rule} =~ /nocomm1960/i))
        {
          if (exists($c{"Commemoratio $cv"})) {
            $c = getrefs($c{"Commemoratio $cv"}, $lang, $cv, $c{Rule});
          } elsif (exists($c{Commemoratio})
            && ($cv != 3 || $commemo =~ /Tempora/i || $c{Commemoratio} =~ /!.*O[ckt]ta/i))
          {
            $c = getrefs($c{Commemoratio}, $lang, $cv, $c{Rule});
          } else {
            $c = '';
          }

          if ($c && $octvespera && $c =~ /$octavestring/) {
            setbuild2("Substitute Commemoratio of Octave to $octvespera");

            if (exists($c{"Commemoratio $octvespera"})) {
              $c = getrefs($c{"Commemoratio $octvespera"}, $lang, $octvespera, $c{Rule});
            } elsif (exists($c{"Commemoratio " . 4 - $octvespera})) {
              $c = getrefs($c{"Commemoratio " . 4 - $octvespera}, $lang, $octvespera, $c{Rule});
            } elsif (exists($c{Commemoratio})) {
              $c = getrefs($c{Commemoratio}, $lang, $octvespera, $c{Rule});
            }
          }

          if ($c) {
            my $redn = setfont($largefont, 'N.');
            $c =~ s/ N\. / $redn /g;
            $c =~ s/\n!/\n!!/g;
            $c =~ s/!!Oratio/!Oratio/gi;
            $c =~ s/\$Oremus\s*\n(v. )?/\$Oremus\nv. /g;
            my @ic = split('!!', $c);

            foreach my $ic (@ic) {
              if (
                  !$ic
                || $ic =~ /^\s*$/
                || ($ic =~ /$octavestring|!.*?$sundaystring/i && nooctnat())
                || ( $version =~ /19(?:55|6)/
                  && $ic =~ /!.*?Vigil/i
                  && $commemo =~ /Sancti/i
                  && $commemo !~ /08\-14|06\-23|06\-28|08\-09/)
                || ($rank >= 5 && $ic =~ /$octavestring/i && ($month != 12 || $day < 18))
              ) {
                next;
              }
              if ($ic !~ /^!/) { $ic = "!$ic"; }
              $ccind++;
              $key =
                  ($ic =~ /$sundaystring/i)
                ? ($version !~ /trident/i ? 3000 : 7100)
                : $ccind + 9900;    # Sundays are all privilegde commemorations under DA
              $cc{$key} = $ic;
              setbuild2("Commemorated: $key");
            }
          }
        }

        if ($dayofweek != 0 && $cv == 2 && exists($c{'Oratio Vigilia'})) {    # only at Laudes
          $c = vigilia_commemoratio($commemo, $lang);

          if ($c) {
            $ccind++;
            $key = $ccind + ($version !~ /cist/i ? 8500 : 8750);    # 10000 - 1.5 * 1000
            $cc{$key} = $c;
          }
        }
      }
    }

    # Under the 1960 rubrics, on II. cl and higher days,
    # allow at most one commemoration. We use @rank rather
    # than $rank as sometimes the latter is adjusted for
    # calculating precedence.
    my @rank = split(';;', $winner{Rank});

    if ($version =~ /1960/ && ($rank[2] >= 5 || ($dayname[1] =~ /Feria/i && $rank[2] >= 4)) && $ccind > 1) {
      my @keys = sort(keys(%cc));
      %cc = ($keys[0] => $cc{$keys[0]});
      $ccind = 1;
    }
  }

  # commented out 9/25/2024 mbab - $ordostatus is never initialized
  # if ($ordostatus =~ /Ordo/i) { return %cc; }

  foreach my $key (sort keys %cc) {
    if (length($s[-1]) > 3) { push(@s, '_'); }

    if ($key >= 900) {
      my $ostr;
      ($ostr, $addconclusio) = delconclusio($cc{$key}, $addconclusio);
      push(@s, $ostr);
      $collectcount++;
    }
  }

  if ((!checksuffragium() || $dayname[0] =~ /Quad5|Quad6/i || $version =~ /1955|196/)
    && $addconclusio)
  {
    push(@s, $addconclusio);
  }
}

#*** delconclusio($ostr)
# deletes the conclusio from the string
# returns string and conclusio
sub delconclusio {
  my $ostr = shift;
  my $conclusio = shift;

  if ($ostr =~ s/^(\$(?!Oremus).*?(\n|$)((_|\s*)(\n|$))*)//m) {
    $conclusio = $1;
  }

  ($ostr, $conclusio);
}

sub getcommemoratio {

  my $wday = shift;
  my $ind = shift;
  my $lang = shift;
  my %w = %{officestring($lang, $wday, $ind == 1)};
  my %c;

  our ($rule, $hora, $vespera, $version, $rank, $winner, @dayname, $month, $day, %winner, %winner2);

  if ( $rule =~ /no\s+(\w+)?\s*commemoratio/i
    && (!$1 || $wday =~ /$1/i)
    && !($hora eq 'Vespera' && $vespera == 3 && $ind == 1))
  {
    return '';
  }

  if ( $version =~ /1960/
    && $hora eq 'Vespera'
    && $ind == 3
    && $rank >= 6
    && $w{Rank} !~ /Adv|Quad|Passio|Epi|Corp|Nat|Cord|Asc|Dominica|;;6/i)
  {
    return '';
  }
  my @rank = split(";;", $w{Rank});

  if (
       $rank[2] < 2.1
    && $rank[2] != 1.15
    && (
      # no commemoration of no privileged feria
      $rank[1] =~ /Feria/

      #no commemoration of octava common in 2nd class unless in concurrence => to be checked
      || ( $rank[0] =~ /Infra Octav/i
        && $rank >= 5
        && $winner =~ /Sancti/i
        && ($wday ne $cwinner || $version !~ /Trident/))
    )
  ) {
    return;
  }

  if ($rank[3] =~ /(ex|vide)\s+(.*)\s*$/i) {
    my $file = $2;
    if ($w{Rule} =~ /Comex=(.*?);/i && $rank < 5) { $file = $1; }
    if ($file =~ /^C[1-3]a?$/ && $dayname[0] =~ /Pasc/i) { $file .= 'p'; }
    $file = "$file.txt";
    if ($file =~ /^C/) { $file = subdirname('Commune', $version) . "$file"; }
    %c = %{setupstring($lang, $file)};

    if ($c{Rank} =~ /;;(ex|vide)\s+(.*)\s*$/i) {

      # allow daisy-chained Commune references to the second-level
      $file = $2;
      if ($file =~ /^C[1-3]a?$/ && $dayname[0] =~ /Pasc/i) { $file .= 'p'; }
      $file = "$file.txt";
      if ($file =~ /^C/) { $file = subdirname('Commune', $version) . "$file"; }
      my %c2 = %{setupstring($lang, $file)};

      $c{Oratio} ||= $c2{Oratio};

      foreach my $i (1, 2, 3) {
        $c{"Ant $i"} ||= $c2{"Ant $i"};
        $c{"Versum $i"} ||= $c2{"Versum $i"};
      }
    }
  } else {
    %c = {};
  }
  if (!$rank) { $rank[0] = $w{Officium}; }    #commemoratio from commune
  my $o = $w{Oratio};
  if ($o =~ /N\./) { $o = replaceNdot($o, $lang); }

  if (!$o && $w{Rule} =~ /Oratio Dominica/i) {
    $wday =~ s/\-[0-9]/-0/;
    $wday =~ s/Epi1\-0/Epi1\-0a/;

    my %w1 = %{officestring($lang, $wday, 0)};

    $o = $w1{'OratioW'} // $w1{'Oratio'};
  }

  $o ||= $w{"Oratio $ind"} || $w{'Oratio ' . (4 - $ind)} || $c{Oratio};

  # Special processing for Common of Supreme Pontiffs.
  my $popeclass = '';
  my %cp;

  if ($version !~ /Trident/i && ((my $plural, $popeclass, my $name) = papal_rule($w{Rule}))) {
    $o = papal_prayer($lang, $plural, $popeclass, $name);
  } elsif ($o =~ /N\./ && (my $name = $w{Name} || papal_rule($w{Rule}))) {
    $o = replaceNdot($o, $lang, $name);
  }
  if (!$o) { return ''; }
  my $a = $w{"Ant $ind"};

  if (!$a || ($winner =~ /Epi1\-0a|01-12t/ && $hora eq 'Vespera' && $vespera == 3)) {
    $a = $w{'Ant ' . (4 - $ind)};
  }
  if (!$a) { $a = $c{"Ant $ind"}; }
  my $name = $w{Name};
  $a = replaceNdot($a, $lang, $name);
  if ($popeclass && $popeclass =~ /C/ && $ind == 3) { $a = papal_antiphon_dum_esset($lang); }

  if ($wday =~ /tempora/i) {
    if (
      $month == 12
      && ( ($hora eq 'Vespera' && $day >= 17 && $day <= 23)
        || ($hora eq 'Laudes' && ($day == 21 || $day == 23)))
    ) {
      my %v = %{setupstring($lang, 'Psalterium/Special/Major Special.txt')};

      if ($hora eq 'Vespera') {
        $a = $v{"Adv Ant $day"};
      } else {
        $a = $v{"Adv Ant $day" . "L"};
      }
    }
  }
  if (!$a) { return ''; }
  postprocess_ant($a, $lang);
  my $v = $w{"Versum $ind"};

  if ($winner =~ /Epi1\-0a|01\-12t/) {
    my %w = columnsel($lang) ? %winner : %winner2;
    $v = $vespera == 1 && $day == 10 ? $c{'Versum 2'} : $c{'Versum Tertia'};
  }
  $v ||=
       $w{'Versum ' . (4 - $ind)}
    || $c{"Versum $ind"}
    || $c{'Versum ' . (4 - $ind)}
    || getfrompsalterium('Versum', $ind, $lang)
    || 'versus missing';
  postprocess_vr($v, $lang);

  # my $w = "!" . &translate("Commemoratio", $lang) . (($lang !~ /latin/i || $wday =~ /tempora/i) ? ':' : ''); # Adding : except for Latin Sancti which are in Genetiv
  my $w = "!" . &translate('Commemoratio', $lang);
  $a =~ s/\s*\*\s*/ / unless ($version =~ /Monastic/i);
  $o =~ s/^(?:v. )?/v. /;
  $w .= " $rank[0]\nAnt. $a\n_\n$v\n_\n\$Oremus\n$o\n";
  return $w;
}

#*** vigilia_commemoratio($fname, $lang)
# gets commemoratio for vigila
sub vigilia_commemoratio {
  my $fname = shift;
  my $lang = shift;
  my $w;

  our ($version, $month, $day, @dayname, $dayofweek);

  if ($version =~ /1955|1960/) {
    my $dt = sprintf("%02i-%02i", $month, $day);
    if ($dt !~ /(08\-14|06\-23|06\-28|08\-09)/) { return ''; }
  } elsif ($dayname[0] =~ /Adv|Quad[0-6]/i
    || ($dayname[0] =~ /Quadp3/i && $dayofweek >= 4)
    || ($dayname[0] =~ /Quadp/i && $version =~ /Monastic.*Divino/i))
  {
    return '';
  }

  if ($fname !~ /\.txt$/) { $fname .= '.txt'; }
  if ($fname !~ /(Tempora|Sancti)/i) { $fname = "Sancti/$fname"; }
  my %w = %{setupstring($lang, $fname)};
  my @wrank = split(';;', $w{Rank});

  if ($w{Rank} =~ /Vigilia/i) {
    $w = $w{Oratio};

    if (!$w && $w{Rank} =~ /(?:ex|vide) C1v/) {
      my %com = columnsel($lang) ? %commune : %commune2;
      $w = $com{Oratio};
      $w = replaceNdot($w, $lang, $w{Name});
    }
  } elsif (exists($w{'Oratio Vigilia'})) {
    $w = $w{'Oratio Vigilia'};
  }
  if (!$w) { return ''; }
  my $c = "!" . &translate('Commemoratio', $lang) . ": " . &translate("Vigilia", $lang) . "\n";
  if ($w{Rank} =~ /Vigilia/i) { $c =~ s/\:.*/: $wrank[0]/; }
  if ($w =~ /(\!.*?\n)(.*)/s) { $c = $1; $w = $2; }
  my %p = %{setupstring($lang, 'Psalterium/Special/Major Special.txt')};
  my $a = $p{"Feria Ant 2"};       #$p{"Day$dayofweek Ant 2"};
  my $v = $p{"Feria Versum 2"};    #$p{"Day$dayofweek Versum 2"};
  $a =~ s/\s*\*\s*/ /;
  $w = $c . "Ant. $a" . "_\n$v" . "_\n\$Oremus\n$w";
  return $w;
}

sub getsuffragium {
  my $lang = shift;

  our ($version, @dayname, $hora, $commune, $month, $day, $churchpatron, %cwinner);
  $commune = "C10"
    if $cwinner{Rank} =~ /C1[012]/ && $hora eq 'Vespera'; # if Sancta Maria in Sabbato is commemorated on Friday Vespers

  my $comment =
      $version =~ /altovadensis/i ? 5
    : $version =~ /cisterciensis/i ? 4
    : $version =~ /trident/i ? 3
    : $dayname[0] =~ /pasc/i ? 2
    : 1;

  my $key = 'Suffragium';

  if ($comment == 2) {
    $key .= ' Paschale';
    $key .= 'V' if $version =~ /Monastic/ && $hora eq 'Vespera';
  } elsif ($comment > 2) {
    $key .= " $hora";
  }

  my %suffr = %{setupstring($lang, 'Psalterium/Special/Major Special.txt')};
  my $suffr = $suffr{$key};

  if ($version =~ /altovadensis/i && $collectcount == 2 && $commune !~ /C1[012]/) {
    $suffr =~ s/\n\!.*//s;
    my $conclBMV = $suffr{'Suffragium ConclusioBMV'};
    $suffr =~ s/$/~\n$conclBMV/s unless $suffr =~ /\$Per eumdem|\$Qui tecum|\$Per Dominum/;
    setbuild1('Suffragium altovadense:', "limited to three collects total");
  }

  if ($churchpatron) { $suffr =~ s/r\. N\./$churchpatron/; }
  ($suffr, $comment);
}

#*** getrefs($w, $lang, $ind)
# $w may contain line starting with @ reference
# @Feria: reference from Psalterium/Major Special: Day$dayofweek Ant|Versum 2|3
# filename:commemoratio reference from file/Commemoratio [1|2]
# filename:oratio proper Ant|Versum $ind from file
# filename:item collects item from file
# return the expanded string
# useable for lectio, responsory, commemoratio
sub getrefs {

  my $w = shift;
  my $lang = shift;
  my $ind = shift;
  my $rule = shift;
  my $file = '';
  my $item = '';
  my $flag = 0;
  my %s = {};
  my %c = {};

  while (
    $w =~ /
    (.*?)               # Prelude
    \@([a-z0-9\/\-]+?)  # Filename
    \:([a-z0-9 ]*)      # Item
    (?::(.*))?          # Substitutions
    (.*)                # Sequel
    /isx
  ) {
    $before = $1;
    $file = $2;
    $item = $3;
    $after = $5;
    my $substitutions = $4;
    $item =~ s/\s*$//;

    if ($file =~ /^feria$/i) {
      %s = %{setupstring($lang, 'Psalterium/Major Special.txt')};
      my $a = chompd($s{"Day$dayofweek Ant $ind"});
      if (!$a) { $a = "Day$dayofweek Ant $ind missing"; }
      my $v = chompd($s{"Day$dayofweek Versum $ind"});
      if (!$v) { $a = "Day$dayofweek Versus $ind missing"; }
      $a =~ s/\s*\*\s*/ /;
      $w = $before . "_\nAnt. $a" . "_\n$v" . "_\n$after";
      do_inclusion_substitutions($a, $substitutions);
      do_inclusion_substitutions($v, $substitutions);
      next;
    }
    if ($dayname[0] =~ /Pasc/i) { $file =~ s/(C[23])/$1p/g; }
    %s = %{setupstring($lang, "$file.txt")};

    if ($item =~ /(commemoratio|Octava)/i) {
      my $ita = $1;
      my $a = $s{"$ita"};
      if (!$a) { $a = $s{"$ita $ind"}; }
      if (!$a) { my $i = ($ind == 2) ? 1 : 2; $a = $s{"$ita $i"}; }
      if (!$a) { $a = "$file $item $ind missing\n"; }
      $flag = 1;

      if ($a =~ /\!.*?(octava|commemoratio)(.*?)\n/i) {
        my $oct = $2;

        if ($octavam =~ /$oct/) {
          $flag = 0;
        } else {
          $octavam .= $oct;
        }
      }

      if ($flag) {
        do_inclusion_substitutions($a, $substitutions);
        $a = "$a" . "_\n";
      } else {
        $a = '';
      }

      $w = "$before$a$after";
      next;
    }

    if ($item =~ /oratio/i) {

      if ($s{Rank} =~ /;;(ex|vide)\s+(.*)\s*$/i) {
        my $file = $2;
        if ($file =~ /^C[1-3]a?$/ && $dayname[0] =~ /Pasc/i) { $file .= 'p'; }
        $file = "$file.txt";
        if ($file =~ /^C/) { $file = subdirname('Commune', $version) . "$file"; }
        %c = %{setupstring($lang, $file)};

        if ($c{Rank} =~ /;;(ex|vide)\s+(.*)\s*$/i) {

          # allow daisy-chained Commune references to the second-level
          $file = $2;
          if ($file =~ /^C[1-3]a?$/ && $dayname[0] =~ /Pasc/i) { $file .= 'p'; }
          $file = "$file.txt";
          if ($file =~ /^C/) { $file = subdirname('Commune', $version) . "$file"; }
          my %c2 = %{setupstring($lang, $file)};

          $c{Oratio} ||= $c2{Oratio};

          foreach my $i (1, 2, 3) {
            $c{"Ant $i"} ||= $c2{"Ant $i"};
            $c{"Versum $i"} ||= $c2{"Versum $i"};
          }
        }
      } else {
        %c = {};
      }

      my $a = chompd($s{"Ant $ind"}) || chompd($c{"Ant $ind"});
      if (!$a) { $a = "$file Ant $ind missing\n"; }
      postprocess_ant($a, $lang);
      my $v = chompd($s{"Versum $ind"}) || chompd($c{"Versum $ind"});
      if (!$v) { $a = "$file Versus $ind missing\n"; }
      postprocess_vr($v, $lang);
      my $o = '';

      if ($item !~ /proper/) {
        my $i = $item;
        $i =~ s/\sgregem.*//i;
        $o = $s{$i} || $c{$i};

        if (!$o) {
          $o = "$file:$item missing\n";
        } elsif ($o !~ /\$Oremus/i) {
          $o = "\$Oremus\n$o";
        }
      }

      # Special processing for Common of Supreme Pontiffs.
      my ($plural, $class, $name) = papal_commem_rule($rule);

      if ($name) {
        if ($version !~ /Trident/i) {
          if ($item =~ /Gregem/i) {
            $o = papal_prayer($lang, $plural, $class, $name);

            if ($after =~ /(!Commem.*)/is) {
              $after = $1;
            } else {
              $after = '';
            }
            $o = "\$Oremus\n" . $o;
          }

          # Confessor-Popes have a common Magnificat antiphon at second Vespers.
          if ($popeclass && $popeclass =~ /C/ && $ind == 3) { $a = papal_antiphon_dum_esset($lang); }
        } else {
          if ($o =~ /N\./) { $o = replaceNdot($o, $lang, $name); }
        }
      }
      do_inclusion_substitutions($a, $substitutions);
      do_inclusion_substitutions($v, $substitutions);
      do_inclusion_substitutions($o, $substitutions);
      $a =~ s/\s*\*\s*/ /;
      $w = $before . "\nAnt. $a\n" . "_\n$v" . "_\n$o" . "_\n$after";
      next;
    }
    my $a = $s{$item};
    if ($after && $after !~ /^\s*$/) { $after = "_\n$after"; }
    if ($before && $before !~ /^\s*$/) { $before .= "_\n"; }
    if (!$a) { $a = "$file $item missing\n"; }
    do_inclusion_substitutions($a, $substitutions);
    $w = $before . $a . $after;
    next;
  }
  $w =~ s/\_\n\_/\_/g;
  return $w;
}

1;
