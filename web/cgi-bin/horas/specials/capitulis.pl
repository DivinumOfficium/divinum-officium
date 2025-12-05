# use warnings;
# use strict;
use utf8;

sub capitulum_major {
  my $lang = shift;

  our ($winner, $vespera, $version, $hora, $label);

  my $name = 'Capitulum Laudes';    # same for Vespera
                                    # special cases
  $name = 'Capitulum Vespera 1' if $winner =~ /12-25/ && $vespera == 1;
  $name = 'Capitulum Vespera' if $winner =~ /C12/ && $hora eq 'Vespera';

  setbuild('Psalterium/Special/Major Special', $name, 'Capitulum ord');

  my ($capit, $c) = getproprium($name, $lang, 1);

  if (!$capit) {
    my %capit = %{setupstring($lang, 'Psalterium/Special/Major Special.txt')};
    $name = gettempora('Capitulum major') . " $hora";
    $capit = $capit{$name};
  }

  # GABC: Capitula are input in database acc. to Ant. Romanum
  # Shorter pause at Flexa in Ant. Monasticum
  $capit =~ s/†\(\;\)/†(,)/g if $lang eq 'Latin-gabc' && $version =~ /monastic/i;

  if ($vespera == 1 && $version =~ /Ordo Praedicatorum/) {
    $capit .= "\n_\n" . monastic_major_responsory($lang);
  }

  setcomment($label, 'Source', $c, $lang);
  $capit;
}

sub monastic_major_responsory {
  my $lang = shift;

  our ($hora, $winner, $vespera, $version);

  my $key = "Responsory $hora";
  my ($resp, $c, $cistrv1f);

  # First Vespers can use special 'Responsory Vespera 1' (cist & OP)
  ($resp, $c) = getproprium("$key 1", $lang, 1) if $vespera == 1;

  if ($resp) {
    if ($version =~ /Cist/) {

      # CIST: the Cistercian rite has Responsoria prolixa for every Festum Serm.
      # on j. Vespers. Of course, we need to limit it to Fest. Serm.
      $cistrv1f = $rank >= 5 || $ctrank[2] >= 5;
      $resp = '' unless $cistrv1f;

      if ($resp =~ /N\./) {
        my %w = columnsel($lang) ? %winner : %winner2;
        my $saint_name = $w{Name};

        if ($saint_name) {
          my @name = split("\n", $saint_name);

          if ($name =~ /Resp.*\=/) {
            @name = grep(/Resp.*\=/, @name);
          }
          $name[0] =~ s/^.*?\=//;

          if ($name[0]) {
            $name[0] =~ s/[\r\n]//g;
            $resp =~ s/N\. .*? N\./$name[0]/;
            $resp =~ s/N\./$name[0]/;
          }
        }
      }
    } else {
      my @resp = split("\n", $resp);
      $resp .= "\n&Gloria1\n$resp[3]" if @resp == 4;
    }
  }

  if (!$resp) {    # 'Responsory $hora'
    ($resp, $c) = getproprium($key, $lang, 1) unless $resp;
  }

  # Monastic Responsories at Major Hours are usually identical to Roman at Tertia and Sexta
  if (!$resp) {
    $key =~ s/Vespera/Breve Tertia/ if $version =~ /cist/i;
    $key =~ s/Laudes/Breve Sexta/ if $version =~ /cist/i;
    $key =~ s/Vespera/Breve Sexta/;
    $key =~ s/Laudes/Breve Tertia/;
    ($resp, $c) = getproprium($key, $lang, 1);
  }

  # For backwards compatability, look for the legacy "R.br & Versicle" if necessary
  if (!$resp) {
    $key =~ s/Breve //;
    ($resp, $c) = getproprium($key, $lang, 1);
  }

  # If no proper Responsory, take it from Psalterium
  if (!$resp) {
    my %resp = %{setupstring($lang, 'Psalterium/Special/Major Special.txt')};
    $name = 'Responsory ' . gettempora('Capitulum major') . " $hora";
    $resp = $resp{$name};
  }

  # For backwards compatibility, remove any attached versicle (safeguard \n for GABC)
  $resp =~ s/\n?_\n.*//s;

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

  our ($hora, $version, $votive, $label, $item);

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

    if ($version !~ /Ordo Praedicatorum/ || $dayname[1] !~ /Dominica/) {

      #look for special from prorium the tempore or sancti
      # use Laudes for Tertia apart C12
      my $key = "Capitulum $hora";
      $key =~ s/Tertia/Laudes/ if ($hora eq 'Tertia' && $votive !~ /C12/);
      my ($w, $c) = getproprium($key, $lang, 1);

      if ($w && $w !~ /\_\nR\.br/) {    # add responsory if missing
        $name = "Responsory $hora";
        $name .= 'M' if ($version =~ /Monastic/);    # getproprium subsitutes Nocturn 123 Versum only from Commune
        my ($wr, $cr) = getproprium($name, $lang, 1);

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
            ($wr, $cr) = getproprium("Responsory Breve $hora", $lang, 1);
            $wr =~ s/\s*$/\n\_\n/ if $wr;
          }

          ($vers, $cvers) = getproprium($replace{$hora}, $lang, 1);
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
  }

  my @capit = split("\n", $capit);
  postprocess_short_resp(@capit, $lang);

  if ($lang =~ /gabc/) {
    if (@capit[-1] =~ /V\/\./) {

      # If V/. ... R/. ... is on a single line, break it in two
      splice(@capit, -1, 1, split('R/.', $capit[-1]));
      $capit[-1] =~ s/^/R\/./;
    }

    if ($version =~ /monastic/i) {

      # Transform Versiculum: Tonus solemnis aut communis into Tonus simplex
      map {
        s/hr\)(.*?\(\,\))/h)$1/g;    # remove (first) superveniente in Tonus solemnis
        s/(.*\(.*?)hr\)/$1fr)/g;     # change superveniente at puncutum
        s/\([a-zA-Z0-9\_\.\~\>\<\'\/\!]+?\) (R\/\.)?\(::\)/\(f\.\) $1\(::\)/g;    # change finalis
        s/\((?:hi|hr|h\_0|f?e|f\'?|f\_0?h|h\_\')\)/\(h\)/g;                       # More changes for solemn Versicle
        s/\(\,\)//g;
      } @capit[-2 .. -1];

      # Capitula are input in database acc. to Ant. Romanum
      # Shorter pause at Flexa in Ant. Monasticum
      $capit[1] =~ s/†\(\;\)/†(,)/g;
    } elsif ($capit[-1] !~ /g\_\'?\/h/) {

      # Transform Versiculum: Tonus solemnis aut simplex into Tonus cum neuma
      map {
        s/\([a-zA-Z0-9\_\.\~\>\<\'\/\!]+?\) (R\/\.)?\(::\)/\(g\_\'\/hvGF\'E\!fgf.\) $1\(::\)/g;    # change finalis
        s/\((?:hi|hr|h\_0|f?e|f\'?|f\_0?h|h\_\')\)/\(h\)/g;    # More changes for solemn Versicle
        s/\(\,\)//g;
      } @capit[-2 .. -1];
    }
  }

  if ($hora ne 'Completorium') {
    setcomment($label, 'Source', $comment, $lang);
  }

  @capit;
}

1;
