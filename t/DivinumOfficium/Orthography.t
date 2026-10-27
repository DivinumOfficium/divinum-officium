use strict;
use warnings;
use utf8;
use lib 'web/cgi-bin';
use DivinumOfficium::Orthography qw(j_orthography is_plain_latin);
use Test2::V0;

# Unit tests for the optional "j" orthography (consonantal i -> j).
# The rules are purely orthographic: i is consonantal (written j) when it
# stands before another vowel, except as the i of "qu", and never before i.

sub conv { j_orthography($_[0]) }

### the headline examples from the feature request
is(conv('eius'), 'ejus', 'eius -> ejus');
is(conv('cuius'), 'cujus', 'cuius -> cujus');
is(conv('Eius'), 'Ejus', 'capitalization preserved');
is(conv('EIUS'), 'EJUS', 'all-caps preserved');

### word-initial consonantal i
is(conv('Iesus'), 'Jesus', 'Iesus -> Jesus');
is(conv('iam'), 'jam', 'iam -> jam');
is(conv('iri'), 'iri', 'initial i before i NOT converted (vocalic)');
is(conv('iis'), 'iis', 'dative "iis" stays all-i');
is(conv('ii'), 'ii', 'numeral "ii" untouched');

### idempotence: text already in j orthography passes through
is(conv('Jesu'), 'Jesu', 'already-j text untouched');
is(conv('ejus'), 'ejus', 'idempotent: ejus stays ejus');
is(conv('Jesus'), 'Jesus', 'idempotent: Jesus stays Jesus');

### intervocalic consonantal i
is(conv('huius'), 'hujus', 'huius -> hujus');
is(conv('maior'), 'major', 'maior -> major');
is(conv('peior'), 'pejor', 'peior -> pejor');
is(conv('eiusdem'), 'ejusdem', 'eiusdem -> ejusdem');

### the "qu" cluster is never j
is(conv('quia'), 'quia', 'quia untouched');
is(conv('Quia'), 'Quia', 'capital Quia untouched');
is(conv('quis'), 'quis', 'quis untouched');
is(conv('exequias'), 'exequias', 'qu-guard inside word');
is(conv('cuiusquam'), 'cujusquam', 'real intervocalic i before a qu-syllable converts');

### vocalic i is never j (not word-initial, not intervocalic)
is(conv('implesse'), 'implesse', 'i after consonant untouched');
is(conv('Dominus'), 'Dominus', 'plain words untouched');
is(conv('fiet'), 'fiet', 'i after consonant before vowel untouched');
is(conv('mihi'), 'mihi', 'final i untouched');
is(conv('quam'), 'quam', 'qu word untouched');

### vowels with diacritics (Latin-Bea psalter style) count
is(conv('cuiús'), 'cujús', 'accented following vowel counts');
is(conv('huíus'), 'huíus', 'accented i itself is not rewritten (it is not a plain i)');

### HTML markup is never damaged
is(
  conv('<FONT COLOR="red">eius</FONT> infirmorum'),
  '<FONT COLOR="red">ejus</FONT> infirmorum',
  'conversion inside, tags intact'
);
is(conv('<A HREF="#eius">eius</A>'), '<A HREF="#eius">ejus</A>',
  'attribute values untouched');

### initiale-styled words: the leading letter arrives wrapped in markup
### (setfont($initiale, substr(...)) splits "Iesus" into markup + rest)
is(
  conv(qq{<FONT SIZE='+2' COLOR="red"><B><I>I</I></B></FONT>esus}),
  qq{<FONT SIZE='+2' COLOR="red"><B><I>J</I></B></FONT>esus},
  'initiale-styled I before vowel becomes J inside its markup run'
);

### a whole cell the way the renderer actually sends it
is(
  conv('Qui sequitur me non ambulat in tenebris, <b>sed</b> habebit lumen vitae. Iesu, Iesu, Iesu.'),
  'Qui sequitur me non ambulat in tenebris, <b>sed</b> habebit lumen vitae. Jesu, Jesu, Jesu.',
  'sentence with markup and repeated vocatives'
);

### is_plain_latin gate: which columns the toggle applies to
ok(is_plain_latin('Latin'), 'Latin is plain Latin');
ok(is_plain_latin('Latin-Bea'), 'Latin-Bea counts as plain Latin');
ok(!is_plain_latin('Latin-gabc'), 'chant (gabc) excluded');
ok(!is_plain_latin('Cantilenæ/Latin-gabc'), 'full chant language excluded');
ok(!is_plain_latin('English'), 'English excluded');
ok(!is_plain_latin(undef), 'undef excluded');

### undef / empty safety
is(j_orthography(undef), undef, 'undef passes through');
is(j_orthography(''), '', 'empty string passes through');

done_testing;
