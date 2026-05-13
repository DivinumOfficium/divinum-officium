use strict;
use warnings;
use lib 'web/cgi-bin';
use DivinumOfficium::Lexicon qw(apply_interlinear);
use Test::Simple tests => 6;

$ENV{LEXICON_PATH} = 't/fixtures/latin_lexicon_test.json';

my $result = apply_interlinear('Dominus');
ok($result =~ /class="lw"/,    'Known word gets lw span');
ok($result =~ /class="gloss"/, 'Known word gets gloss span');
ok($result =~ /\(Lord\)/,      'Correct gloss for Dominus');

my $unknown = apply_interlinear('xyz123');
ok($unknown eq 'xyz123', 'Unknown word passes through');

my $html = apply_interlinear('<b>Deus</b>');
ok($html =~ m{<b><span class="lw">Deus}, 'HTML tag before word preserved');
ok($html !~ m{<span.*?<b},                'HTML tag not wrapped in span');
