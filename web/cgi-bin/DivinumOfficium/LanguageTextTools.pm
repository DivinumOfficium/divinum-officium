package DivinumOfficium::LanguageTextTools;

# use strict;
# use warnings;
use utf8;

BEGIN {
  require Exporter;
  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(prayer rubric prex translate load_languages_data
    omit_regexp suppress_alleluia process_inline_alleluias
    alleluia_ant ensure_single_alleluia ensure_double_alleluia);
}

### private vars
#
my %_translate;
my %_prayers;
my %_preces;
my %_rubrics;
my $alleluia_regexp;
my $omit_regexp;
my $fb_lang;

## private functions

sub alleluia {
  my ($lang) = @_;

  my $text = prayer('Alleluia', $lang);
  $text =~ s/^v. (.*?)\..*/$1/rs;
}

## public functions
#
#*** suppress_alleluia($text_ref)
# Removes all alleluia
sub suppress_alleluia {
  my $text_ref = shift;

  $$text_ref =~ s/[,.]?\s*$alleluia_regexp//ig;
}

#*** process_inline_alleluia($text_ref, $paschalf)
# unbrackets bracketed alleluias when $paschalf is true
# removes bracketed alleluias otherwise
sub process_inline_alleluias {
  my ($text_ref, $paschalf) = @_;

  if ($paschalf) {
    $$text_ref =~ s/\(($alleluia_regexp.*?)\)/ $1 /isg;
  } else {
    $$text_ref =~ s/\($alleluia_regexp.*?\)//isg;
  }
}

#*** ensure_single_alleluia($text, $lang)
# Ensures that $text ends in a single 'alleluia' (or rather the
# appropriate translation for $lang).
sub ensure_single_alleluia {
  my ($text_ref, $lang) = @_;

  # Add a single 'alleluia', unless it's already there.
  $$text_ref =~ s/\p{P}?\s*$/ ", " . lc(alleluia($lang)) . '.'/e unless $$text_ref =~ /$alleluia_regexp\p{P}?\)?\s*$/ || !$$text_ref;
}

#*** ensure_double_alleluia($text, $lang)
# Arranges that $text should end in a double 'alleluia' (or rather the
# appropriate translation for $lang), and that the asterisk should be
# placed correctly, if it appears that the response is not already in
# the Paschal form.
sub ensure_double_alleluia {
  my ($text_ref, $lang) = @_;

  my $alleluia = prayer('Alleluia Duplex', $lang);
  $alleluia =~ s/\s+$//;

  if ($$text_ref !~ /$alleluia_regexp[,.] $alleluia_regexp\p{P}?\s*$/i) {

    # Add a double 'alleluia' and move the asterisk.
    $$text_ref =~ s/\s*\*\s*(.)/ \l$1/;
    $$text_ref =~ s/\p{P}?\s*$/', * ' . alleluia($lang) . ', ' . lc(alleluia($lang) . '.')/e;
  }
}

#*** alleluia_ant($lang)
# 'Alleluja * alleluja, alleluja.'
sub alleluia_ant {
  my ($lang) = @_;
  my $u = alleluia($lang);
  my $l = lc $u;

  "$u, * $l, $l.";
}

sub omit_regexp {
  $omit_regexp;
}

#*** translate($name)
# return the translated name
sub translate {
  my $name = shift;
  my $lang = shift;

  my $prefix = '';
  if ($name =~ s/^([\$&])//) { $prefix = $1; }

  return $prefix . ($_translate{Latin}{$name} =~ s/\s*$//r || $name) if $lang =~ /Latin/;

  my $output =
    $prefix . ($_translate{$lang}{$name} || $_translate{$main::langfb}{$name} || $_translate{Latin}{$name} || $name);
  $output =~ s/\s*$//r;
}

#*** prayer($name)
# return the prayer
sub prayer {
  my $name = shift;
  my $lang = shift;
  my $version = $main::version;

  my $prayer =
       $_prayers{"$lang$version"}{$name}
    || $_prayers{"$fb_lang$version"}{$name}
    || $_prayers{"Latin$version"}{$name}
    || $name;

  if ($version =~ /cist/i && $name !~ /Pater Ave|Incipit|clara|bene.*Final/i) {
    $prayer =~ s/\++ //g;
  }
  return $prayer;
}

#*** rubric($name)
# return the prayer
sub rubric {
  my $name = shift;
  my $lang = shift;
  my $version = $main::version;

       $_rubrics{"$lang$version"}{$name}
    || $_rubrics{"$fb_lang$version"}{$name}
    || $_rubrics{"Latin$version"}{$name}
    || $name;
}

#*** prex($name)
# return the prayer
sub prex {
  my $name = shift;
  my $lang = shift;
  my $version = $main::version;

       $_preces{"$lang$version"}{$name}
    || $_preces{"$fb_lang$version"}{$name}
    || $_preces{"Latin$version"}{$name}
    || $name;
}

#*** load_languages_data($lang1, $lang2, $langfb, $version, $missaf)
sub load_languages_data {
  my ($lang1, $lang2, $langfb, $version, $missaf) = @_;

  my @langs = ('Latin', $lang1, $lang2, $langfb);

  # take unique values from @langs
  @langs = do {
    my %seen;
    grep { !$seen{$_}++ } @langs;
  };

  # save fallabck lang for local module use
  $fb_lang = $langfb;

  my $dir = $missaf ? 'Ordo' : 'Psalterium/Common';

  foreach my $lang (@langs) {
    $_prayers{"$lang$version"} = main::setupstring($lang, "$dir/Prayers.txt");
    $_rubrics{"$lang$version"} = main::setupstring($lang, "Psalterium/Common/Rubricae.txt");
    $_preces{"$lang$version"} = main::setupstring($lang, "Psalterium/Special/Preces.txt");
    $_translate{$lang} = main::setupstring($lang, "Psalterium/Common/Translate.txt");
  }

  my $alleluias = join('|', map { lc(alleluia($_)) } @langs);
  $alleluias .= '|allel[uú][ij]a';    # alternative spelling in Latin
  $alleluia_regexp = qr/(?:\L$alleluias)/i;

  my $omits = join(
    '|',
    map {
      my %comm = %{main::setupstring($_, 'Psalterium/Comment.txt')};
      (split("\n", $comm{'Preces'}))[1] . '|' . (split("\n", $comm{'Suffragium'}))[0];
    } @langs,
  );
  $omit_regexp = qr/\b(?:$omits)\b/;
}

1;
