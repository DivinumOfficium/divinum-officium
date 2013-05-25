# These need to be included as part of the main package for the time being.
require "horas/horascommon.pl";
require "horas/dialogcommon.pl";
require "horas/do_io.pl";

package horas::caldata;

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";

use List::Util qw(min);
use Digest::MD5 qw(md5_hex);

use horas::caldef;

BEGIN
{
  require Exporter;

  our $VERSION = 1.00;
  our @ISA = qw(Exporter);
  our @EXPORT_OK = qw(load_calendar_file get_implicit_office get_all_offices);
}

# Parse the rank line from the calendar file and return a hash representing it.
sub parse_rank_line($)
{
  local $_ = shift;

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
    $rank{rankord} = ($1 =~ /V/i) ? 4 : length($1);
  }
  else
  {
    $rank{rankord} =
      $rank{category} == SUNDAY_OFFICE ?        ($rank{standing} == GREATER_DAY ? 2 : 3) :
      $rank{category} == FERIAL_OFFICE ?        ($rank{standing} == GREATER_PRIVILEGED_DAY ? 1 : ($rank{standing} == GREATER_DAY ? 3 : 4)) :
      $rank{category} == FESTAL_OFFICE ?        ($rank{rite} == SIMPLE_RITE ? 4 : 3) :
      $rank{category} == OCTAVE_DAY_OFFICE ?    ($rank{octrank} <= 2 ? 1 : 3):
      $rank{category} == WITHIN_OCTAVE_OFFICE ? min($rank{octrank}, 3) :
      $rank{category} == VIGIL_OFFICE ?         ($::version =~ /1960/ ? 3 : 4) :
                                                4;
  }

  return %rank;
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
    return @{$alias_pairs{lc(shift)} // []};
  }
}


sub load_calendar_file($$;$)
{
  my ($datafolder, $filename, $basecal) = @_;
  my %global_defaults = (partic => $basecal ? PARTICULAR_OFFICE : UNIVERSAL_OFFICE);

  $basecal ||= {offices => {}, calpoints => {}};

  my %caldata = %{::setupstring($datafolder, '', $filename)};

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

      $office{$field} = $value;
    }

    $office{id} ||= "$calpoint-" . md5_hex(%office);

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
      
      my $old_office = $$basecal{offices}{$office{id}}{office};

      $office{$_} //= $$old_office{$_} foreach(keys(%$old_office));
    }
    else
    {
      my %def_ce = default_calentry($calpoint);
      $office{$_} //= $def_ce{$_} foreach(keys(%def_ce));
    }

    next unless(exists($office{rank}));
    my %rank = parse_rank_line($office{rank});
    $office{$_} = $rank{$_} foreach(keys(%rank));

    $office{$_} //= $global_defaults{$_} foreach(keys(%global_defaults));

    # Now we insert the office in all the correct places.
    
    $$basecal{offices}{$office{id}}{calpoint} = $calpoint;
    $$basecal{offices}{$office{id}}{office} = \%office;

    # Link to the the office at the appropriate calpoint (unless
    # it's already linked there).
    my $calpoint_arr = ($$basecal{calpoints}{$calpoint} ||= []);
    splice @$calpoint_arr, ++$insertion_index, 0, $office{id} unless($inplace_modification);
    
    # Make sure the new/modified office is in the correct place in
    # the list.
    if(@$calpoint_arr > 1)
    {
      @$calpoint_arr[$insertion_index, $insertion_index + 1] = @$calpoint_arr[$insertion_index + 1, $insertion_index++]
        while(cmp_occurrence($$basecal{offices}{$$calpoint_arr[$insertion_index]}{office}, $$basecal{offices}{$$calpoint_arr[$insertion_index + 1]}{office}) > 0);
      @$calpoint_arr[$insertion_index, $insertion_index - 1] = @$calpoint_arr[$insertion_index - 1, $insertion_index--]
        while(cmp_occurrence($$basecal{offices}{$$calpoint_arr[$insertion_index - 1]}{office}, $$basecal{offices}{$$calpoint_arr[$insertion_index]}{office}) > 0);
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
    return map {$calendar_ref->{offices}{$_}{office}} @{$calendar_ref->{calpoints}{$calpoint}};
  }
  
  # No entry for this calpoint, so see whether we have an implicit office.
  my $implicit_office_ref = get_implicit_office($calpoint);
  if($implicit_office_ref)
  {
    # Parse the rank.
    my %rank = parse_rank_line($implicit_office_ref->{rank});
    $implicit_office_ref->{$_} //= $rank{$_} foreach(keys(%rank));

    # TODO: Assign an ID?

    return $implicit_office_ref;
  }

  return ();
}

1;

