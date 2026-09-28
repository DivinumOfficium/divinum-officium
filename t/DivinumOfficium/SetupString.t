use strict;
use warnings;
use utf8;

use lib 'web/cgi-bin';
use Test2::V0;

# setupstring() layers a language on top of its fallback language, which in turn
# layers on top of Latin. The fallback language is allowed to translate a proper
# by writing the text out in full where Latin only holds an @-reference to
# another proper. When the requested language has no text of its own for such a
# section, taking the fallback's full text drops the requested language out of a
# proper it does translate elsewhere, so the Latin reference is preferred instead
# - but only when the requested language really has the referenced section.
#
# These tests run against a small, purpose-built fixture data set in
# t/fixtures/setupstring (a missa/ and a horas/ tree), so they don't depend on
# (and can't be broken by) ongoing edits to the actual liturgical data.
{
  no warnings 'once';    # these are read by the code under test, not by the test
  $main::version = 'Fixture 1960';
  $main::datafolder = 't/fixtures/setupstring/missa';
  $main::langfb = 'English';
  $main::missa = 1;
  $main::dayname = ['Fixture day'];
  $main::month = 1;
  $main::dayofweek = 0;
}

require './web/cgi-bin/DivinumOfficium/SetupString.pl';

# A section value ends with the blank line that separated it from the next
# section in the file; compare without that trailing whitespace.
sub sec {
  my ($sections, $key) = @_;
  my $value = defined $sections->{$key} ? $sections->{$key} : '';
  $value =~ s/\s+\z//;
  $value;
}

### pure_inclusion - what counts as a bare @-reference.
#
# The Latin section of a day proper usually carries its own scripture citation
# ('!Rubric') above the reference, and the referenced section brings a citation
# of its own, so that is still a bare reference.

ok(pure_inclusion("\@Tempora/Nat1-0:Oratio\n"), 'A bare @-reference');
ok(pure_inclusion("\@Tempora/Nat1-0\n"), 'An @-reference without a section name');
ok(pure_inclusion("!Sap 18:14-15.\n\@Tempora/Nat1-0:Introitus\n"), 'A citation line above the reference');
ok(pure_inclusion("\@Tempora/Nat1-0:Graduale:s/Alfa/Beta/\n"), 'A reference carrying substitutions');
ok(pure_inclusion("\@Tempora/Nat1-0:Oratio\n\@Tempora/Nat1-0:Graduale:s/Alfa/Beta/\n"),
  'Several @-lines are still a bare reference');
ok(pure_inclusion("\@Tempora/Nat1-0:Oratio\n\n\@Tempora/Nat1-0:Graduale\n"),
  'A blank line between references is fine');
ok(!pure_inclusion("\@Tempora/Nat1-0:Oratio\nSome Latin text.\n\@Tempora/Nat1-0:Graduale\n"),
  'A text line between references is not a bare reference');
ok(!pure_inclusion("!Sap 18:14-15.\n\@Tempora/Nat1-0:Introitus\nSome Latin text.\n"),
  'A reference plus a text of its own is not a bare reference');
ok(!pure_inclusion("Some Latin text.\n\@Tempora/Nat1-0:Introitus\n"),
  'Text above the reference is not a bare reference');
ok(!pure_inclusion("\n"), 'An empty section');
ok(!pure_inclusion(undef), 'An undefined section');

### section_in_own_layer - does the requested language have the text itself?
#
# A section that is only another @-reference does not count: the question is
# whether the translation exists in this language, not whether it delegates
# somewhere.

ok(section_in_own_layer('Magyar', 'Tempora/Nat1-0', 'Oratio'), 'A translated section counts');
ok(section_in_own_layer('Magyar', 'Tempora/Nat1-0.txt', 'Oratio'), 'The file name may carry the extension');
ok(!section_in_own_layer('Magyar', 'Tempora/Nat1-0', 'Evangelium'), 'A section the file does not have');
ok(!section_in_own_layer('Magyar', 'Tempora/Missing-1-0', 'Oratio'), 'A file the language does not have');
ok(!section_in_own_layer('Magyar', 'Tempora/Deleg-1-0', 'Oratio'), 'A section that only delegates elsewhere');
ok(!section_in_own_layer('Latin', 'Tempora/Nat1-0', 'Oratio'), 'Latin is never its own translation');
ok(!section_in_own_layer('', 'Tempora/Nat1-0', 'Oratio'), 'No language at all');
ok(section_in_own_layer('Magyar', 'Commune/C3a', 'Lectio'),
  'A reference redirected from the missa tree to the horas tree is found');

### The rule itself: a section the requested language lacks follows the Latin
### reference, as long as the referenced proper exists in the requested language.

my $hu = setupstring('Magyar', 'Sancti/01-05.txt');

is(sec($hu, 'Introitus'), 'Magyar introitus.',
  'A Latin reference to a proper the requested language has is followed there');
is(sec($hu, 'Oratio'), 'Magyar oratio.', 'A reference with no section name of its own');
is(sec($hu, 'Graduale'), 'Magyar graduale.', 'A reference carrying substitutions loses them');
is(sec($hu, 'Lectio'), 'Magyar C3a lectio.', 'A reference into the horas tree is followed there');
is(sec($hu, 'Epistula'), "Magyar oratio.\nMagyar graduale.",
  'Every line of a multi-line Latin reference is followed into the requested language');

# The requested language's own text still wins over everything.
is(sec($hu, 'Name'), 'Magyar név', 'A section the requested language translates itself is untouched');
is(sec($hu, 'Communio'), 'Magyar communio.', 'A section the requested language translates itself is untouched');

# Structural keys are never taken from the Latin layer by reference.
is(sec($hu, 'Rule'), "Gloria\nCredo", 'A structural key keeps the fallback value');
is(sec($hu, 'Officium'), 'Az i nap misája', 'The requested language keeps its own Office of the day');
is(sec($hu, 'Rank'), 'Az i nap misája;;Duplex;;1.1', 'The rank is rebuilt around the Office of the day');

# A reference the requested language cannot satisfy stays as the fallback had it.
my $hu_missing = setupstring('Magyar', 'Sancti/01-06.txt');
is(sec($hu_missing, 'Oratio'), 'English oratio of 01-06.',
  'A reference to a proper that is not translated stays the fallback');
is(sec($hu_missing, 'Lectio'), 'English lectio of 01-06.',
  'A reference to a proper missing in the requested language stays the fallback');
is(sec($hu_missing, 'Tractus'), 'English tractus of 01-06.',
  'One unsatisfiable line makes the whole multi-line section fall back');

# A section that only delegates to another reference is not a translation of its
# own either, so the fallback text stays.
my $hu_deleg = setupstring('Magyar', 'Sancti/01-08.txt');
is(sec($hu_deleg, 'Oratio'), 'English oratio of 01-08.', 'A delegating section is not a translation');

# A proper the requested language does not have at all still follows the Latin
# reference, section by section.
my $hu_nofile = setupstring('Magyar', 'Sancti/01-07.txt');
is(sec($hu_nofile, 'Introitus'), 'Magyar introitus.',
  'A proper the requested language does not have follows the Latin reference');
is(sec($hu_nofile, 'Name'), 'The Name', 'and falls back to the fallback language for the rest');

### The fallback language's own pages must not change: the layer below it already
### is Latin, so there is nothing to prefer.

my $en = setupstring('English', 'Sancti/01-05.txt');
is(sec($en, 'Oratio'), 'English oratio.', 'The fallback language keeps its own text');
is(sec($en, 'Introitus'), "!Wis 18:14-15.\nEnglish introitus.", 'The fallback language keeps its own text');
is(sec($en, 'Lectio'), 'English lectio.', 'The fallback language keeps its own text');

### Nor must Latin's.

my $la = setupstring('Latin', 'Sancti/01-05.txt');
is(sec($la, 'Oratio'), 'Latin oratio.', 'Latin is left alone');
is(sec($la, 'Introitus'), "!Sap 18:14-15.\nLatin introitus.", 'Latin is left alone');

### A Monastic-style '../missa/...' lookup behaves the same as a plain one.

my $hu_monastic = setupstring('../missa/Magyar', 'Sancti/01-05.txt');
is(sec($hu_monastic, 'Oratio'), 'Magyar oratio.', "A '../missa/...' lookup behaves the same");

### prefer_latin_inclusion() only ever carries over a reference Latin holds, with
### its substitutions, which must survive whichever language the reference
### resolves in.

sub english_layer {
  setupstring('English', 'Sancti/01-05.txt', 'resolve@' => RESOLVE_NONE());
}

{
  # There is nothing to prefer for Latin itself: the layer below it is Latin.
  my %new = (Name => 'Kétszeresen');
  prefer_latin_inclusion(\%new, english_layer(), 'Latin', 'Latin', 'Sancti/01-05.txt');
  is(join(',', sort keys %new), 'Name', 'Latin is not given references to itself');
}

{
  # Structural keys drive day selection, ranking, rule guards and the display
  # name; their value is the meaningful one and is never replaced. (The
  # sections the requested language is missing are still taken.)
  my %new = map { $_ => 'Saját érték.' }
    grep { /^(?:__preamble|Rank|Rule|Officium|Name)$/ } keys %{english_layer()};
  my $structural = sub {
    join '|', map { "$_=$new{$_}" }
      grep { /^(?:__preamble|Rank|Rule|Officium|Name)$/ } sort keys %new;
  };
  my $before = $structural->();
  prefer_latin_inclusion(\%new, english_layer(), 'Magyar', 'Latin', 'Sancti/01-05.txt');
  is($structural->(), $before, 'A structural key is not given a Latin reference');
  is($new{Oratio}, "\@Tempora/Nat1-0:Oratio\n", 'a section that was missing is still taken');
}

{
  # A section the requested language has text for is left alone.
  my %new = map { $_ => 'Saját szöveg.' }
    grep { !/^__preamble$/ } keys %{english_layer()};
  my $count = scalar keys %new;
  prefer_latin_inclusion(\%new, english_layer(), 'Magyar', 'Latin', 'Sancti/01-05.txt');
  is(scalar keys %new, $count, 'A section the requested language has is not overwritten');
  is($new{Oratio}, 'Saját szöveg.', 'and keeps its text');
}

{
  my %new;
  prefer_latin_inclusion(\%new, english_layer(), 'Magyar', 'Latin', 'Sancti/01-05.txt');
  is(
    join(',', sort keys %new),
    'Communio,Epistula,Graduale,Introitus,Lectio,Oratio',
    'Exactly the sections the requested language can satisfy through a Latin reference'
  );
  is($new{Introitus}, "\@Tempora/Nat1-0:Introitus\n", 'The reference is carried over');
  is($new{Oratio}, "\@Tempora/Nat1-0:Oratio\n", 'A reference without a section name of its own names one');
  is($new{Graduale}, "\@Tempora/Nat1-0:Graduale:s/Alfa/Beta/\n", 'The substitutions are carried over');
  is($new{Epistula},
    "\@Tempora/Nat1-0:Oratio\n\@Tempora/Nat1-0:Graduale:s/Alfa/Beta/\n",
    'Every line of a multi-line reference is carried over, substitutions intact');
  is($new{Communio}, "\@Tempora/Nat1-0:Communio\n", 'The reference is carried over');
  is($new{Lectio}, "\@Commune/C3a:Lectio\n", 'A reference into the horas tree is carried over');
  ok(!exists $new{Alleluia},
    'A reference the fallback language itself satisfies by reference is not taken over');
}

done_testing;
