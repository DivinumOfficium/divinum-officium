# These need to be included as part of the main package for the time being.
require "horas/horascommon.pl";
require "horas/dialogcommon.pl";

package horas::caldata;

use strict;
use warnings;

BEGIN
{
	require Exporter;

	our $VERSION = 1.00;
	our @ISA = qw(Exporter);
	our @EXPORT = qw(load_calendar_file default_calentry);
}

sub load_calendar_file($$)
{
	my ($datafolder, $filename) = @_;

	my %cal = %{::setupstring($datafolder, '', $filename)};

	foreach my $calentry (values(%cal))
	{
		my @implicit_fields = ('title', 'rank');
		my @field_pairs;

		foreach ($calentry =~ /(.*?)$/mg)
		{
			push @field_pairs, /(?:([^=]*)=)?(.*)$/;
			my $implicit_field = shift(@implicit_fields);
			$field_pairs[-2] ||= $implicit_field;
		}

		$calentry = {@field_pairs};
	}

	return \%cal;
}

sub roman_numeral($)
{
	use integer;

	my $n = shift;
	my $roman;

	if($n >= 4000)
	{
		warn "roman_numeral: $n is too big.";
		return '';
	}

	my @mod10 = ('', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX');

	my @tens = @mod10;
	tr/IVX/XLC/ foreach(@tens);

	my @hundreds = @mod10;
	tr/IVX/CDM/ foreach(@hundreds);

	my @thousands = ('', 'M', 'MM', 'MMM');

	return $thousands[$n/1000] . $hundreds[$n/100 % 10] . $tens[$n/10 % 10] . $mod10[$n % 10];
}

sub default_calentry($)
{
	local $_ = shift;
	my @feria = ('', 'Feria Secunda', 'Feria Tertia', 'Feria Quarta', 'Feria Quinta', 'Feria Sexta', 'Sabbato');
	my @feriarom = ('', 'Feria II', 'Feria III', 'Feria IV', 'Feria V', 'Feria VI', 'Sabbato');
	my @calentry = ('filename' => (/^\d\d-\d\d$/ ? 'Sancti/' : 'Tempora/') . $_);

	if(/^Adv(\d)-(\d)$/i)
	{
		my $week = roman_numeral($1);
		push @calentry, $2 == 0 ?
			('title' => "Dominica $week Adventus",
			'rank' => 'Dominica Maior Semiduplex II. classis')
			:
			('title' => "$feriarom[$2] infra Hebdomadam $week Adventus",
			'rank' => 'Feria Maior Simplex');
	}
	elsif(/^Epi(\d)-(\d)$/i)
	{
		my $week = roman_numeral($1);
		push @calentry, $2 == 0 ?
			('title' => "Dominica $week Post Epiphaniam",
			'rank' => 'Dominica Semiduplex II. classis')
			:
			('title' => "$feriarom[$2] infra Hebdomadam $week post Epiphaniam",
			'rank' => 'Feria Simplex');
	}
	elsif(/^Quadp(\d)-(\d)$/i && ($1 < 3 || $2 < 3))
	{
		my $week = ('Septuagesima', 'Sexagesima', 'Quinquagesima')[$1-1];
		push @calentry, $2 == 0 ?
			('title' => "Dominica in $week",
			'rank' => 'Dominica Maior Semiduplex II. classis')
			:
			('title' => "$feriarom[$2] infra Hebdomadam ${week}e",
			'rank' => 'Feria Simplex');
	}
	elsif(/^Quad(\d)-(\d)$/i && $1 < 6)
	{
		my $week = roman_numeral($1);
		push @calentry, $2 == 0 ?
			('title' => 'Dominica ' . ($1 == 5 ? 'de Passione' : "$week in Quadragesima"),
			'rank' => 'Dominica Maior Semiduplex I. classis')
			:
			('title' => "$feria[$2] infra Hebdomadam " . ($1 == 5 ? 'Passionis' : "$week in Quadragesima"),
			'rank' => 'Feria Maior Simplex');
	}
	elsif(/^Pasc(\d)-(\d)$/i && $1 >= 2 && $1 <= 5)
	{
		my $week = roman_numeral($1);
		push @calentry, $2 == 0 ?
			('title' => "Dominica $week post Pascha",
			'rank' => 'Dominica Semiduplex II. classis')
			:
			('title' => "$feria[$2] infra Hebdomadam $week post Octavam Paschae",
			'rank' => 'Feria Simplex');
	}
	elsif(/^Pent(\d\d)-(\d)$/i)
	{
		my $week = roman_numeral($1);
		push @calentry, $2 == 0 ?
			('title' => "Dominica $week Post Pentecosten",
			'rank' => 'Dominica Semiduplex II. classis')
			:
			('title' => "$feria[$2] infra Hebdomadam $week post Octavam Pentecostes",
			'rank' => 'Feria Simplex');
	}

	return @calentry;
}

1;

