#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office fills the chapters from ordinarium
$a = 4;

#*** specials(\@s, $lang)
# input the array of the script for hora, and the language
# fills the content of the various chapters from the databases
# returns the text for further adjustment and print to sub horas
sub specials {
  my $s = shift;
  my $lang = shift;
  $octavam = '';    #check duplicate commemorations
  my %w = (columnsel($lang)) ? %winner : %winner2;
  my $hymntrans = $translate{$lang}{Hymnus};
  $hymntrans =~ s/\s+//g;    # this should be done in setupstring @mbab 2016-1-14

  if ($column == 1) {
    my $r = $w{Rule};
    $r =~ s/\s*$//;
    $r =~ s/\n/ /sg;
    $buildscript =
      setfont($largefont, "$hora $date1") . "\n" . setfont($smallblack, "$dayname[1] ~ $dayname[2] : $r") . "\n";
  }
  my $i = ($hora =~ /laudes/i) ? ' 2' : ($hora =~ /vespera/i) ? " $vespera" : '';
  if (exists($w{"Special $hora$i"})) { return loadspecial($w{"Special $hora$i"}); }
  our @s = @$s;
  @t = ();
  foreach (@s) { push(@t, $_); }
  @s = ();
  $skipflag = 0;
  $tind = 0;

  while ($tind < @t) {
    $item = $t[$tind];
    $tind++;

    if ($item !~ /^\s*\#/) {
      if (!$skipflag) { push(@s, $item); }
      next;
    }
    if ($skipflag) { push(@s, "\n"); }
    $label = $item;
    $item =~ s/\n//g;
    $skipflag = 0;
    $ite = $item;
    $ite =~ s/#//;
    @ite = split(' ', $ite);

    # Handle replacement of the Chapter (etc.) with a versicle on those
    # occasions when this occurs. The 'Capitulum Versum 2' directive takes
    # precedence over the 'Omit' directive, and so we handle this first.
    if ( $item =~ /Capitulum/i
      && $rule =~ /Capitulum Versum 2(.*);?$/im)
    {
      my $cv2hora = $1;

      unless (($cv2hora =~ /ad Laudes tantum/i && $hora !~ /Laudes/i)
        || ($cv2hora =~ /ad Laudes et Vesperas/i && $hora !~ /Laudes|Vespera/i))
      {
        # Compline is a special case: there the Chapter is omitted, as the
        # verse appears later and is handled separately. That being so, we have
        # nothing to do here.
        unless ($hora =~ /Completorium/i) {
          my %c = (columnsel($lang)) ? %commune : %commune2;
          my $v = (exists($w{"Versum 2"}) ? $w{"Versum 2"} : $c{"Versum 2"});
          push(@s, "#Versus (In loco Capituli)");
          push(@s, $v);
          push(@s, "");
          setbuild1("Versus speciale in loco calpituli");
        }
        $skipflag = 1;
        next;
      }
    }

    # Omit this section if the rule says so.
    if (
      $rule =~ /Omit.*? $ite[0]/i
      && !(
           $item =~ /Capitulum/i
        && $rule =~ /Capitulum Versum 2( etiam ad Vesperas)?/i
        && (($1 && $hora =~ /Vespera/i) || $hora =~ /Laudes/i)
      )
      )
    {
      $skipflag = 1;

      if ($item =~ /incipit/i && $version !~ /(1955|1960|Monastic)/) {
        $comment = 2;
        setbuild1($ite, 'limit');
      } else {
        $comment = 1;
        setbuild1($label, 'omit');
      }
      setcomment($label, 'Preces', $comment, $lang);

      if ($item =~ /incipit/i && $version !~ /(1955|1960|Monastic)/) {
        my $p1 = translate_label('$Pater noster', $lang);
        my $p2 = translate_label('$Ave Maria', $lang);
        push(@s, (setfont($smallfont, 'secreto'), $p1, $p2));
        if ($hora =~ /(matutinum|prima)/i) { push(@s, '$Credo'); }
      }
      next;
    }

    # Prelude pseudo-item. Include it if it exists; otherwise drop it
    # entirely.
    if ($item =~ /Prelude/i) {
      push(@s, $w{"Prelude $hora"}) if exists($w{"Prelude $hora"});
      next;
    }

    if ($rule =~ /Ave only/i && $item =~ /incipit/i) {
      setcomment($label, 'Preces', 2, $lang);

      while ($t[$tind] !~ /^\s*\#/) {
        if ($t[$tind] !~ /(Pater|Credo)/) { push(@s, $t[$tind]); }
        $tind++;
      }
      next;
    }

    if ($item =~ /preces/i) {
      $skipflag = preces($item);
      $comment = ($skipflag) ? 1 : 0;
      setcomment($label, 'Preces', $comment, $lang);

      if ($skipflag) {
        setbuild1($item, 'omit');
      } else {
        setbuild1($item, 'include');
      }
      next;
    }

    if ($item =~ /invitatorium/i) {
      invitatorium($lang);
      next;
    }

    if ($item =~ /hymnus|$hymntrans/i && $hora =~ /matutinum/i) {
      hymnus($lang);
      next;
    } elsif ($item =~ /hymnus|$hymntrans/i && $hora !~ /(laudes|vespera)/i) {
      $item = translate_label($item, $lang);
      my ($dox, $dname) = doxology('', $lang);
      if ($dox) { $item = "$item {Doxology: $dname}"; }
      push(@s, $item);

      if ($hora =~ /Tertia/ && $dayname[0] =~ /Pasc7/) {
        my %h = %{setupstring($datafolder, $lang, 'Psalterium/Minor Special.txt')};
        push(@s, $h{'Hymnus Pasc7 Tertia'});
        $skipflag = 1;
      } else {
        if (!$dox) { next; }

        while ($t[$tind] !~ /^\s*\#/) {
          if ($t[$tind] =~ /^\s*\*/) {
            push(@s, $dox);
            $skipflag = 1;
            last;
          } else {
            push(@s, $t[$tind]);
            $tind++;
            next;
          }
        }
      }
      next;
    }

    if ($item =~ /psalm/i) {
      $psalmnum1 = 0;
      $psalmnum2 = 0;

      if ($hora =~ /matutinum/i) {
        my $saveduplex = $duplex;
        if ($rule =~ /Matins simplex/i) { $duplex = 1; }
        psalmi_matutinum($lang);
        $duplex = $saveduplex;
      } elsif ($hora =~ /(laudes|vespera)/i) {
        psalmi_major($lang);
      } else {
        psalmi_minor($lang);
      }
      next;
    }

    if ($item =~ /Capitulum/i && $hora =~ /prima/i) {
      my %brevis = %{setupstring($datafolder, $lang, 'Psalterium/Prima Special.txt')};

      if ( $dayofweek > 0
        && $version !~ /1960/
        && $version !~ /monastic/i
        && $winner{Rank} =~ /Feria|Vigilia/i 
        && $commune !~ /C10/
        && ($rank < 3 || $dayname[0] =~ /Quad6/)
        && $dayname[0] !~ /Pasc/i)
      {
        @capit = split("\n", $brevis{'Feria'});
        $comment = 1;
        setbuild1('Capitulum', 'Psalterium Feria');
      } else {
        @capit = split("\n", $brevis{'Dominica'});
        $comment = 0;
        setbuild1('Capitulum', 'Psalterium Dominica');
      }
      setcomment($label, 'Source', $comment, $lang);
      foreach $l (@capit) { push(@s, $l); }
      my $primaresponsory = ($version !~ /monastic/i) ? get_prima_responsory($lang) : '';
      my %wpr = (columnsel($lang)) ? %winner : %winner2;
      if (exists($wpr{'Versum Prima'})) { $primaresponsory = $wpr{'Versum Prima'}; }
      push(@s, $t[$tind++]);
      my @resp = ();

      while ($t[$tind] !~ /^\s*\#/) {
        if (($t[$tind] =~ /^\s*V\. /) && $primaresponsory) {
          $t[$tind] = "V. $primaresponsory";
          $primaresponsory = '';
        }
        push(@resp, $t[$tind++]);
      }
      postprocess_short_resp(@resp, $lang);
      push(@s, $_) for (@resp);
      next;
    }

    if ($item =~ /Capitulum/i && $hora =~ /Completorium/i) {
      $tind--;
      if ($version =~ /Monastic/i) {
        while ($t[$tind] !~ /^\s*V\./) { push(@s, $t[$tind++]); }
      }
      else {
        while ($t[$tind] !~ /^\s*R\.br\./) { push(@s, $t[$tind++]); }
      }
      my @resp = ();
      while ($t[$tind] !~ /^\s*\#/) { push(@resp, $t[$tind++]); }
      postprocess_short_resp(@resp, $lang);
      push(@s, $_) for (@resp);
      next;
    }

    if ($item =~ /Capitulum/i && $hora =~ /(Tertia|Sexta|Nona)/i) {
      my %capit = %{setupstring($datafolder, $lang, 'Psalterium/Minor Special.txt')};
      my $name = minor_getname();
      $name .= 'M' if ($version =~ /monastic/i);
      my $capit = $capit{$name};
      my $resp = '';

      if ($capit !~ /\_\nR\.br. (.*)/is) {
        $resp = $capit{"Responsory $name"};
        $capit =~ s/\s*$//;
        $capit .= "\n_\n$resp";
      } else {
        $resp = "R.br. $1";
      }
      my @capit = split("\n", $capit);
      $comment = ($name =~ /(Dominica|Feria)/i) ? 5 : 1;
      setbuild('Psalterium/Minor Special', $name, 'Capitulum ord');

      #look for special from prorium the tempore of sancti
      my ($w, $c) = getproprium("Capitulum $hora", $lang, $seasonalflag, 1);

      if ($w !~ /\_\nR\.br/i) {
        ($wr, $cr) = getproprium("Responsory $hora", $lang, $seasonalflag, 1);
        $w =~ s/\s*$//;
        if ($wr) { $w .= "\n_\n$wr"; }
      }

      if ($w && $w !~ /\_\nR\.br/i && !($version =~ /monastic/i && $w =~ /\_\nV\. /)) {
        $w =~ s/\s*//;
        $w .= "\n_\n$resp";
      }
      if ($w) { @capit = split("\n", $w); $comment = $c; }
      postprocess_short_resp(@capit, $lang);
      setcomment($label, 'Source', $comment, $lang);
      foreach $l (@capit) { push(@s, $l); }
      next;
    }

    if ($item =~ /Capitulum/i && $hora =~ /(Laudes|Vespera)/i) {
      my %capit = %{setupstring($datafolder, $lang, 'Psalterium/Major Special.txt')};
      my $name = major_getname(1);
      if ($version =~ /monastic/i) { $name =~ s/Day[1-5]M/DayFM/i; }
      my $capit = $capit{$name};
      my $name = major_getname();
      my $hymn = '';

      if ($capit =~ /!H[iy]mn(.*)/is) {
        $hymn = $1;
        $hymn =~ s/^[\.\s]*//;
      } else {
        if (
          $name =~ /Day0 Laudes/i
          && ( $dayname[0] =~ /Epi[2-6]/
            || $dayname[0] =~ /Quadp/i
            || $winner{Rank} =~ /(Octobris|Novembris)/i)
          )
        {
          $name = 'Day0 Laudes2';
        }

        if ($version =~ /(Monastic|1570)/i && exists($capit{"HymnusM $name"})) {
          $hymn = $capit{"HymnusM $name"};
        } else {
          $hymn = $capit{"Hymnus $name"};
        }
      }
      $capit =~ s/\s*$//;
      $capit .= "\n_\n!$hymntrans\n$hymn";
      setbuild('Psalterium/Major Special', $name, 'Capitulum ord');

      #look for special from prorium the tempore or sancti
      my ($w, $c);
      $w = '';

      if (
           $hora =~ /Vespera/i
        && $vespera == 3
        && (exists($winner{'Capitulum Vespera 3'})
          || !exists($winner{'Capitulum Vespera'}))
        )
      {
        ($w, $c) = getproprium("Capitulum Vespera 3", $lang, $seasonalflag, 1);
      }
      if (!$w) { ($w, $c) = getproprium("Capitulum $hora", $lang, $seasonalflag, 1); }
      if (!$w && !$seasonflag) { ($w, $c) = getproprium("Capitulum $hora", $lang, 1, 1); }

      if ($w && $w !~ /!$hymntrans/i) {
        my $wr = '';
        my $hmn = (($version =~ /1955|1960/ && $winner{Rule} =~ /(C4|C5)/ && $hora =~ /Vespera/i)
            || ($winner{Rule} =~ /\;mtv/i && $hora =~ /Vespera/i)) ? 'Hymnus1' : 'Hymnus';

        if (
          (!exists($winner{"$hmn Vespera"}) && ($vespera == 3 && !exists($winner{"$hmn Vespera 3"})))
          && (($vespera == 3 && exists($winner{"Hymnus Vespera 3"}))
            || exists($winner{"Hymnus Vespera"}))
          )
        {
          $hmn = 'Hymnus';
        }

        if ($hora =~ /Vespera/i && $vespera == 3) {
          ($wr, $cr) = getproprium("$hmn Vespera 3", $lang, $seasonalflag, 1);
        }
        if (!$wr) { ($wr, $cr) = getproprium("$hmn $hora", $lang, $seasonalflag, 1); }
        $w =~ s/\s*$//;
        $wr ||= $hymn;
        if ($wr) { $w .= "\n_\n!$hymntrans\n$wr"; }
      }

      if ($w && $w !~ /!$hymntrans/i) {
        $w =~ s/\s*$//;
        $w .= "\n_\n!$hymntrans\n$hymn";
      }
      if ($w) { $capit = $w; $comment = $c; }
      if ($capit) { $capit = doxology($capit, $lang); }
      my $ind = ($hora =~ /laudes/i) ? 2 : $vespera;
      my ($versum, $c1) = getantvers('Versum', $ind, $lang);
      setcomment($label, 'Source', $c, $lang);
      $capit = chompd($capit) . "_\n" . $versum;
      if ($version =~ /monastic/i) {
        (@capit) = split(/\n/, $capit);
        postprocess_short_resp(@capit, $lang);
        $capit = join("\n", @capit);
      }
      push(@s, $capit);

      #my @capit = split("\n", chompd($capit) . "_\n" . $versum);
      #foreach $l (@capit) {push(@s, $l);}
      next;
    }

    if ($item =~ /Lectio brevis/i && $hora =~ /prima/i) {
      my %brevis = %{setupstring($datafolder, $lang, 'Psalterium/Prima Special.txt')};
      my $name =
          ($dayname[0] =~ /(Quad5|Quad6)/i) ? 'Quad5'
        : ($dayname[0] =~ /Quad/i && $dayname[0] !~ /Quadp/i) ? 'Quad'
        : ($dayname[0] =~ /Quadp[3]/i && $dayofweek >= 3 && $version !~ /1960/) ? 'Per Annum'
        : ($dayname[0] =~ /Adv/i) ? 'Adv'
        : ($dayname[0] =~ /Pasc6/i || ($dayname[0] =~ /Pasc5/i && $dayofweek > 3)) ? 'Asc'
        : ($dayname[0] =~ /Pasc[0-6]/i) ? 'Pasc'
        : ($dayname[0] =~ /Pasc7/i) ? Pent
        : 'Per Annum';

      if ($version =~ /1960/) {
        my $d = ($dayname[0] =~ /Nat/i) ? $dayname[0] : "$dayname[0]-$dayofweek";
        if ($d =~ /Nat/i) { $name = 'Nat'; }

        if ($d =~ /Nat([0-9]+)/i) {
          my $n = $1;
          if ($1 > 5 && $1 < 14) { $name = 'Epi'; }
        }
        if ($d =~ /Epi1\-[0-9]/i && $day < 14) { $name = 'Epi'; }
        if ($d =~ /Pasc/i && $d ge 'Pasc5-4' && $d lt 'Pasc7-0') { $name = 'Asc'; }
      }
      my @brevis = split("\n", $brevis{$name});
      $comment = ($name =~ /per annum/i) ? 5 : 1;
      setbuild('Psalterium/Prima Special', $name, 'Lectio brevis ord');

      #look for [Lectio Prima]
      if ($version !~ /(1955|1960)/) {
        %w = (columnsel($lang)) ? %winner : %winner2;
        my $b = '';

        if (exists($w{'Lectio Prima'})) {
          $b = $w{'Lectio Prima'};
          if ($b) { setbuild2("Subst Lectio Pima $winner"); $comment = 3; }
        }

        if (!$b && $communetype =~ /ex/i && exists($commune{'Lectio Prima'})) {
          $b = (columnsel($lang)) ? $commune{'Lectio Prima'} : $commune2{'Lectio Prima'};
          if ($b) { setbuild2("Subst Lectio Pima $commune"); $comment = 3; }
        }

        if (!$b && ($winner =~ /sancti/i || $commune =~ /C10/)) {
          $b = getfromcommune("Lectio", "Prima", $lang, 1, 1);
          if ($b) { $comment = 4; }
        }
        if ($b) { @brevis = split("\n", $b); }
      }
      setcomment($label, 'Source', $comment, $lang);
      foreach $l (@brevis) { push(@s, $l); }
      next;
    }

    if ($item =~ /(benedictus|magnificat)/i) {
      $comment = ($winner =~ /sancti/i) ? 3 : 2;
      setcomment($label, 'Source', $comment, $lang, translate('Antiphona', $lang));
      next;
    }

    if ($item =~ /Nunc Dimittis/i) {
      my $w = $w{"Ant 4$vespera"};
      my $c;
      if (!$w && $communetype =~ /ex/) { ($w, $c) = getproprium("Ant 4$vespera", $lang, 1); }
      if ($w) { setbuild1($ite, 'special'); }
      $tind--;
      my $non_first_ant = 0;

      while ($t[$tind] !~ /^\s*$/) {
        if ($t[$tind] =~ /^Ant/) {
          if ($w) {
            $t[$tind] = (split("\n", $w))[-1 * $non_first_ant];
          } else {
            postprocess_ant($t[$tind], $lang) if ($version =~ /1960/ || $non_first_ant);
          }
          $non_first_ant = 1;
        }
        push(@s, $t[$tind++]);
      }
      next;
    }

    if ($item =~ /Oratio/i) {

      # Normally we only handle the Oratio(nes) section at the hours other than
      # Prime and Compline, but during the Triduum, we do it for those hours,
      # too. The test for this case is somewhat oblique.
      my $prime_or_compline = ($hora =~ /Prima|Completorium/i);
      my $triduum = ($rule =~ /Limit.*?Oratio/);
      my %oratio_params;

      # Skip the usual stuff at Prime and Compline in the Triduum.
      if ($prime_or_compline && $triduum) {
        $skipflag = 1;
        $oratio_params{special} = 1;
      }

      # Generate the prayer(s) together with the title.
      if (!$prime_or_compline || $triduum) {
        oratio($lang, $month, $day, %oratio_params);
        next;
      }
    }

    if ($item =~ /Suffragium/i && $hora =~ /Laudes|Vespera/i) {
      if (!checksuffragium() || $dayname[0] =~ /(Quad5|Quad6)/i) {
        setcomment($label, 'Suffragium', 0, $lang);
        push(@s, "\n");
        setbuild1($item, 'omit');
        next;
      }
      my %suffr = %{setupstring($datafolder, $lang, 'Psalterium/Major Special.txt')};
      my ($suffr, $comment);

      if ($version =~ /trident/i) {
        if ($dayname[0] =~ /pasc/i && $dayname[1] =~ /(?:feria|vigilia)/i) { $suffr = $suffr{"Suffragium2"}; }
        else {
          if ($dayname[1] =~ /(?:feria|vigilia)/i && $commune !~ /C10/) {
            $suffr = $suffr{"SuffragiumTridentinumFeriale"};
          }
          if ($commune !~ /(C1[0-9])/i) {
            if (($month == 1 && $day > 13) || $month == 2 && $day == 1) {
              $suffr .= $suffr{Suffragium3Epi};
            } else {
              $suffr .= $suffr{Suffragium3};
            }
          }
          my($v) = $hora =~ /vespera/i ? 1 : 2;
          $suffr .= $suffr{"Suffragium4$v"} if ($version !~ /1570/);
          $suffr .= $suffr{"Suffragium5$v"};
          $suffr .= $suffr{Suffragium6};
        }
        $comment = 3;
      } else {
        $comment = ($dayname[0] =~ /(pasc)/i) ? 2 : 1;
        my $c = $comment;
        if ($c == 1 && $commune =~ /(C1[0-9])/) { $c = 11; }
        $suffr = $suffr{"Suffragium$c"};
      }
      if ($churchpatron) { $suffr =~ s/r\. N\./$churchpatron/; }
      setcomment($label, 'Suffragium', $comment, $lang);
      setbuild1("Suffragium$comment", 'included');
      push (@s, split("\n", $suffr));
      next;
    }

    #flag for Litaniae majores for St Marks day: for Easter Sunday (in 1960 also from Easter Monday) to Tuesday,
    my $flag = 0;

    if (!$votive) {
      if ($month == 4 && $day == 25 && ($dayname[0] !~ /Pasc0/ || $dayofweek > 1)) { $flag = 1; }
      if ($month == 4 && $day == 27 && $dayname[0] =~ /Pasc0/ && $dayofweek == 2) { $flag = 1; }    #25 Sunday
      if ($version !~ /1960/ && $month == 4 && $day == 25 && $dayname[0] =~ /Pasc0/ && $dayofweek == 1) { $flag = 1; }
      if ($version =~ /1960/ && $month == 4 && $day == 26 && $dayname[0] =~ /Pasc0/ && $dayofweek == 2) { $flag = 1; }
      if ($rule =~ /Laudes Litania/i && $winner =~ /Sancti/ && $day != 25) { $rule =~ s/Laudes Litania//ig; }
    }

    # Insert the title.
    $label = translate_label($label, $lang);
    push(@s, $label);

    # The remaining special cases come *after* the title has been inserted.
    if (
         $item =~ /Conclusio/i
      && $hora =~ /Laudes/i
      && ($month == 4 || $version !~ /1960/)
      && ( $rule =~ /Laudes Litania/i
        || $commemoratio{Rule} =~ /Laudes Litania/i
        || $scriptura{Rule} =~ /Laudes Litania/i
        || $flag)
      )
    {
      my %w = %{setupstring($datafolder, $lang, 'Psalterium/Major Special.txt')};
      my $lname = ($version =~ /monastic/i) ? 'LitaniaM' : 'Litania';
      if ($version =~ /1570/ && exists($w{LitaniaT})) { $lname = 'LitaniaT'; }
      push(@s, $w{$lname});
      setbuild1($item, 'Litania omnium sanctorum');
      $skipflag = 1;
      $litaniaflag = 1;
    }

    # Special conclusions, e.g. on All Souls' day.
    if ($item =~ /Conclusio/i && $rule =~ /Special Conclusio/i) {
      my %w = (columnsel($lang)) ? %winner : %winner2;
      push(@s, $w{Conclusio});
      $skipflag = 1;
    }

    # Set special conclusion when Office of the Dead follows.
    if ($item =~ /Conclusio/i && $dirge && $commune !~ /C9/i && $votive !~ /C9/i) {
      our %prayers;

      if ($hora =~ /Vespera/i && $dirge == 1) {
        push(@s, $prayers{$lang}->{DefunctV});
        setbuild1($item, 'Recite Vespera defunctorum');
        $skipflag = 1;
      } elsif ($hora =~ /Laudes/i && $dirge == 2) {
        push(@s, $prayers{$lang}->{DefunctM});
        setbuild1($item, 'Recite Officium defunctorum');
        $skipflag = 1;
      }
    }
  }
  return @s;
}

#***  ($label, $comment, $ind, $lang, $prefix)
# prepares for print the chapter headline.
# $label is the large font (translated), prefix is untranslated
# comment[ind] is translated
sub setcomment {

  my $label = shift;
  my $comment = shift;
  my $ind = shift;
  my $lang = shift;
  my $prefix = shift;

  if ($comment =~ /Source/i && $votive) { $ind = 7; }
  $label = translate_label($label, $lang);
  my %comm = %{setupstring($datafolder, $lang, 'Psalterium/Comment.txt')};
  my @comm = split("\n", $comm{$comment});
  $comment = $comm[$ind];
  if ($prefix) { $comment = "$prefix $comment"; }

  if ($label =~ /\}\s*/) {
    $label =~ s/\}\s*$/ $comment}/;
  } else {
    $label .= "{$comment}";
  }
  push(@s, $label);
}

#*** translate_label($label, $lang)
# finds the equivalent of the latin label in translate file
sub translate_label {
  my $item = shift;
  my $lang = shift;
  $item =~ s/\s*$//;
  if (exists($translate{$lang}{$item})) { $item = $translate{$lang}{$item}; }
  $item =~ s/\n//g;
  return $item;
}

#*** preces($item)
# returns 0 = yes or 1 = omit after deciding about the preces
sub preces {
  my $item = shift;
  my $dominicales = 0;
  my $feriales = 0;
  our $precesferiales = 0;
  if ($winner =~ /C12/i) { return 1; }    #Officium parvum BMV
  if ($rule =~ /Omit.*? Preces/i) { return 1; }
  if ($duplex > 2 && $seasonalflag) { return 1; }
  $dominicales = 1;                       #taken off from Ordinary for 1955, 1960
  if ($winner{Rank} =~ /octav/i && $winner{Rank} !~ /post octavam pente/i) { $dominicales = 0; }
  if (checkcommemoratio(\%winner) =~ /Octav/i) { $dominicales = 0; }

  if ($commemoratio) {
    my @r = split(';;', $commemoratio{Rank});

    if ($r[2] >= 3 || $commemoratio{Rank} =~ /Octav/i || checkcommemoratio(\%commemoratio) =~ /octav/i) {
      $dominicales = 0;
    }
  }
  if ($dayofweek > 0 && (($dayname[0] =~ /(Adv|Quad)/i && $dayname[0] !~ /Quadp/i) || emberday())) { $feriales = 1; }
  if ($winner =~ /sancti/i && $winner{Rank} !~ /vigil/i) { $feriales = 0; }
  if ($dayname[0] =~ /pasc7/i && $dayofweek == 6) { $feriales = 0; }
  if ($rule =~ /Preces/i) { $feriales = 1; }

  if ($version =~ /(1955|1960|Newcal)/ && $feriales == 1) {
    if ($dayofweek =~ /[1246]/ && !emberday()) { $feriales = 0; }
  } elsif ($dayname[1] =~ /vigilia/i && $version !~ /(1955|1960|Newcal)/ && $dayname[1] !~ $dayname[1] !~ /(Epi|Pasc)/i) {
    $feriales = 1;
  }
  if ($winner =~ /Sancti/i && $version =~ /(1955|1960|Newcal)/) { $feriales = 0; }
  if ($dayname[1] =~ /dominica/i) { $feriales = 0; }
  if ($dayname[0] =~ /Pasc[67]/i) { $feriales = $dominicales = 0; }

  if ($feriales && $item =~ /Feriales/i) {
    $precesferiales = 1;
    return 0;
  }

  if ($dominicales && $item =~ /Dominicales/i) {
    if ($hora =~ /prima/i) { $precesferiales = 1; }
    return 0;
  }
  return 1;
}

#*** checkcommemoratio \%office
# return the text of [Commemoratio] [Commemoratio n] or an empty string
sub checkcommemoratio {
  my $w = shift;
  my %w = %$w;
  if (exists($w{'Commemoratio'})) { return $w{'Commemoratio'}; }
  if (exists($w{'Commemoratio 1'})) { return $w{'Commemoratio 1'}; }
  if (exists($w{'Commemoratio 2'})) { return $w{'Commemoratio 2'}; }
  if (exists($w{'Commemoratio 3'})) { return $w{'Commemoratio 3'}; }
  return '';
}

#*** psalmi_minor($lang)
#collects and returns psalms for prim, tertia, sexta, none, completorium
sub psalmi_minor {
  my $lang = shift;
  my %psalmi = %{setupstring($datafolder, $lang, 'Psalterium/Psalmi minor.txt')};
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
    if ($rule =~ /Psalmi\s*(minores)*\s*Dominica/i || $communerule =~ /Psalmi\s*(minores)*\s*Dominica/i) { $i = 0; }
    if ($version =~ /1955|1960/ && $rule =~ /horas1960 feria/i) { $i = 2 * $dayofweek; }
    if ($version =~ /1955|1960/ && $winner =~ /Sancti/i && $rank < 5) { $i = 2 * $dayofweek; }

    #if ($winner =~ /tempora/i && $dayofweek > 0 && $winner{Rank} =~ /Dominica/i && $rank < 6
    #  && $dayname[0] !~ /Nat/i) {$i = 2 * $dayofweek;}  #anticipated Sunday
    if ( $version =~ /1960/
      && $winner =~ /sancti/i
      && $rank < 6
      && $hora =~ /(Prima|Tertia|Sexta|Nona)/i)
    {
      $i = 2 * $dayofweek;
    }
    if ($hora =~ /Completorium/i && $dayofweek == 6 && $winner{Rank} =~ /Dominica/i && $dayname[0] !~ /Nat/) { $i = 12; }
    $ant = chompd($psalmi[$i]);
    $psalms = chompd($psalmi[$i + 1]);
    if (($version =~ /1960/ && $psalms =~ /117/ && $laudes == 2) || $rule =~ /Prima=53/i) { $psalms =~ s/117/53/; }
  }
  setbuild("Psalterium/Psalmi minor", "$hora Day$dayofweek", 'Psalmi ord');
  $comment = 0;

  if ($hora =~ /completorium/i && $version !~ /trident/i) {
    if ($winner =~ /tempora/i && $dayofweek > 0 && $winner{Rank} =~ /Dominica/i && $rank < 6) {
      ;
    }

    #psalmi dominica rule for completorium
    elsif (($rule =~ /Psalmi\s*(minores)*\s*Dominica/i || $communerule =~ /Psalmi\s*(minores)*\s*Dominica/i)
      && ($version !~ /1960/ || $rank >= 6))
    {
      $ant = chompd($psalmi[0]);
      $psalms = chompd($psalmi[1]);
      $comment = 6;
    }
  }

  if ($winner =~ /tempora/i || $testmode =~ /seasonal/i || $dayname[0] =~ /pasc/i) {

    #*** look for Adv, Quad Pasc
    my $ind =
        ($hora =~ /Prima/i) ? 0
      : ($hora =~ /Tertia/i) ? 1
      : ($hora =~ /Sexta/i) ? 2
      : ($hora =~ /Nona/i) ? 4
      : -1;
    my $name =
        ($dayname[0] =~ /Adv1/i) ? 'Adv1'
      : ($dayname[0] =~ /Adv2/i) ? 'Adv2'
      : ($dayname[0] =~ /Adv3/i) ? 'Adv3'
      : ($dayname[0] =~ /Adv4/i) ? 'Adv4'
      : ($dayname[0] =~ /(Quad5|Quad6)/i) ? 'Quad5'
      : ($dayname[0] =~ /Quad/i && $dayname[0] !~ /Quadp/i) ? 'Quad'
      : ($dayname[0] =~ /Pasc/i && ($dayname[0] !~ /Pasc7/i || $hora =~ /Completorium/i)) ? 'Pasch'
      : '';

    if ($month == 12 && $day > 16 && $day < 25 && $dayofweek > 0) {
      my $i = $dayofweek + 1;
      $name = "Adv4$i";
    }
    if ($name =~ /pasc/i && ($dayname[0] !~ /Pasc7/i || $hora =~ /Completorium/i)) { $ind = 0; }

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
  }

  if ($w{Rule} =~ /Minores sine Antiphona/i) {
    $ant = '';
    setbuild2('Sine antiphonae');
  }
  if ($ant =~ /(.*?)\;\;/s) { $ant = $1; }
  if ($dayname[0] =~ /Quad/i) { $ant =~ s/[(]*allel[uú][ij]a[\.\,]*[)]*//ig; }
  if ($ant) { $ant = "Ant. $ant"; }
  my @ant = split('\*', $ant);
  postprocess_ant($ant, $lang);
  $ant1 = ($version !~ /1960|monastic/i) ? $ant[0] : $ant;    #difference between 1955 and 1960
  setcomment($label, 'Source', $comment, $lang, $prefix);
  $psalms =~ s/\s//g;
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
  push(@s, $ant1);

  foreach $p (@psalm) {
    if ($p =~ /[\[\]]/ && ($laudes != 2 || $version =~ /1960/)) { next; }
    $p =~ s/[\[\]]//g;
    $p =~ s/[\(\-]/\,/g;
    $p =~ s /\)//;
    push(@s, "\&psalm($p)");
    push(@s, "\n");
  }

  #quicumque
  if ( ($version !~ /(1955|1960|Monastic)/i || $dayname[0] =~ /Pent01/i)
    && $hora =~ /prima/i
    && ($dayname[0] =~ /(Epi|Pent)/i || $version !~ /Divino/i)
    && $dayofweek == 0
    && ($dayname[0] =~ /(Adv|Pent01)/i || checksuffragium()))
  {
    push(@s, "\&psalm(234)");
    push(@s, "\n");
    setbuild2('Quicumque');
  }
  pop(@s);
  push(@s, '_');
  $ant =~ s/\s*\*\s*/ /;
  push(@s, $ant);
  return;
}

#*** psalmi_major($lang)
# collects and return the psalms for laudes and vespera
sub psalmi_major {
  $lang = shift;
  if ($version =~ /monastic/i && $hora =~ /Laudes/i) { $psalmnum1 = $psalmnum2 = -1; }
  my %psalmi = %{setupstring($datafolder, $lang, 'Psalterium/Psalmi major.txt')};
  my $name = $hora;
  if ($hora =~ /Laudes/) { $name .= $laudes; }
  my @psalmi = splice(@psalmi, @psalmi);

  if ($version =~ /monastic/i) {
    my $head = "Daym$dayofweek";
    if ($hora =~ /Laudes/i) {
      if ($rule =~ /Psalmi Dominica/ || ($winner =~ /Sancti/i && $rank >= 4 && $dayname[1] !~ /vigil/i)) { $head = 'DaymF'; }
      if ($dayname[0] =~ /Pasc/i && $head =~ /Daym0/i) { $head = 'DaymP'; }
    }
    @psalmi = split("\n", $psalmi{"$head $hora"});

    if ($hora =~ /Laudes/i && $head =~ /Daym[1-6]/) {
      $sday = get_sday($month, $day, $year);
      unless ( (($dayname[0] =~ /Adv|Quadp/) && ($duplex < 3) && ($commune !~ /C10/))
               || (($dayname[0] =~ /Quad\d/) && ($dayname[1] =~ /Feria/))
               || ($dayname[1] =~ /Quattuor Temporum Septembris/)
               || ($sday =~ /(06\-23|06\-28|08\-09|08\-14)/))
      {
        my @canticles = split("\n", $psalmi{'DaymF Canticles'});
        if ($dayofweek == 6) { $psalmi[2] = $canticles[7]; }
        $psalmi[3] = $canticles[$dayofweek];
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
  } elsif ($version =~ /trident/i) {
    my $dow =
      ($hora =~ /Laudes/i && $dayname[0] =~ /Pasc/i)
      ? 0
      : (  $hora =~ /Laudes/i
        && ($winner =~ /sancti/i || exists($winner{'Ant Laudes'}))
        && $rule !~ /Feria/i) ? 'C'
      : $dayofweek;
    @psalmi = split("\n", $psalmi{"Daya$dow $name"});
  } else {
    @psalmi = split("\n", $psalmi{"Day$dayofweek $name"});
  }
  $comment = 0;
  $prefix = translate("Psalmi et antiphonae", $lang) . ' ';
  setbuild("Psalterium/Psalmi major", "Day$dayofweek $name", 'Psalmi ord');

  my @antiphones;
  if (($hora =~ /Laudes/ || ($hora =~ /Vespera/ && $version =~ /Monastic/)) && $month == 12 && $day > 16 && $day < 24 && $dayofweek > 0) {
    my @p1 = split("\n", $psalmi{"Day$dayofweek Laudes3"});
    for (my $i = 0; $i < @p1; $i++) {
      my @p2 = split(';;', $psalmi[$i]);
      $antiphones[$i] = "$p1[$i];;$p2[1]";
    }
    setbuild2("Special laudes antiphonas for week before vigil of Christmas");
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
  if (!$w && exists($w{"Ant $hora"})) { $w = $w{"Ant $hora"}; $c = ($winner =~ /tempora/i) ? 2 : 3; }

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
  } elsif (
    (
         $rule =~ /Psalmi Dominica/i
      || $commune{Rule} =~ /Psalmi Dominica/i
      || ($anterule && $anterule =~ /Psalmi Dominica/i)
    )
    && ($antiphones[0] !~ /\;\;\s*[0-9]+/)
    )
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
  if ($version =~ /monastic/i && $hora =~ /Vespera/i && ($commune !~ /C9/) && ($dayname[0] !~ /Quad6/ || $dayofweek < 4)) {
    $lim = 4;
    if ($antiphones[4]) {
      local($a1,$p1) = split(/;;/, $antiphones[3]);
      local($a2,$p2) = split(/;;/, $antiphones[4]);
      $antiphones[3] = "$a2;;$p1"
    }
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

  # $prefix = ''; # this line prevent display prefix set in line 883 commented out by @mbab 2017/02/09
  if (($dayname[0] =~ /(Adv|Quad)/i || emberday()) && $hora =~ /laudes/i && $version !~ /trident/i) {
    $prefix = "Laudes:$laudes $prefix";
  }
  setcomment($label, 'Source', $comment, $lang, $prefix);

  if ($version =~ /monastic/i) {
    antetpsalm_mm('', -1);
    for ($i = 0; $i < @psalmi; $i++) { antetpsalm_mm($psalmi[$i], $i); }
    antetpsalm_mm('', -2);
  } else {
    for ($i = 0; $i < @psalmi; $i++) {
      my $last = ($i == (@psalmi - 1)) ? 1 : 0;
      antetpsalm($psalmi[$i], $i, $last, $lang);
    }
  }
  return;
}

#*** antetpsalm($line, $i, $last, $lang)
# format of line is antiphona;;psalm number
# returns the psalm included into the starting end ending antiphones
# handles duplex or no attribute, and the nonreadeable beginnings
sub antetpsalm {
  my ($line, $ind, $last, $lang) = @_;
  my @line = split(';;', $line);
  my @ant = split('\*', $line[0]);
  my $ant = $line[0];
  postprocess_ant($ant, $lang);
  my $ant1 = ($duplex > 2 || $version =~ /1960|Monastic/i) ? $ant : $ant[0];    #difference between 1995, 1960

  if ( $dayname[0] =~ /Pasc/i
    && $hora =~ /(laudes|vespera)/i
    && $version !~ /monastic/i
    && !exists($winner{"Ant $hora"})
    && $communetype !~ /ex/i)
  {
    if ($ind == 0) {
      $ant1 = Alleluia_ant($lang, 0);
      $ant = '';
    } elsif ($last) {
      $ant1 = '';
      $ant = Alleluia_ant($lang, 1);
    } else {
      $ant1 = $ant = '';
    }
  }
  if ($hora =~ /Matutinum/i && $dayname[0] =~ /Pasc[1-6]/i) { ($ant1, $ant) = ant_matutinum($ant1, $ant, $ind); }
  $ant1 =~ s/\;\;[0-9\;n]+//;
  if ($ant1) { push(@s, "Ant. $ant1"); }
  my $p = $line[1];
  my @p = split(';', $p);

  for (my $i = 0; $i < @p; $i++) {
    if ($expand =~ /(psalms|all)/i && $i > 0) { push(@s, "\_"); }
    $p = $p[$i];
    $p =~ s/[\(\-]/\,/g;
    $p =~ s/\)//;
    if ($i < (@p - 1)) { $p = '-' . $p; }
    push(@s, "\&psalm($p)");
    if ($i < (@p - 1)) { push(@s, "\n"); }
  }

  if ($ant) {
    $ant =~ s/\;\;[0-9\;n]+//;
    $ant =~ s/\s*\*\s*/ /;
    push(@s, '_');
    push(@s, "Ant. $ant");
  }
  push(@s, "\n");
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
  our $addconclusio = '';
  my %w = (columnsel($lang)) ? %winner : %winner2;

  # Output the title.
  setcomment(
    $label, $params{special}
    ? ('Preces', 2)
    : ('Source', ($winner =~ /sancti/i) ? 3 : 2), $lang
  );
  $ind = ($hora =~ /vespera/i) ? $vespera : 2;

  # Special handling for days during the suppressed octave of the Epiphany.
  # Before the Sunday formerly in the octave, the collect of the Epiphany is
  # said, as in the past; afterwards, the collect of the Sunday is said, in
  # which case we have to override it.
  if ( $dayname[0] =~ /Epi1/i
    && $rule =~ /Infra octavam Epiphaniæ Domini/i
    && $version =~ /(monastic|1955|1960)/i)
  {
    $rule .= "Oratio Dominica\n";
  }

  if ( ($rule =~ /Oratio Dominica/i && (!exists($w{Oratio}) || $hora =~ /Vespera/i))
    || ($winner{Rank} =~ /Quattuor/i && $version !~ /1960|Monastic/i && $hora =~ /Vespera/i))
  {
    my $name = "$dayname[0]-0";
    if ($name =~ /(Epi1|Nat)/i && $version ne 'Monastic') { $name = 'Epi1-0a'; }
    %w = %{setupstring($datafolder, $lang, "$temporaname/$name.txt")};
  }

  if ($dayofweek > 0 && exists($w{"OratioW"}) && $rank < 5) {
    $w = $w{"OratioW"};
  } else {
    $w = $w{"Oratio"};
  }
  if ($hora =~ /Matutinum/i && exists($w{'Oratio Matutinum'})) { $w = $w{'Oratio Matutinum'}; }
  if (!$w) { $w = $w{"Oratio $ind"}; }

  if (!$w) {
    my %c = (columnsel($lang)) ? %commune : %commune2;
    my $i = $ind;
    $w = $c{"Oratio $i"};
    if (!$w) { $i = 4 - $i; $w = $c{"Oratio $i"}; }
    if (!$w) { $w = $c{Oratio}; }
  }
  if ($hora !~ /Matutinum/i) { setbuild($winner, "Oratio $ind", 'Oratio ord'); }
  my $i = $ind;

  if (!$w) {
    if ($i == 2) {
      $i = 3;
      $w = $w{"Oratio $i"};
    } else {
      $w = $w{'Oratio 2'};
    }
    if (!$w) { $i = 4 - $i; $w = $w{"Oratio $i"}; }
    if ($w && $hora !~ /Matutinum/i) { setbuild($winner, "Oratio $i", 'try'); }
  }

  # Special processing for Common of Supreme Pontiffs.
  if ($version !~ /Trident/i && (my ($plural, $class, $name) = papal_rule($w{Rule}))) {
    $w = papal_prayer($lang, $plural, $class, $name);
    if ($w && $hora !~ /Matutinum/i) { setbuild2("Oratio Gregem tuum"); }
  }

  if (!$w && $commune) {
    my %com = (columnsel($lang)) ? %commune : %commune2;
    my $ti = '';
    $w = $com{"Oratio"};

    if (!$w) {
      $ti = " $ind";
      $w = $com{"Oratio $ind"};
    }
    if ($w && $hora !~ /Matutinum/i) { setbuild2("$commune Oratio$ti"); }
  }

  if ($winner =~ /tempora/i && !$w) {
    my $name = "$dayname[0]-0";
    %w = %{officestring($datafolder, $lang, "$temporaname/$name.txt")};
    $w = $w{Oratio};
    if (!$w) { $w = $w{'Oratio 2'}; }
    if ($w) { setbuild2("Oratio Dominica"); }
  }

  #* deletes added commemoratio
  $comm_regex_str = "!(" . &translate('Commemoratio', $lang) . "|Commemoratio)";

  if (
    ($w =~ /(?<prelude>.*?)$comm_regex_str/is && $hora !~ /(laudes|vespera)/i)
    || ( $hora =~ /laudes/i
      && $w =~ /$comm_regex_str/i
      && $w =~ /(?<prelude>.*?)(precedenti|sequenti)/is)
    )
  {
    $w = $+{prelude};
    $w =~ s/\s*_$\s*//;
  }
  if (!$w) { $w = 'Oratio missing'; }

  #* limit oratio
  if ($rule !~ /Limit.*?Oratio/i) {
    if ($priest) {
      push(@s, "&Dominus_vobiscum");
    } elsif (!$precesferiales) {
      push(@s, "&Dominus_vobiscum");
    } else {
      our %prayers;
      my $text = $prayers{$lang}->{'Dominus'};
      my @text = split("\n", $text);
      push(@s, $text[4]);
      $precesferiales = 0;
    }
    my $oremus = translate('Oremus', $lang);
    push(@s, "v. $oremus");
  }

  if ($hora =~ /(Laudes|Vespera)/i && $winner{Rule} =~ /Sub unica conc/i) {
    if ($version !~ /1960|Monastic/i) {
      if ($w =~ /(.*?)(\n\$Per [^\n\r]*?\s*)$/s) { $addconclusio = $2; $w = $1; }
      if ($w =~ /(.*?)(\n\$Qui [^\n\r]*?\s*)$/s) { $addconclusio = $2; $w = $1; }
    } else {
      $w =~ s/\$(Per|Qui) .*?\n//;
    }
  }
  $w =~ s/^(?:v. )?/v. /;
  push(@s, $w);
  if ($rule =~ /omit .*? commemoratio/i) { return; }

  #*** SET COMMEMORATIONS
  our %cc = ();
  our $ccind = 0;
  our $octavcount = 0;

  #* add commemorated office from Sancti
  if (
       $hora =~ /(laudes|vespera)/i
    && $commemoratio1
    && ( $hora =~ /laudes/i
      || $version !~ /1960/
      || $rank < 6
      || $commemoratio1{Rank} =~ /Dominica|;;6/i
      || ($commemoratio1 =~ /Tempora/i && $commemoratio1{Rank} =~ /;;[23]/))
    )
  {
    $i = getind($commemoratio1, ($hora =~ /laudes/i) ? 2 : 3, $day);
    $w = getcommemoratio($commemoratio1, $i, $lang);
    my $num = concurrent_office($commemoratio1, 1, $day);
    if ($w) { setcc($w, $num, setupstring($datafolder, $lang, $commemoratio1)); }
  }

  if (
       $hora =~ /(laudes|vespera)/i
    && $commemoratio
    && ( $hora =~ /laudes/i
      || $version !~ /1960/
      || $rank < 6
      || $commemoratio{Rank} =~ /(Dominica|;;6)/i
      || ($commemoratio =~ /Tempora/i && $commemoratio{Rank} =~ /;;[23]/))
    )
  {
    $i = getind($commemoratio, ($hora =~ /laudes/i) ? 2 : $cvespera, $day);
    if ($i == 0) { $i = 1; }    #Christ the King on 10-31
    $w = getcommemoratio($commemoratio, $i, $lang);
    my $num = concurrent_office($commemoratio, 2, $day);
    if ($w) { setcc($w, $num, setupstring($datafolder, $lang, $commemoratio)); }
  }

  #transfervigil
  if ($hora =~ /Laudes/i && $transfervigil) {
    if (!(-e "$datafolder/$lang/$transfervigil")) { $transfervigil =~ s/v\.txt/\.txt/; }
    $w = vigilia_commemoratio($transfervigil, $lang);
    if ($w) { setcc($w, 3, setupstring($datafolder, $lang, $transfervigil)); }
  }

  #add commemoratio in winner for lauds or first vespers
  my $ci = $ind;

  if (
    $hora =~ /laudes/i
    || ($version !~ /1960/ && ($vespera == 1 || $winner =~ /tempora/i)
      || exists($winner{'Commemoratio 3'}))
    )
  {
    commemoratio('winner', $ci, $lang);
  }

  #commemoratio from commemorated office
  if ($hora =~ /vespera/i) { $ci = 4 - $ind; }

  if (
    $commemoratio
    && ( $version !~ /1960/ && $hora =~ /vespera/i && ($cvespera == 1 || $commemoratio =~ /Tempora/i)
      || $hora =~ /laudes/i)
    )
  {
    commemoratio('commemoratio', $ci, $lang);
  }

  if (
    $commemoratio1
    && (($version !~ /1960/ && $hora =~ /vespera/i && $vespera == 3)
      || $hora =~ /laudes/i)
    )
  {
    commemoratio('commemoratio1', $ci, $lang);
  }
  if ($commemorated && $version !~ /1960/) { commemoratio('commemorated', ($hora =~ /Laudes/i) ? 2 : 1, $lang); }

  if ($dayofweek != 0 && exists($commemoratio{'Oratio Vigilia'}) && $hora =~ /Laudes/i) {
    $w = vigilia_commemoratio($commemoratio, $lang);
    if ($w) { setcc($w, 3, setupstring($datafolder, $lang, $commemoratio)); }
  }
  my $key;
  if ($ordostatus =~ /Ordo/i) { return %cc; }

  foreach $key (sort keys %cc) {
    if (length($s[-1]) > 3) { push(@s, '_'); }
    if ($key >= 900) { push(@s, delconclusio($cc{$key})); }
  }

  if ((!checksuffragium() || $dayname[0] =~ /(Quad5|Quad6)/i || $version =~ /(1955|1960|monastic)/i)
    && $addconclusio)
  {
    push(@s, $addconclusio);
  }
}

sub getind {
  my ($office, $num, $day) = @_;
  if ($office !~ /Sancti/i) { return $num; }
  if ($hora =~ /Laudes/i) { return 2; }
  my $d = sprintf("-%02i", $day);
  if ($office =~ /$d.*\.txt/i) { return 3; }
  return 1;
}

#*** concurrent_office($office, $num, $day)
#returns 1 if the office is concurrent
sub concurrent_office {
  my ($office, $num, $day) = @_;
  my $d = sprintf("%02i", $day);
  if ($hora =~ /laudes/i) { return $num; }

  if ($office eq $winner && $vespera == 1 && $office =~ /$d.*\.txt/) {
    $num = 0;
  } elsif ($office eq $winner && $vespera == 3 && $office !~ /$d.*\.txt/) {
    $num = 0;
  } elsif ($office =~ /Sancti/i && $office !~ /$d.*\.txt/) {
    $num = 0;
  }
  return $num;
}

#*** setcc($str, $code, \%source) {
#set str with calculated code to %cc
sub setcc {

  my $str = shift;
  my $code = shift;
  my $s = shift;
  my %s = %$s;
  my $key = 90;
  our @dayname;
  our %winner;
  my @rank = split(';;', $winner{Rank});

  if ($s{Rank} =~ /Dominica/i && $code < 10) {
    $key = 10;
  }    #Dominica=10
  elsif ($s{Rank} =~ /;;Feria/i) {
    $key = ($s{Rank} =~ /;;[6]/) ? 20 : 50;
  }

  #{$key = ($dayname[0] =~ /Adv/i) ? 50 : 20;} #Feria major =  (Adv) ? 50 :20
  elsif (nooctnat() && ($s{Rank} =~ /infra Octav/i || $str =~ /octav/i)) {    #infra octavam=40
    $key = 40;
    $octavcount++;
    if ($version !~ /Trident/i && $octavcount > 1) { return; }
  } elsif ($s{Rank} =~ /Vigilia com/i || ($code % 10) == 3) {
    $key = 60;
  }    #vigilia communis
  elsif ($s{Rank} =~ /;;([2-7])/ && $code < 10) {
    $key = 30 + (8 - $1);
  } elsif ($s{Rank} =~ /;;1/ || $code >= 10) {
    $key = 80;
  }    #Simplex=80;
  if ($winner =~ /Tempora/i && $s{Rank} =~ /S\./) { $key = 90 + floor($code / 10); }    #*** commemorated main saint
  if ($s{Rule} =~ /Comkey=([0-9]+)/i) { $key = $1; }                                    #oct day Epi Cor = 20, simpl=70

  if ( $s{Rank} =~ /Octav.*?(Epiph|Corporis|Cordis|Ascension)/i
    || $str =~ /!.*?Octav.*?(Epiph|Corporis|Cordis|Ascension)/i)
  {
    $key = 20;
    $code = 0;
  } elsif ($s{Rank} =~ /Octav/i || $str =~ /!.*?Octav/i) {
    $key = 70;
    $code = 2;
  }

  if (($code % 10) != 1) {
    $key .= '0';
  }    #concurrent
  else { $key .= '1'; }    #occurrent
  $key .= "$ccind";

  if ($code == 0) {

    #$key = ($s{Rank} =~ /(Feria|Dominica)/i || $str !~ /Dominica.*?Nat/i) ? '099' : '098';
    #$key .= $ccind;}
    $key = '09' . floor($key / 1000) . $ccind;
  }
  $ccind++;
  $cc{$key} = $str;

  # Under the 1960 rubrics, on II. cl and higher days,
  # allow at most one commemoration. We use @rank rather
  # than $rank as sometimes the latter is adjusted for
  # calculating precedence.
  if ($version =~ /1960/ &&
    ($rank[2] >= 5 || ($dayname[1] =~ /Feria/i && $rank[2] >= 3)) &&
    $ccind > 1) {
    my @keys = sort(keys(%cc));
    %cc = ($keys[0] => $cc{$keys[0]});
    $ccind = 1;
  }
}

#*** commemoratio($winner, $ind, $lang)
# adds commemoratio from $winner office $ind= hora
sub commemoratio {
  my $item = shift;
  my $ind = shift;
  my $lang = shift;
  my $code = 10;

  if ( $rank > 6.51
    || ($version =~ /(1955|1960)/ && $winner{Rank} =~ /Dominica/i)
    || ($rank >= 6 && ($dayname[0] !~ /Pasc[07]/ || $dayofweek < 2) && $item !~ /winner/i))
  {
    return;
  }
  if ($hora !~ /(laudes|vespera)/i || ($rule =~ /no commemoratio/i && $item !~ /winner/i)) { return; }
  if ($hora =~ /vespera/i && $winner =~ /Sancti/i && $rank >= 5 && nooctnat()) { return; }
  my %w;

  if ($item =~ /winner/i) {
    %w = (columnsel($lang)) ? %winner : %winner2;
    $ite = $winner;
  } elsif ($item =~ /commemoratio1/i) {
    %w = %{officestring($datafolder, $lang, $commemoratio1)};
    $code = 11;
    $ite = $commemoratio1;
  } elsif ($item =~ /commemoratio/i) {
    %w = (columnsel($lang)) ? %commemoratio : %commemoratio2;
    $code = 12;
    $ite = $commemoratio;
  } elsif ($item =~ /commemorated/i) {
    %w = %{officestring($datafolder, $lang, $commemorated)};
    $code = 13;
    $ite = $commemorated;
  }
  if ($version =~ /1960/ && $w{Rule} =~ /nocomm1960/i) { return; }
  $ind = getind($ite, $ind, $day);
  my $w = '';

  if (exists($w{"Commemoratio $ind"})) {
    $w = getrefs($w{"Commemoratio $ind"}, $lang, $ind, $w{Rule});
    if ($ind == 1 && $item !~ /winner/i) { $code = 0; }
  } elsif (exists($w{Commemoratio})) {
    $w = getrefs($w{Commemoratio}, $lang, $ind, $w{Rule});
  }

  if ($hora =~ /Laudes/i && $dayofweek == 6 && exists($w{'Commemoratio Sabbat'}) && $version !~ /1960/) {
    $w = getrefs($w{'Commemoratio Sabbat'}, $lang, 2, $w{Rule});
  }

  if ($version =~ /1955|1960|Newcal|Monastic/i && $w =~ /!.*?(O[ckt]ta|Dominica)/i && nooctnat()) { return; }
  if ($version =~ /(1955|1960|Newcal)/ && $hora =~ /Vespera/i && $rank >= 5 && nooctnat()) { return; }
  if ($rank >= 5 && $w =~ /!.*?Octav/i && $winner =~ /Sancti/i && $hora =~ /Vespera/i && nooctnat()) { return; }

  if ( $w
    && $version =~ /1955|1960|Newcal/
    && $w =~ /!.*?Vigil/i
    && $ite =~ /Sancti/i
    && $ite !~ /(08\-14|06\-23|06\-28|08\-09)/)
  {
    return;
  }
  my $sday = get_sday($month, $day, $year);

  if ( $hora =~ /Vespera/i
    && $w
    && $ite =~ /Sancti/i
    && $ite =~ /$sday/
    && $w !~ /!.*Octav/i
    && ($ind != 3 || !exists($w{'Commemoratio 3'})))
  {
    return;
  }

  if ($w) {
    my $redn = setfont($largefont, 'N.');
    $w =~ s/ N\. / $redn /g;
    $w =~ s/\n!/\n!!/g;
    $w =~ s/!!Oratio/!Oratio/gi;
    $w =~ s/\$Oremus\s*\n(v. )?/\$Oremus\nv. /g;
    my @iw = split('!!', $w);

    foreach my $iw (@iw) {
      if (!$iw || $iw =~ /^\s*$/) { next; }
      if ($iw !~ /^!/) { $iw = "!$iw"; }
      setcc("$iw", $code, \%w);
    }
  }
}

sub getcommemoratio {

  my $wday = shift;
  my $ind = shift;
  my $lang = shift;
  my %w = %{officestring($datafolder, $lang, $wday, ($ind == 1) ? 1 : 0)};
  my %c = undef;

  if ($version =~ /Trident|Divino/i && $wday =~ /12-30/) { return ''; }

  if ($hora =~ /Vespera/i && $rank >= 5 && $w{Rank} =~ /;;1/ && $winner !~ /Tempora/i) {
    return '';
  }    #2nd class and commemorated simplex
  if ($rule =~ /no commemoratio/i && !($hora =~ /Vespera/i && $vespera == 3 && $svesp == 1)) { return ''; }

  if ( $version =~ /1960/
    && $hora =~ /Vespera/i
    && $ind == 3
    && $rank >= 6
    && $w{Rank} !~ /Adv|Quad|Passio|Epi|Corp|Nat|Cord|Asc|Dominica|;;6/i)
  {
    return '';
  }
  my @rank = split(";;", $w{Rank});
  if ($rank[1] =~ /Feria/ && $rank[2] < 2) { return; }    #no commemoration of no privileged feria

  if ( $rank[0] =~ /Infra Octav/i
    && $rank[2] < 2
    && $rank >= 5
    && $winner =~ /Sancti/i)
  {
    return;
  }                                                       #no commemoration of octava common in 2nd class
      #if ($rank[2] < 3 && $wday =~ /Sancti/i && $rank >= 6) {return;} #octava communi

  #my $lim = ($commemoratio =~ /tempora/i) ? 2 : 1;
  #if ($ind == 3 && $rank[2] < $lim) {return '';}
  if ($rank[3] =~ /(ex|vide)\s+(.*)\s*$/i) {
    my $file = $2;
    if ($w{Rule} =~ /Comex=(.*?);/i && $rank < 5) { $file = $1; }
    if ($file =~ /^C[0-9]+$/ && $dayname[0] =~ /Pasc/i) { $file .= 'p'; }
    $file = "$file.txt";
    if ($file =~ /^C/) { $file = "Commune/$file"; }
    %c = %{setupstring($datafolder, $lang, $file)};
  } else {
    %$c = {};
  }
  if (!$rank) { $rank[0] = $w{Name}; }    #commemoratio from commune
  my $o = $w{Oratio};
  if ($o =~ /N\./) { replaceNdot($w, $lang); }

  if (!$o && $w{Rule} =~ /Oratio Dominica/i) {
    $wday =~ s/\-[0-9]/-0/;
    $wday =~ s/Epi1\-0/Epi1-0a/;
    my %w1 = %{officestring($datafolder, $lang, $wday, ($i == 1) ? 1 : 0)};

    if (exists($w1{'OratioW'})) {
      $o = $w1{'OratioW'};
    } else {
      $o = $w1{'Oratio'};
    }
  }
  if (!$o) { $o = $w{"Oratio $ind"}; }
  if (!$o) { $i = 4 - $ind; $o = $w{"Oratio $i"}; }
  if (!$o) { $o = $c{"Oratio"}; }

  # Special processing for Common of Supreme Pontiffs.
  my $popeclass = '';
  my %cp = {};

  if ($version !~ /Trident/i && ((my $plural, $popeclass, my $name) = papal_rule($w{Rule}))) {
    $o = papal_prayer($lang, $plural, $popeclass, $name);
  }
  if (!$o) { return ''; }
  my $a = $w{"Ant $ind"};
  if (!$a) { $i = 4 - $ind; $a = $w{"Ant $i"}; }
  if (!$a) { $a = $c{"Ant $ind"}; }
  my $name = $w{Name};
  $a = replaceNdot($a, $lang, $name);
  if ($popeclass && $popeclass =~ /C/ && $ind == 3) { $a = papal_antiphon_dum_esset($lang); }

  if ($wday =~ /tempora/i) {
    if (
      $month == 12
      && ( ($hora =~ /vespera/i && $day >= 17 && $day <= 23)
        || ($hora =~ /laudes/i && ($day == 21 || $day == 23)))
      )
    {
      my %v = %{setupstring($datafolder, $lang, 'Psalterium/Major Special.txt')};

      if ($hora =~ /vespera/i) {
        $a = $v{"Adv Ant $day"};
      } else {
        $a = $v{"Adv Ant $day" . "L"};
      }
    }
  }
  if (!$a) { return ''; }
  postprocess_ant($a, $lang);
  my $v = $w{"Versum $ind"};
  if (!$v) { $i = 4 - $ind; $v = $w{"Versum $i"}; }
  if (!$v) { $v = $c{"Versum $ind"}; }
  if (!$v) { $v = getfrompsalterium('Versum', $ind, $lang); }
  if (!$v) { $v = 'versus missing'; }
  postprocess_vr($v, $lang);
  our %prayers;
  my $w = "!" . &translate("Commemoratio", $lang);
  $a =~ s/\s*\*\s*/ / unless ($version =~ /Monastic/i);
  $o =~ s/^(?:v. )?/v. /;
  $w .= " $rank[0]\nAnt. $a\n_\n$v\n_\n$prayers{$lang}->{Oremus}\n$o\n";
  return $w;
}

#*** vigilia_commemoratio($fname, $lang)
# gets commemoratio for vigila
sub vigilia_commemoratio {
  my $fname = shift;
  my $lang = shift;
  my $w = '';

  if ($version =~ /1955|1960/) {
    my $dt = sprintf("%02i-%02i", $month, $day);
    if ($dt !~ /(08\-14|06\-23|06\-28|08\-09)/) { return ''; }
  }
  if ($fname !~ /\.txt$/) { $fname .= '.txt'; }
  if ($fname !~ /(Tempora|Sancti)/i) { $fname = "Sancti/$fname"; }
  my %w = %{setupstring($datafolder, $lang, $fname)};

  if ($w{Rank} =~ /Vigilia/i) {
    $w = $w{Oratio};
  } elsif (exists($w{'Oratio Vigilia'})) {
    $w = $w{'Oratio Vigilia'};
  }
  if (!$w) { return ''; }
  my $c = "!Commemoratio Vigilia\n";
  if ($w =~ /(\!.*?\n)(.*)/s) { $c = $1; $w = $2; }
  my %p = %{setupstring($datafolder, $lang, 'Psalterium/Major Special.txt')};
  my $a = $p{"Day$dayofweek Ant 2"};
  my $v = $p{"Day$dayofweek Versum 2"};
  $a =~ s/\s*\*\s*/ /;
  $w = $c . "Ant. $a" . "_\n$v" . "_\n\$Oremus\n$w";
  return $w;
}

#*** minor_getname()
# returns the database hashname for minor horas from' minor special.txt' file
sub minor_getname {
  my $name =
      ($dayname[0] =~ /Adv/i) ? 'Adv'
    : ($dayname[0] =~ /(Quad5|Quad6)/i) ? 'Quad5'
    : ($dayname[0] =~ /Quad/i && $dayname[0] !~ /Quadp/i) ? 'Quad'
    : ($dayname[0] =~ /Pasc/i) ? 'Pasch'
    : ($dayofweek == 0 || ($dayname[1] =~ /Duplex/i && $dayname[1] !~ /(Dominica|Vigilia)/i)) ? 'Dominica'
    : 'Feria';
  return "$name $hora";
}

#*** major_getname
# returns the database hashname for vespera laudes from 'Major Special.txt' file
sub major_getname {
  my $flag = shift;
  my $name =
      ($dayname[0] =~ /Adv/i) ? 'Adv'
    : ($dayname[0] =~ /(Quad5|Quad6)/i) ? 'Quad5'
    : ($dayname[0] =~ /Quad/i && $dayname[0] !~ /Quadp/i) ? 'Quad'
    : ($dayname[0] =~ /Pasc/i) ? 'Pasch'
    : "Day$dayofweek";
  if ($version =~ /monastic/i && $flag) { $name .= 'M'; }
  $name .= " $hora";
  return $name;
}

#*** getproprium($name, $lang, $flag, $buidflag)
# returns $name item from tempora or sancti file
# if $flag and no item in the proprium checks commune
# if buildflag is set adds a composing libe to building scrip
sub getproprium {

  my $name = shift;
  my $lang = shift;
  my $flag = shift;
  my $buildflag = shift;
  my $w = '';
  my $c = 0;
  my $prefix = 0;
  my %w = (columnsel($lang)) ? %winner : %winner2;

  if (exists($w{$name})) {
    $w = tryoldhymn(\%w, $name);
    $c = ($winner =~ /sancti/i) ? 3 : 2;
  }

  if ($w) {
    if ($buildflag) { setbuild($winner, $name, 'subst'); }
    return ($w, $c);
  }

  if (!$w && $communetype && ($communetype =~ /ex/i || $flag)) {
    my %com = (columnsel($lang)) ? %commune : %commune2;

    if (exists($com{$name})) {
      $w = tryoldhymn(\%com, $name);
      $c = 4;
    }

    if (
        !$w
      && $commune =~ /Sancti/i
      && ( $commune{Rank} =~ /;;ex\s*(C[0-9a-z]+)/i
        || $commune{Rank} =~ /;;ex\s*(Sancti\/.*?)\s/i)
      )
    {
      my $fn = $1;
      my $cn = ($fn =~ /^Sancti/i) ? $fn : "$communename/$fn";
      my %c = %{setupstring($datafolder, $lang, "$cn.txt")};
      $w = tryoldhymn(\%c, $name, $w);
      $c = 4;
    }

    if ($w) {
      $w = replaceNdot($w, $lang);
      my $n = $com{Name};
      $n =~ s/\n//g;
      if ($buildflag) { setbuild($n, $name, 'subst'); }
    }
  }
  return ($w, $c);
}

#*** tryoldhymn(\%source, $name)
# search for HymnusM $name in the source
sub tryoldhymn {
  my $source = shift;
  my %source = %$source;
  my $name = shift;
  $name1 = $name;
  $name1 =~ s/Hymnus\S*/$&M/;

  if ($version =~ /(Monastic|1570|Praedicatorum)/i && $name =~ /Hymnus/i && exists($source{$name1})) {
    return $source{$name1};
  } else {
    return $source{$name};
  }
}

#*** getanthoras($lang)
# returns the [Ant $hora] item for the officium
sub getanthoras {
  my $lang = shift;
  my $tflag = ($version =~ /Trident|Monastic/i && $winner =~ /Sancti/i) ? 1 : 0;
  $tflag = 0 if ($winner =~ /SanctiM.01-(?:0[2-5789])|(?:1[12])/);

  my $ant = '';
  if ($rule !~ /Antiphonas horas/i && $communerule !~ /Antiphonas horas/i && !$tflag) { return ''; }
  if ($version =~ /(1960|Newcal)/ && ($dayofweek > 0 || $1 eq '1960') && $rank < 6) { return ''; }
  my %w = (columnsel($lang)) ? %winner : %winner2;
  my $w = $w{'Ant Laudes'};
  my $c = ($winner =~ /sancti/i) ? 3 : 2;

  if (!$w && ($communetype =~ /ex\s*/i || $version =~ /Trident|Monastic/i)) {
    my %com = (columnsel($lang)) ? %commune : %commune2;
    $w = $com{'Ant Laudes'};
    $c = 4;
  }
  my @ant = split('\n', $w);
  my $ind =
      ($hora =~ /prima/i) ? 0
    : ($hora =~ /tertia/i) ? 1
    : ($hora =~ /Sexta/i) ? 2
    : 4;
  if (@ant > 3) { $ant = $ant[$ind]; }
  return ($ant, $c);
}

#*** getantvers($item, $ind, $lang)
# returns {$item $ind] item, trying first from the proprium then from the psalterium
# $item = Ant Versum
# $ind = 1 = Vespera1, 2 = Laudes  3=Vespera2; as special: 0=matutinum, 4=completorium
sub getantvers {

  my $item = shift;
  my $ind = shift;
  my $lang = shift;
  our ($hora, $winner);
  my $w = '';
  my $c = 0;

  ($w, $c) = getproprium("$item $ind", $lang, 1, 1);

  if (!$w && $ind > 1) {
    my $i = 4 - $ind;
    ($w, $c) = getproprium("$item $i", $lang, 1, 1);
  }

  #if (!$w && $ind != 2) {($w, $c) = getproprium("$item 2", $lang, 1, 1);}
  #if (!$w && $ind == 2) {($w, $c) = getproprium("$item 3", $lang, 1, 1);}
  #if (!$w && $ind == 2) {($w, $c) = getproprium("$item 1", $lang, 1, 1);}
  #handle seant
  if (!$w && $hora =~ /Vespera/i && $item =~ /Ant/i && $winner =~ /Tempora\/Quadp[12]/i) {
    $w = getseant($lang);

    if ($w) {
      setbuild2("$item $ind ex praevio omitto");
      $c = 0;
    }
  }

  if (!$w) {
    $w = getfrompsalterium($item, $ind, $lang);
    $c = 0;
    setbuild2("$item $ind ex Psalterio");
  }

  if ($w) {
    if ($item =~ /Versum/i) {
      postprocess_vr($w, $lang);
    } else {
      postprocess_ant($w, $lang);
    }
  } else {
    $w = "$item $ind missing";
  }
  return ($w, $c);
}

#*** sub getseant($lang)
# chech Ant3 from Str$year file
sub getseant {
  my $lang = shift;
  my $w = '';
  my $ver =
      ($version =~ /monastic/i) ? 'M'
    : ($version =~ /1570/i) ? '1570'
    : ($version =~ /Trid/i) ? '1910'
    : ($version =~ /Newcal/) ? 'Newcal'
    : ($version =~ /1960/) ? '1960'
    : 'DA';

  if (my @a = do_read("$datafolder/Latin/Tabulae/Str$ver$year.txt")) {
    my $str = join('', @a);
    $str =~ s/\=/;;/g;
    $str =~ s/\s*//g;
    my %c = split(';;', $str);
    my $key = sprintf("seant%02i-%02i", $month, $day);
    my $d = $c{$key};
    my %w = %{setupstring($datafolder, $lang, "Tempora/$d.txt")};
    $w = $w{'Ant 3'};
  }
  return $w;
}

#*** geffrompsalterium($item, $ind, $lang)
# returns $item (antiphona/versum) $ind(1-3) from $lang/Psalterium/Major Special.txt
sub getfrompsalterium {
  my $item = shift;
  my $ind = shift;
  my $lang = shift;

  #get from psalterium
  my %c = %{setupstring($datafolder, $lang, 'Psalterium/Major Special.txt')};
  my $name = major_getname();
  $name =~ s/(Laudes|Vespera)/$item/i;
  my $w = $c{"$name $ind"};
  if (!$w) { $w = $c{"$name 1"}; }
  if (!$w) { $w = $c{"$name 3"}; }
  if (!$w) { $w = $c{"$name 2"}; }
  return $w;
}

#*** getfromcommune($name, $ind, $lang, $flag, $buildflag)
# collects and returns [$name $ind] item for the commemorated office from the commune
# if $flag ir collects for vide reference too
# if buildflag sets the building script item
sub getfromcommune {

  my $name = shift;
  my $ind = shift;
  my $lang = shift;
  my $flag = shift;
  my $buildflag = shift;
  my $c = '';

  if ($commemoratio{Rule} =~ /ex\s*(C[0-9]+[a-z]*)/) { $c = $1; }
  if ($commemoratio{Rule} =~ /vide\s*(C[0-9]+[a-z]*|Sancti\/.*?|Tempora\/.*?)(\s|\;)/ && $flag) { $c = $1; }
  if ($hora =~ /Prima/i && $rule =~ /(ex|vide)\s*(C[0-9]+[a-z]*|Sancti\/.*?|Tempora\/.*?)(\s|\;)/) { $c = $2; }
  if (!$c) { return; }

  if ($c =~ /^C/) {
    $c = "Commune/$c";
    my $fname = "$datafolder/$lang1/$c" . "p.txt";
    if ($dayname[0] =~ /Pasc/i && (-e $fname)) { $c .= 'p'; }
  }
  my %w = %{setupstring($datafolder, $lang, "$c.txt")};
  my $v = $w{$name};
  if (!$v) { $v = $w{"$name $ind"}; }
  if (!$v) { $ind = 4 - $ind; $v = $w{"$name $ind"}; }

  if ($v && $name =~ /Ant/i) {
    my $source = $w{Name};
    $source =~ s/\n//g;
    setbuild($source, "$name $ind", 'try');
  }
  return $v;
}

#*** setbuild1($label, $coment)
# set a red black line into building script
sub setbuild1 {
  if ($column != 1) { return; }    #to avoid duplication
  my $label = shift;
  my $comment = shift;
  $label =~ s/[\#\n]//g;
  $label = "$label";
  $buildscript .= setfont($redfont, $label) . " $comment\n";
}

#*** setbuild2(($comment)
# set a tabulated black line into building script
sub setbuild2 {
  if ($column != 1) { return; }
  my $comment = shift;
  $buildscript .= ",,,$comment\n";
}

#*** setbuild($line, $name, $vomment)
# set a headline into building script
sub setbuild {
  if ($column != 1) { return; }
  my $file = shift;
  my $name = shift;
  my $comment = shift;
  $source = $file;
  if ($source =~ /(.*?)\//s) { $source = $1; }

  if ($comment =~ /ord/i) {
    $comment = setfont($redfont, $comment);
  } else {
    $comment = ",,,$comment";
  }
  $buildscript .= "$comment: $source $name\n";
}

sub doxology {
  my $hymn = shift;
  my $lang = shift;
  my $dox = '';
  my $dname = '';

  if ($version !~ /1960/ || ($commune =~ /C1p/i && $hora =~ /Matutinum|Laudes|Vespera/i)) {
    if (exists($winner{Doxology})) {
      my %w = (columnsel($lang)) ? %winner : %winner2;
      $dox = $w{Doxology};
      setbuild2("Special doxology");
    } elsif ($rule =~ /Doxology=([a-z]+)/i) {
      $dname = $1;
    } elsif (($version =~ /Trident/i || $winner{Rank} !~ /Adventus/)
      && $commemoratio{Rule} =~ /Doxology=([a-z]+)/i)
    {
      $dname = $1;
    } elsif (($month == 8 && $day > 15 && $day < 23 && $version !~ /Monastic/i)
      || ($version != /1570/ && $month == 12 && $day > 8 && $day < 16 && $dayofweek > 0))
    {
      $dname = 'Nat';
    } else {
      my $d = ($dayname[0] =~ /Nat/) ? $dayname[0] : "$dayname[0]-$dayofweek";
      my $d1 = ($d =~ /Nat([0-9]+)/i) ? $1 : 0;

      if ($rule =~ /Doxology\=([a-z]+)/i) {
        $dname = $1;
      } elsif ($d =~ /Nat/i && ($d1 >= 25 || $d1 < 6)) {
        $dname = 'Nat';
      } elsif ($d =~ /Nat/i && $d1 >= 6) {
        $dname = 'Epi';
      } elsif ($d =~ /Pasc/i && $d ge 'Pasc1-0' && $d lt 'Pasc5-4') {
        $dname = 'Pasc';
      } elsif ($d =~ /Pasc/i && $d ge 'Pasc5-4' && $d lt 'Pasc7-0') {
        $dname = 'Asc';
      } elsif ($d =~ /Pasc/i && $d ge 'Pasc7-0') {
        $dname = 'Pent';
      }
    }
  }

  if ($dname) {
    my %w = %{setupstring($datafolder, $lang, 'Psalterium/Doxologies.txt')};
    if ($version =~ /Monastic|1570/i && $w{"${dname}T"}) { $dname .= 'T'; }
    $dox = $w{$dname};
    setbuild2("Doxology: $dname");
  }
  if (!$hymn) { return ($dox, $dname); }
  if ($dox && $hymn =~ /(.*?)\n\s*\*.*?[AÁ]men/si) { $hymn = "$1\n$dox"; }
  return $hymn;
}

#*** checksuffragium
# versions 1956 and 1960 exclude from Ordinarium
sub checksuffragium {
  if ($rule =~ /no suffragium/i) { return 0; }
  if (!$dayname[0] || $dayname[0] =~ /Adv|Nat|Quad5|Quad6/i) { return 0; }    #christmas, adv, passiontime omit
  if ($dayname[0] =~ /Pasc[07]/i) { return 0; }
  if ($winner =~ /sancti/i && $rank >= 3 && $seasonalflag) { return 0; }
  if ($commemoratio =~ /sancti/i && $commemoratio{Rank} =~ /;duplex/i && $seasonalflag) { return 0; }

  if ($winner{Rank} =~ /octav/i && $winner{Rank} !~ /post Octavam/i) {
    return 0;
  }                                                                       # && $winner{Rank} !~ /Feria/i) {return 0;}
  if ($commemoratio{Rank} =~ /octav/i) { return 0; }
  if ($octavcount) { return 0; }
  if ($winner =~ /C12/) { return 1; }
  if ($duplex > 2 && $version !~ /trident/i && $seasonalflag) { return 0; }
  return 1;
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

  while (
    $w =~ /
      (.*?)               # Prelude
      \@([a-z0-9\/\-]+?)  # Filename
      \:([a-z0-9 ]*)      # Item
      (?::(.*))?          # Substitutions
      (.*)                # Sequel
    /isx
    )
  {
    $before = $1;
    $file = $2;
    $item = $3;
    $after = $5;
    my $substitutions = $4;
    $item =~ s/\s*$//;

    if ($file =~ /^feria$/i) {
      %s = %{setupstring($datafolder, $lang, 'Psalterium/Major Special.txt')};
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
    %s = %{setupstring($datafolder, $lang, "$file.txt")};

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
      my $a = chompd($s{"Ant $ind"});
      if (!$a) { $a = "$file Ant $ind missing\n"; }
      my $v = chompd($s{"Versum $ind"});
      if (!$v) { $a = "$file Versus $ind missing\n"; }
      my $o = '';

      if ($item !~ /proper/) {
        my $i = $item;
        $i =~ s/\sgregem.*//i;
        $o = $s{$i};

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
      $w = $before . "_\nAnt. $a" . "_\n$v" . "_\n$o" . "_\n$after";
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

sub get_prima_responsory {
  my $lang = shift;
  my $key = '';
  if ($dayname[0] =~ /(Adv|Nat)/i) { $key = $1; }
  if ($dayname[0] =~ /Pasc/i) { $key = 'Pasch'; }

  if ( $rule =~ /Doxology=(Nat|Epi|Pasch|Asc|Corp|Heart)/i
    || $scriptura{Rule} =~ /Doxology=(Nat|Epi|Pasch|Asc)/i
    || ($version !~ /(1960|Newcal)/ && $scriptura{Rule} =~ /Doxology=(Nat|Epi|Pasch|Asc|Corp|Heart)/i)
    || ($version !~ /(1960|Newcal)/ && $commemoratio{Rule} =~ /Doxology=(Nat|Epi|Pasch|Asc|Corp|Heart)/i))
  {
    $key = $1;
  } elsif ($version !~ /1960/ && $month == 8 && $day > 15 && $day < 23) {
    $key = 'Nat';
  }
  if ($dayname[0] =~ /Pasc7/i) { $key = 'Pent'; }

  if ( ($version =~ /1960/ && $month == 12 && $day > 8 && $day < 16)
    || ($version !~ /Trident/i && $winner{Rank} =~ /Adventus/))
  {
    $key = 'Adv';
  }
  if ($version =~ /1960/ && $month == 1 && $day > 5 && $day < 14) { $key = 'Epi'; }
  if ($version =~ /1960/ && $key =~ /Corp/) { $key = ''; }
  if (!$key) { return ''; }
  my %t = %{setupstring($datafolder, $lang, 'Psalterium/Prima Special.txt')};
  return $t{"Responsory $key"};
}

#*** loadspecial($str)
# removes second part of antifones for non 1960 versions
# returns arrat of the string
sub loadspecial {
  my $str = shift;
  my @s = split("\n", $str);

  # Un-double the antiphons, except in 1960.
  unless ($version =~ /1960/) {
    my $i;
    my $ant = 0;

    for ($i = 0; $i < @s; $i++) {
      if (($ant & 1) == 0 && $s[$i] =~ /^(Ant\..*?)\*/) { $s[$i] = $1; }
      if ($s[$i] =~ /^Ant\./) { $ant++; }
    }
  }
  return @s;
}

#*** delconclusio($ostr)
# deletes the conclusio from the string
sub delconclusio {
  my $ostr = shift;

  # Stripped conclusion, perhaps to be added in again later.
  our $addconclusio;

  if ($ostr =~ s/^(\$(?!Oremus).*?(\n|$)((_|\s*)(\n|$))*)//m) {
    $addconclusio = $1;
  }
  return $ostr;
}

#*** replaceNdot($s, $lang)
# repleces N. with name in $s from %c
# return corrected string
sub replaceNdot {
  my $s = shift;
  my $lang = shift;
  my $name = shift;
  if ($s !~ /N\./) { return $s; }
  my %c = (columnsel($lang)) ? %winner : %winner2;
  if (!$name) { $name = $c{Name}; }

  if (!$name) {
    %c = (columnsel($lang)) ? %commemoratio : %commemoratio2;
    $name = $c{Name};
  }

  if ($name) {
    $name =~ s/[\r\n]//g;
    $s =~ s/N\. (et|and|és) N\./$name/;
    $s =~ s/N\./$name/;
  }
  return $s;
}
