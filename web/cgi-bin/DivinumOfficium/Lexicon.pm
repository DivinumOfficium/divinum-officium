package DivinumOfficium::Lexicon;

use strict;
use warnings;
use utf8;
use JSON::PP;
use Storable qw(retrieve);
use File::Basename;
use Exporter 'import';

our @EXPORT_OK = qw(apply_interlinear preload);

my %_lexicon;
my $_loaded = 0;

sub _load_lexicon {
  return if $_loaded;
  my $base_file = $ENV{LEXICON_PATH}
    || dirname(__FILE__) . '/../../../lexicon-tools/latin_lexicon.json';
  my $override_file = $ENV{LEXICON_OVERRIDE_PATH}
    || dirname(__FILE__) . '/../../../lexicon-tools/lexicon_overrides.json';

  (my $storable_file = $base_file) =~ s/\.json$/.storable/;

  if (-f $storable_file) {
    my $ref = retrieve($storable_file);
    %_lexicon = %$ref;
  } elsif (-f $base_file) {
    open(my $fh, '<:raw', $base_file) or die "Cannot open $base_file: $!";
    my $json = do { local $/; <$fh> };
    %_lexicon = %{decode_json($json)};

    if (-f $override_file) {
      open($fh, '<:raw', $override_file) or die "Cannot open $override_file: $!";
      $json = do { local $/; <$fh> };
      my $overrides = decode_json($json);

      while (my ($k, $v) = each %$overrides) {
        if ($v eq '') {
          delete $_lexicon{$k};
        } else {
          $_lexicon{$k} = $v;
        }
      }
    }
  }
  $_loaded = 1;
}

sub preload { _load_lexicon() }

sub apply_interlinear {
  my ($text) = @_;
  _load_lexicon();

  # Reunite words split by initiale styling: <FONT...><B><I>X</I></B></FONT>rest → glossed
  $text =~ s{((?:<[A-Za-z][^>]*>)+)([A-Za-z\x{00C0}-\x{024F}])((?:</[^>]+>)+)([A-Za-z\x{00C0}-\x{024F}]+)}{
    my ($open, $first, $close, $rest) = ($1, $2, $3, $4);
    my $word = $first . $rest;
    my $lc = lc($word);
    (my $lc_ij_acc = $lc) =~ s/i(?=[aeiouy\x{00E0}-\x{024F}])/j/g;
    (my $lc_plain = $lc) =~ s/\x{01FD}/\x{00E6}/g;
    $lc_plain =~ tr/áéíóúàèìòùäëïöüæœÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÆŒ/aeiouaeiouaeiouaeAEIOUAEIOUAEIOUAE/;
    (my $lc_ij = $lc_plain) =~ s/i(?=[aeiouy])/j/g;
    (my $lc_ji = $lc_plain) =~ s/j/i/g;
    my $gloss = $_lexicon{$lc} // $_lexicon{$lc_ij_acc} // $_lexicon{$lc_plain} // $_lexicon{$lc_ij} // $_lexicon{$lc_ji} // '';
    if ($gloss) {
      $gloss =~ s/\s*\([^)]*\)//g;
      my @senses = grep { /\S/ } split /\s*[,;]\s*/, $gloss;
      $gloss = @senses > 1 ? "$senses[0]/$senses[1]" : $senses[0];
      $gloss =~ s/^\s+|\s+$//g;
      $gloss = ucfirst($gloss) if $word =~ /^\p{Upper}/;
    }
    $gloss
      ? qq(<span class="lw">${open}${first}${close}${rest}<span class="gloss"> ($gloss)</span></span>)
      : "${open}${first}${close}${rest}"
  }ge;

  my @parts = split(/(<[^>]+>)/, $text);
  my $lw_depth = 0;

  for my $part (@parts) {
    if ($part =~ /^</) {
      $lw_depth++ if $part =~ /class="lw"/;
      $lw_depth-- if $part eq '</span>' && $lw_depth > 0;
      next;
    }
    next if $lw_depth > 0;
    $part =~ s{([A-Za-z\x{00C0}-\x{024F}]+)}{
      my $word = $1;
      my $lc = lc($word);
      # Swap consonantal i→j on accented form (e.g. iubiláte → jubiláte)
      (my $lc_ij_acc = $lc) =~ s/i(?=[aeiouy\x{00E0}-\x{024F}])/j/g;
      # Strip liturgical stress accents (e.g. adiutórium → adiutorium)
      (my $lc_plain = $lc) =~ s/\x{01FD}/\x{00E6}/g;  # ǽ → æ
      $lc_plain =~ tr/áéíóúàèìòùäëïöüæœÁÉÍÓÚÀÈÌÒÙÄËÏÖÜÆŒ/aeiouaeiouaeiouaeAEIOUAEIOUAEIOUAE/;
      (my $lc_ij = $lc_plain) =~ s/i(?=[aeiouy])/j/g;
      (my $lc_ji = $lc_plain) =~ s/j/i/g;
      my $gloss = $_lexicon{$lc} // $_lexicon{$lc_ij_acc} // $_lexicon{$lc_plain} // $_lexicon{$lc_ij} // $_lexicon{$lc_ji} // '';
      if ($gloss) {
        $gloss =~ s/\s*\([^)]*\)//g;  # strip parentheticals
        my @senses = grep { /\S/ } split /\s*[,;]\s*/, $gloss;
        $gloss = @senses > 1 ? "$senses[0]/$senses[1]" : $senses[0];
        $gloss =~ s/^\s+|\s+$//g;
        $gloss = ucfirst($gloss) if $word =~ /^\p{Upper}/;
      }
      $gloss
        ? qq(<span class="lw">$word<span class="gloss"> ($gloss)</span></span>)
        : $word
    }ge;
  }
  return join('', @parts);
}

1;
