# use strict;
# use warnings;
use utf8;

sub gethymn {
  my ($lang) = @_;
  my ($name, $hymn, $hymnsource, $versum, $dname, $cr);
  our ($hora, $version, $vespera, @dayname);
  my $section = translate('Hymnus', $lang);

  if ($hora eq 'Matutinum') {
    ($hymn, $name) = hymnusmatutinum($lang);
    $hymnsource = 'Matutinum' if (!$hymn);
    $section = '';
  } elsif ($hora eq 'Laudes' || $hora eq 'Vespera') {
    ($hymn, $name) = hymnusmajor($lang);
    $name = "Hymnus $name";
    $hymnsource = 'Major' if (!$hymn);
    $section = "_\n!$section";

    my $ind = $hora eq 'Laudes' ? 2 : $vespera;
    ($versum, $cr) = getantvers('Versum', $ind, $lang);
  } else {    # minor hours
    $name = "Hymnus $hora";
    $name =~ s/ / Pasc7 / if ($hora eq 'Tertia' && $dayname[0] =~ /Pasc7/);

    if ($hora eq 'Completorium' && $version =~ /^Ordo Praedicatorum/) {
      my %ant = %{setupstring($lang, 'Psalterium/Special/Minor Special.txt')};
      $versum = $ant{'Versum 4'};
      postprocess_vr($versum, $lang);
      my $tempname = gettempora('*');

      if ($tempname =~ /^(?:Quad5?|Pasch|Asc|Pent)$/) {
        $name .= " $tempname";
      }
    }
    $hymnsource = $hora eq 'Prima' ? 'Prima' : 'Minor';
    $section = '#' . $section;
  }

  if ($hymnsource) {
    my %h = %{setupstring($lang, "Psalterium/Special/$hymnsource Special.txt")};
    $name = tryoldhymn(\%h, $name);
    $hymn = $h{$name};
  }

  if ($version !~ /1960/ && $hymn =~ /\*/) {    # doxology needed
    my ($dox, $dname) = doxology($lang);
    if ($dname) { $hymn =~ s/\*.*/$dox/s }
    $section .= " {Doxology: $dname}"
      if ($dname && $section && ($dayname[0] !~ /Pasc7/ || ($hora ne 'Tertia' && $hora ne 'Vespera')));
  }

  $hymn =~ s/^(?:v\.\s*)?(\p{Lu})/v. $1/;       # add initial
  $hymn =~ s/\*\s*//g;                          # remove star
  $hymn =~ s/_\n(?!!)/_\nr. /g;                 # start stropha with red letter

  my $output = "$section\n$hymn";
  $output .= "_\n$versum" if $versum;
  $output;
}

sub hymnusmajor {
  our ($hora, $version, $vespera, @dayname, %winner, $day, $month, $year);
  my $lang = shift;
  my $hymn = '';
  my $name = 'Hymnus';
  $name .= checkmtv($version, \%winner) if $hora eq 'Vespera';
  $name = 'Hymnus'
    if (
      (!exists($winner{"$name Vespera"}) && ($vespera == 3 && !exists($winner{"$name Vespera 3"})))
      && (($vespera == 3 && exists($winner{'Hymnus Vespera 3'}))
        || exists($winner{'Hymnus Vespera'}))
    );

  if (hymnshift($version, $day, $month, $year)) {
    $name .= ' Matutinum' if $hora eq 'Laudes';
    $name .= ' Laudes' if $hora eq 'Vespera';
    setbuild2("Hymnus shifted");
  } else {
    $name .= " $hora";
  }

  my $cr = 0;

  if ($hora eq 'Vespera' && $vespera == 3) {
    ($hymn, $cr) = getproprium("$name 3", $lang, 1);
  }

  if ($version =~ /cist/i && $hora =~ /Vespera/i && $winner{Rule} =~ /C[45]/ && $winner{Rule} =~ /Hac die/i) {
    $name = "Hymnus Vespera Hac die";
  }
  if (!$hymn) { ($hymn, $cr) = getproprium("$name", $lang, 1); }

  if (!$hymn) {
    $name = gettempora('Hymnus major') . " $hora";
    $name .= ' hiemalis'
      if (
           $name =~ /Day0/i
        && ($name =~ /Laudes/i || $version =~ /cist/i)
        && ( $dayname[0] =~ /Epi[2-6]/
          || $dayname[0] =~ /Epi1/i && $version =~ /cist/i
          || $dayname[0] =~ /Quadp/i
          || $winner{Rank} =~ /Novembris/i
          || ($month < 5 && $version =~ /cist/i)
          || ($winner{Rank} =~ /Octobris/i && $version !~ /cist/i))
      );
    setbuild1('Hymnus', $name);
  }
  ($hymn, $name);
}

sub doxology {
  our ($version, $rule, @dayname, %winner, %winner2, %commemoratio, $day, $month, $year, $dayofweek);
  my $lang = shift;
  my $dox = '';
  my $dname = '';

  if (exists($winner{Doxology})) {
    my %w = columnsel($lang) ? %winner : %winner2;
    $dox = $w{Doxology};
    $dname = 'Special';
    setbuild2('Special doxology');
  } else {
    if ($rule && $rule =~ /Doxology=([a-z]+)/i) {
      $dname = $1;
    } elsif (($version =~ /Trident/i || $winner{Rank} !~ /Adventus/)
      && $commemoratio{Rule}
      && $commemoratio{Rule} =~ /Doxology=([a-z]+)/i)
    {
      $dname = $1;
    } elsif (($month == 8 && $day > 15 && $day < 23 && $version !~ /1955|1963/i)
      || ($version !~ /1570|1617|altovadensis/i && $month == 12 && $day > 8 && $day < 16 && $dayofweek > 0))
    {
      $dname = 'Nat';
    } else {
      $dname = gettempora('Doxology');
    }

    if ($dname) {
      my %w = %{setupstring($lang, 'Psalterium/Doxologies.txt')};
      if ($version =~ /Monastic|1570|Praedicatorum/i && $w{"${dname}T"}) { $dname .= 'T'; }
      $dox = $w{$dname};
      setbuild2("Doxology: $dname");
    }
  }

  ($dox, $dname);
}

1;
