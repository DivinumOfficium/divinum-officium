use strict;
use warnings;

use DivinumOfficium::Main qw(liturgical_color);

use Test::Simple tests => 57;

# These tests check liturgical_color() against real day titles pulled from
# the actual data shipped in web/www/horas/Latin/ (the [Officium]/[Rank]
# text used to label each day), across every part of the liturgical year
# under the 1960 rubrics (informally "the 1962 rubrics", after the year of
# the last Missale Romanum printed under John XXIII's 1960 Code of Rubrics).
# Unlike Main.t's tests for this function (which probe the regex mechanics
# and branch ordering in isolation with synthetic strings), these are
# acceptance-style checks that the mapping is faithful to the real calendar.
#
# NB: the function has no distinct "white" return value. 'black' is both the
# fallback/default *and* the color used for every genuinely white-vestment
# day (Christmastide, Eastertide, Confessors, etc.): since the app is
# presented against a white background, white text would be unreadable, so
# it renders these days as black text instead. Test cases below that expect
# 'black' for a white-liturgical-color feast are annotated as such, to
# distinguish that from a title that merely matches no keyword at all.
#
# Where a day has distinct titles for different rubrics versions (this
# happened more than once - Jan 1, the eve of Ascension, Good Friday - both
# real titles are tested, since liturgical_color() has no notion of "version"
# itself; it only ever sees whatever title string the caller passes it).

### Tempus Adventus (Advent) - violet

ok(liturgical_color('Dominica I Adventus') eq 'purple', 'Advent Sunday is violet');

### Tempus Nativitatis (Christmastide) - white, except martyrs within it

ok(liturgical_color('In Nativitate Domini') eq 'black', 'Christmas Day is white');
ok(liturgical_color('Dominica infra Octavam Nativitatis') eq 'black', 'Christmastide is white');

# 26 Dec, within the Octave of Christmas, but a martyr's feast overrides the
# season's own white and is red instead.
ok(liturgical_color('S. Stephani Protomartyris') eq 'red', 'St Stephen (26 Dec) is red, overriding the white octave');

# 1 Jan has two real historical titles for the same day.
ok(liturgical_color('In Circumcisione Domini') eq 'black', '1 Jan, pre-1960 title ("Circumcision"), is white');
ok(
  liturgical_color("Die Octav\x{e6} Nativitatis Domini") eq 'black',
  '1 Jan, 1960-rubrics title ("Octave Day of the Nativity"), is white',
);

# The Vigil of the Epiphany (5 Jan) is white, reached via the anchored
# ^In Vigilia Epiphaniae branch.
ok(liturgical_color("In Vigilia Epiphani\x{e6}") eq 'black', 'Vigil of the Epiphany is white');

# The Feast of the Holy Family (Sunday within the Octave of the Epiphany) is
# white; despite mentioning Mary, it is not a Marian feast, and this is a
# real-data near-miss for the blue Marian pattern (Sanct + ae/ae is not
# immediately followed by " Mari" here).
ok(liturgical_color("Sanct\x{e6} Famili\x{e6} Jesu Mari\x{e6} Joseph") eq 'black', 'Feast of the Holy Family is white');

### Tempus post Epiphaniam (Time after Epiphany)

# The Octave Day of the Epiphany (13 Jan, pre-1960) keeps the Epiphany's own
# white color; the ordinary green season does not begin until after the
# octave ends, even though this title doesn't match any "white" keyword
# either - it's white purely via the default fallback.
ok(liturgical_color("In Octava Epiphani\x{e6}") eq 'black', 'Octave Day of the Epiphany is still white, not yet green');

# Once the octave has ended, ordinary Sundays "post Epiphaniam" are green.
ok(liturgical_color('Dominica II post Epiphaniam') eq 'green', 'An ordinary Sunday after Epiphany is green');

### Septuagesima, Lent, Ember Days - violet

ok(liturgical_color('Dominica in Septuagesima') eq 'purple', 'Septuagesima Sunday is violet');
ok(liturgical_color('Dominica I in Quadragesima') eq 'purple', 'The first Sunday of Lent is violet');
ok(
  liturgical_color('Feria Quarta Quattuor Temporum Septembris') eq 'purple',
  'The September Ember Wednesday is violet',
);

### Passiontide and Holy Week

ok(liturgical_color('Dominica de Passione') eq 'purple', 'Passion Sunday is violet');
ok(liturgical_color('Dominica I Passionis') eq 'purple', 'Passion Sunday is violet');
ok(liturgical_color('Dominica in Palmis') eq 'purple', 'Palm Sunday is violet');
ok(liturgical_color('Dominica II Passionis seu in Palmis') eq 'purple', 'Palm Sunday is violet');
ok(liturgical_color('Feria Secunda in Rogationibus') eq 'purple', 'Rogation Monday is violet');

# The eve of the Ascension (Wednesday of Rogation week) has two real titles:
# the older one keeps the Rogation Days' own violet, while the 1960-rubrics
# title drops the Rogation reference and is the Ascension Vigil proper
# (white) - see the comment on the anchored branch in Main.pm.
ok(
  liturgical_color('Feria Quarta in Rogationibus in Vigilia Ascensionis') eq 'purple',
  'Eve of the Ascension, pre-1960 title (still a Rogation Day), is violet',
);
ok(
  liturgical_color('In Vigilia Ascensionis') eq 'black',
  'Eve of the Ascension, 1960-rubrics title (Ascension Vigil proper), is white',
);

ok(liturgical_color('Feria Quinta in Cena Domini') eq 'black', 'Holy Thursday (Mass "in Cena Domini") is white');

# Good Friday also has two real titles, both correctly grey (the app's
# stand-in for black vestments) since the grey pattern recognizes both the
# older "Parasceve" and the 1955/1960-rubrics "Morte" wording.
ok(liturgical_color('Feria Sexta in Parasceve') eq 'grey', 'Good Friday, pre-1960/1955 title, is black (grey here)');
ok(
  liturgical_color('Feria Sexta in Passione et Morte Domini') eq 'grey',
  'Good Friday, 1955/1960-rubrics title, is still black (grey here) despite also containing "Passione"',
);

ok(liturgical_color('Sabbato Sancto') eq 'purple', 'Holy Saturday (before the Vigil) is violet');

### Tempus Paschale (Eastertide) - white

ok(liturgical_color("Die II infra octavam Pasch\x{e6}") eq 'black', 'Easter Monday is white');

# Easter Sunday's real title doesn't actually contain "Pascha" at all (it
# says "Resurrectionis"), so unlike most of the Easter octave, this reaches
# white via the default fallback rather than the black2 "Pasch" keyword.
ok(liturgical_color('Dominica Resurrectionis') eq 'black', 'Easter Sunday itself is white, via the default fallback');
ok(liturgical_color("Dominica in Albis in Octava Pasch\x{e6}") eq 'black', 'Sundays after Easter are white');
ok(liturgical_color('Dominica III post Pascha') eq 'black', 'Sundays after Easter are white');
ok(liturgical_color('Dominica infra Octavam Ascensionis') eq 'black', 'Sundays after Ascension is white');

### Pentecost - red

ok(liturgical_color('Sabbato in Vigilia Pentecostes') eq 'red', 'The Vigil of Pentecost is red');
ok(liturgical_color('Dominica Pentecostes') eq 'red', 'Pentecost Sunday is red');

### Tempus post Pentecosten (Time after Pentecost)

ok(
  liturgical_color("Dominica Sanctissim\x{e6} Trinitatis") eq 'black',
  'Trinity Sunday is white (also a real-data near-miss for the blue Marian pattern)',
);
ok(liturgical_color('Festum Sanctissimi Corporis Christi') eq 'black', 'Corpus Christi is white');

# A Sunday falling within the Octave of Corpus Christi keeps that white
# octave rather than the ordinary green of Time after Pentecost - this is
# exactly the real-world case the green pattern's negative lookahead exists
# for ("Pentecosten" followed later by "infra octavam" is excluded).
ok(
  liturgical_color('Dominica II Post Pentecosten infra Octavam Corporis Christi') eq 'black',
  'A Sunday within the Corpus Christi octave stays white, not green',
);

ok(liturgical_color('Sacratissimi Cordis Domini Nostri Jesu Christi') eq 'black', 'The Sacred Heart is white');
ok(liturgical_color('Domini Nostri Jesu Christi Regis') eq 'black', 'Christ the King is white');

# Ordinary Sundays after Pentecost, including the last one of the liturgical
# year, are green.
ok(liturgical_color('Dominica X Post Pentecosten') eq 'green', 'An ordinary Sunday after Pentecost is green');
ok(
  liturgical_color('Dominica XXIV et Ultima Post Pentecosten') eq 'green',
  'The last Sunday after Pentecost is also green',
);

### Sanctorale: Marian feasts - blue
# The actual liturgical color for Marian feasts is white, but the app renders them as blue
# to distinguish them from other white feasts (Christmastide, Eastertide, Confessors, etc.) that are not Marian.

ok(liturgical_color("In Purificatione Beat\x{e6} Mari\x{e6} Virginis") eq 'blue', 'Candlemas is blue');
ok(liturgical_color("In Annuntiatione Beat\x{e6} Mari\x{e6} Virginis") eq 'blue', 'The Annunciation is blue');
ok(liturgical_color("In Assumptione Beat\x{e6} Mari\x{e6} Virginis") eq 'blue', 'The Assumption is blue');
ok(liturgical_color("Assumptio BeatBeat\x{e6} Mari\x{e6} Mari\x{e6} Virginis") eq 'blue', 'The Assumption is blue');
ok(
  liturgical_color("In Conceptione Immaculata Beat\x{e6} Mari\x{e6} Virginis") eq 'blue',
  'The Immaculate Conception is blue',
);
ok(liturgical_color("In Nativitate Beat\x{e6} Mari\x{e6} Virginis") eq 'blue', 'The Nativity of Mary is blue');
ok(liturgical_color("Beat\x{e6} Mari\x{e6} Virginis a Rosario") eq 'blue', 'Our Lady of the Rosary is blue');

### Sanctorale: red feasts (martyrs, apostles, the Holy Cross)

ok(liturgical_color("In Exaltatione Sanct\x{e6} Crucis") eq 'red', 'The Exaltation of the Holy Cross is red');
ok(liturgical_color('SS. Apostolorum Petri et Pauli') eq 'red', 'Ss Peter and Paul (apostles and martyrs) is red');
ok(liturgical_color('S. Laurentii Martyris') eq 'red', 'St Lawrence (martyr) is red');
ok(liturgical_color('Ss. Fabiani et Sebastiani Martyrum') eq 'red', 'Ss Fabian and Sebastian (martyrs) is red');
ok(liturgical_color("S. Marci Evangelist\x{e6}") eq 'red', 'St Mark Evangelist is red');

### Sanctorale: white feasts, several of them real-data near-misses for blue

ok(
  liturgical_color("In Nativitate S. Joannis Baptist\x{e6}") eq 'black',
  'The Nativity of St John the Baptist is white',
);
ok(
  liturgical_color('S. Joseph Sponsi B.M.V. Confessoris') eq 'black',
  'St Joseph, Spouse of the BVM (a confessor), is white despite mentioning the BVM',
);
ok(liturgical_color('S. Francisci Confessoris') eq 'black', 'St Francis (a confessor) is white');
ok(liturgical_color('S. Joseph Opificis') eq 'black', 'St Joseph the Worker (a 1960-rubrics-specific feast) is white');
ok(liturgical_color('Sanctissimi Nominis Jesu') eq 'black', 'The Holy Name of Jesus is white');
ok(liturgical_color('Omnium Sanctorum') eq 'black', 'All Saints is white');

### All Souls - black (grey here)

ok(liturgical_color('In Commemoratione Omnium Fidelium Defunctorum') eq 'grey', 'All Souls is black (grey here)');
