# These need to be included as part of the main package for the time being.
require "horas/horascommon.pl";
require "horas/dialogcommon.pl";
require "horas/do_io.pl";

package DivinumOfficium::Calendar::Data;

use strict;
use warnings;

use List::Util qw(min);
use Digest::MD5 qw(md5_hex);

use DivinumOfficium::Calendar::Definitions;

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(
    load_calendar_file
    get_implicit_office
    get_all_offices
    generate_rank_line
  );
}

# Parse the rank line from the calendar file and return a hash representing it.
sub parse_rank_line
{
  local $_ = shift;
  my $version = shift;

  my %rank;

  if(s/Festum(\s+Domini)?\s+//i)
  {
    $rank{category} = FESTAL_OFFICE;
    $rank{tags} = 'Festum Domini' if($1);
  }
  elsif(s/Dominica(\s+Ma[ij]or)?\s+//i)
  {
    $rank{category} = SUNDAY_OFFICE;
    $rank{standing} = $1 ? GREATER_DAY : LESSER_DAY;
  }
  elsif(s/Feria(\s+Ma[ij]or(\s+Privilegiata)?)?\s+//i)
  {
    $rank{category} = FERIAL_OFFICE;
    $rank{standing} = $1 ? ($2 ? GREATER_PRIVILEGED_DAY : GREATER_DAY) : LESSER_DAY;
  }
  elsif(s/Vigilia\s+//i) { $rank{category} = VIGIL_OFFICE; }
  elsif(s/Dies\s+infra\s+octavam\s+//i) { $rank{category} = WITHIN_OCTAVE_OFFICE; }
  elsif(s/Dies\s+octava\s+//i) { $rank{category} = OCTAVE_DAY_OFFICE; }
  else {warn "parse_rank_line: Missing category: $_";}

  if($rank{category} == WITHIN_OCTAVE_OFFICE || $rank{category} == OCTAVE_DAY_OFFICE)
  {
    s/(?:(I|II|III)\.\s+ordinis|(communis|communem)|simplex)\s+//i;
    $rank{octrank} = $1 ? length($1) : ($2 ? COMMON_OCTAVE : SIMPLE_OCTAVE);
  }

  $rank{rite} =  s/Duplex ma[ij]us\s*//i ? GREATER_DOUBLE_RITE :
      s/Semiduplex\s*//i ?                 SEMIDOUBLE_RITE :
      s/Duplex\s*//i ?                     DOUBLE_RITE :
      (s/Simplex\s*//i,                    SIMPLE_RITE);

  if(s/Primaria\s*//i) { $rank{nobility} = PRIMARY_OFFICE; }
  elsif(s/Secundaria\s*//i) { $rank{nobility} = SECONDARY_OFFICE; }

  if(/(IV|III|II|I)\.\s+classis/i)
  {
    my $class = $1;
    $rank{rankord} = ($class =~ /V/i) ? 4 : length($class);
  }
  else
  {
    $rank{rankord} = implicit_rank_ordinal($version, \%rank);
  }

  # In 1955, semidoubles became simples, and simples became commemorations. We
  # handled the latter above, so now we can do the former without introducing
  # ambiguity. They become "III. cl. simples".
  if($version =~ /1955/ && $rank{rite} == SEMIDOUBLE_RITE)
  {
    $rank{rite} = SIMPLE_RITE;
  }

  return %rank;
}


#*** implicit_rank_ordinal($version, \%desc)
# Returns the rank to be used for a descriptor when the calendar has not
# overriden it.
sub implicit_rank_ordinal
{
  my ($version, $desc_ref) = @_;

  $desc_ref->{category} == SUNDAY_OFFICE ?
    ($desc_ref->{standing} == GREATER_DAY ? 2 : 3) :
  $desc_ref->{category} == FERIAL_OFFICE ?
    ($desc_ref->{standing} == GREATER_PRIVILEGED_DAY ?
      1 :
      ($desc_ref->{standing} == GREATER_DAY ? 3 : 4)) :
  $desc_ref->{category} == FESTAL_OFFICE ?
    ($desc_ref->{rite} == SIMPLE_RITE ? 4 : 3) :
  $desc_ref->{category} == OCTAVE_DAY_OFFICE ?
    ($desc_ref->{octrank} <= SECOND_ORDER_OCTAVE ? 1 :
     $desc_ref->{octrank} <= COMMON_OCTAVE       ? 3 : 4) :
  $desc_ref->{category} == WITHIN_OCTAVE_OFFICE ?
    min($desc_ref->{octrank}, 3) :
  $desc_ref->{category} == VIGIL_OFFICE ? ($version =~ /1960/ ? 3 : 4) :
  # Otherwise:
    4;
}


#*** generate_rank_line($version, \%office_desc)
# Given an office descriptor, generates a rank line for it.
sub generate_rank_line
{
  my $office_desc_ref = shift;
  my $category = $office_desc_ref->{category};
  my $rankline = office_category_string($category) . ' ';

  if ($category == OCTAVE_DAY_OFFICE)
  {
    $rankline .= office_octrank_string($office_desc_ref->{octrank}) . ' ';
  }
  elsif ($category == WITHIN_OCTAVE_OFFICE)
  {
    $rankline .= office_octrank_string_infra($office_desc_ref->{octrank}) . ' ';
  }

  if (exists($office_desc_ref->{standing}) &&
    $office_desc_ref->{standing} != LESSER_DAY)
  {
    $rankline .= office_standing_string($office_desc_ref->{standing}) . ' ';
  }

  if (exists($office_desc_ref->{nobility}))
  {
    $rankline .= office_nobility_string($office_desc_ref->{nobility}) . ' ';
  }

  $rankline .= office_rite_string($office_desc_ref->{rite}) . ' ';

  # TODO: Not quite right, but it'll do for now.
  $rankline .= ('I' x $office_desc_ref->{rankord}) . '. classis';

  return ucfirst($rankline);
}


# Aliases for certain key=value pairs in calendar files.
{
  my %alias_pairs =
  (
    'de tempore'        => ['cycle', TEMPORAL_OFFICE],
    'proprio sanctorum' => ['cycle', SANCTORAL_OFFICE],
  );

  sub get_aliased_field_and_value
  {
    return @{$alias_pairs{canonicalise_tag(shift)} // []};
  }
}


# *** canonicalise_tag
# Put tags -- i.e. null-valued fields -- into a canonical form: lowercase,
# trimmed and with single spaces for all internal whitespace.
sub canonicalise_tag
{
  local $_ = lc(shift);

  s/^\s*(.*?)\s*$/$1/;
  s/\s+/ /g;
  s/\N{U+00E6}/ae/g;
  s/\N{U+0153}/oe/g;

  return $_;
}


sub generate_internal_office_fields
{
  my $version = shift;
  my $office_ref = shift;

  my %rank = parse_rank_line($office_ref->{rank}, $version);
  $office_ref->{$_} = $rank{$_} foreach(keys(%rank));

  if(exists($office_ref->{occurrencerules}))
  {
    $office_ref->{occurrencetable} = {$office_ref->{occurrencerules} =~ /([^,]*),([^;]*);?/g};
    my %keywords = (OMIT => OMIT_LOSER, COMMEMORATE => COMMEMORATE_LOSER, TRANSLATE => TRANSLATE_LOSER);
    $_ = $keywords{$_} foreach(values(%{$office_ref->{occurrencetable}}));
  }

  $office_ref->{firstvespers} =
    $version =~ /1955|1960/ ?
      # In the later rubrics, only high-ranking offices and Sundays have first
      # vespers.
      ($office_ref->{category} == FESTAL_OFFICE && $office_ref->{rankord} <= ($version =~ /1960/ ? 1 : 2)) || 
      $office_ref->{category} == SUNDAY_OFFICE
      :
      # Otherwise, only vigils and ferias lack them. Days in octaves are
      # complicated and are handled elsewhere; we label them as having both
      # vespers, since that is potentially true.
      ($office_ref->{category} != VIGIL_OFFICE && $office_ref->{category} != FERIAL_OFFICE);

  # Vigils never have second vespers; all other offices have them, except for
  # simple non-ferias.
  $office_ref->{secondvespers} =
    !exists($office_ref->{'officium terminatur post nonam'}) &&
    $office_ref->{category} != VIGIL_OFFICE &&
    ($office_ref->{category} == FERIAL_OFFICE || $office_ref->{rite} != SIMPLE_RITE);
}


sub load_calendar_file($$;$)
{
  my ($datafolder, $filename, $basecal) = @_;
  my %global_defaults = (partic => $basecal ? PARTICULAR_OFFICE : UNIVERSAL_OFFICE);

  $basecal ||= {offices => {}, calpoints => {}};

  my %caldata = %{horas::setupstring($datafolder, '', $filename)};

  foreach my $calpoint (keys(%caldata))
  {
    my $caldata_entry = $caldata{$calpoint};
    my @implicit_fields = ('title', 'rank');
    my %office;

    my $insertion_index = -1;

    foreach ($caldata_entry =~ /(.+?)$/mg)
    {
      my ($field, $value) = /(?:([^=]*)=)?(.*)$/;
      $field ||= shift(@implicit_fields);

      # If we still don't have a field, try to interpret this line as an alias
      # for a particular field and value pair.
      if(!$field)
      {
        my @aliased_pair = get_aliased_field_and_value($value);
        ($field, $value) = @aliased_pair if(@aliased_pair);
      }

      if($field)
      {
        $office{$field} = $value;
      }
      else
      {
        # Treat this as a null-valued field, whose name is specified by what we
        # had hitherto been thinking of as the value.
        $office{canonicalise_tag($value)} = undef;
      }
    }

    {
      # We expect that some values in %office might be undefined.
      no warnings 'uninitialized';
      $office{id} = "$calpoint-" . md5_hex(%office) unless(exists($office{id}));
    }

    my $inplace_modification = 0;

    if(exists($$basecal{offices}{$office{id}}))
    {
      # We're modifying an existing office.

      # Find the existing office's position in the array of
      # offices for its day.
      my $existing_index;
      for($existing_index = 0;
        $$basecal{calpoints}{$$basecal{offices}{$office{id}}{calpoint}}[$existing_index] ne $office{id};
        $existing_index++) {}

      if($$basecal{offices}{$office{id}}{calpoint} eq $calpoint)
      {
        # The office isn't changing day, so act as if we
        # had inserted it at its current position.
        $insertion_index = $existing_index;

        $inplace_modification = 1;
      }
      else
      {
        # Unlink from old calpoint.
        splice($$basecal{calpoints}{$calpoint}, $existing_index, 1);
      }
      
      my $old_office = $$basecal{offices}{$office{id}};

      $office{$_} //= $$old_office{$_} foreach(keys(%$old_office));
    }
    else
    {
      my %def_ce = default_calentry($calpoint);
      $office{$_} //= $def_ce{$_} foreach(keys(%def_ce));
    }

    next unless(exists($office{rank}));

    generate_internal_office_fields($horas::version, \%office);
    $office{calpoint} = $calpoint;

    $office{$_} //= $global_defaults{$_} foreach(keys(%global_defaults));

    # Now we insert the office in all the correct places.
    
    $$basecal{offices}{$office{id}} = \%office;

    # Link to the the office at the appropriate calpoint (unless
    # it's already linked there).
    my $calpoint_arr = ($$basecal{calpoints}{$calpoint} ||= []);
    splice @$calpoint_arr, ++$insertion_index, 0, $office{id} unless($inplace_modification);
    
    # Make sure the new/modified office is in the correct place in
    # the list.
    if(@$calpoint_arr > 1)
    {
      @$calpoint_arr[$insertion_index, $insertion_index + 1] = @$calpoint_arr[$insertion_index + 1, $insertion_index++]
        while(cmp_occurrence($$basecal{offices}{$$calpoint_arr[$insertion_index]}, $$basecal{offices}{$$calpoint_arr[$insertion_index + 1]}) > 0);
      @$calpoint_arr[$insertion_index, $insertion_index - 1] = @$calpoint_arr[$insertion_index - 1, $insertion_index--]
        while(cmp_occurrence($$basecal{offices}{$$calpoint_arr[$insertion_index - 1]}, $$basecal{offices}{$$calpoint_arr[$insertion_index]}) > 0);
    }
  }

  return $basecal;
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
  my $calpoint = shift;
  local $_ = $calpoint;
  my @feria = ('', 'Feria Secunda', 'Feria Tertia', 'Feria Quarta', 'Feria Quinta', 'Feria Sexta', 'Sabbato');
  my @feriarom = ('', 'Feria II', 'Feria III', 'Feria IV', 'Feria V', 'Feria VI', 'Sabbato');
  my $sanctoral = /^\d\d-/;
  my @calentry = ('filename' => ($sanctoral ? 'Sancti/' : 'Tempora/') . $_, 'cycle' => $sanctoral ? SANCTORAL_OFFICE : TEMPORAL_OFFICE);

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
  elsif(/^Pasc(\d)-(\d)$/i && $1 >= 1 && $1 <= 5)
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


# *** get_implicit_office($calpoint)
# Returns the office implicitly falling on $calpoint, if any exists, and undef
# otherwise. This is intended for generating ferias and Sundays.
sub get_implicit_office
{
  my $calpoint = shift;

  my %office = default_calentry($calpoint);
  return exists($office{title}) ? \%office : undef;
}


sub get_all_offices
{
  my ($calendar_ref, $calpoint) = @_;

  if(exists($calendar_ref->{calpoints}{$calpoint}))
  {
    # Easy case: everything is explicit. Dereference the offices.
    return map {$calendar_ref->{offices}{$_}} @{$calendar_ref->{calpoints}{$calpoint}};
  }
  
  # No entry for this calpoint, so see whether we have an implicit office.
  my $implicit_office_ref = get_implicit_office($calpoint);
  if($implicit_office_ref)
  {
    generate_internal_office_fields($horas::version, $implicit_office_ref);
    $implicit_office_ref->{calpoint} = $calpoint;
    $implicit_office_ref->{partic} = UNIVERSAL_OFFICE;

    return ($implicit_office_ref);
  }

  return ();
}

1;

