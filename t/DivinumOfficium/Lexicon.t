use strict;
use warnings;
use lib 'web/cgi-bin';
use DivinumOfficium::Lexicon qw(apply_interlinear);
use Test2::V0;

$ENV{LEXICON_PATH} = 't/fixtures/latin_lexicon_test.json';

my $result = apply_interlinear('Dominus');
like($result, qr/class="lw"/, 'Known word gets lw span');
like($result, qr/class="gloss"/, 'Known word gets gloss span');
like($result, qr/\(Lord\)/, 'Correct gloss for Dominus');

my $unknown = apply_interlinear('xyz123');
is($unknown, 'xyz123', 'Unknown word passes through');

my $html = apply_interlinear('<b>Deus</b>');
like($html, qr{<b><span class="lw">Deus}, 'HTML tag before word preserved');
unlike($html, qr{<span.*?<b}, 'HTML tag not wrapped in span');

done_testing;
