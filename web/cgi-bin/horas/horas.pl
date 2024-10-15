#!/usr/bin/perl
use utf8;

# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office
use FindBin qw($Bin);
use lib "$Bin/..";

use DivinumOfficium::LanguageTextTools
  qw(prayer translate omit_regexp suppress_alleluia process_inline_alleluias alleluia_ant ensure_single_alleluia ensure_double_alleluia);
use DivinumOfficium::Date qw(date_to_days days_to_date);

my $precesferiales;

$a = 1;

sub adhoram {
  my $hora = shift;
  my $head = "Ad $hora";
  $head =~ s/a$/am/;
  $head = 'Ad Vesperas' if $hora =~ /vesper/i;
  $head;
}

#*** horas($hora)
# collects and prints the officium for the given $hora
sub horas {
  my $command = shift;
  $hora = $command;
  $hora = 'Vespera' if $hora =~ /vesper/i;
  print "<H2 ID='${hora}top'>" . adhoram($hora) . "</H2>\n";
  my (@script1, @script2);
  our ($lang1, $lang2, $column);
  $column = 1;    # The 'setbuild' functions in specials.pl check for this to set the Building Script

  if ($Ck) {
    $version = $version1;
    precedence();
  }

  @script1 = getordinarium($lang1, $command);
  @script1 = specials(\@script1, $lang1);
  $column = 2;    # This prevents the duplications in the Building Script

  if ($Ck) {
    $version = $version2;
    load_languages_data($lang1, $lang2, $version, $missa);
    precedence();
  }

  if (!$only) {
    @script2 = getordinarium($lang2, $command);
    @script2 = specials(\@script2, $lang2);
  }

  print_content($lang1, \@script1, $lang2, \@script2, $version !~ /(1570|1955|196)/);
}

#*** resolve refs($text_of_block, $lang)
#resolves $name &name references and special characters
#retuns the to be listed text
sub resolve_refs {
  my $t = shift;
  my $lang = shift;
  my @t = split("\n", $t);

  #handles expanding for skeleton
  if ($expand =~ /skeleton/ && $expandind != $expandnum) {
    if ($t[0] =~ /\#/) {
      return setlink($t[0], $expandind, $lang);
    } else {
      return "";
    }
  }

  if ($t[0] =~ omit_regexp()) {
    $t[0] =~ s/^\s*\#/\!\!\!/;
  } else {
    $t[0] =~ s/^\s*(\#.*)(\{.*\})?\s*$/'!!' . substr(translate($1, $lang), 1) . $2/e;
  }
  my @resolved_lines;    # Array of blocks expanded from lines.
  my $merged_lines;      # Preceding continued lines.

  #cycle by lines
  for (my $it = 0; $it < @t; $it++) {
    $line = adjust_refs($t[$it], $lang);
    $line =~ s/\s+$//;
    $line =~ s/^\s+//;

    my $merge_with_next = ($line =~ s/~$//);

    #$ and & references
    if ($line =~ /^[\#\$\&]/) {
      $line =~ s/\.//g;

      #prepares reading the part of common w/ antiphona
      if ($line =~ /psalm/ && $it > 0 && $t[$it - 1] =~ /^\s*Ant\. /i) {
        $line = expand($line, $lang, $t[$it - 1]);

        # If the psalm has a cross, then so should the antiphon.
        @resolved_lines[-1] .= setfont($smallfont, " \x{2021}") if $line =~ /\x{2021}/;
      } else {
        $line = expand($line, $lang);
      }

      if ($line !~ /\<input/i) {
        $line = resolve_refs($line, $lang);
      }    #for special chars
    }

    # add dot if missing in Antiphona
    $line =~ s/(\w)$/$&./ if ($line =~ /^Ant\./);

    #red prefix
    if ($line =~ /^(R\.br\.|R\.|V\.|Ant\.|Benedictio\.|Absolutio\.)(.*)/) {
      my $h = setvrbar($1);
      my $l = $2;

      $h =~ s/(Benedictio|Absolutio)/ translate($1, $lang) /e;
      $line = setfont($redfont, $h) . $l;
    }

    #cross
    $line = setcross($line);

    #small omitted title
    if ($line =~ /^\!\!\!(.*)/) {
      $l = $1;
      $line = setfont($smallblack, $l);
    }

    #large chapter title
    elsif ($line =~ /^\!\!(.*)/) {
      my $l = $1;
      my $suffix = '';
      if ($l =~ s/(\{[^:].*?\})//) { $suffix = setfont($smallblack, $1); }
      $line = setfont($largefont, $l) . " $suffix\n";
      if ($expand =~ /skeleton/i) { $line .= linkcode1(); }
    }

    #red line
    elsif ($line =~ /^\!(.*)/) {
      $l = $1;
      my $suffix = '';
      if ($l =~ s/(\{[^:].*?\})//) { $suffix = setfont($smallblack, $1); }
      $line = setfont($redfont, $l) . " $suffix\n";
    }

    #first letter red
    elsif ($line =~ /^r\.\s*(.\.?)(.*)/) {
      $line = setfont($largefont, $1) . $2;
    }

    # first letter initial
    elsif ($line =~ /^v\.\s*(.*)/ || $line =~ /\{\:.*?\:\}\s*v\.\s*(.*)/) {
      $line = $1;
      $line = setfont($initiale, substr($line, 0, 1)) . substr($line, 1);
    }

    # rubrics - small red
    $line =~ s{/:(.*?):/}{setfont($smallfont, $1)}eg;

    # italic for mute vovels in hymns
    $line =~ s/\[([æaeiou]m?)\]/setfont('italic', $1)/eg;

    if ($merge_with_next) {
      $merged_lines .= $line . ' ';
    } else {
      push @resolved_lines, $merged_lines . $line;
      $merged_lines = '';
    }

  }    #line by line cycle ends

  # Concatenate the expansions of the lines with a line break between each.
  push @resolved_lines, '';
  my $resolved_block = join "<br/>\n", @resolved_lines;

  #removes occasional double linebreaks
  $resolved_block =~ s/<br\/>\s*<br\/>/<br\/>/ig;
  $resolved_block =~ s/<\/P>\s*<br\/>/<\/P>/ig;
  return $resolved_block;
}

#*** Septuagesima_vesp
# Determines whether we're saying first Vespers of Septuagesima Sunday.
sub Septuagesima_vesp {
  our ($dayofweek, @dayname, $hora, $vespera, $cwinner);
  return ($dayofweek == 6
      && $hora =~ /Vespera/i
      && (($vespera == 1 && $dayname[0] =~ /Quadp1/) || ($vespera == 3 && $cwinner =~ /Quadp1\-0/)));
}

#*** triduum_gloria_omitted
# Determines whether the Gloria at the end of the psalms should be omitted
# owing to the Triduum.
sub triduum_gloria_omitted() {
  our (@dayname, $dayofweek, $tvesp);

  # TODO: A much more elegant check would be to see what *today's office* is,
  # checking for Quad6-[456], but this information is not reliably available.
  return
       $dayname[0] =~ /Quad6/i
    && $dayofweek > 3
    && $tvesp != 1;
}

#*** getantcross($psalmline, $antline)
# set a	‡ sign if psalmline matches antline
# eliminating accents and pintuation
sub getantcross {

  my $psalmline = shift;
  my $antline = shift;
  my @psalmline = split(' ', $psalmline);
  my @antline = split(' ', $antline);
  my $pind = 0;
  my $aind = 0;

  $psalmline1 = $psalmline;
  $psalmline = '';
  $antline = '';

  while ($aind < @antline && $pind < @psalmline) {
    my $item1 = $psalmline[$pind];
    $pind++;
    $item1 = depunct($item1);
    if (!$item1) { next; }
    my $item2 = $antline[$aind];
    $aind++;
    $item2 = depunct($item2);
    if (!$item2) { $pind--; next; }
    if ($item1 !~ /$item2/i) { return $psalmline1; }
    $psalmline .= " $psalmline[$pind-1]";
  }

  # Don't place a dagger if the antiphon is longer than the verse.
  return $psalmline1 if ($aind < @antline && $pind == @psalmline);

  # Skip over any remaining punctuation.
  $psalmline .= ' ' . $psalmline[$pind++] while ($pind < @psalmline && !depunct($psalmline[$pind]));

  # Output dagger.
  $psalmline .= " \x{2021}";

  # Append rest of the verse.
  $psalmline .= ' ' . $psalmline[$pind++] while ($pind < @psalmline);
  return $psalmline;
}

sub depunct {
  my $item = shift;
  $item =~ s/[.,:?!"';*()]//g;
  $item =~ s/[áÁ]/a/g;
  $item =~ s/[éÉ]/e/g;
  $item =~ s/[íí]/i/g;
  $item =~ tr/Jj/Ii/;
  $item =~ s/[óöõÓÖÔ]/o/g;
  $item =~ s/[úüûÚÜÛ]/u/g;
  $item =~ s/æ/ae/g;
  $item =~ s/œ/oe/g;
  return $item;
}

sub settone {
  if (
    (
      $voicecolumn !~ /chant/i || ($hora =~ /Matutinum/i
        && !$chantmatins)
    )
    && !$notes
  ) {
    return '';
  }
  my $flag = shift;
  if (!$flag) { return " {::} "; }
  my $ind = 0;
  my $i = 0;
  my @parray;
  my $tone = '';

  if ($version =~ /Monastic/i) {
    if ($hora =~ /Matutinum/i) { return ''; }

    if ($hora =~ /(Laudes|Vespera)/i) {
      if ($flag != 2 && $psalmnum1 == 0) { return ' {:p9d:} '; }
      @parray = split("\n", $chant{"Monastic $hora"});
      my @a = split(',', $parray[$dayofweek]);
      my $j = ($flag == 2) ? -1 : $psalmnum1 - 1;
      return " {:p$a[$j]:} ";
    } else {
      @parray = split("\n", $chant{"Monastic Horas"});
      my $j =
          ($hora =~ /Prima/i) ? 0
        : ($hora =~ /Tertia/i) ? 1
        : ($hora =~ /Sexta/i) ? 2
        : ($hora =~ /Nona/i) ? 3
        : 4;
      my @a = split(',', $parray[$j]);
      return " {:p$a[$dayofweek]:}";
    }
  } elsif ($hora =~ /matutinum/i) {
    @parray =
        ($dayname[0] =~ /Pasc/i) ? split("\n", $chant{'Matins Pasc'})
      : ($dayname[0] =~ /Adv/i && $winner =~ /tempora/i && $dayofweek == 0) ? split("\n", $chant{'Matins Adv'})
      : split("\n", $chant{'Matins'});
    $i = $dayofweek;

    if ($version =~ /Trident/i && $winner{Rank} =~ /(ex|vide) C([0-9]+)/i) {
      my $n = $2;

      if ($n != 10) {
        if ($dayname[0] =~ /Pasc/i) { $n = 'p'; }
        @parray = split("\n", $chant{"Matins C$n"});
        $i = 0;
      }
    }
    $ind = $psalmnum1 - 1;

    if ($dayname[0] =~ /Pasc/i) {
      $ind = floor($ind / 3);
    } elsif ($version =~ /Trident/i && @parray > 1) {
      my @tridind =
          ($dayofweek == 0)
        ? (0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 4, 5, 6, 7, 8)
        : (0, 0, 1, 1, 3, 3, 4, 4, 6, 6, 7, 7);
      $ind = $tridind[$ind];
    }
  } else {
    my $d = ($rule =~ /psalmi dominica/i) ? 0 : $dayofweek;
    @parray = split("\n", $chant{"Day$d"});
    $i = ($hora =~ /laudes/i) ? 0 : ($hora =~ /vespera/i) ? 3 : 2;
    if ($hora =~ /laudes/ && $laudes == 2 && $flag == 1) { $i++; }
    $ind = ($flag == 1) ? $psalmnum1 - 1 : 5;
    my @tridind = (0, 1, 2, 2, 3, 4, 4, 4, 5);
    my @tridind0 = (0, 0, 0, 0, 3, 4, 4, 4, 5);

    if ($version =~ /Trid/i && $hora =~ /Laudes/i) {
      $ind = ($flag > 1) ? 5 : ($d > 0) ? $tridind[$ind] : $tridind0[$ind];
    }
  }
  my @a = split(',', $parray[$i]);
  my $j =
      ($hora =~ /(laudes|vespera|matutinum)/i) ? $ind
    : ($hora =~ /Prima/i) ? 0
    : ($hora =~ /Tertia/i) ? 1
    : ($hora =~ /Sexta/i) ? 2
    : ($hora =~ /Nona/i) ? 3
    : 4;
  $tone = $a[$j];
  return ($flag == 2) ? " {:pc$tone:} " : " {:p$tone:} ";
}

sub adjust_refs {
  use strict;
  my ($name, $lang) = @_;
  our ($rule, @dayname, $winner, $smallfont, $priest);

  if ($name =~ /\&Gloria/ && $rule =~ /Requiem gloria/i) {
    return '$Requiem';
  }

  if (
    ($name =~ /\&Gloria$/i && triduum_gloria_omitted())
    || ( $name =~ /\&Gloria[12]/i
      && $dayname[0] =~ /(Quad[56])/i)
    && $winner !~ /Sancti/i
    && $rule !~ /Gloria responsory/i
  ) {
    return setfont($smallfont, translate('Gloria omittitur', $lang));
  }

  if (
    !$priest
    && (($name =~ /&Dominus_vobiscum1/i && preces('Dominicales et Feriales'))
      || $name =~ /&Dominus_vobiscum2/i)
  ) {
    my $text = prayer('Dominus', $lang);
    my @text = split("\n", $text);
    return $text[4];
  }

  # No adjustment necessary.
  return $name;
}

#*** setlink($name, $ind, $lang
# sets a link for expand a skeleton chapter line or to call a popup
sub setlink {

  my $name = shift;
  my $ind = shift;
  my $lang = shift;
  my $disabled = ($name =~ omit_regexp()) ? 'DISABLED' : '';
  my $smallflag = ($name =~ /(ante|post)/i) ? 1 : 0;

  $name =~ s/\s*$//;
  my $item = $name;
  my $suffix = '';

  if ($name =~ /\{.*?\}/) {
    $name =~ s/(\{.*?\})//;
    $suffix = $1;
    $suffix = setfont($smallblack, $suffix);
  }
  my $t = linkcode($name, $ind, $lang, $disabled);

  if ($name =~ /Alleluia|Oremus|Deo gratias/i) {
    $t = '';
  }

  if ($name =~ /(Deus in adjutorium$|Indulgentiam|Te decet|Benedictio Prima2)/i) {
    $suffix = " + $suffix";
  }

  if ($name =~ /Domine[ _]labia/i) {
    $suffix = " ++ $suffix";
  }

  # Get index into translation table for the short text.
  $name = get_link_name($name);
  $name = translate($name, $lang) unless ($name =~ /^\#/);
  $name .= $suffix;
  $name =~ s/[\#\$\&]//g;
  my $after = '';

  if ($name =~ /(.*?)(<input.*)/i) {
    $name = $1;
    $after = $2;
  }

  if ($item =~ /Deo gratias/) {
    return $name;
  } elsif ($disabled || $smallflag) {
    $name = setfont($smallblack, $name);
  } elsif ($expand =~ /skeleton/i) {
    $name = setfont($largefont, substr($name, 0, 1)) . setfont($redfont, substr($name, 1));
  } else {
    $name = setfont($largefont, uc(substr($name, 0, 1))) . substr($name, 1);
  }
  return "$t$name$after";
}

sub get_link_name {
  my $name = shift;
  our $priest;
  our @dayname;
  our $hora;

  if ($name =~ /\&Gloria1/i) {
    $name = "\&gloria";
  } elsif ($name =~ /\&Gloria2/i) {
    $name = "\&Gloria";
  } elsif ($name =~ /&Dominus/i && !$priest) {
    $name = '&Domine exaudi';
  } elsif ($name =~ /&Dominus/) {
    $name =~ s/[12]//;
  } elsif ($name =~ /&Alleluia/i
    && $dayname[0] =~ /Quad/i
    && !Septuagesima_vesp())
  {
    $name = '&Laus tibi';
  } elsif (
    $name =~ /\&Benedicamus[_ ]Domino/i
    && (($dayname[0] =~ /(Pasc0)/i && $hora =~ /(Laudes|Vespera)/i)
      || Septuagesima_vesp())
  ) {
    $name = '&Benedicamus Domino alleluja';
  }
  return $name;
}

#*** ant_special($lang)
# return special ant. for canticum major hours & duplexflag;
sub ant123_special {
  my $lang = shift;

  my $ant, $duplexf;

  if ($month == 12 && ($day > 16 && $day < 24) && $winner =~ /tempora/i) {
    my %specials = %{setupstring($lang, 'Psalterium/Major Special.txt')};

    if ($hora eq 'Laudes' && ($day == 21 || $day == 23)) {
      $ant = $specials{"Adv Ant $day" . 'L'};
    } elsif ($hora eq 'Vespera') {
      $ant = $specials{"Adv Ant $day"};
      $duplexf = 1;
    }
  } elsif ($winner =~ /^Sancti/ && $version !~ /Trident/ && $vespera == 3) {

    # Special processing for Common of Supreme Pontiffs. Confessor-Popes
    # have a common Magnificat antiphon at second Vespers.
    my $popeclass;

    if (((undef, $popeclass, undef) = papal_rule($winner{Rule}))
      && $popeclass =~ /C/i)
    {
      $ant = papal_antiphon_dum_esset($lang);
      setbuild2('subst: Special Magnificat Ant. Dum esset');
    }
  }
  ($ant, $duplexf);
}

#*** canticum($psnum, $lang)
# returns the formatted text of Benedictus, Magnifificat or Nunc dimittis ($num=1-3)
# with antiphones
sub canticum {

  my $item = shift;
  my $lang = shift;

  our ($hora, $vespera);
  my $num =
      $hora eq 'Laudes' ? 2
    : $hora eq 'Completorium' ? 4
    : 3;

  my $ant, $ant2;
  my $duplexf = $version =~ /196/;

  if ($hora eq 'Completorium') {
    push(@s, '#' . translate(substr($item, 1), $lang));
    my ($w, $c) = getproprium("Ant 4$vespera", $lang, 1);

    if ($w) {
      setbuild1($ite, 'special');
      ($ant, $ant2) = split("\n", $w);
    } else {
      my %a = %{setupstring($lang, 'Psalterium/Minor Special.txt')};
      my $name;
      $name = gettempora('Nunc dimittis') if $version =~ /^Ordo Praedicatorum/;
      $ant = $a{"Ant 4$name"};

      if ($version =~ /^Ordo Praedicatorum/ && $name eq ' Quad3') {
        ($ant, $ant2) = split("\n", $ant);
        $ant2 = "$ant\n$ant2";
      }
    }
  } else {
    $comment = ($winner =~ /sancti/i) ? 3 : 2;
    setcomment($item, 'Source', $comment, $lang, translate('Antiphona', $lang));

    $duplexf ||= $duplex > 2;
    my $key = $num == 3 ? $vespera : $num;
    my $df;
    ($ant, $df) = ant123_special($lang);

    unless ($ant) {
      ($ant, $c) = getantvers('Ant', $key, $lang);
    } else {
      $duplexf ||= $df;
    }
  }
  my @psalmi = ("$ant;;" . (229 + $num));
  antetpsalm(\@psalmi, $duplexf, $lang);
  $s[-1] = "Ant. $ant2" if $ant2;
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
  } else {
    return ("$months[$month - 1] $day$sfx1 $year, the $gday$sfx2 day of the Moon,", $months[$month - 1]);
  }

  #return sprintf("%02i", $gday);
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
  } else {
    return ("$months[$month - 1] $day$sfx1 $year. The $dist$sfx2 day of the Moon.", $months[$month - 1]);
  }
}

#*** laudes()
# not used
sub laudes {
  return "skip";
}

#*** getordinarium($lang, $command)
# returns the ordinarium for the language and hora
sub getordinarium {
  my $lang = shift;
  my $command = shift;

  $command =~ s/Vesperae/Vespera/;
  if ($command =~ /Tertia|Sexta|Nona/i) { $command = 'Minor'; }    # identical for Terz/Sext/Non

  our $datafolder;
  my $fname = "$datafolder/Ordinarium/$command.txt";

  my @script = process_conditional_lines(do_read($fname));
  $error = "$fname cannot be opened or gives an empty script." unless @script;

  # Prelude pseudo-item.
  unshift @script, '#Prelude', '';
  return @script;
}

#*** setasterisk($line)
# stets the asterisk to a non pointed psalm verse line by line
sub setasterisk {
  my $line = shift;
  $line =~ s/\s*$//;
  if ($line =~ /\*(.*)/ && length($1) > 9) { return $line; }
  my $lp2 = (length($line) > 64) ? 24 : (length($line) < 24) ? 6 : 12;
  my $t = '';
  my $l = $line;

  if ($line =~ /(.*?)[\.\:\;\?\!](.*)$/ && length($2) > $lp2) {
    while ($l =~ /(.*)([\.\:\;\?\!])(.*?)$/) {
      $breaker = $2;
      $after = $3;
      $l = $1;

      if (length("$after$t") > $lp2) {
        if (length($l) > $lp2) { return "$l$breaker *$after$t"; }
        last;
      }
      $t = "$breaker$after$t";
    }
  }
  $t = '';
  $l = $line;
  my $b = ($line =~ /(.*?),(.*)$/ && length($2) > $lp2) ? ',' : ' ';

  while ($l =~ /(.*)($b)(.*?)$/) {
    $breaker = $2;
    $after = $3;
    $l = $1;
    if (length($l) < $lp2 && $b eq ',') { $b = ' '; $l = $line; $t = ''; next; }

    while ($breaker eq ' ' && length($l) > ($lp2 + 3) && $l =~ /(.*) (.*?)$/ && length($2) < 4) {
      $l = $1;
      $after = "$2 $after";
    }

    if (length("$after$t") > $lp2) {
      if ($after !~ /^ /) { $after = " $after"; }
      return "$l$breaker *$after$t";
    }
    $t = "$breaker$after$t";
  }
  if ($t !~ /^ /) { $t = " $t"; }
  return "$l *$t";
}

sub columnsel {
  my $lang = shift;
  if ($Ck) { return ($column == 1) ? 1 : 0; }
  return ($lang =~ /^$lang1$/i) ? 1 : 0;
}

#*** postprocess_ant($ant, $lang)
# Performs necessary adjustments to an antiphon.
sub postprocess_ant(\$$) {
  my ($ant, $lang) = @_;
  our (@dayname, $votive);

  # Don't do anything to null antiphons.
  return unless $$ant;
  ensure_single_alleluia($ant, $lang) if alleluia_required($dayname[0], $votive);
}

#*** postprocess_vr($vr, $lang)
# Performs necessary adjustments to a versicle and repsonse.
sub postprocess_vr(\$$) {
  my ($vr, $lang) = @_;
  our (@dayname, $votive);

  # Don't do anything to null v/r.
  return unless $$vr;

  if (alleluia_required($dayname[0], $votive)) {
    my ($versicle, $response) = split(/(?=^\s*R\.)/m, $$vr);
    ensure_single_alleluia(\$versicle, $lang);
    ensure_single_alleluia(\$response, $lang);
    $$vr = $versicle . "\n" . $response;
  }
}

#*** postprocess_short_resp(@capit, $lang)
# Performs necessary adjustments to a short responsory.
sub postprocess_short_resp(\@$) {
  my ($capit, $lang) = @_;
  s/&Gloria1?/&Gloria1/ for (@$capit);

  if ($dayname[0] =~ /Pasc/i) {
    my $rlines = 0;

    for (@$capit) {
      if (/^R\.br\./ ... (/^R\./ && ++$rlines >= 3)) {

        # Short responsory proper.
        if ((/^V\./ .. /^R\./) && /^R\./) {
          $_ = 'R. ' . prayer('Alleluia Duplex', $lang);
        } elsif (/^R\./) {
          ensure_double_alleluia(\$_, $lang);
        }
      } elsif (/^[VR]\./) {

        # V/R following short responsory.
        ensure_single_alleluia(\$_, $lang);
      }
    }
  }
}

#*** alleluia_required
# check if alleluia addition is required
# it is Paschaltide and not officium defunctorum or BMV Parv.
sub alleluia_required {
  my ($dayname, $votive) = @_;

  $dayname =~ /Pasc/i && $votive !~ /C(?:9|12)/;
}
