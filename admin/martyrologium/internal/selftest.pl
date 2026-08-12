#!/usr/bin/perl
#
# Checks the rendering rules on a made-up language, so the cases that are
# awkward to find in the real data are covered: the scope of the version
# conditionals, an entry with no translation, an entry the Latin has never
# had, and a day a version leaves with nothing but its title.
#
#     perl internal/selftest.pl

use strict;
use warnings;
use utf8;
use FindBin;
use File::Path qw(make_path remove_tree);

my $DO = "$FindBin::Bin/../../..";
unshift @INC, "$DO/web/cgi-bin";
require DivinumOfficium::FileIO;
DivinumOfficium::FileIO->import(qw(do_read));

binmode STDOUT, ':encoding(utf-8)';

our ($datafolder, $version, $langfb, @dayname, $hora, $dayofweek, %winner);
our %setupstring_caches_by_version;
my $tmp = "$FindBin::Bin/../.selftest";
remove_tree($tmp);
make_path("$tmp/horas/Latin/Martyrologium", "$tmp/horas/Testlang/Martyrologium",
  "$tmp/horas/Testother/Psalterium");
$datafolder = "$tmp/horas";
$langfb = 'Testlang';
@dayname = ('Pent05', '', '');
$hora = 'Prima';
$dayofweek = 3;
%winner = (Rank => '');

do "$DO/web/cgi-bin/DivinumOfficium/SetupString.pl" or die "SetupString: " . ($@ || $!);
do "$DO/web/cgi-bin/horas/specials/specprima.pl" or die "specprima: " . ($@ || $!);
*main::checklatinfile = sub { } unless defined &main::checklatinfile;

sub w {
  my ($path, $text) = @_;
  open(my $fh, '>:encoding(utf-8)', "$tmp/horas/$path") or die "$path: $!";
  print $fh $text;
  close $fh;
}

w('Latin/Martyrologium/05-01.txt', <<'EOT');
[Titulus]
Kaléndis Maii

[Martyrologium]
@:Semper

@:SoloDA
(rubrica 1960 aut rubrica Newcal omittitur)

(rubrica 1960 aut rubrica Newcal dicitur)
@:Solo1960

@:Reworded

@:Untranslated

@:OnlyTestlang

@Martyrologium/05-02:Elsewhere

[Semper]
latine semper

[SoloDA]
latine solo DA

[Solo1960]
latine solo 1960

[Reworded]
latine reworded base

[Reworded] (rubrica 1960 aut rubrica Newcal)
latine reworded 1960

[Untranslated]
latine untranslated
EOT

w('Latin/Martyrologium/05-02.txt', <<'EOT');
[Titulus]
Sexto Nonas Maii

[Martyrologium]
@:Elsewhere

[Elsewhere]
latine elsewhere
EOT

# a day this version empties out: only the title is left, so there is
# nothing for the separator to separate
w('Latin/Martyrologium/05-03.txt', <<'EOT');
[Titulus]
Quinto Nonas Maii

[Martyrologium]
@:Gone
(rubrica 1960 aut rubrica Newcal omittitur)

[Gone]
latine gone
EOT

w('Testlang/Martyrologium/05-01.txt', <<'EOT');
[Titulus]
TESTLANG TITULUS

[Semper]
testlang semper

[SoloDA]
testlang solo DA

[Solo1960]
testlang solo 1960

[Reworded]
testlang reworded

[OnlyTestlang]
testlang only here
EOT

w('Testlang/Martyrologium/05-02.txt', <<'EOT');
[Elsewhere]
testlang elsewhere
EOT

w('Testlang/Martyrologium/05-03.txt', <<'EOT');
[Titulus]
TESTLANG MAY THIRD
EOT

# A recension, rather than a rubric: the Cistercian martyrology has
# elogia of its own and words others differently.  Nothing in the format
# is particular to 1570/1955/1960 -- any name the version string carries
# can be tested the same way.
w('Latin/Martyrologium/05-04.txt', <<'EOT');
[Titulus]
Quarto Nonas Maii

[Martyrologium]
@:Romanus

(rubrica Cisterciensis dicitur)
@:Cisterciensis-Proprius

@:Bernardi

[Romanus]
latine romanus

[Cisterciensis-Proprius]
latine proprius Cisterciensium

[Bernardi]
latine Bernardi romano more

[Bernardi] (rubrica Cisterciensis)
latine Bernardi cisterciensi more
EOT

w('Testlang/Martyrologium/05-04.txt', <<'EOT');
[Romanus]
testlang romanus

[Cisterciensis-Proprius]
testlang proprius Cisterciensium

[Bernardi]
testlang Bernardi romano more

[Bernardi] (rubrica Cisterciensis)
testlang Bernardi cisterciensi more
EOT

my ($pass, $fail) = (0, 0);

sub render {
  my ($lang, $day, $v) = @_;
  $version = $v;
  %setupstring_caches_by_version = ();
  return martyrologium_elogia($lang, $day);
}

sub is {
  my ($got, $want, $what) = @_;
  my $g = join(' | ', @$got);

  if ($g eq $want) {
    $pass++;
    print "  ok   $what\n";
  } else {
    $fail++;
    print "  FAIL $what\n       got:  $g\n       want: $want\n";
  }
}

sub has {
  my ($got, $line, $what) = @_;

  if (grep { $_ eq $line } @$got) {
    $pass++;
    print "  ok   $what\n";
  } else {
    $fail++;
    print "  FAIL $what\n       $line not in: ", join(' | ', @$got), "\n";
  }
}

print "Latin, Divino Afflatu\n";
is([render('Latin', '05-01', 'Divino Afflatu')],
  'Kaléndis Maii | _ | latine semper | latine solo DA | latine reworded base | latine untranslated | latine elsewhere',
  'base entries, no 1960-only one, cross-day entry resolved');

print "Latin, Rubrics 1960\n";
is([render('Latin', '05-01', 'Rubrics 1960 - 1960')],
  'Kaléndis Maii | _ | latine semper | latine solo 1960 | latine reworded 1960 | latine untranslated | latine elsewhere',
  'omittitur drops one entry, dicitur adds one, the section override applies');

print "the conditionals reach only their own entry\n";
my @da = render('Latin', '05-01', 'Divino Afflatu');
has(\@da, 'latine semper', 'the entry above an omittitur survives');
has(\@da, 'latine reworded base', 'the entry below a dicitur survives');

print "an entry the Latin never had\n";
is([grep { /only here/ } render('Latin', '05-01', 'Divino Afflatu')],
  '', 'renders nothing in the Latin column');

print "Testlang\n";
is([render('Testlang', '05-01', 'Divino Afflatu')],
  'TESTLANG TITULUS | _ | testlang semper | testlang solo DA | testlang reworded | testlang only here | testlang elsewhere',
  'own text, own entry kept, own order ignored, and no Latin in the column');

is([render('Testlang', '05-01', 'Rubrics 1960 - 1960')],
  'TESTLANG TITULUS | _ | testlang semper | testlang solo 1960 | testlang reworded | testlang only here | testlang elsewhere',
  'the version rules come from the Latin index');

print "a column falls back to the reader's language, not past it\n";
is([grep { /untranslated/ } render('Testlang', '05-01', 'Divino Afflatu')],
  '', 'an entry nobody translated is left out rather than shown in Latin');
is([render('Testother', '05-01', 'Divino Afflatu')],
  'TESTLANG TITULUS | _ | testlang semper | testlang solo DA | testlang reworded | testlang only here | testlang elsewhere',
  'a language with no martyrology of its own reads the fallback language');

print "a day left with only its title\n";
is([render('Latin', '05-03', 'Rubrics 1960 - 1960')],
  'Quinto Nonas Maii', 'no separator when nothing follows it');
is([render('Latin', '05-03', 'Divino Afflatu')],
  'Quinto Nonas Maii | _ | latine gone', 'separator back when an entry is');

print "a recension, not a rubric\n";
is([render('Latin', '05-04', 'Divino Afflatu')],
  'Quarto Nonas Maii | _ | latine romanus | latine Bernardi romano more',
  'the Roman books do not see the Cistercian entry');
is([render('Latin', '05-04', 'Monastic Tridentinum Cisterciensis 1951')],
  'Quarto Nonas Maii | _ | latine romanus | latine proprius Cisterciensium | latine Bernardi cisterciensi more',
  'Cisterciensis adds its own entry and words Bernard its own way');
is([render('Latin', '05-04', 'Monastic Tridentinum Cisterciensis Altovadensis')],
  'Quarto Nonas Maii | _ | latine romanus | latine proprius Cisterciensium | latine Bernardi cisterciensi more',
  'and so does the Altovadensis use of it');
print "a translation may word an entry per recension too\n";
is([render('Testlang', '05-04', 'Divino Afflatu')],
  'Quarto Nonas Maii | _ | testlang romanus | testlang Bernardi romano more',
  'the Roman books get the translation of the Roman wording');
is([render('Testlang', '05-04', 'Monastic Tridentinum Cisterciensis 1951')],
  'Quarto Nonas Maii | _ | testlang romanus | testlang proprius Cisterciensium | testlang Bernardi cisterciensi more',
  'and Cisterciensis the translation of its own');

# The tools read the same files, and a version's wording sits in a section
# whose conditional is outside the brackets.  Read carelessly it lands
# under the base's name and overwrites the text it is a variant of, which
# then feeds the matcher the wrong wording.
print "a version's wording does not displace the base\n";
{
  push @INC, "$FindBin::Bin";
  require MartyrLib;
  my $raw = "[Key]\nbase text\n\n[Key] (rubrica 1570)\nvariant text\n";
  my $pool = MartyrLib::pool_read_text($raw, '01-01');
  my @entries = MartyrLib::pool_entries($pool);
  is([scalar @{$pool->{order}}], '2', 'both sections are kept apart');
  is([scalar @entries], '1', 'but they are one entry');
  is([$entries[0][1]], 'base text', 'and it is the base wording');
  is([MartyrLib::pool_render($pool) eq $raw ? 'yes' : 'no'], 'yes', 'and it writes back unchanged');
}

remove_tree($tmp);
printf "\n%d passed, %d failed\n", $pass, $fail;
exit($fail ? 1 : 0);
