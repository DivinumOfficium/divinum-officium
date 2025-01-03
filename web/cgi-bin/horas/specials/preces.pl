# use strict;
# use warnings;
use utf8;

#*** preces($item)
# returns 1 = yes or 0 = omit after deciding about the preces
sub preces {
  my $item = shift;

  our (
    $winner, %winner, $rule, $duplex, $seasonalflag, @dayname,
    $version, $commemoratio, %commemoratio, @commemoentries, $hora, $dayofweek,
  );

  return 0
    if ( $winner =~ /C12/i
      || $rule =~ /Omit.*? Preces/i
      || ($duplex > 2 && $seasonalflag)
      || $dayname[0] =~ /Pasc[67]/i);

  our $precesferiales = 0;

  if ($item =~ /Dominicales/i) {
    my $dominicales = 1;

    if ($commemoratio) {
      my @r = split(';;', $commemoratio{Rank});

      if ($r[2] >= 3 || $commemoratio{Rank} =~ /Octav/i || checkcommemoratio(\%commemoratio) =~ /octav/i) {
        $dominicales = 0;
      } elsif (@commemoentries) {
        foreach my $commemo (@commemoentries) {

          if (!(-e "$datafolder/Latin/$commemo") && $commemo !~ /txt$/i) { $commemo =~ s/$/\.txt/; }
          my %c = %{officestring('Latin', $commemo, 0)};
          my @cr = split(";;", $c{Rank});

          if ($cr[2] >= 3 || $c{Rank} =~ /Octav/i || checkcommemoratio(\%c) =~ /octav/i) {
            $dominicales = 0;
          }
        }
      }
    }

    if ( $dominicales
      && ($winner{Rank} !~ /octav/i || $winner{Rank} =~ /post octav/i)
      && checkcommemoratio(\%winner) !~ /Octav/i)
    {
      $precesferiales = preces('Feriales');
      return 1;
    }
  }

  if (
       $item =~ /Feriales/i
    && $dayofweek
    && !($dayofweek == 6 && $hora eq 'Vespera')
    && (
      $winner !~ /sancti/i && ($rule =~ /Preces/i || $dayname[0] =~ /Adv|Quad(?!p)/i || emberday())    #
      || ($version !~ /1955|1960|Newcal/ && $winner{Rank} =~ /vigil/i && $dayname[1] !~ /Epi|Pasc/i)
    )    # certain vigils before 1955
    && ( $version !~ /1955|1960|Newcal/
      || $dayofweek =~ /[35]/
      || emberday())    # in 1955 and 1960, only Wednesdays, Fridays and emberdays
  ) {
    $precesferiales = 1;
    return 1;
  }

  return 0;
}

sub getpreces {
  my $hora = shift;
  my $lang = shift;
  my $flag = shift;    # 1 for 'Dominicales'

  use v5.10;
  state $precdomfer = $hora eq 'Prima';
  my ($src, $key);

  if ($hora =~ /^(?:Tertia|Sexta|Nona)$/) {
    $src = 'Minor';
    $key = 'Feriales';
  } elsif ($hora =~ /^(?:Laudes|Vespera)$/) {
    $src = 'Major';
    $key = "feriales $hora";
  } elsif ($hora eq 'Completorium') {
    $src = 'Minor';
    $key = 'Dominicales';
  } elsif ($flag) {    # $hora eq Prima
    $src = 'Prima';
    $key = 'Dominicales Prima ' . (($precdomfer + 1) % ($version =~ /^Monastic/ ? 1 : 2) + 1);
    $precdomfer++;
  } else {             # $hora eq Prima
    $src = 'Prima';
    $key = 'feriales Prima';
  }

  my %brevis = %{setupstring($lang, "Psalterium/Special/$src Special.txt")};
  $brevis{"Preces $key"};
}

1;
