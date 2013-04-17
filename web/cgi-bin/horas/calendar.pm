package horas::calendar;

use strict;

BEGIN
{
	require Exporter;

	our $VERSION = 1.00;
	our @ISA = qw(Exporter);
	our @EXPORT =
	qw(
		cmp_occurrence
		FESTAL_OFFICE SUNDAY_OFFICE FERIAL_OFFICE VIGIL_OFFICE WITHIN_OCTAVE_OFFICE OCTAVE_DAY_OFFICE
		LESSER_DAY GREATER_DAY GREATER_PRIVILEGED_DAY
		SIMPLE_RITE SEMIDOUBLE_RITE DOUBLE_RITE GREATER_DOUBLE_RITE
		PRIMARY_OFFICE SECONDARY_OFFICE
		FIRST_ORDER_OCTAVE SECOND_ORDER_OCTAVE THIRD_ORDER_OCTAVE COMMON_OCTAVE SIMPLE_OCTAVE
		OMIT_LOSER COMMEMORATE_LOSER TRANSLATE_LOSER FROM_THE_CHAPTER
		PARTICULAR_OFFICE UNIVERSAL_OFFICE
	);
}

use constant
{
	FESTAL_OFFICE	=> 0,
	SUNDAY_OFFICE	=> 1,
	FERIAL_OFFICE	=> 2,
	VIGIL_OFFICE	=> 3,
	WITHIN_OCTAVE_OFFICE	=> 4,
	OCTAVE_DAY_OFFICE	=> 5
};

use constant
{
	LESSER_DAY		=> 0,
	GREATER_DAY		=> 1,
	GREATER_PRIVILEGED_DAY	=> 2
};

use constant
{
	SIMPLE_RITE		=> 0,
	SEMIDOUBLE_RITE		=> 1,
	DOUBLE_RITE		=> 2,
	GREATER_DOUBLE_RITE	=> 3
};

use constant
{
	PRIMARY_OFFICE		=> 1,
	SECONDARY_OFFICE	=> 2
};

use constant
{
	FIRST_ORDER_OCTAVE	=> 1,
	SECOND_ORDER_OCTAVE	=> 2,
	THIRD_ORDER_OCTAVE	=> 3,
	COMMON_OCTAVE		=> 4,
	SIMPLE_OCTAVE		=> 5
};

use constant
{
	OMIT_LOSER		=> 1,
	COMMEMORATE_LOSER	=> 2,
	TRANSLATE_LOSER		=> 3,
	FROM_THE_CHAPTER	=> 4
};

use constant
{
	UNIVERSAL_OFFICE	=> 0,
	PARTICULAR_OFFICE	=> 1
};


sub cmp_occurrence_1960
{
	my ($a, $b) = @_;

	# Assume that $b wins until we find otherwise. We multiply the return value by
	# +/- 1 according to the winning office.
	my $sign = 1;

	# Higher-ranked days always win.
	($a, $b, $sign) = ($b, $a, -1) if($$a{rankord} < $$b{rankord});
	if($$b{rankord} < $$a{rankord})
	{
		# If winner is I. cl. or Sunday, restrict to privileged
		# commemorations; otherwise, always commemorate.
		return $sign * COMMEMORATE_LOSER if(
			($$b{rankord} != 1 && $$b{category} != SUNDAY_OFFICE) ||
			($$a{category} == SUNDAY_OFFICE || ($$a{category} == FERIAL_OFFICE && $$a{rankord} <= 3)));

		return $sign * OMIT_LOSER;
	}

	# In the case of equal ranks:

	# Make sure that Office A is a feast if we have any feasts.
	($a, $b, $sign) = ($b, $a, -1) if($$b{category} == FESTAL_OFFICE);
	
	if($$b{rankord} == 1)
	{
		# I. cl. feasts yield to first-class non-feasts
		# (including days in octaves), and are translated.
		return $sign * TRANSLATE_LOSER if($$b{category} != FESTAL_OFFICE);

		# If two I. cl. feasts occur, a universal feast is
		# preferred to a particular one.
		($a, $b, $sign) = ($b, $a, -$sign) if($$a{partic} == UNIVERSAL_OFFICE);
		return $sign * TRANSLATE_LOSER if($$a{partic} == PARTICULAR_OFFICE && $$b{partic} == UNIVERSAL_OFFICE);
		
		# TODO: Otherwise, the feast of greater dignity wins. For
		# now, we guess!
		return -$sign * TRANSLATE_LOSER;
	}
	elsif($$b{rankord} == 2)
	{
		if($$a{category} == FESTAL_OFFICE)
		{
			# II. cl. feast beats day in II. cl. octave and
			# II. cl. vigil.
			return -$sign * COMMEMORATE_LOSER if(grep($$b{category} == $_, (WITHIN_OCTAVE_OFFICE, VIGIL_OFFICE)));

			if($$b{category} == FERIAL_OFFICE)
			{
				# II. cl. feast beats II. cl feria iff
				# feast is universal.
				$sign = -$sign if($$a{partic} == UNIVERSAL_OFFICE);
				return $sign * COMMEMORATE_LOSER;
			}

			return $sign * COMMEMORATE_LOSER if($$b{category} == SUNDAY_OFFICE);

			# Two II. cl. feasts. Universal beats particular.
			($a, $b, $sign) = ($b, $a, -$sign) if($$b{partic} == PARTICULAR_OFFICE);
			return $sign * COMMEMORATE_LOSER if($$b{partic} == UNIVERSAL_OFFICE);
			
			# Two particular II. cl. feasts. Movable beats fixed.
			($a, $b, $sign) = ($b, $a, -$sign) if($$b{calpoint} =~ /^\d\d-\d\d$/);
			return $sign * COMMEMORATE_LOSER;

		}
		else
		{
			# No feasts. This should happen only when a II.
			# cl. Sunday and vigil occur.
			($a, $b, $sign) = ($b, $a, -$sign) if($$a{category} == SUNDAY_OFFICE);
			return $sign * OMIT_LOSER if ($$a{category} == VIGIL_OFFICE && $$b{category} == SUNDAY_OFFICE);

			warn 'cmp_occurrence_1960: Unexpected II. cl. occurrence.';
		}
	}
	elsif($$b{rankord} == 3)
	{
		# Office A should always be a feast at this point.
		
		return -$sign * COMMEMORATE_LOSER if($$b{category} == VIGIL_OFFICE);

		# III. cl. feasts beat Advent ferias but yield to
		# Lenten ones.
		return ($$b{calpoint} =~ /Quad/i ? $sign : -$sign) * COMMEMORATE_LOSER if($$a{category} == FERIAL_OFFICE);

		# III. cl. particular feast beats III. cl. universal
		# feast, in contrast to the II. cl. case.
		($a, $b, $sign) = ($b, $a, -$sign) if($$a{partic} == PARTICULAR_OFFICE);
		return $sign * COMMEMORATE_LOSER if($$a{partic} == UNIVERSAL_OFFICE);

		# Movable particular feast beats fixed.
		($a, $b, $sign) = ($b, $a, -$sign) if($$b{calpoint} =~ /^\d\d-\d\d$/);
		return $sign * COMMEMORATE_LOSER;
	}
	else
	{
		# IV. cl., which means commemorations and lesser ferias.
		return $sign * COMMEMORATE_LOSER if($$b{category} == FERIAL_OFFICE);
	}

	# In the case of parity, or of an invalid combination, indicate that
	# Office A wins. This is intended to reflect the order of feasts in the
	# calendar lists, where higher-ranking feasts come first.
	return -$sign * COMMEMORATE_LOSER;
}


sub cmp_occurrence(\%\%)
{
	return cmp_occurrence_1960(@_) if($::version =~ /1960/);

	my ($a, $b) = @_;

	# Lesser ferias are always omitted in occurrence.
	return  OMIT_LOSER   if($$a{category} == FERIAL_OFFICE && $$a{standing} == LESSER_DAY);
	return -(OMIT_LOSER) if($$b{category} == FERIAL_OFFICE && $$b{standing} == LESSER_DAY);

	# Assume that $b wins until we find otherwise. We multiply the return value by
	# +/- 1 according to the winning office.
	my $sign = 1;

	# Higher-ranked days always win.
	($a, $b, $sign) = ($b, $a, -$sign) if($$a{rankord} < $$b{rankord});
	if($$b{rankord} < $$a{rankord})
	{
		# TODO: Vigils vs. Sundays.

		return $sign * TRANSLATE_LOSER if($$b{rankord} == 1 && $$a{rankord} == 2);

		return $sign * OMIT_LOSER if(
			# Simple feasts and octave days are omitted on I. cl. doubles.
			($$b{rankord} == 1 && $$b{rite} >= DOUBLE_RITE && $$a{rite} == SIMPLE_RITE && grep($$a{category} == $_, (FESTAL_OFFICE, OCTAVE_DAY_OFFICE))) ||
			# Vigils are omitted on greater ferias and days that are
			# genuinely of the first class.
			($$a{category} == VIGIL_OFFICE && (($$b{rankord} == 1 && $$b{category} != OCTAVE_DAY_OFFICE) || ($$b{category} == FERIAL_OFFICE && $$b{rankord} >= 3))) ||
			# Days within common octaves are omitted on doubles of
			# the I. or II. class.
			($$a{category} == WITHIN_OCTAVE_OFFICE && $$a{octrank} == COMMON_OCTAVE && $$b{rankord} <= 2 && $$b{rite} >= DOUBLE_RITE));

		return $sign * COMMEMORATE_LOSER;
	}

	# Equal ranks.
	
	if($$b{rankord} <= 2)
	{
		# Sundays win.
		($a, $b, $sign) = ($b, $a, -$sign) if($$a{category} == SUNDAY_OFFICE);
		return $sign * TRANSLATE_LOSER if($$b{category} == SUNDAY_OFFICE);

		# At this point, at least one of the offices must be a feast,
		# which yields to all non-feasts (which must be a I. cl. vigil,
		# privileged feria or day within an octave of the appropriate
		# order).
		($a, $b, $sign) = ($b, $a, -$sign) if($$b{category} == FESTAL_OFFICE);
		return $sign * TRANSLATE_LOSER if($$b{category} != FESTAL_OFFICE);

		# Must have two feasts now. TODO: Choose the feast of greater
		# dignity.
		return -$sign * TRANSLATE_LOSER;
	}
	else
	{
		# For the remaining possibilities, we synthesise a sub-rank:
		# 	Greater-double octave day >
		# 	Greater double >
		# 	Double >
		# 	Semi-double (feast) >
		# 	(Semi-double) day in III. ord. octave >
		# 	(Semi-double) day in common octave >
		# 	(Simple) greater feria >
		# 	(Simple) vigil >
		# 	Simple octave day >
		# 	TODO: [BVM on Saturday >]
		# 	Simple (feast).
		sub synthsubrank
		{
			my $office = shift;
			return
				$$office{rite} == GREATER_DOUBLE_RITE ?
					$$office{category} == OCTAVE_DAY_OFFICE ? 1 : 2 :
				$$office{rite} == DOUBLE_RITE ? 3 :
				$$office{rite} == SEMIDOUBLE_RITE ?
					$$office{category} == FESTAL_OFFICE ? 4 :
					# Must be in an octave:
					$$office{octrank} == THIRD_ORDER_OCTAVE ? 5 : 6 :
				# Must be simple rite.
				$$office{category} == FERIAL_OFFICE ? 7 :
				$$office{category} == VIGIL_OFFICE ? 8 :
				$$office{category} == OCTAVE_DAY_OFFICE ? 9 :
				10;
		}

		my $a_subrank = synthsubrank($a);
		my $b_subrank = synthsubrank($b);
		($a, $b, $a_subrank, $b_subrank, $sign) = ($b, $a, $b_subrank, $a_subrank, -$sign) if($b_subrank > $a_subrank);

		return $sign * COMMEMORATE_LOSER unless($a_subrank == $b_subrank);
	}

	# TODO: If we're still tied, choose the feast of greater dignity.
	return -$sign * (($$b{rankord} >= 2) ? TRANSLATE_LOSER : COMMEMORATE_LOSER);
}

1;

