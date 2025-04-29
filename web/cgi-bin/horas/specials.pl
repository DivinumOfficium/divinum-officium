use utf8;

# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office fills the chapters from ordinarium
$a = 4;

use DivinumOfficium::Directorium qw(dirge);

require "$Bin/specials/capitulis.pl";
require "$Bin/specials/hymni.pl";
require "$Bin/specials/orationes.pl";
require "$Bin/specials/preces.pl";
require "$Bin/specials/psalmi.pl";
require "$Bin/specials/specprima.pl";

#*** specials(\@s, $lang)
# input the array of the script for hora, and the language
# fills the content of the various chapters from the databases
# returns the text for further adjustment and print to sub horas
sub specials {
  my $s = shift;
  my $lang = shift;
  my $special = shift;
  $octavam = '';    #check duplicate commemorations
  my %w = columnsel($lang) ? %winner : %winner2;

  if ($column == 1) {
    my $r = $w{Rule};
    $r =~ s/\s*$//;
    $r =~ s/\n/ /sg;
    $buildscript =
      setfont($largefont, "$hora $date1") . "\n" . setfont($smallblack, "$dayname[1] ~ $dayname[2] : $r") . "\n";
  }

  my $i = $hora eq 'Laudes' ? ' 2' : $hora eq 'Vespera' ? " $vespera" : '';
  if (!$special && exists($w{"Special $hora$i"})) { return loadspecial($w{"Special $hora$i"}); }

  our @s = ();
  my @t = @$s;

  our $litaniaflag;
  my ($specialflag, $skipflag, $tind);

  while ($tind < @t) {
    $item = $t[$tind++];
    $item =~ s/\s*$//;

    if ($item !~ /^\s*\#/) {
      if (!$skipflag) { push(@s, $item); }
      next;
    }
    if ($skipflag) { push(@s, "\n"); }
    $label = $item;
    $skipflag = 0;

    # Handle replacement of the Chapter (etc.) with a versicle on those
    # occasions when this occurs. The 'Capitulum Versum 2' directive takes
    # precedence over the 'Omit' directive, and so we handle this first.
    if ( $item =~ /Capitulum/
      && $rule =~ /Capitulum Versum 2(.*);?$/im)
    {
      my $cv2hora = $1;

      next if $cv2hora =~ /nisi ad Laudes/i && $hora eq 'Laudes';

      unless (($cv2hora =~ /ad Laudes tantum/i && $hora ne 'Laudes')
        || ($cv2hora =~ /ad Laudes et Vesperas/i && $hora !~ /^(?:Laudes|Vespera)$/))
      {
        # Compline is a special case: there the Chapter is omitted, as the
        # verse appears later and is handled separately. That being so, we have
        # nothing to do here.
        if ($hora ne 'Completorium' || ($version =~ /Praedicatorum/ && $winner =~ /Pasc0/)) {
          my %c = columnsel($lang) ? %commune : %commune2;
          push(@s, '#' . translate('Versus in loco', $lang), $w{"Versum 2"} // $c{"Versum 2"}, '');
          setbuild1("Versus speciale in loco calpituli");
        }
        $skipflag = 1;
        next;
      }
    }

    # Omit this section if the rule says so.
    $item =~ /\#(.+?)(\s|$)/;
    my $ite = $1;

    if (
      $rule =~ /Omit.*? $ite/i
      && !(
           $item =~ /Capitulum/
        && $rule =~ /Capitulum Versum 2( etiam ad Vesperas)?/i
        && (($1 && $hora eq 'Vespera') || $hora eq 'Laudes')
      )
      && ($rule !~ /Omit ad Matutinum/ || $hora eq 'Matutinum')
    ) {
      $skipflag = 1;

      if ($item =~ /incipit/i && $version !~ /Cist|1955|196/i) {
        $comment = 2;
        setbuild1($ite, 'limit');
      } else {
        $comment = 1;
        setbuild1($label, 'omit');
      }
      setcomment($label, 'Preces', $comment, $lang) if ($rule !~ /Omit.*? $ite mute/i);

      if ( $item =~ /incipit/i
        && $version !~ /1955|196/
        && $winner !~ /C12/
        && !($version =~ /cist/i && $winner =~ /C9/))
      {
        if ($hora eq 'Laudes') {
          push(@s, '/:' . translate('Si Laudes', $lang) . ':/');
        } else {
          push(@s, '/:' . translate('secreto', $lang) . ':/');
        }
        push(@s, '$Pater noster', '$Ave Maria');
        if ($hora =~ /^(?:Matutinum|Prima)$/) { push(@s, '$Credo'); }
      }
      next;
    }

    # Prelude pseudo-item. Include it if it exists; otherwise drop it
    # entirely.
    if ($item =~ /Prelude/) {
      push(@s, $w{"Prelude $hora"}) if exists($w{"Prelude $hora"});
      next;
    }

    if ($rule =~ /Ave only/i && $item =~ /incipit/i) {
      setcomment($label, 'Preces', 2, $lang);

      while ($t[$tind] !~ /^\s*\#/) {
        if ($t[$tind] !~ /(Pater|Credo)/) {
          push(@s, $t[$tind]);
        } elsif ($t[$tind] =~ /Ave/) {
          push(@s, '$Ave Maria');
        }
        $tind++;
      }
      next;
    }

    if ($item =~ /Commemoratio officii parvi/) {
      my %mariae = %{setupstring($lang, 'CommuneM/C12.txt')};
      push(@s, $item, $mariae{"COP $hora"});
      next;
    }

    # Preces:
    if ($item =~ /preces/i) {
      $skipflag = !preces($item);    # check if Preces Feriales or Dominicales are to be said
      setcomment($label, 'Preces', $skipflag, $lang);
      setbuild1($item, $skipflag ? 'omit' : 'include');

      if ($precesferiales && $item =~ /Dominicales/i) {
        push(@s, '$rubrica Preces flexis genibus') unless $skipflag;
      }

      push(@s, getpreces($hora, $lang, $item =~ /Dominicales/)) unless $skipflag;
      next;
    }

    if ($item =~ /invitatorium/i) {
      invitatorium($lang);
      next;
    }

    if ($item =~ /psalm/i) {
      psalmi($lang);
      next;
    }

    if ($item =~ /Capitulum/i && $hora eq 'Prima') {
      push(@s, capitulum_prima($lang, $item =~ /Responsorium/i));
      next;
    }

    if ($item =~ /Lectio brevis/i && $hora eq 'Completorium') {
      my %lectio = %{setupstring($lang, 'Psalterium/Special/Minor Special.txt')};
      push(@s, $item, $lectio{'Lectio Completorium'});
      next;
    }

    if ($item =~ /Capitulum/i && $hora =~ /^(?:Tertia|Sexta|Nona|Completorium)$/i) {
      push(@s, translate($item, $lang)) if ($hora eq 'Completorium');
      push(@s, capitulum_minor($lang));
      next;
    }

    if ($item =~ /Capitulum/i && $hora =~ /^(?:Laudes|Vespera)$/) {
      push(@s, capitulum_major($lang));
    }

    if ($item =~ /Responsor/ && $version =~ /^Monastic/ && $hora =~ /^(?:Laudes|Vespera)$/) {
      if (my $resp = monastic_major_responsory($lang)) {
        push(@s, '_', $resp);
      }
    }

    if ($item =~ /Regula/i) {
      my $regula = regula($lang);
      push(@s, translate($label, $lang));
      push(@s, $regula);
      next unless $item =~ /Lectio brevis/i;
    }

    if ($item =~ /Lectio brevis/i && $hora eq 'Prima') {
      my ($b, $c) = lectio_brevis_prima($lang);
      $label = '' if $label =~ /regula/i;
      setcomment($label, 'Source', $c, $lang);

      if (!$label) {

        # Join the source of the Lectio brevis to the rubric describing its use outside of choir.
        my $comment = pop(@s);
        my $regula = pop(@s);
        $regula =~ s/\.?\:\/\s*$/ $comment:\//;
        push(@s, $regula);
      }
      push(@s, $b);
      next;
    }

    if ($item =~ /Hymnus/) {

      # Fills in Hymnus (and Versus if necessary)
      push(@s, gethymn($lang));
      next;
    }

    if ($item =~ /Canticum/) {
      canticum($item, $lang);
      next;
    }

    if ($item =~ /Oratio/) {

      # Normally we only handle the Oratio(nes) section at the hours other than
      # Prime and Compline, but during the Triduum, we do it for those hours,
      # too. The test for this case is somewhat oblique.
      my $prime_or_compline = ($hora =~ /^(?:Prima|Completorium)$/i);
      my $triduum = ($rule =~ /Limit.*?Oratio/);    # $winner =~ /Quad6-[4-6]/
      my %oratio_params;

      # Skip the usual stuff at Prime and Compline in the Triduum.
      if ($prime_or_compline && $triduum) {
        $skipflag = 1;
        $oratio_params{special} = 1;
      }

      # Ordo Praedicatorum includes some kind of preces in Laudes due triduum
      if ($triduum && $version =~ /Ordo Praedicatorum/ && $hora eq 'Laudes') {
        my $w = columnsel($lang) ? \%winner : \%winner2;
        push(@s, $w{'Preces ad Laudes'});
      }

      # Generate the prayer(s) together with the title.
      if (!$prime_or_compline || $triduum) {
        oratio($lang, $month, $day, %oratio_params);
        next;
      }
    }

    if ($item =~ /Suffragium/i && $hora =~ /^(?:Laudes|Vespera)$/) {
      if (!checksuffragium() || $dayname[0] =~ /(Quad5|Quad6)/i) {
        setcomment($label, 'Suffragium', 0, $lang);
        push(@s, "\n");
        setbuild1($item, 'omit');
        next;
      }
      my ($suffr, $c) = getsuffragium($lang);
      setcomment($label, 'Suffragium', $c, $lang);
      setbuild1("Suffragium$c", 'included');
      push(@s, $suffr);
      next;
    }

    if ($item =~ /Martyrologium/) {
      setcomment($label, 'Martyrologium', 0, $lang);
      push(@s, martyrologium($lang));
      push(@s, '', '$Pretiosa') unless $rule =~ /ex C9/;
      next;
    }

    if ($item eq '#Commemoratio defunctorum') {
      $item =~ s/.//;
      push @s, translate($label, $lang);
      my %ps = %{setupstring($lang, 'Psalterium/Special/Prima Special.txt')};
      push @s, $ps{$item};
      next;
    }

    if ($item =~ /Antiphona finalis/) {
      next if $litaniaflag || $specialflag;

      if ($version =~ /^Ordo Praedicatorum/) {
        push(@s, '#' . translate('Antiphonae finalis', $lang));
        push(@s, '$ant Salve Regina');
      } else {
        push(@s, '#' . translate('Antiphona finalis BMV', $lang));

        if ($version =~ /cist/i) {
          push(@s, '$ant Salve Regina');
        } elsif ($dayname[0] =~ /Adv|Nat/i
          || $month == 1
          || ($month == 2 && $day < 2)
          || ($month == 2 && $day == 2 && $hora !~ /Completorium/i))
        {
          push(@s, '$ant Alma Redemptoris Mater');
        } elsif (($month == 2 || $month == 3 || $dayname[0] =~ /Quad/i) && $dayname[0] !~ /Pasc/i) {
          push(@s, '$ant Ave Regina caelorum');
        } elsif ($dayname[0] =~ /Pasc/) {
          push(@s, '$ant Regina caeli');
        } else {
          push(@s, '$ant Salve Regina');
        }
      }
      push(@s, '&Divinum_auxilium');
      next;
    }

    #flag for Litaniae majores for St Marks day: for Easter Sunday (in 1960 also from Easter Monday) to Tuesday,
    my $flag = 0;

    if ($votive eq 'Hodie') {
      if ($month == 4 && $day == 25 && ($dayname[0] !~ /Pasc0/ || $dayofweek > 1)) { $flag = 1; }
      if ($month == 4 && $day == 27 && $dayname[0] =~ /Pasc0/ && $dayofweek == 2) { $flag = 1; }    #25 Sunday
      if ($version !~ /1960/ && $month == 4 && $day == 25 && $dayname[0] =~ /Pasc0/ && $dayofweek == 1) { $flag = 1; }
      if ($version =~ /1960/ && $month == 4 && $day == 26 && $dayname[0] =~ /Pasc0/ && $dayofweek == 2) { $flag = 1; }
      if ($rule =~ /Laudes Litania/i && $winner =~ /Sancti/ && $day != 25) { $rule =~ s/Laudes Litania//ig; }
    }

    # Insert the title.
    push(@s, translate($label, $lang));

    # The remaining special cases come *after* the title has been inserted.
    if (
         $item =~ /Conclusio/i
      && $hora eq 'Laudes'
      && ($month == 4 || $version !~ /1960/)
      && ( $rule =~ /Laudes Litania/i
        || $commemoratio{Rule} =~ /Laudes Litania/i
        || $scriptura{Rule} =~ /Laudes Litania/i
        || $flag)
    ) {
      my %w = %{setupstring($lang, 'Psalterium/Special/Preces.txt')};
      my $lname = $version =~ /Monastic/ ? 'LitaniaM' : 'Litania';
      if ($version =~ /1570/ && exists($w{LitaniaT})) { $lname = 'LitaniaT'; }
      push(@s, '$Domine exaudi', '&Benedicamus_Domino', '');
      my @lit = split("\n\n", $w{$lname});
      push(@lit, '', '');
      push(@s, @lit[0, -1, 1, -2, 2]);
      setbuild1($item, 'Litania omnium sanctorum');
      $skipflag = 1;
      $litaniaflag = 1;
    }

    # Special conclusions, e.g. on All Souls' day.
    if ($item =~ /Conclusio/ && $rule =~ /Special Conclusio/i) {
      my %w = columnsel($lang) ? %winner : %winner2;
      push(@s, $w{Conclusio});
      $skipflag = 1;
      $specialflag = 1;
    }

    # Set special conclusion when Office of the Dead follows.
    if ($item =~ /Conclusio/ && $commune !~ /C9/i && $votive !~ /C9/i) {
      my $dirge = dirge($version, $hora, $day, $month, $year);

      if (($dirge || ($winner{Rule} =~ /Vesperae Defunctorum/ && $vespera == 3))
        && $hora eq 'Vespera')
      {
        push(@s, prayer('DefunctV', $lang));
        setbuild1($item, 'Recite Vespera defunctorum');
        $skipflag = 1;
        $specialflag = 1;
      } elsif (($dirge || $winner{Rule} =~ /Matutinum et Laudes Defunctorum/)
        && $hora eq 'Laudes')
      {
        push(@s, prayer('DefunctM', $lang));
        setbuild1($item, 'Recite Officium defunctorum');
        $skipflag = 1;
        $specialflag = 1;
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

  if ($ind > -1) {
    if ($comment =~ /Source/i && $votive && $votive !~ /hodie/i) { $ind = 7; }
    $label = translate($label, $lang);
    my %comm = %{setupstring($lang, 'Psalterium/Comment.txt')};
    my @comm = split("\n", $comm{$comment});
    $comment = $comm[$ind];
    if ($prefix) { $comment = "$prefix $comment"; }

    if ($label =~ /\}\s*/) {
      $label =~ s/\}\s*$/ $comment}/;
    } else {
      $label .= "{$comment}";
    }
  }
  push(@s, $label);
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
  my %w = columnsel($lang) ? %winner : %winner2;

  if (exists($w{$name})) {
    $name = tryoldhymn(\%w, $name) if $name =~ /^Hymnus/;
    $w = $w{$name};
    $c = $winner =~ /Sancti/ ? 3 : 2;
  }

  if ($w) {
    if ($buildflag) { setbuild($winner, $name, 'proprium'); }
    return ($w, $c);
  }

  if (!$w && $communetype && ($communetype =~ /^ex/i || $flag)) {
    my %com = columnsel($lang) ? %commune : %commune2;
    my $cn = $commune;
    my $substitute =
        $name eq 'Nocturn 1 Versum' ? 'Versum 1'
      : $name eq 'Responsory TertiaM' ? 'Nocturn 1 Versum'
      : ($name eq 'Versum Tertia' || $name eq 'Responsory SextaM') ? 'Nocturn 2 Versum'
      : ($name eq 'Versum Sexta' || $name eq 'Responsory NonaM') ? 'Nocturn 3 Versum'
      : $name eq 'Versum Nona' ? 'Versum 2'
      : '';
    my $loopcounter = 0;

    while (!$w && $loopcounter < 5) {
      $loopcounter++;

      if (exists($com{$name})) {

        # if element exists in referenced Commune, go for it
        $name = tryoldhymn(\%com, $name) if $name =~ /^Hymnus/;
        $w = $com{$name};
        $c = 4;
        last;
      } elsif ($cn =~ /^C/i && $substitute && exists($com{$substitute})) {

        # for 1st Nocturn default to [Versum 1] for Commune files
        # for Versicle ad Nonam default to [Versum 2] for Commune files
        $w = $com{$substitute};
        $c = 4;
        $name .= " ex $substitute";
        last;
      } elsif ($cn !~ /^C/i
        && ($com{Rank} =~ /;;(ex|vide)\s*(C[0-9a-z]+)/i || $com{Rank} =~ /;;(ex|vide)\s*(SanctiM?\/.*?)\s/i))
      {
        # if Pseudo-Commune ex Sancti, ensure daisy-chained references work (max. 5 nested references)
        # vide only followed if $flag is set
        my $ctype = $1;
        last if $ctype eq 'vide' && !$flag;
        my $fn = $2;
        $cn = $fn =~ /^Sancti/i ? $fn : subdirname('Commune', $version) . "$fn";
        %com = %{setupstring($lang, "$cn.txt")};
        next;
      } else {
        last;
      }
    }

    if ($w) {
      $w = replaceNdot($w, $lang);
      my $n = $com{Officium} || $cn;
      $n =~ s/\n//g;
      if ($buildflag) { setbuild($n, $name, 'subst'); }
    }
  }
  return ($w, $c);
}

#*** tryoldhymn(\%source, $name)
# return if possible for oldversion, name of Hymnus section in source
sub tryoldhymn {
  my $source = shift;
  my $name = shift;
  my $name1 = $name;

  our ($version, $oldhymns);
  $name1 =~ s/Hymnus\S*/$&M/;

  ($oldhymns || ($version =~ /(Monastic|1570|Praedicatorum)/i)) && exists(${$source}{$name1}) ? $name1 : $name;
}

#*** checkmtv(version, winner)
# after "Cum Nostra Hac Aetate", the verse has always changed
sub checkmtv {
  my $version = shift;
  my $winner = shift;
  my %winner = %$winner;
  ($version =~ /1955|196/ || $winner{Rule} =~ /\;mtv/i) && $winner{Rule} =~ /C[45]/ ? '1' : '';
}

#*** getanthoras($lang)
# returns the [Ant $hora] item for the officium
sub getanthoras {
  my $lang = shift;
  my $tflag = ($version =~ /Trident|Monastic/i && $winner =~ /Sancti/i) ? 1 : 0;
  $tflag = 0 if ($version =~ /1963/ && $winner =~ /SanctiM?.01-(?:(?:0[2-5789])|(?:1[012]))/);

  my $ant = '';
  if ($rule !~ /Antiphonas horas/i && $communerule !~ /Antiphonas horas/i && !$tflag) { return ''; }
  if ($version =~ /(1960|Newcal)/ && ($dayofweek > 0 || $1 eq '1960') && $rank < 6) { return ''; }
  my %w = columnsel($lang) ? %winner : %winner2;
  my $w = $w{'Ant Laudes'};
  my $c = $winner =~ /Sancti/ ? 3 : 2;

  if (!$w && ($communetype =~ /ex\s*/i || $version =~ /Trident|Monastic/i)) {
    my %com = columnsel($lang) ? %commune : %commune2;
    $w = $com{'Ant Laudes'};
    $c = 4;
  }
  my @ant = split('\n', $w);
  my $ind =
      $hora eq 'Prima' ? 0
    : $hora eq 'Tertia' ? 1
    : $hora eq 'Sexta' ? 2
    : 4;
  $ind++ if $ind < 3 && $version =~ /cist/i;    # Cistercian: shift by 1 except ad Nonam
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
  if (!$w && $hora eq 'Vespera' && $item =~ /Ant/i && $winner =~ /Tempora\/Quadp[12]/i) {
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

  my $key = sprintf("seant%02i-%02i", $month, $day);

  if (my ($d) = get_stransfer($year, $version, $key)) {
    my %w = %{setupstring($lang, "Tempora/$d.txt")};
    $w = $w{'Ant 3'};
  }

  return $w;
}

#*** geffrompsalterium($item, $ind, $lang)
# returns $item (antiphona/versum) $ind(1-3/0) from $lang/Psalterium/Major Special.txt
sub getfrompsalterium {
  my $item = shift;
  my $ind = shift;
  my $lang = shift;

  #get from psalterium
  my %c = %{setupstring($lang, 'Psalterium/Special/Major Special.txt')};
  my $name = gettempora('getfrompsalterium major') . " $item";

  my $w = $c{"$name $ind"};
  if (!$w) { $w = $c{"$name 1"}; }
  if (!$w) { $w = $c{"$name 3"}; }
  if (!$w) { $w = $c{"$name 2"}; }
  return $w;
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

#*** setbuild($line, $name, $comment)
# set a headline into building script
sub setbuild {
  if ($column != 1) { return; }
  my $file = shift;
  my $name = shift;
  my $comment = shift;
  $source = $file;

  if ($source =~ /(.*?)\//s) {
    $source = $1 unless $1 =~ /Sancti/;
    $source =~ s/\.txt$//;
  }

  if ($comment =~ /ord/i) {
    $comment = setfont($redfont, $comment);
  } else {
    $comment = ",,,$comment";
  }
  $name = setfont('italic', $name);
  $buildscript .= "$comment: $source $name\n";
}

#*** checksuffragium
# versions 1956 and 1960 exclude from Ordinarium
sub checksuffragium {

  our $collectcount;
  my $ranklimit = ($version =~ /cist/i ? 4 : 3);    # Roman: Duplex; Cist: MM. maj.
  return 0
    if $rule =~ /no suffragium/i

    # early January
    || !$dayname[0]

    # Nativity, Hebd. maj., Octaves of Pasch and Pente, and Ascensiontide
    || $dayname[0] =~ /Nat|Quad6|Pasc[067]/i

    # Passiontide and Advent for non-Cistercian
    || $version !~ /cist/i && $dayname[0] =~ /Adv|Quad5/i

    # All Duplex (MM. maj.) Saints (except Patr. S. Joseph)
    || ($winner =~ /sancti/i && $rank >= $ranklimit && $seasonalflag)
    || ($winner =~ /tempora/i && $duplex > 2 && $seasonalflag)

    # Octaves
    || ($winner{Rank} =~ /octav/i && $winner{Rank} !~ /post Octavam/i)
    || ($octavcount || $commemoratio{Rank} =~ /octav/i)

    # Cistercian: minor Feasts of Apostles
    || $version =~ /cist/i && $commune =~ /C1a?$/i

    # Altovadensis: max 3. collects
    || $version =~ /altovadensis/i && $collectcount > 2

    # Altovadensis: limit at xij. Lect. et M.
    || $version =~ /altovadensis/i && $rank > 2.5;

  if ($commemoratio && $seasonalflag) {
    my @r = split(';;', $commemoratio{Rank});

    return 0
      if $r[2] >= $ranklimit
      || $commemoratio{Rank} =~ /in.*Octav/i
      || checkcommemoratio(\%commemoratio) =~ /octav/i;

    if (@commemoentries || @ccommemoentries) {
      my @cccentries = (@commemoentries, @ccommemoentries);

      foreach my $commemo (@cccentries) {
        if (!(-e "$datafolder/Latin/$commemo") && $commemo !~ /txt$/i) { $commemo =~ s/$/\.txt/; }
        my %c = %{officestring('Latin', $commemo, 0)};
        my @cr = split(";;", $c{Rank});

        return 0 if $cr[2] >= $ranklimit || $c{Rank} =~ /in.*Octav/i || checkcommemoratio(\%c) =~ /octav/i;

      }
    }
  }

  return 1;
}

#*** loadspecial($str)
# removes second part of antifones for non 1960 versions
# returns arrat of the string
sub loadspecial {
  local ($_) = shift;

  # Un-double the antiphons, except in 1960
  unless ($version =~ /196/) {
    s/^Ant\. .*?\K \* .*?$//ms;
  }
  split "\n";
}

#*** replaceNdot($s, $lang)
# repleces N. with name in $s from %c
# return corrected string
sub replaceNdot {
  my $s = shift;
  my $lang = shift;
  my $name = shift;
  if ($s !~ /N\./) { return $s; }
  my %c = columnsel($lang) ? %winner : %winner2;
  if (!$name) { $name = $c{Name}; }

  if (!$name) {
    %c = columnsel($lang) ? %commemoratio : %commemoratio2;
    $name = $c{Name};
  }

  # Safeguard against Secreta / Postcommunio from missa; switch for Doctor Antiphone
  my @name = split("\n", $name);

  if ($s =~ /^[OÓ],?\s/ && $name =~ /Ant\=/) {
    @name = grep(/Ant\=/, @name);
  } else {
    @name = grep(/Oratio\=/, @name) unless $name !~ /Oratio\=/;
  }
  $name[0] =~ s/^.*?\=//;

  if ($name[0]) {
    $name[0] =~ s/[\r\n]//g;
    $s =~ s/N\. .*? N\./$name[0]/;
    $s =~ s/N\./$name[0]/;
  }
  return $s;
}
