# use warnings;
# use strict;

sub lectio_brevis_prima {

  my $lang = shift;

  our ($version, %winner, %winner2, $communetype, %commune, %commune2, $winner, $commune);

  my %brevis = %{setupstring($lang, 'Psalterium/Prima Special.txt')};
  my $name = gettempora("Lectio brevis Prima");
  my $brevis = $brevis{$name};
  my $comment = $name =~ /per annum/i ? 5 : 1;

  setbuild('Psalterium/Prima Special', $name, 'Lectio brevis ord');

  #look for [Lectio Prima]
  if ($version !~ /1955|196/) {
    my %w = columnsel($lang) ? %winner : %winner2;
    my $b;

    if (exists($w{'Lectio Prima'})) {
      $b = $w{'Lectio Prima'};
      if ($b) { setbuild2("Subst Lectio Prima $winner"); $comment = 3; }
    }

    if (!$b && $communetype && $communetype eq 'ex' && exists($commune{'Lectio Prima'})) {
      $b = columnsel($lang) ? $commune{'Lectio Prima'} : $commune2{'Lectio Prima'};
      if ($b) { setbuild2("Subst Lectio Prima $commune"); $comment = 3; }
    }

    if (!$b && ($winner =~ /Sancti/ || ($commune && $commune =~ /C10/))) {
      $b = getfromcommune("Lectio", "Prima", $lang, 1, 1);
      if ($b) { $comment = 4; }
    }

    $brevis = $b || $brevis;
  }
  $brevis = prayer('benedictio Prima', $lang) . "\n$brevis" unless $version =~ /^Monastic/;
  $brevis .= "\n\$Tu autem";
  ($brevis, $comment);
}

sub capitulum_prima {

  my $lang = shift;
  my $withresponsory = shift;

  our ($dayofweek, $version, %winner, $commune, $rank, @dayname, $label, %winner2);

  my %brevis = %{setupstring($lang, 'Psalterium/Prima Special.txt')};

  my $key =
    (    $dayofweek > 0
      && $version !~ /196/
      && $winner{Rank} =~ /Feria|Vigilia/i
      && $winner{Rank} !~ /Vigilia Epi/i
      && (!$commune || $commune !~ /C10/)
      && ($rank < 3 || $dayname[0] =~ /Quad6/)
      && $dayname[0] !~ /Pasc/i) ? 'Feria' : 'Dominica';

  my $capit = $brevis{$key} . "\n\$Deo gratias\n_\n";
  setbuild1('Capitulum', "Psalterium $key");
  setcomment($label, 'Source', $key eq 'Feria', $lang);

  my @resp;

  if ($withresponsory) {
    @resp = split("\n", $brevis{'Responsory'});
    my $primaresponsory = get_prima_responsory($lang);
    my %wpr = columnsel($lang) ? %winner : %winner2;
    if (exists($wpr{'Versum Prima'})) { $primaresponsory = $wpr{'Versum Prima'}; }
    if ($primaresponsory) { $resp[2] = "V. $primaresponsory"; }
    push(@resp, "_");
  }

  push(@resp, split("\n", $brevis{Versum}));

  postprocess_short_resp(@resp, $lang);

  $capit . join("\n", @resp);
}

1;
