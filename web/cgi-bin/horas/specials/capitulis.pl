# use warnings;
# use strict;
use utf8;

sub capitulum_major {
  my $lang = shift;

  our ($winner, $vespera, $seasonalflag, $version, $hora, $label);

  my $name = 'Capitulum Laudes';    # same for Vespera
                                    # special cases
  $name = 'Capitulum Vespera 1' if $winner =~ /12-25/ && $vespera == 1;
  $name = 'Capitulum Vespera' if $winner =~ /C12/ && $hora eq 'Vespera';

  setbuild('Psalterium/Special/Major Special', $name, 'Capitulum ord');

  my ($capit, $c) = getproprium($name, $lang, $seasonalflag, 1);
  if (!$capit && !$seasonalflag) { ($capit, $c) = getproprium($name, $lang, 1, 1); }

  if (!$capit) {
    my %capit = %{setupstring($lang, 'Psalterium/Special/Major Special.txt')};
    $name = gettempora('Capitulum major') . " $hora";
    $capit = $capit{$name};
  }

  if ($vespera == 1 && $version =~ /Ordo Praedicatorum/) {
    $capit .= "\n_\n" . monastic_major_responsory($lang);
  }

  setcomment($label, 'Source', $c, $lang);
  $capit;
}

sub monastic_major_responsory {
  my $lang = shift;

  our ($hora, $winner, $vespera, $seasonalflag, $version);

  my $key = "Responsory $hora";
  my ($resp, $c, $cistrv1f);

  # First Vespers can use special 'Responsory Vespera 1' (cist & OP)
  ($resp, $c) = getproprium("$key 1", $lang, $seasonalflag, 1) if $vespera == 1;

  if ($resp && $version =~ /Cist/) {

    # CIST: the Cistercian rite has Responsoria prolixa for every Festum Serm.
    # on j. Vespers. Of course, we need to limit it to Fest. Serm.
    $cistrv1f = $rank >= 5 || $ctrank[2] >= 5;
    $resp = '' unless $cistrv1f;
  }

  if (!$resp) {    # 'Responsory $hora'
    ($resp, $c) = getproprium($key, $lang, $seasonalflag, 1) unless $resp;
  }

  # Monastic Responsories at Major Hours are usually identical to Roman at Tertia and Sexta
  if (!$resp) {
    $key =~ s/Vespera/Breve Tertia/ if $version =~ /cist/i;
    $key =~ s/Laudes/Breve Sexta/ if $version =~ /cist/i;
    $key =~ s/Vespera/Breve Sexta/;
    $key =~ s/Laudes/Breve Tertia/;
    ($resp, $c) = getproprium($key, $lang, $seasonalflag, 1);
  }

  # For backwards compatability, look for the legacy "R.br & Versicle" if necessary
  if (!$resp) {
    $key =~ s/Breve //;
    ($resp, $c) = getproprium($key, $lang, $seasonalflag, 1);
  }

  # If no proper Responsory, take it from Psalterium
  if (!$resp) {
    my %resp = %{setupstring($lang, 'Psalterium/Special/Major Special.txt')};
    $name = 'Responsory ' . gettempora('Capitulum major') . " $hora";
    $resp = $resp{$name};
  }

  # For backwards compatibility, remove any attached versicle
  $resp =~ s/\n?_.*//s;

  if ($resp) {
    my @resp = split("\n", $resp);
    postprocess_short_resp(@resp, $lang) unless $cistrv1f;
    $resp = join("\n", @resp);
    $resp =~ s/\&gloria.*//gsi if $version =~ /cist/i;
  }

  $resp;
}

sub capitulum_minor {
  my $lang = shift;

  our ($hora, $version, $votive, $seasonalflag, $label, $item);

  my %capit = %{setupstring($lang, 'Psalterium/Special/Minor Special.txt')};
  my $name = gettempora('Capitulum minor') . " $hora";
  $name = 'Completorium' if $hora eq 'Completorium';
  my $capit = $capit{$name} =~ s/\s*$//r;
  my ($resp, $vers, $comment);

  $name .= 'M' if ($version =~ /Monastic/);
  $name =~ s/Quad/Quad3/ if $version =~ /Praedicatorum/ && $dayname[0] =~ /^Quad[34]/;

  if ($resp = $capit{"Responsory $name"}) {
    $resp =~ s/\s*$//;
    $capit =~ s/\s*$/\n_\n$resp/;
  } elsif (($resp = $capit{"Responsory breve $name"}) && ($vers = $capit{"Versum $name"})) {
    $vers =~ s/\s*$//;
    $resp =~ s/\s*$/\n_\n$vers/;
    $capit =~ s/\s*$/\n_\n$resp/;
  }

  if ($hora eq 'Completorium' && $version !~ /^Ordo Praedicatorum/) {
    $capit .= "\n_\n$capit{'Versum 4'}";
  } else {
    $comment = $name =~ /Dominica|Feria/ ? 5 : 1;
    setbuild('Psalterium/Special/Minor Special', $name, 'Capitulum ord');

    #look for special from prorium the tempore or sancti
    # use Laudes for Tertia apart C12
    my $key = "Capitulum $hora";
    $key =~ s/Tertia/Laudes/ if ($hora eq 'Tertia' && $votive !~ /C12/);
    my ($w, $c) = getproprium($key, $lang, $seasonalflag, 1);

    if ($w && $w !~ /\_\nR\.br/) {    # add responsory if missing
      $name = "Responsory $hora";
      $name .= 'M' if ($version =~ /Monastic/);    # getproprium subsitutes Nocturn 123 Versum only from Commune
      my ($wr, $cr) = getproprium($name, $lang, $seasonalflag, 1);

      if (!$wr) {

        # The Versicle in Monastic is usually taken from the 3 Nocturns in order
        my %replace = (
          Tertia => 'Nocturn 1 Versum',    # getproprium subsitutes Versum 1 only from Commune
          Sexta => 'Nocturn 2 Versum',
          Nona => 'Nocturn 3 Versum',
        );
        my $vers = '';

        if ($version !~ /Monastic/) {

          # The Short Response in Roman is usually composed of the Versicles of the 3 Nocturns
          # with the Versicle of the next Nocturn (Laudes being the "4th") attached
          %replace = (
            Tertia => 'Versum Tertia',    #	getproprium substitutes Nocturn 2 Versum only from Commune
            Sexta => 'Versum Sexta',      #	getproprium substitutes Nocturn 3 Versum only from Commune
            Nona => 'Versum Nona',        #	getproprium substitutes Versum 2 only from Commune
          );
          ($wr, $cr) = getproprium("Responsory Breve $hora", $lang, $seasonalflag, 1);
          $wr =~ s/\s*$/\n\_\n/ if $wr;
        }

        ($vers, $cvers) = getproprium($replace{$hora}, $lang, $seasonalflag, 1);
        $wr .= $vers;
      }
      $resp = $wr || $resp;
      $w =~ s/\s*$/\n_\n$resp/;
    }

    if ($w) {
      $capit = $w;
      $comment = $c;
    }
  }

  my @capit = split("\n", $capit);
  postprocess_short_resp(@capit, $lang);

  if ($hora ne 'Completorium') {
    setcomment($label, 'Source', $comment, $lang);
  }

  @capit;
}

1;
