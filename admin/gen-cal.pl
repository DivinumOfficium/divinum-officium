#!/usr/bin/perl

use 5.014;	# Array functions operating on references.
use strict;

use FindBin qw($Bin);
use lib "$Bin/../web/cgi-bin";

require "horas/horascommon.pl";
require "horas/do_io.pl";
require "horas/dialogcommon.pl";

use horas::caldata;

use Data::Dumper;
use List::Util qw(min max);


sub rubric_condition(+)
{
	my @rubrics = @{shift()};
	my @rubric_conditions;

	my %rubric_flags = (
		'pre Trident Monastic' => 1,
		'Trident 1570' => 2,
		'Trident 1910' => 4,
		'Divino Afflatu' => 8,
		'Reduced 1955' => 16,
		'Rubrics 1960' => 32,
		'1960 Newcalendar' => 64);
	my $rubric_flags;

	$rubric_flags |= $rubric_flags{$_} foreach(@rubrics);

	my @shorthand_pairs = (
		'1960' =>	$rubric_flags{'Rubrics 1960'} |	$rubric_flags{'1960 Newcalendar'},
		'tridentina' =>	$rubric_flags{'Trident 1570'} |	$rubric_flags{'Trident 1910'},
		'monastica' =>	$rubric_flags{'pre Trident Monastic'},
		'1570' =>	$rubric_flags{'Trident 1570'},
		'1910' =>	$rubric_flags{'Trident 1910'},
		'Divino' =>	$rubric_flags{'Divino Afflatu'},
		'1955' =>	$rubric_flags{'Reduced 1955'},
		'Rubrics 1960' =>
				$rubric_flags{'Rubrics 1960'},
		'innovata' =>	$rubric_flags{'1960 Newcalendar'});

	for(my $i = 0; $i < @shorthand_pairs; $i += 2)
	{
		if(($rubric_flags & $shorthand_pairs[$i + 1]) == $shorthand_pairs[$i+1])
		{
			push @rubric_conditions, $shorthand_pairs[$i];
			$rubric_flags &= ~$shorthand_pairs[$i+1];
		}
	}
	
	return join(' aut ', map {"rubrica $_"} @rubric_conditions);
}


sub build_rank_line($$)
{
	my ($calpoint, $entry) = @_;
	my $rankline;

	# What sort of day are we?
	for($$entry{title})
	{
		if(/^Dominica/i)
		{
			$rankline = 'Dominica ';
			$rankline .= 'Maior ' if $calpoint =~ /Adv|Quad|Pasc[017]/;
		}
		elsif(/\bVigilia\b/i)
		{
			$rankline = 'Vigilia ';
		}
		elsif(/infra octavam/i)
		{
			$rankline = 'Dies infra octavam ';
			if($$entry{ranknum} >= 6) { $rankline .= 'I. ordinis '; }
			elsif($$entry{ranknum} >= 5) { $rankline .= 'II. ordinis '; }
			elsif(/Nativitatis$|Cordis|Ascensionis/i) { $rankline .= 'III. ordinis '; }
			elsif($$entry{ranknum} >= 2) { $rankline .= 'communem '; }
			else { $rankline .= 'simplex '; }
		}
		elsif(/in octava/i)
		{
			$rankline = 'Dies octava ';
			if($$entry{rite} =~ /Duplex ma[ij]us/i)
			{
				if(/Epiph|Corporis/) { $rankline .= 'II. ordinis '; }
				elsif(/Nativitatis$|Cordis|Ascensionis/i) { $rankline .= 'III. ordinis '; }
				else { $rankline .= 'communis '; }
			}
			else { $rankline .= 'simplex '; }

		}
		elsif(/Feria|Sabbato/i)
		{
			$rankline = 'Feria ';
			if($$entry{rite} =~ /privilegiata/i || $$entry{ranknum} >= 6)
			{
				$rankline .= 'Maior privilegiata ';
			}
			elsif($$entry{rite} =~ /Ma[ij]or/i)
			{
				$rankline .= 'Maior ';
			}
		}
		else
		{
			$rankline = 'Festum ';
			$rankline .= 'Domini ' if ($$entry{rule} =~ /Festum Domini/i);
		}
	}

	for($$entry{rite})
	{
		if(/Semiduplex/i)
		{
			$rankline .= 'Semiduplex';
		}
		elsif(/Duplex ma[ij]us/i)
		{
			$rankline .= 'Duplex maius';
		}
		elsif(/Duplex/i)
		{
			$rankline .= 'Duplex';
		}
		else
		{
			$rankline .= 'Simplex';
		}
	}

	if($$entry{ranknum} >= 6)
	{
		$rankline .= ' I. classis';
	}
	elsif($$entry{ranknum} >= 5)
	{
		$rankline .= ' II. classis';
	}

	return $rankline;
}



our $version;

my %tfer_filenames = (
	'pre Trident Monastic' => ['K500', 'TrM'],
	'Trident 1570' => ['K1570', 'Tr1570'],
	'Trident 1910' => ['K1888', 'Tr1910'],
	'Divino Afflatu' => ['K1942', 'TrDA'],
	'Reduced 1955' => ['K1942', 'Tr1955'],
	'Rubrics 1960' => ['K1960', 'Tr1960'],
	'1960 Newcalendar' => ['K2009', 'TrNewcal']);

use constant {SANCTORAL => 0, TEMPORAL => 1};


# Expand the transfer tables from filenames to the processed files themselves.
foreach my $tfer_filenames (values(%tfer_filenames))
{
	foreach my $tfer (@{$tfer_filenames})
	{
		my $tfer_fname = "$Bin/../web/www/horas/Latin/Tabulae/$tfer.txt";

		if(-e $tfer_fname)
		{
			open(my $fh, '<', $tfer_fname) or die "Couldn't open $tfer: $!";
			my @tferlines = <$fh>;
			close($fh);

			$tfer = {map {my @arr = /(?:[^=]*?\/)?([^=\/]*)=(?:.*?\/)?([^=;]*)/} @tferlines};
		}
		else
		{
			$tfer = {};
		}
	}
}



my @calpoints;
my %calentries;

my @week_pairs = (
	Adv => 4,
	Nat => 2,
	Epi => 6,
	Quadp => 3,
	Quad => 6,
	Pasc => 8,
	Pent => 24,
	PentEpi => 3
);
my %weeks = @week_pairs;

foreach my $week_class (@week_pairs[map {2*$_} (0..$#week_pairs/2)])
{
	my $fmt = ($weeks{$week_class} >= 10) ? "%s%02d-%d" : "%s%d-%d";
	for(my $week_num = $week_class eq 'Pasc' ? 0 : 1; $week_num <= $weeks{$week_class}; $week_num++)
	{
		for my $day_num (0..6)
		{
			push(@calpoints, sprintf($fmt, $week_class, $week_num, $day_num));
		}
	}
}

my @days_in_month = (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

foreach my $month (1..12)
{
	foreach my $day (1..$days_in_month[$month - 1])
	{
		push (@calpoints, sprintf("%02d-%02d", $month, $day));
	}
}



foreach my $calpoint (@calpoints)
{
	my $cycle_index = ($calpoint =~ /^\d\d/) ? SANCTORAL : TEMPORAL;

	foreach $version (keys(%tfer_filenames))
	{
		# Find the right file for this version.
		my $versioned_calpoint = $tfer_filenames{$version}[$cycle_index]{$calpoint};

		if(!$versioned_calpoint)
		{
			# Missing entry means no feast if sanctoral, default if temporal.
			next if($cycle_index == SANCTORAL);
			$versioned_calpoint = $calpoint;
		}

		# Promote to full name.
		my $filename = ($cycle_index == TEMPORAL ? 'Tempora/' : 'Sancti/') . $versioned_calpoint;

		my $file_ref = setupstring("$Bin/../web/www/horas/", 'Latin', "$filename.txt");
		
		if($file_ref)
		{
			my $calpoint_entry = $calentries{$calpoint}{$version} = {};
			my $rankline =
				($version =~ /1960/ && $$file_ref{Rank1960}) ||
				($version =~ /1570/ && $$file_ref{Rank1570}) ||
				$$file_ref{Rank};
			@$calpoint_entry{'title','rite','ranknum'} = split(/;+/, $rankline);
			$$calpoint_entry{rule} = $$file_ref{Rule};
			$$calpoint_entry{filename} = $filename;
			$$calpoint_entry{cycle} = $cycle_index;

			$$calpoint_entry{rank} = build_rank_line($calpoint, $calpoint_entry);
		}
	}
}

# These are ordered by *time* so that similar offices should (heuristically)
# be adjacent.
my @ordered_versions = (
	'pre Trident Monastic',
	'Trident 1570',
	'Trident 1910',
	'Divino Afflatu',
	'Reduced 1955',
	'Rubrics 1960',
	'1960 Newcalendar');

# These are ordered by *importance* for output purposes.
my @ranked_versions = (
	'Divino Afflatu',
	'Rubrics 1960',
	'Trident 1570',
	'Trident 1910',
	'pre Trident Monastic',
	'Reduced 1955',
	'1960 Newcalendar');

my %ranked_version_indices;
@ranked_version_indices{@ranked_versions} = (0..$#ranked_versions);

# Fields that we will actually emit, in the appropriate order.
my @output_fields = ('title', 'rank', 'filename');


# Now we build the entries for the calendar file. We do for-if-exists rather
# than for-keys because we care about the order.
foreach my $calpoint (@calpoints) { if(exists($calentries{$calpoint}))
{
	# Group days by similarity.
	
	my @sections;
	my $have_all_versions = 1;
	my %default_cpe = default_calentry($calpoint);

	my $version_prev = '';
	foreach my $version_curr (@ordered_versions)
	{
		my $cpe_prev = $version_prev && $calentries{$calpoint}{$version_prev};
		my $cpe_curr = $calentries{$calpoint}{$version_curr};

		# Delete any fields whose values are the defaults.
		foreach(keys(%$cpe_curr))
		{
			delete $$cpe_curr{$_} if(lc($$cpe_curr{$_}) eq lc($default_cpe{$_}));
		}

		if(!$cpe_curr || !grep {$_} @$cpe_curr{@output_fields})
		{
			# No entry for this day for these rubrics.
			$have_all_versions = 0;
			next;
		}
		elsif(!$cpe_prev ||
			($$cpe_curr{filename} ne $$cpe_prev{filename} &&
			 $$cpe_curr{title}    ne $$cpe_prev{title})
	 	  )
		{
			# Start a new group containing only this version.
			push @sections, [$version_curr];
		}
		else
		{
			# Add this version to the end of the current group.
			push $sections[-1], $version_curr;
		}

		# Remember the last version that wasn't skipped.
		$version_prev = $version_curr;
	}

	# Sort the array so that more important rubric sets come earlier.
	@sections = sort {min(@ranked_version_indices{@$a}) <=> min(@ranked_version_indices{@$b})} @sections;

	# Emit entry for each group.
	for(my $sec_version_index = 0; $sec_version_index < @sections; $sec_version_index++)
	{
		my $sec_versions = $sections[$sec_version_index];

		print "[$calpoint]";
		print ' (' . rubric_condition($sec_versions) . ')' unless($sec_version_index == 0 && $have_all_versions);
		print "\n";

		# Begin by assuming that all versions have all the implicit
		# fields.
		my $have_all_implicit_fields = 1;

		foreach my $field (@output_fields)
		{
			my %value_lookup;

			# Identify the grouping of versions for this field by
			# reversing the hash.
			foreach(@$sec_versions)
			{
				my $lookup_entry = ($value_lookup{$calentries{$calpoint}{$_}{$field}} ||= []);
				push $lookup_entry, $_;
			}

			# Did any versions omit the field?
			my $have_all_subsec_versions = !exists($value_lookup{''});
			if(!$have_all_subsec_versions)
			{
				$have_all_implicit_fields = 0;
				delete $value_lookup{''};
			}

			my @subsections = keys(%value_lookup);

			# Sort this little subsection, too.
			@subsections = sort {min(@ranked_version_indices{@{$value_lookup{$a}}}) <=> min(@ranked_version_indices{@{$value_lookup{$b}}})} @subsections;

			for(my $subsec_index = 0; $subsec_index < @subsections; $subsec_index++)
			{
				my $subsec_val = $subsections[$subsec_index];

				if($subsec_index != 0 || !$have_all_subsec_versions)
				{
					print '(';
					print 'sed ' if($have_all_subsec_versions);
					print rubric_condition($value_lookup{$subsec_val}) . ') ';
				}

				print "$field=" unless($have_all_implicit_fields && ($field eq 'title' || $field eq 'rank'));
				print "$subsec_val\n";
			}
		}

		print "\n";
	}
} }	# Close a for-if double block.


1;

