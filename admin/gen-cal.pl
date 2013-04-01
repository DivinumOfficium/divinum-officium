#!/usr/bin/perl

use strict;

use FindBin qw($Bin);
require "$Bin/../web/cgi-bin/horas/horascommon.pl";
require "$Bin/../web/cgi-bin/horas/do_io.pl";
require "$Bin/../web/cgi-bin/horas/dialogcommon.pl";

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
	
	return join(' aut ', @rubric_conditions);
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

			$tfer = {map {my @arr = /([^=]*)=([^=]*)/} @tferlines};
		}
		else
		{
			$tfer = {};
		}
	}
}



my @days_in_month = (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
my @calpoints;
my %calentries;

foreach my $month (1..12)
{
	foreach my $day (1..$days_in_month[$month - 1])
	{
		push (@calpoints, "$month-$day");
	}
}

my %weeks = (
	Adv => 4,
	Nat => 2,
	Epi => 6,
	Quadp => 3,
	Quad => 6,
	Pasc => 8,
	Pent => 24,
	PentEpi => 3
);

foreach my $week_class (keys(%weeks))
{
	my $fmt = ($weeks{$week_class} >= 10) ? "%s%02d-%d" : "%s%d-%d";
	for(my $week_num = 1; $week_num <= $weeks{$week_class}; $week_num++)
	{
		for my $day_num (0..6)
		{
			push(@calpoints, sprintf($fmt, $week_class, $week_num, $day_num));
		}
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


# Now we build the entries for the calendar file.
foreach my $calpoint (keys %calentries)
{
	# TODO: Delete auto-generatable days.

	# Group days by similarity.
	
	my @sections;

	my $version_prev = '';
	foreach my $version_curr (@ordered_versions)
	{
		my $cpe_prev = $version_prev && $calentries{$calpoint}{$version_prev};
		my $cpe_curr = $calentries{$calpoint}{$version_curr};

		if(!$cpe_curr)
		{
			# No office for this day for these rubrics.
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
		print ' (rubrica ' . rubric_condition($sec_versions) . ')' unless($sec_version_index == 0);
		print "\n";

		foreach my $field ('title','rank','filename')
		{
			my %value_lookup;

			# Identify the grouping of versions for this field by
			# reversing the hash.
			foreach(@$sec_versions)
			{
				my $lookup_entry = ($value_lookup{$calentries{$calpoint}{$_}{$field}} ||= []);
				push $lookup_entry, $_;
			}

			my @subsections = keys(%value_lookup);

			# Sort this little subsection, too.
			@subsections = sort {min(@ranked_version_indices{@{$value_lookup{$a}}}) <=> min(@ranked_version_indices{@{$value_lookup{$b}}})} @subsections;

			for(my $subsec_index = 0; $subsec_index < @subsections; $subsec_index++)
			{
				my $subsec_val = $subsections[$subsec_index];

				print '(sed rubrica ' . rubric_condition($value_lookup{$subsec_val}) . ') ' unless($subsec_index == 0);
				print "$field=" unless($field eq 'title' || $field eq 'rank');
				print "$subsec_val\n";
			}
		}

		print "\n";
	}
}


1;

