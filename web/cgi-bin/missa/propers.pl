#!/usr/bin/perl
use utf8;

# áéíóöõúüûÁÉæ ‡
# Name : Laszlo Kiss
# Date : 01-20-08
# Divine Office fills the chapters from ordinarium
use FindBin qw($Bin);
use lib "$Bin/..";

# Defines ScriptFunc and ScriptShortFunc attributes.
use horas::Scripting;
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

  if ($column == 1) {
    my $r = $w{Rule};
    $r =~ s/\s*$//;
    $r =~ s/\n/ /sg;
    $buildscript =
      setfont($largefont, "$hora $date1") . "\n" . setfont($smallblack, "$dayname[1] ~ $dayname[2] : $r") . "\n";
  }
  our @s = @$s;
  @t = splice(@t, @t);
  foreach (@s) { push(@t, $_); }
  @s = splice(@s, @s);
  $tind = 0;

  while ($tind < @t) {
    $item = $t[$tind];

    if ($item =~ /\&communicantes/ && $rule =~ /Communicantes/) {
      my %w = (columnsel($lang)) ? %winner : %winner2;
      $item = $w{Communicantes};
      while ($t[$tind] !~ /!!!/ && $tind < @t) { $tind++; }
      $tind--;
    }
    if ($item =~ /N\.p/) { $item = replaceNpb($item, $pope, $lang, 'p', 'o'); }
    if ($item =~ /N\.b/) { $item = replaceNpb($item, $bishop, $lang, 'b', 'o'); }
    $tind++;

    # Hooks.
    if ($item =~ /^\s*!&([a-z]+)\s*$/im) {

      # We use a string as a subroutine reference.
      no strict refs;

      # Run the hook, and omit this line from the output.
      &$1();
      next;
    }

    if ($item =~ /^\s*!\*/) {
      $skipflag = 0;
      if ($item =~ /!\*(\&[a-z]+)\s/i) { $skipflag = eval($1); }
      if ($item =~ /!\*[A-Z]*nD/ && $votive =~ /Defunct/i) { $skipflag = 1; }
      if ($item =~ /!\*S/ && !$solemn) { $skipflag = 1; }
      if ($item =~ /!\*R/ && $solemn) { $skipflag = 1; }
      if ($item =~ /!\*D/ && $votive !~ /Defunct/i) { $skipflag = 1; }

      if ($skipflag) {
        while ($tind < @t && $t[$tind] !~ /^\s*$/) { $tind++; }

        if ($tind < @t) {
          next;
        } else {
          last;
        }
      } else {
        next;
      }
    }
    my $section_regex = qr/^\s*#\s*(.*)/;

    if ($item =~ $section_regex) {
      $label = $1;

      if (
           ($rule =~ /omit.*\b$label\b/i)
        || (($version =~ /1570/) && ($item =~ / Le/))    # omit Leonine prayers issue #367
        )
      {
        # Skip omitted section
        $tind++ while ($tind < @t && $t[$tind] !~ $section_regex);
      } elsif ($label =~ /^\s*Evangelium\s*$/ && $rule =~ /^\s*Passio\s*$/m) {

        # Special form for the Passion. What ceremony there is is
        # embedded in the data file itself.
        push(@s, '#' . translate_label($label, $lang), '&evangelium');
        $tind++ while ($tind < @t && $t[$tind] !~ /^\s*$/);
      } else {
        $label = translate_label($label, $lang);
        push(@s, "#$label");
      }
      next;
    }
    if ($item !~ /^\s*!!/ && ($item !~ /^\s*!x!/ || $item =~ /!x!!/) && $item =~ /^\s*!/ && !$rubrics) { next; }
    $item =~ s/\(([^\n\r]*?)\)/ if ($rubrics) { setfont($smallfont,$1) } else { '_' } /egs;
    $item =~ s/N\./ setfont($largefont, 'N.') /eg;
    push(@s, $item);
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
  my %comm = %{setupstring($datafolder, $lang, 'Ordo/Comment.txt')};
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
# Finds the equivalent of the latin label in translate file
# Also changes 'Gradual' to 'Alleluja' during the Pascal season.
# TODO this inefficiently pulls the whole translate file every time!
sub translate_label {
  my $item = shift;
  my $lang = shift;
  $item =~ s/\s*$//;

  if ($lang !~ /Latin/i) {
    our %prayers;
    $item = exists(${$prayers{$lang}}{$item}) ? $prayers{$lang}->{$item} : $item;
  }

  if ($item =~ /Gradual/i) {

    #if ($dayname[0] =~ /Quad/i || (0 && $winner{Rank} =~ /(Quattuor|Quatuor)/i)) {$item = 'Graduale & Tractus';}
    #elsif ($dayname[0] =~ /Pasc/i && $winner !~ /Defunct/i) {$item = '#Alleluia';}
    if ($dayname[0] =~ /Pasc[1-5]/i && $winner !~ /Defunct/i) {
      $item = $lang =~ /Latin/i ? 'Alleluja' : 'Alleluia';
    }
  }
  $item =~ s/\n//g;
  return $item;
}

#*** oratio($lang, $type)
#input language
# collects and prints the appropriate oratio and commemorationes
# on ember days also includes all the additional lections
# since they intervene before the other commemmorations
sub oratio {

  my $lang = shift;
  my $type = shift;
  my $retvalue = '';
  our %cc = undef;
  our $ccind = 0;
  our $ctotalnum = 0;
  our $addconclusio = '';
  my %w = (columnsel($lang)) ? %winner : %winner2;

  $comment = ($winner =~ /sancti/i) ? 3 : 2;
  setcomment($label, 'Source', $comment, $lang);

  if ($rule =~ /Oratio Dominica/i && !exists($w{$type})) {
    my $name = "$dayname[0]-0";
    $name = 'Epi1-0a' if $name =~ /(Epi1|Nat)/i;
    %w = %{officestring($datafolder, $lang, "$temporaname/$name.txt")};
  }

  if ($dayofweek > 0 && exists($w{$type . "W"})) {
    $w = $w{$type . "W"};
  } else {
    $w = $w{$type};
  }

  if (!$w && $commune) {
    my %com = (columnsel($lang)) ? %commune : %commune2;
    $w = $com{$type};
    setbuild2("$commune Oratio") if $w;
  }

  # Special processing for Common of Supreme Pontiffs.
  if ($version !~ /Trident/i && (my ($plural, $class, $name) = papal_rule($w{Rule}))) {
    $w = papal_prayer($lang, $plural, $class, $name, $type);
    setbuild2("$type Gregem tuum");
  }

  if ($winner =~ /tempora/i && !$w) {
    my $name = "$dayname[0]-0";
    %w = %{officestring($datafolder, $lang, "$temporaname/$name.txt")};
    $w = $w{$type};
    setbuild2("$type Dominica") if $w;
  }
  $w = 'Oratio missing' unless $w;

  if (($version =~ /196/ || "$month$day" =~ /1102/)
    && $w =~ /(.*?)\&psalm\([0-9]+\)\s*\_\s*(.*)/is)
  {
    $w = "$1\_\n$2";    #triduum 1960  not 1955
  }
  my $sub_unica_conc = ($commemoratio{Rule} =~ /Sub unica conclusione in commemoratione/i)
    || ($winner{Rule} =~ /Sub unica concl(usione)?\s*$/mi);

  if ($sub_unica_conc) {
    if ($version !~ /196/) {
      if ($w =~ /(.*?)(\n\$Per [^\n\r]*?\s*)$/s) {
        $addconclusio = $2;
        $w = $1;
      }

      if ($w =~ /(.*?)(\n\$Qui [^\n\r]*?\s*)$/s) {
        $addconclusio = $2;
        $w = $1;
      }
    } else {
      $w =~ s/\$(Per|Qui) .*?\n//i;
    }
  }
  our %prayers;
  my $orm = '';

  # The Priest says Orémus except for Secreta prayers...
  $orm = "$prayers{$lang}->{Oremus}\n" unless $type =~ /Secreta/i;

  # ... and the Deacon says Flectamus for Oratio prayers during IV Temporum
  $orm .= "$prayers{$lang}->{Flectamus}\n" if $type =~ /Oratio/i && $rule =~ /LectioL/ && $dayname[0] !~ /Pasc/i;
  $retvalue = "$orm\n$w\n";
  $ctotalnum = 1;
  my $coron = '';

  if (my $tr = join('', do_read("$datafolder/../horas/Latin/Tabulae/Tr1960.txt"))) {
    my %tr = split('=|;;', $tr);

    # Override perpetual commemoration with this year's transfer table.
    if (my $yearly_transfer = join('', do_read("$datafolder/../horas/Latin/Tabulae/Tr1960$year.txt"))) {
      %tr = (%tr, split('=|;;', $yearly_transfer));
    }
    my $mm = sprintf("C%02i-%02i", $month, $day);
    $coron = $tr{$mm} if exists($tr{$mm});
  }

  if ($coron) {
    $retvalue =~ s/\$(Per|Qui) .*\n//g;
    my %c = %{setupstring($datafolder, $lang, "$coron.txt")};
    my $c = $c{$type};
    $c = replaceNpb($c, $pope, $lang, 'p', 'um') if $coron =~ /Coronatio/i;
    $retvalue .= "_\n\$Papa\n$c";
  }
  return resolve_refs($retvalue, $lang) if $rule =~ /omit .*? commemoratio/i || ($version =~ /196/ && $solemn);
  $w = '';
  our $oremusflag = "\_\n$prayers{$lang}->{Oremus}\n";
  $oremusflag = '' if $type =~ /Secreta/i || $sub_unica_conc;

  if (exists($w{'$type Vigilia'}) && ($version !~ /(1955|196)/ || $rule =~ /Vigilia/i)) {
    $w = "!Commemoratio vigilia\n";
    $w .= "!$type\n" . $w{"$type Vigilia"};
    $retvalue .= "$oremusflag$w\n";
    $oremusflag = "";
  }

  # add IV Temporum lectio/gradual/collect  (LectioLn) for the main oration
  if ($type =~ /Oratio/ && $rule =~ /LectioL/) {
    $retvalue .= LectionesTemporum($lang);
  }

  #* add commemorated office
  if ($commemoratio1 && $rank < 6) {
    $w = getcommemoratio($commemoratio1, $type, $lang);
    setcc($w, 1, setupstring($datafolder, $lang, $commemoratio1)) if $w;
  }

  if (
    $commemoratio
    && ( $rank < 6
      || $version !~ /(1955|196)/i
      || $commemoratio{Rank} =~ /(Dominica|;;6)/i
      || ($commemoratio =~ /Tempora/i && $commemoratio{Rank} =~ /;;[23]/))
    )
  {
    $w = getcommemoratio($commemoratio, $type, $lang);
    setcc($w, 2, setupstring($datafolder, $lang, $commemoratio)) if $w;
  }

  #add commemoratio in winner
  if (
    $rule !~ /nocomm1960/i
    && (
      (
        $version =~ /(1955|196)/
        && ($winner{'Commemoratio Oratio'} !~ /Octav/i || $winner{'Commemoratio Oratio'} =~ /Octav.*?Nativ/i)
      )
      || !($version =~ /(1955|196)/ && $rank >= 5)
    )
    )
  {
    commemoratio('winner', $type, $lang);

    if ($version !~ /196/ || $rank < 5) {

      #commemoratio from commemorated office
      commemoratio('commemoratio', $type, $lang) if $commemoratio;
      commemoratio('commemoratio1', $type, $lang) if $commemoratio1;
      commemoratio('commemorated', $type, $lang) if $commemorated && $version !~ /196/;
    }
  }
  $retvalue = getcc($retvalue);

  if ($version =~ /1955|196/ || !checksuffragium()) {
    $retvalue .= $addconclusio;
    return resolve_refs($retvalue, $lang);
  }
  $rule .= $1 if ($winner =~ /Sancti/i && $duplex < 3 && $scriptura && $scriptura{Rule} =~ /(Suffr.*?=.*?;;)/i);

  if ($rule =~ /Suffr.*?=(.*?);;/i) {
    my $sf = $1;
    my @sf = split(';', $sf);
    my %sf = %{setupstring($datafolder, $lang, 'Ordo/Suffragium.txt')};
    my ($sf1, @sf1);

    foreach $sf (@sf) {

      # No more than 3 commemorations TODO is this for all rubrics?
      last if $ctotalnum > 3;
      @sf1 = split(',', $sf);
      my $i = ($dayofweek % @sf1);
      $sf1[$i] = 'Maria3' if ($sf1[$i] =~ /Maria2/i && ($month > 2 || ($month == 2 && $day > 1)));
      $retvalue .= "_\n" . delconclusio($sf{"$type $sf1[$i]"});
    }
  }
  $retvalue .= $addconclusio;
  return resolve_refs($retvalue, $lang);
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

  # Under the 1960 rubrics, on II. cl and higher days,
  # allow at most one commemoration. We use @rank rather
  # than $rank as sometimes the latter is adjusted for
  # calculating precedence.
  return
    if ($version =~ /196/
    && ($rank[2] >= 5 || ($dayname[1] =~ /Feria/i && $rank[2] >= 3))
    && $ccind > 0
    && nooctnat());
  if ($version =~ /1955|196/ && $ccind >= 3) { return; }

  if ($s{Rank} =~ /Dominica/i && $code < 10) {
    $key = 10;
  }    #Dominica=10
  elsif ($s{Rank} =~ /;;Feria/i && $s{Rank} =~ /;;[23456]/) {
    $key = 50;
  }    #Feria major=50
  elsif ($s{Rank} =~ /infra Octav/i) {
    $key = 40;
  }    #infra octavam=4000
  elsif ($s{Rank} =~ /Vigilia com/i || ($code % 10) == 3) {
    $key = 60;
  }    #vigilia communis
  elsif ($s{Rank} =~ /;;([2-7])/ && $code < 10) {
    $key = 30 + (8 - $1);
  } elsif ($s{Rank} =~ /;;1/ || $code >= 10) {
    $key = 80;
  }    #Simplex=80;
  if ($s{Rule} =~ /Comkey=([0-9]+)/i) { $key = $1; }    #oct day Epi Cor = 20, simpl=70

  if (($code % 10) != 1) {
    $key .= '0';
  }                                                     #concurrent
  else { $key .= '1'; }                                 #occurrent
  $key .= "$ccind";
  $ccind++;
  $cc{$key} = $str;
}

#*** getcc($retvalue)
# adds the sorted items to retvalue
sub getcc {
  my $retvalue = shift;
  my $key;

  foreach $key (sort keys %cc) {
    if ($key > 999) { $retvalue .= delconclusio($cc{$key}); }
  }
  return $retvalue;
}

#*** commemoratio($item, $type, $lang)
# adds commemoratio from $winner office $ind= hora
sub commemoratio {
  my $item = shift;
  my $type = shift;
  my $lang = shift;
  my $code = 10;
  if ($rank > 6.9 || ($version =~ /(1955|196)/ && $winner{Rank} =~ /Dominica/i)) { return ''; }
  if ($rule =~ /no commemoratio/i) { return ''; }
  my %w;

  if ($item =~ /winner/i) {
    %w = (columnsel($lang)) ? %winner : %winner2;
    $ite = $winner;
  } elsif ($item =~ /commemoratio1/i) {
    %w = %{officestring($datafolder, $lang, $commemoratio1)};
    $code = 11;
    $ite = $commmemoratio1;
  } elsif ($item =~ /commemoratio/i) {
    %w = (columnsel($lang)) ? %commemoratio : %commemoratio2;
    $code = 22;
    $ite = $commemoratio;
  } elsif ($item =~ /commemorated/i) {
    %w = %{officestring($datafolder, $lang, $commemorated)};
    $code = 13;
    $ite = $commemoratio2;
  }
  my $w = '';
  $w = $w{"Commemoratio $type"} if exists($w{"Commemoratio $type"});
  if ($version =~ /(1955|196)/ && ($w =~ /!.*?(Octav|Dominica)/i && $w !~ /Octav.*?Nativ/i)) { return ''; }
  if ($version =~ /(1955|196)/ && $w =~ /!.*?Vigil/i && $rule =~ /no Vigil1960/i) { return ''; }

  if ( $w
    && $version =~ /1955|196/
    && $w =~ /!.*?Vigil/i
    && $ite =~ /Sancti/i
    && $ite !~ /(08\-14|06\-23|06\-28|08\-09)/)
  {
    $w = '';
  }

  if ($w) {
    my $redn = setfont($largefont, 'N.');
    $w =~ s/ N\. / $redn /g;
    setcc($w, $code, \%w);
  }
}

sub getcommemoratio {

  my $wday = shift;
  my $type = shift;
  my $lang = shift;
  my %w = %{officestring($datafolder, $lang, $wday)};
  my %c = undef;

  if ($rule =~ /no commemoratio/i) { return ''; }
  my @rank = split(";;", $w{Rank});
  if ($rank[1] =~ /Feria/ && $rank[2] < 2) { return; }    #no commemoration of no privileged feria

  if ($rank[3] =~ /(ex|vide)\s+(.*)\s*$/i) {
    my $file = $2;
    if ($file =~ /^C[0-9]+$/ && $dayname[0] =~ /Pasc/i) { $file .= 'p'; }
    $file = "$file.txt";
    if ($file =~ /^C/) { $file = "Commune/$file"; }
    %c = %{setupstring($datafolder, $lang, $file)};
  } else {
    %$c = {};
  }
  if (!$rank) { $rank[0] = $w{Name}; }                    #commemoratio from commune
  my $o = $w{$type};
  if (!$o) { $o = $c{$type}; }
  if ($o =~ /N\./) { replaceNdot($w, $lang); }

  if (!$o && $w{Rule} =~ /Oratio Dominica/i) {
    $wday =~ s/\-[0-9]/-0/;
    $wday =~ s/Epi1\-0/Epi1-0a/;
    my %w1 = %{officestring($datafolder, $lang, $wday, ($i == 1) ? 1 : 0)};

    if (exists($w1{$type . 'W'})) {
      $o = $w1{$type . 'W'};
    } else {
      $o = $w1{$type};
    }
  }

  # Special processing for Common of Supreme Pontiffs.
  if ($version !~ /Trident/i && (my ($plural, $class, $name) = papal_rule($w{Rule}))) {
    $o = papal_prayer($lang, $plural, $class, $name, $type);
  }
  if (!$o) { return ''; }
  $w = "! Commemoratio $rank[0]\nv. $o\n";
  return $w;
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
    $w = $w{$name};
    $c = ($winner =~ /sancti/i) ? 3 : 2;
  }

  if ($w) {
    if ($buildflag) { setbuild($winner, $name, 'subst'); }
    return ($w, $c);
  }

  if (!$w && $communetype && ($communetype =~ /ex/i || $flag)) {
    my %com = (columnsel($lang)) ? %commune : %commune2;

    if (exists($com{$name})) {
      $w = $com{$name};
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
      $w = $c{$name};
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

#setalleluia(@capit) set alleluia
sub setalleluia {
  my @capit = @_;

  if ($dayname[0] !~ /Pasc/i) {
    for ($i = 0; $i < @capit; $i++) {
      $capit[$i] =~ s/\&Gloria/\&Gloria1/;
    }
    return @capit;
  }
  my $i;
  my $flag = 0;

  for ($i = 0; $i < @capit; $i++) {
    if ($capit[$i] =~ /^R\.br/i) { $flag = 3; }
    if ($capit[$i] =~ /^V\./ && $flag == 3) { $flag = 4; next; }
    if ($capit[$i] =~ s/^&Gloria/&Gloria1/i) { $flag = 2; next; }
    if ($flag == 0) { next; }
    if ($capit[$i] =~ /(alleluia|alleluja)/i || $capit[$i] !~ /[RV]\./i) { next; }
    $capit[$i] = chompd($capit[$i]);

    if ($flag == 4) {
      $capit[$i] = 'R. Alleluia, alleluia';
      $flag = 3;
    } elsif ($flag > 1) {
      $capit[$i] .= " alleluia, alleluia\n";
    } else {
      $capit[$i] .= " alleluia.\n";
    }
    if ($flag == 2) { $flag = 1; }
  }
  return @capit;
}

#*** checksuffragium
# versions 1956 and 1960 exclude from Ordinarium
sub checksuffragium {
  if ($rule =~ /no suffragium/i) { return 0; }
  if (!$dayname[0] || $dayname[0] =~ /Quad5/i) { return 0; }    #christmas, passiontime omit
  if ($winner =~ /sancti/i && $rank >= 3 && $seasonalflag) { return 0; }
  if ($commemoratio =~ /sancti/i && $commemoratio{Rank} =~ /;duplex/i && $seasonalflag) { return 0; }
  if ($winner{Rank} =~ /octav/i && $winner{Rank} !~ /post Octavam/i) { return 0; }
  if ($duplex > 2 && $version !~ /trident/i && $seasonalflag) { return 0; }
  return 1;
}

#*** loadspecial($str)
# removes second part of antifones for non 1960 versions
# returns arrat of the string
sub loadspecial {
  my $str = shift;
  my @s = split("\n", $str);
  if ($version =~ /196/) { return (@s); }
  my $i;
  my $ant = 0;

  for ($i = 0; $i < @s; $i++) {
    if (($ant & 1) == 0 && $s[$i] =~ /^(Ant\..*?)\*/) { $s[$i] = $1; }
    if ($s[$i] =~ /^Ant\./) { $ant++; }
  }
  return @s;
}

#*** delconclusio($ostr)
# deletes the conclusio from the string
sub delconclusio {
  $ctotalnum++;
  if ($version =~ /(1955|196)/ && $rank >= 5 && $ctotalnum > 2) { return ""; }
  if ($version =~ /(196|196)/ && $ctotalnum > 3) { return ""; } # Fixme
  my $ostr = shift;
  my @ostr = split("\n", $ostr);
  $ostr = '';
  if ($oremusflag) { $ostr = $oremusflag; $oremusflag = ''; }
  my $line;

  foreach $line (@ostr) {
    if ($line =~ /^\$/ && $line !~ /\$Oremus/) {
      $addconclusio = "$line\n";
      next;
    }
    $ostr .= "$line\n";
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

sub replaceNpb {

  my $s = shift;
  my $pb = shift;
  my $lang = shift;
  my $let = shift;
  my $e = shift;
  my @pb = split(',', $pb);

  $pb = ($lang =~ /Latin/i) ? $pb[0] : ($lang =~ /English/i) ? $pb[1] : $pb[2];
  if ($lang =~ /Latin/i) { $pb =~ s/us$/$e/; }
  $s =~ s/N\.$let/$pb/g;
  return $s;
}

sub Gloria : ScriptFunc {
  my $lang = shift;
  if (DeTemporePassionis() && $rule !~ /Requiem gloria/) { return ""; }
  our %prayers;
  if ($rule =~ /Requiem gloria/i) { return $prayers{$lang}->{Requiem}; }
  return $prayers{$lang}->{'Gloria'};
}

sub getitem {
  my $type = shift;
  my $lang = shift;
  my %w = (columnsel($lang)) ? %winner : %winner2;
  my $w = $w{$type};
  if ($type =~ /Graduale/i && $dayname[0] =~ /Pasc/i && exists($w{GradualeP})) { $w = $w{'GradualeP'}; }
  if ($type =~ /Graduale/i && $dayname[0] =~ /Quad/i && exists($w{Tractus})) { $w = $w{'Tractus'}; }

  if (!$w) {
    %w = (columnsel($lang)) ? %commune : %commune2;
    $w = $w{$type};
    if ($type =~ /Graduale/i && $dayname[0] =~ /Pasc/i && exists($w{GradualeP})) { $w = $w{'GradualeP'}; }
    if ($type =~ /Graduale/i && $dayname[0] =~ /Quad/i && exists($w{Tractus})) { $w = $w{'Tractus'}; }
  }

  if (!$w && $winner =~ /Tempora/i) {
    my $name = "$dayname[0]-0";
    if ($name =~ /(Epi1|Nat)/i) { $name = 'Epi1-0a'; }
    if ($name =~ /Pent01/i) { $name = 'Pent01-0a'; }
    %w = %{officestring($datafolder, $lang, "$temporaname/$name.txt")};
    $w = $w{$type};
    if ($type =~ /Graduale/i && $dayofweek > 0 && exists($w{GradualeF})) { $w = $w{'GradualeF'}; }
  }
  if (!$w) { $w = "$type missing!\n" }

  #if ($type =~ /(Introitus|Offertorium!Communio)/) {
  if ($dayname[0] =~ /Pasc/i) {
    $w =~ s/\((Allel.*?)\)/$1/ig;
  } else {
    $w =~ s/\(Allel.*?\)//ig;
  }

  #}
  if ($w && $w !~ /^\s*$/) {
    $w =~ s/(?<!\() \( ([^()]*?) \) (?!\))/setfont($smallfont, $1)/egx;
    $w =~ s/\(\(/(/g;
    $w =~ s/\)\)/)/g;
  }
  return $w;
}

sub Vidiaquam : ScriptFunc {
  my $lang = shift;

  if ($solemn && $dayofweek == 0 && $votive !~ /Defunct/i) {
    our %prayers;
    my $name = ($dayname[0] =~ /Pasc/i) ? 'Vidi aquam' : 'Asperges me';
    my $w = $prayers{$lang}->{$name};
    return resolve_refs($w);
  } else {
    return '';
  }
}

sub Introibo {
  if ($votive =~ /Defunct/ || DeTemporePassionis()) { push(@s, "!omit. psalm"); return 1; }
  return 0;
}

sub gloriflag {
  my $flag = 1;
  if ($dayofweek == 0) { $flag = 0; }

  if ($rule =~ /no Gloria/i) {
    $flag = 1;
  } elsif ($rule =~ /Gloria/ || $communerule =~ /Gloria/i) {
    $flag = 0;
  } elsif ($votive && $votive =~ /Defunct/i) {
    $flag = 1;
  } elsif ($winner =~ /Sancti/) {
    $flag = 0;
  } elsif ($dayname[0] =~ /Adv|Quad/i) {
    $flag = 1;
  } elsif ($dayname[0] =~ /Pasc/) {
    $flag = 0;
  }
  return $flag;
}

# This Proper &LectionesTemporum handles ember day readings which precede the Collect
sub LectionesTemporum {
  my $lang = shift;

  # Generate nothing unless there's a LectioL rule.
  return '' if $winner{Rule} !~ /LectioL([0-9])/i;
  my $n = $1;
  my $i;
  my %w = (columnsel($lang) ? %winner : %winner2);
  my $s = '';

  for ($i = 1; $i <= $n; $i++) {
    $s .= "\n_\n#" . translate_label('Lectio', $lang) . "\n";
    $s .= $w{"LectioL$i"} . "\n_\n";

    if (exists($w{"GradualeL$i"})) {
      $s .= "\n#" . translate_label('Graduale', $lang) . "\n";
      $s .= $w{"GradualeL$i"} . "\n_\n";
    }
    $s .= "#" . translate_label('Oratio', $lang) . "\n";

    # (ultima oratio:) "Hic dicitur V. Dominus vobiscum, sine Flectamus genua."
    $s .= DominusVobiscum($lang, 1) if $i == $n;
    $s .= "\$Oremus\n";
    $s .= Flectamus($lang) if $i < $n && $dayname[0] !~ /Pasc/i;
    $s .= $w{"OratioL$i"} . "\n_\n_\n";
  }

  if ($s && $s !~ /^\s*$/) {
    $s =~ s/\((.*?)\)/setfont($smallfont, $1)/egs;
  }
  $s =~ s/#/!!/g;
  return $s;
}

sub GloriaM {
  my $flag = gloriflag();
  if ($flag) { push(@s, "!omit."); }
  return $flag;
}

sub Credo {
  my $flag = 1;
  if ($dayofweek == 0) { $flag = 0; }
  if ($rank >= 5 && $winner =~ /Sancti/ && $winner{Rank} !~ /Vigil/i) { $flag = 0; }

  if ( ($winner{Rank} =~ /Octav/i && $winner{Rank} !~ /post Octavam/i)
    || ($commemoratio{Rank} =~ /Octav/i && $commemoratio{Rank} !~ /post Octavam/i && $version !~ /196/))
  {
    $flag = 0;
  }

  if ($rule =~ /no Credo/i) {
    $flag = 1;
  } elsif ($rule =~ /Credo/i || $communerule =~ /Credo/i) {
    $flag = 0;
  }
  if ($version =~ /(1955|196)/ && $rule =~ /CredoDA/i) { $flag = 1; }
  if ($flag) { push(@s, "!omit."); }
  return $flag;
}

sub introitus : ScriptFunc {
  my $lang = shift;
  return getitem('Introitus', $lang);
}

sub collect : ScriptFunc {
  my $lang = shift;
  return oratio($lang, 'Oratio');
}

sub lectio : ScriptFunc {
  my $lang = shift;
  return getitem('Lectio', $lang) . "\$Deo gratias\n";
}

sub graduale : ScriptFunc {
  my $lang = shift;
  my $t = '';
  $t = getitem('Graduale', $lang);

  if (exists($winner{Sequentia})) {
    $t .= "_\n!!Sequentia\n" . getitem('Sequentia', $lang);
  } elsif ($communerule =~ /Sequentia/i && exists($commune{Sequentia})) {
    my %c = columnsel($lang) ? %commune : %commune2;
    $t .= "_\n!!Sequentia\n" . $c{Sequentia};
  }
  return $t;
}

sub evangelium : ScriptFunc {
  my $lang = shift;
  my $t = getitem('Evangelium', $lang);
  our ($rule, $version);

  if ($t && $t !~ /^\s*$/) {
    $t = "v. $t";
    $t =~ s/\n/\n\$Gloria tibi\n/ unless ($rule =~ /^\s*Passio\s*$/m);
    $t .= "\$Laus tibi\n" unless ($rule =~ /^\s*Passio\s*$/m && $version =~ /1955|196/);
  }

  if ($version =~ /(1955|196)/ && $rule =~ /Maundi/i) {
    my %w = columnsel($lang) ? %winner : %winner2;
    $t .= "_\n_\n" . norubr1($w{Maundi});
  }
  return $t;
}

sub offertorium : ScriptFunc {
  my $lang = shift;
  return getitem('Offertorium', $lang);
}

sub secreta : ScriptFunc {
  my $lang = shift;
  my $t = oratio($lang, 'Secreta');
  return "\n$t";
}

sub prefatio : ScriptFunc {

  my $lang = shift;
  my %pr = %{setupstring($datafolder, $lang, 'Ordo/Prefationes.txt')};
  my $name =
      ($version =~ /(1955|196)/ && $rule =~ /Prefatio1960=([a-z0-9]+)/i) ? $1
    : ($rule =~ /Prefatio=([a-z0-9]+)/i) ? $1
    : (($month == 12 && $day > 24) || ($month == 1 && $day == 1)) ? 'Nat'
    : ($month == 1 && $day > 5 && $day < 14) ? 'Epi'
    : ($dayname[0] =~ /Quad[1-4]/i) ? 'Quad'
    : ($dayname[0] =~ /Quad[56]/i) ? 'Quad5'
    : ($dayname[0] =~ /Pasc[0-4]/i || ($dayname[0] =~ /Pasc5/i && $dayofweek < 4)) ? 'Pasch'
    : (($dayname[0] =~ /Pasc5/i && $dayofweek > 3) || $dayname[0] =~ /Pasc6/i) ? 'Asc'
    : ($dayname[0] =~ /Pasc7/i) ? 'Spiritu'
    : ($winner{Rank} =~ /Beata.*?Maria.*?Virg/i) ? 'Maria'
    : ($communetpe =~ /^C1$/i) ? 'Apostolis'
    : ($votive =~ /Defunct/i) ? 'Defunctorum'
    : ($dayofweek == 0) ? 'Trinitate'
    : 'Communis';
  my $pref = $pr{$name};
  my %prw = (columnsel($lang)) ? %winner : %winner2;
  my $rr = $prw{Rule};

  if ($rr =~ /prefatio=(.*?)=(.*?);/i) {
    my $str = $2;
    $pref =~ s/\*.*?\*/$str/;
  } else {
    $pref =~ s/\*//g;
  }
  return norubr($pref);
}

sub norubr {
  my $t = shift;
  if ($rubrics) { return $t; }
  $t =~ s/!!/``/g;
  $t =~ s/\n!.*?\n/\n/g;
  $t =~ s/\n!.*?\n/\n/g;
  $t =~ s/``/!!/g;
  return $t;
}

# Routine for handling rubrics in special sections added to the Mass
# (preludes etc.).
sub norubr1($) {
  my $t = shift;

  if ($rubrics) {
    $t =~ s/\((.*?)\)/setfont($smallfont, $1)/ge;
  } else {
    $t =~ s/^\s*!(?!!).*?\n//gm;
    $t =~ s/\(.*?\)//g;
  }
  return $t;
}

sub communicantes($) : ScriptFunc {
  my $lang = shift;
  our $version;
  my $name;

  # We run various tests on $dayname[0].
  for ($dayname[0]) {

    # Do we have octaves of the Epiphany and the Ascension?
    my $have_octaves = ($version !~ /1955|196/);
    $name =
        (($month == 12 && $day > 24) || ($month == 1 && $day == 1)) ? 'Nat'
      : ($month == 1 && ($day == 6 || ($have_octaves && $day >= 7 && $day <= 13))) ? 'Epi'
      : (/Pasc0/) ? 'Pasc'
      : (  (/Pasc5/ && $dayofweek == 4)
        || ($have_octaves && ((/Pasc5/i && $dayofweek >= 5) || (/Pasc6/i && $dayofweek <= 4)))) ? 'Asc'
      : (/Pasc7/i || (/Pasc6/ && $dayofweek == 6)) ? 'Pent'
      : 'common';
  }
  my %pr = %{setupstring($datafolder, $lang, 'Ordo/Prefationes.txt')};
  if ($version =~ /196/) { $name .= '1962'; }    # St Joseph.
  my $t = chompd($pr{"C-$name"});
  return norubr($t);
}

sub hancigitur : ScriptFunc {
  my $lang = shift;
  if ($dayname[0] !~ /Pasc[07]/) { return ''; }
  my %pr = %{setupstring($datafolder, $lang, 'Ordo/Prefationes.txt')};
  my $t = chompd($pr{'H-Pent'});
  return norubr($t);
}

sub AgnusHook {
  our (@s, $rule);

  if ($rule =~ /ter miserere/i) {

    # At revised Holy Thursday Mass, "miserere nobis" is said thrice
    # at the Agnus Dei.
    @s[$#s] = @s[$#s - 1];
  }
}

# Check whether the prayer "Domine Jesu Christe, qui dixisti" should
# be omitted.
sub CheckQuiDixisti { our $votive =~ /Defunct/i || our $rule =~ /no Qui Dixisti/i; }
sub CheckPax { !(our $solemn) || our $votive =~ /Defunct/i || our $rule =~ /no Pax/i; }
sub CheckBlessing { our $votive =~ /Defunct/i || our $rule =~ /no Benedictio/i; }
sub CheckUltimaEv { our $rule =~ /no Ultima Evangelium/i; }

sub communio : ScriptFunc {
  my $lang = shift;
  return getitem('Communio', $lang);
}

sub Flectamus {
  my $lang = shift;
  our %prayers;
  return $prayers{$lang}->{Flectamus};
}

# DominusVobiscum returns the prayer unless in IV Tempora when it's not usually used
# the second argument 'opt' being true returns the prayer no matter what
sub DominusVobiscum : ScriptFunc {
  my $lang = shift;
  my $opt = shift || 0;
  our %prayers;

  # In missis IV temporum: "Post Kyrie, eleison, dicitur: Oremus. Flectamus genua. — Levate."
  return ($rule =~ /LectioL/ && !$opt) ? '' : "$prayers{$lang}->{'Dominus vobiscum'}";
}

sub postcommunio : ScriptFunc {
  my $lang = shift;
  my $str = oratio($lang, 'Postcommunio');
  if ($rule =~ /Super pop/i) { $str .= "_\n_\n" . getitem('Super populum', $lang); }
  return $str;
}

sub itemissaest : ScriptFunc {

  our ($version, $rule);
  my $lang = shift;
  our %prayers;
  my $text = $prayers{$lang}->{'IteMissa'};
  my @text = split("\n", $text);
  my $benedicamus = (gloriflag() && $version !~ /196/) || ($rule =~ /^\s*Benedicamus Domino\s*$/mi);

  return ($dayname[0] =~ /Pasc0/i) ? "$text[2]\n$text[3]" :    # Ite, missa est, alleluia, alleluia.
    ($votive =~ /Defunct/i) ? "$text[6]\n$text[7]" :           # Requiescant in pace.
    ($benedicamus) ? "$text[4]\n$text[5]" :                    # Benedicamus Domino.
    "$text[0]\n$text[1]";                                      # Ite, missa est.
}

# This function is now redundant: we never have reason to omit the Placeat.
sub placeattibi {
  return 0;
}

sub Communio_Populi : ScriptFunc {
  my $lang = shift;
  return htmlcall('Communio', $lang);
}

sub Ultimaev : ScriptFunc {
  my $lang = shift;
  my ($t, %p);

  if ($version =~ /(1955|196)/ || !exists($commemoratio{Evangelium})) {
    our %prayers;
    $t = $prayers{$lang}->{'Ultima Evangelium'};
  } else {
    %p = (columnsel($lang)) ? %commemoratio : %commemoratio2;
    $t = $p{Evangelium};
  }

  if ($t && $t !~ /^\s*$/) {
    $t =~ s/\((.*?)\)/setfont($smallfont, $1)/eg;
    $t =~ s/\n/\n\$Gloria tibi\n/;
    $t = "$t\$Deo gratias";
  }
  return $t;
}

sub DeTemporePassionis {
  our (@dayname, $winner, %winner);

  # We need a special check for the Seven Sorrows since this is
  # currently implemented as temporal, despite actually being
  # sanctoral. TODO: Fix this.
  return
       ($dayname[0] =~ /Quad5/i || ($dayname[0] =~ /Quad6/ && $dayofweek < 6))
    && $winner =~ /Tempora/i
    && $winner{'Rank'} !~ /Septem Dolorum/i;
}
