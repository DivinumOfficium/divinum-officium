#!/usr/bin/perl

use utf8;
use open ':encoding(UTF-8)';
use warnings;
use strict;
use Getopt::Long 'GetOptions';
use Algorithm::Diff ();
use File::Temp 'tempfile';
use URI;

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

my @filters = (
  'kalendar', 'hymns', 'titles', 'psalms', 'antiphons', 'html', 'accents', 'case',
  'ij', 'site', 'urls', 'punctuation', 'spacing', 'cookies',
);
my $filters = join(' ', @filters);

my $USAGE = <<USAGE;
Run divinumofficium regression tests against a current version.
Usage: divinum-replay [options] FILE...

Parameters:
  FILE...   file(s) of tests previously established by divinum-get

Options:
--base=BASE (new) base URL
            defaults to environment DIVINUM_OFFICIUM if defined
            otherwise http://divinumofficium.com
--filter=[+|-]FILTER  suppress (-) or include only (+) differences
                      of type FILTER
--[no]baulk don't report detailed differences if everything
            is different, which could happen if thete is a major
            regression or network issue. These are still failures.
--failures=FILENAME   Write failed test names to FILENAME 
--tests=FILENAME      Read test names from FILENAME
                      Tests specified as FILE.. are also replayed.
                      This option can be specfied multiple times.
--save=FILENAME       Output the current result to this file                      
            
Parameters:
FILTER   one of [$filters]
         When + is specified, compare only the content which
         the filter matches, and ignore everything else.
         This is the default.
         When - is specified, that category is ignored
         when + is specified, everything else is ignored
+hymns,+html       compare only the html presentation of hymns
+psalms,-antiphons compare only psalm textual content
-kalendar    Title of day 
-hymns       Hymns and their titles
-titles      Titles of things
-psalms      Psalm content, antiphony, and order
-antiphons   Psalm and canticle antiphons
-html        HTML and javascript content
-accents     accents and ligatures in all languages (-accents only)
-ij          i vs j (-ij only)
-site        site specifications (from http:// up to /cgi-bin)
-urls        URL strings
-punctuation presence and type of punctuation in text (-punctuation only)
-spacing     all white space (-spaces only)
USAGE

sub show_change($$);
sub title_hash($);

my $filter = '';
my $base_url;
my $failures_path;
my @tests_paths;
my $baulk = 1;
my $new_domain;
my $save;

my $help;

GetOptions(
  'base=s' => \$base_url,
  'baulk!' => \$baulk,
  'filter=s' => \$filter,
  'failures=s' => \$failures_path,
  'tests=s' => \@tests_paths,
  'save=s' => \$save,
  'help' => \$help,
) or die $USAGE;

if ($help) {
  print STDOUT $USAGE;
  exit 0;
}

$base_url = $ENV{DIVINUM_OFFICIUM} unless $base_url;
$base_url = 'http://divinumofficium.com' unless $base_url;

if ($failures_path) {
  open FAILURES, ">$failures_path"
    or die "Cannot write to $failures_path\n";
}

my @filter = split(',', $filter);
push @filter, '-site' unless $filter =~ /site/;

foreach my $f (@filter) {
  die "Invalid filter: $f\n"
    unless $f =~ /^[+-]?(.*)/ && grep $1 eq $_, @filters;
}

# Start with test files named directly on command line.
my @testfiles = @ARGV;

# Add tests from each file of test filenames given on command line.
foreach my $tests_path (@tests_paths) {
  open IN, "<$tests_path" || die "Cannot read $tests_path";

  while (<IN>) {
    chomp;
    push @testfiles, $_;
  }
  close IN;
}

die "Specify at least one FILE.\n" unless @testfiles;

my $url = URI->new($base_url);

foreach my $file (@testfiles) {
  if (open IN, "<$file") {
    print "$file\n";

    if (<IN> =~ /^DIVINUM OFFICIUM TEST CASE\s+(.*)$/) {
      my $old_url = URI->new(scalar <IN>);
      my @old_result = <IN>;
      close IN;

      # Adjust the URL.
      $url->path_query($old_url->path_query);

      # Collect cookies to resend
      my %snd_cookies = ();

      while (@old_result) {
        if ($old_result[0] =~ /^Cookie:(\w*)=(.*)/) {
          $snd_cookies{$1} = $2;
          shift @old_result;
        } else {
          last;
        }
      }

      # Collect cookies to compare
      my %old_cookies = ();

      while (@old_result) {
        if ($old_result[0] =~ /^Set-Cookie:(\w*)=(.*)/) {
          $old_cookies{$1} = $2;
          shift @old_result;
        } else {
          last;
        }
      }

      # Arrange jar to receive cookies on download.
      my ($new_jar_h, $new_jar_fn) = tempfile(UNLINK => 1);

      # Assemble the download curl command.
      my $cmd = "curl -s -c $new_jar_fn";
      $cmd .= " -b $_=$snd_cookies{$_}" for sort keys %snd_cookies;
      $cmd .= " '$url'";

      #print "$cmd\n";

      # Finally replay the download.
      my $new_result = `$cmd`;

      if ($save) {
        open SAVE, ">$save" or die "Cannot write $save.";
        print SAVE $new_result;
        close SAVE;
      }

      unless ($? == 0) {
        warn "cannot download $url\n";
        next;
      }
      my @new_result = split /^/, $new_result;

      unless (@new_result) {
        warn "no content from $url\n";
        next;
      }

      # Ingest newly received cookies.
      my %new_cookies = ();
      open $new_jar_h, "<$new_jar_fn";

      for (<$new_jar_h>) {
        chomp;

        if (/^Set-Cookie:\s*(.*)$/) {

          # Header-style jar
          for (split /;/, $1) {
            $new_cookies{$1} = $2 if /^\s*(\w+)=(\S*)\s*$/;
          }
        } elsif (/\t/) {

          # Netscape-style jar: ignore hostname etc
          my @c = split /\t/;
          $new_cookies{$c[5]} = $c[6] if @c > 6;
        }
      }
      close $new_jar_h;

      # Capture and hash the calendar lines.

      my $old_kal = '';

      for (@old_result) {
        if (!$old_kal && /<FONT COLOR=[^"]/ && !/COLOR=MAROON/ && !/HREF/) {
          $old_kal = title_hash($_);
        }
      }

      my $new_kal = '';

      for (@new_result) {
        if (!$new_kal && /<FONT COLOR=[^"]/ && !/COLOR=MAROON/ && !/HREF/) {
          $new_kal = title_hash($_);
        }
      }

      # Ignore specified differences.
      foreach (@filter) {
        my $ignore = /-/;

        if (/cookie/) {
          if ($ignore) {
            %old_cookies = ();
            %new_cookies = ();
          }

        } elsif (/site/) {
          if ($ignore) {

            # Ignore site specification
            s/https?..[^ ]*(cgi-bin|www)./.../g for @old_result, @new_result;
          } else {
            for (@old_result, @new_result) {
              $_ = '...' unless /https?:..[^ ]*cgi-bin/;
            }
          }

        } elsif (/case/) {
          if ($ignore) {

            # TODO : this properly using Unicode
            tr/A-Z/a-z/ for @old_result, @new_result;
          } else {
            warn "skipping filter +$_\n";
          }
        } elsif (/ij/) {
          if ($ignore) {

            # TODO : this better (!!)
            tr/Jj/Ii/ for @old_result, @new_result;
          } else {
            warn "skipping filter +$_\n";
          }

        } elsif (/accents/) {
          if ($ignore) {

            # Write accented letters back to nonaccented.
            # TODO do this for Hungarian as well
            for (@old_result, @new_result) {
              tr/áéëíóúýÁÉËÍÓÚÝ/aeeiouyAEEIOUY/;
              s/[æǽ]/ae/g;
              s/[ÆǼ]/Ae/g;
              s/œ/oe/g;
              s/Œ/Oe/g;
            }
          } else {
            warn "skipping filter +$_\n";
          }

        } elsif (/urls/) {
          for (@old_result, @new_result) {
            my @bits = split(/(\bhttp:[^ '"]*)/, $_);

            for (@bits) {
              my $url = /^http/;

              if ($url == $ignore) {
                $_ = ' ';
              }
            }
            $_ = join('', @bits);
          }

        } elsif (/html/) {
          for (@old_result, @new_result) {

            # doesn’t handle multi line comments, sorry
            my @bits = split(/(<!--.*-->|<[^<>]*>)/, $_);

            for (@bits) {
              my $html = /^</;

              if ($html == $ignore) {
                $_ = '</>';
              }
            }
            $_ = join('', @bits);
          }

        } elsif (/kalendar/) {
          if ($ignore) {
            $old_kal = '';
            $new_kal = '';

          }

          for (@old_result, @new_result) {

            # Ad hoc!
            my $match = /<FONT COLOR=[^"]/ && !/COLOR=MAROON/ && !/HREF/;

            if ($match == $ignore) {
              $_ = "...";
            }
          }

        } elsif (/titles/) {
          for (@old_result, @new_result) {

            # Ad hoc!
            my $match = /^<FONT SIZE=\+/
              || (/^<FONT COLOR="red"/ && !/Ant\.|\bV\.|\bR./);

            if ($match == $ignore) {
              $_ = "...";
            }
          }

        } elsif (/spacing/) {
          for (@old_result, @new_result) {

            # Capture interword spaces as escape character,
            # then remove all spaces,
            # then replace the escapes with spaces again.
            s/\b +\b/\x{1E}/g;
            s/ //g;
            s/\x{1E}/ /g;
          }

        } elsif (/punctuation/) {

          # Eliminate punctuation but keep word boundaries.
          # Similar to spacing except capture all punctuation
          for (@old_result, @new_result) {
            s/\b[.,!?:;]+\b/\x{1E}/g;
            s/[.,!?:;]+//g;
            s/\x{1E}/ /g;
          }

        } else {
          warn "$_ filtering not implemented\n";
        }
      }

      # Remove lines marked for deletion.
      my @new_slice = ();

      for (0 .. $#new_result) {
        push @new_slice, $_ if $new_result[$_] ne "...";
      }
      @new_result = @new_result[@new_slice];

      my @old_slice = ();

      for (0 .. $#old_result) {
        push @old_slice, $_ if $old_result[$_] ne "...";
      }
      @old_result = @old_result[@old_slice];

      # Add cookies in key order.
      unshift @old_result, "$_=$old_cookies{$_}\n" for sort keys %old_cookies;
      unshift @new_result, "$_=$new_cookies{$_}\n" for sort keys %new_cookies;

      # Report differences
      my $diff = Algorithm::Diff->new(\@old_result, \@new_result);
      my $printed = 0;

      $diff->Base(1);    # Return line numbers, not indices
    DIFF: while ($diff->Next()) {
        next if $diff->Same();

        if ($failures_path && !$printed) {
          print FAILURES "$file\n";
        }
        my @old = $diff->Items(1);
        my @new = $diff->Items(2);

        if (@old && @new) {
          while (@old || @new) {
            my $old = shift @old;
            my $new = shift @new;
            chomp $old if $old;
            chomp $new if $new;

            if (defined $old && defined $new) {
              my $kal = show_change($old, $new);

              last DIFF if $baulk && $kal && $old_kal ne $new_kal;
            } elsif (defined $old) {
              print "REMOVED $old\n";
            } elsif (defined $new) {
              print "ADDED $new\n";
            }
          }
        } elsif (@old) {
          for (@old) {
            print "REMOVED $_";
          }
        } else {
          for (@new) {
            print "ADDED $_";
          }
        }
      }
    } else {
      warn "$file doesn't look like a test case\n";
      next;
    }
  } else {
    warn "can't read $file\n";
    next;
  }
}
close FAILURES;

# Display a pair of Different lines.
# Return true iff they included kalendar data
sub show_change($$) {
  my $old = shift;
  my $new = shift;
  my $kal = '';

  # Ad hoc test for kalendar data TODO do this properly
  if ($old =~ /FONT COLOR=green.*\/FONT/) {
    $kal = ' CALENDAR';
  }
  my $spaces = ' ' x (length("CHANGED$kal") - 2);

  if (length($old) + length($new) > 100) {

    # Subdivide long diffs into words: they're (usually) text.

    my @old_words = split(/\b/, $old);
    my @new_words = split(/\b/, $new);
    my $diff = Algorithm::Diff->new(\@old_words, \@new_words);

    # Collect the differences, suppressing long bits of sameness.

    my $old_diff = '';
    my $new_diff = '';

    $diff->Base(0);

    while ($diff->Next()) {
      if ($diff->Same()) {
        my @them = $diff->Items(1);
        @them = (@them[0 .. 3], ' ... ', @them[-4 .. -1]) if @them > 10;
        my $them = join('', @them);

        $old_diff .= $them;
        $new_diff .= $them;
      } else {
        $old_diff .= join('', $diff->Items(1));
        $new_diff .= join('', $diff->Items(2));
      }
    }
    print "CHANGED$kal $old_diff\n${spaces}TO $new_diff\n";
  } else {
    print "CHANGED$kal $old\n${spaces}TO $new\n";
  }
  return $kal;
}

# This routine should reduce a title line to a hash string such that
# a) spelling or minor differences in nomenclature result in no change in the hash
# b) sanctoral or computus changes do result in a change in the hash
# (In [default] --baulk mode, on change of hash, subsequent changes are not reported.)
# For now, we take the case-independent initial letters of important words.
sub title_hash($) {
  my $line = shift;
  $line = $_;
  $line =~ s/<[^<>]*>//g;        # throw away HTML
  $line =~ s/~.*//g;             # throw away trailing ~ (class of feast)
  $line =~ s/\b\w{1,3}\b/ /g;    # throw away short words
  $line =~ s/\b(\w)\w*/$1/g;     # keep only initials anyway
  $line =~ s/\W//g;              # throw away nonletters
  $line =~ tr/a-z/A-Z/;          # zap uppercase
  return $line;
}
