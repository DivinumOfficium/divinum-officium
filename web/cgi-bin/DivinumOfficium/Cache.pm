#!/usr/bin/perl
use utf8;

package DivinumOfficium::Cache;

use strict;
use warnings;
use Exporter 'import';
use Digest::SHA qw(sha256_hex);
use File::Path qw(make_path);
use File::Spec;
use Encode qw(encode_utf8);

our @EXPORT_OK = qw(
  get_cache_key
  get_cached_content
  store_cached_content
  cache_enabled
  serve_from_cache_enabled
  build_horas_cache_params
  build_missa_cache_params
  start_output_capture
  end_output_capture
);

# Check if caching is enabled (CACHE_DIR environment variable is set)
sub cache_enabled {
  return defined $ENV{CACHE_DIR} && $ENV{CACHE_DIR} ne '';
}

# Check if serving from cache is enabled
sub serve_from_cache_enabled {
  return cache_enabled()
    && defined $ENV{SERVE_FROM_CACHE}
    && ($ENV{SERVE_FROM_CACHE} eq '1' || lc($ENV{SERVE_FROM_CACHE}) eq 'true');
}

# Generate a cache key from parameters
# Takes a hash of all parameters that affect the output
sub get_cache_key {
  my (%params) = @_;

  # Sort keys for consistent ordering
  my @sorted_keys = sort keys %params;

  # Build a canonical string representation
  my @parts;

  for my $key (@sorted_keys) {
    my $value = $params{$key};
    $value = '' unless defined $value;
    push @parts, "$key=$value";
  }
  my $canonical = join('|', @parts);

  # Generate SHA256 hash for the cache key
  my $hash = sha256_hex(encode_utf8($canonical));

  return $hash;
}

# Get the cache file path for a given key and type
sub _get_cache_path {
  my ($cache_key, $type) = @_;

  my $cache_dir = $ENV{CACHE_DIR};
  return unless $cache_dir;

  # Create subdirectory structure based on first 4 chars of hash
  # This prevents having too many files in one directory
  my $subdir = substr($cache_key, 0, 2);
  my $subsubdir = substr($cache_key, 2, 2);

  my $full_dir = File::Spec->catdir($cache_dir, $type, $subdir, $subsubdir);

  return ($full_dir, File::Spec->catfile($full_dir, "$cache_key.html"));
}

# Retrieve cached content if it exists
# Returns undef if not cached or caching disabled
sub get_cached_content {
  my ($cache_key, $type) = @_;
  $type ||= 'general';

  return unless serve_from_cache_enabled();

  my ($dir, $path) = _get_cache_path($cache_key, $type);
  return unless $path && -f $path;

  # Read and return the cached content
  open my $fh, '<:encoding(utf-8)', $path or return;
  local $/;
  my $content = <$fh>;
  close $fh;

  return $content;
}

# Store content in the cache
# Returns 1 on success, 0 on failure
sub store_cached_content {
  my ($cache_key, $content, $type) = @_;
  $type ||= 'general';

  return 0 unless cache_enabled();
  return 0 unless defined $content && $content ne '';

  my ($dir, $path) = _get_cache_path($cache_key, $type);
  return 0 unless $path;

  # Create directory structure if it doesn't exist
  unless (-d $dir) {
    eval { make_path($dir) };

    if ($@) {
      warn "Cache: Failed to create directory $dir: $@";
      return 0;
    }
  }

  # Write content to cache file
  open my $fh, '>:encoding(utf-8)', $path or do {
    warn "Cache: Failed to write to $path: $!";
    return 0;
  };
  print $fh $content;
  close $fh;

  return 1;
}

# Build cache parameters for Divine Office (horas)
sub build_horas_cache_params {
  my (%args) = @_;

  return (
    type => 'horas',
    date1 => $args{date1} // '',
    version => $args{version} // '',
    version1 => $args{version1} // '',
    version2 => $args{version2} // '',
    lang1 => $args{lang1} // '',
    lang2 => $args{lang2} // '',
    langfb => $args{langfb} // '',
    hora => $args{hora} // '',
    votive => $args{votive} // '',
    expand => $args{expand} // '',
    psalmvar => $args{psalmvar} // '',
    priest => $args{priest} // '',
    Ck => $args{Ck} // '',
    content => $args{content} // '',
    whitebground => $args{whitebground} // '',
    building => $args{building} // '',
    rubrics => $args{rubrics} // '',
    testmode => $args{testmode} // '',
    oldhymns => $args{oldhymns} // '',
  );
}

# Build cache parameters for Mass (missa)
sub build_missa_cache_params {
  my (%args) = @_;

  return (
    type => 'missa',
    date1 => $args{date1} // '',
    version => $args{version} // '',
    lang1 => $args{lang1} // '',
    lang2 => $args{lang2} // '',
    langfb => $args{langfb} // '',
    Propers => $args{Propers} // '',
    missanumber => $args{missanumber} // '',
    votive => $args{votive} // '',
    rubrics => $args{rubrics} // '',
    solemn => $args{solemn} // '',
    Ck => $args{Ck} // '',
    content => $args{content} // '',
    whitebground => $args{whitebground} // '',
    building => $args{building} // '',
    testmode => $args{testmode} // '',
  );
}

# Output capture variables
my $captured_output = '';
my $original_stdout;
my $capture_active = 0;

# Start capturing STDOUT
# Returns 1 if capture started, 0 if caching not enabled
sub start_output_capture {
  return 0 unless cache_enabled();
  return 0 if $capture_active;

  $captured_output = '';

  # Save original STDOUT and redirect to capture variable
  open $original_stdout, '>&', \*STDOUT or do {
    warn "Cache: Failed to duplicate STDOUT: $!";
    return 0;
  };

  close STDOUT;
  open STDOUT, '>', \$captured_output or do {
    # Restore original STDOUT on failure
    open STDOUT, '>&', $original_stdout;
    warn "Cache: Failed to redirect STDOUT: $!";
    return 0;
  };
  binmode(STDOUT, ':encoding(utf-8)');

  $capture_active = 1;
  return 1;
}

# End output capture and return captured content
# Also restores STDOUT and prints the captured content
sub end_output_capture {
  return '' unless $capture_active;

  # Close capture and restore original STDOUT
  close STDOUT;
  open STDOUT, '>&', $original_stdout or die "Cache: Failed to restore STDOUT: $!";
  binmode(STDOUT, ':encoding(utf-8)');
  close $original_stdout;

  $capture_active = 0;

  # Print the captured content to the actual STDOUT
  print $captured_output;

  return $captured_output;
}

# Get the captured output without ending capture (for inspection)
sub get_captured_output {
  return $captured_output;
}

1;
