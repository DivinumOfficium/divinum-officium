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
use JSON::PP;
use Time::HiRes qw(gettimeofday);
use Fcntl qw(:flock);

our @EXPORT_OK = qw(
  get_cache_key
  get_cached_content
  store_cached_content
  cache_enabled
  serve_from_cache_enabled
  build_cache_params
  start_output_capture
  end_output_capture
  cache_log
);

# Check if caching is enabled (CACHE_DIR environment variable is set)
sub cache_enabled {
  return defined $ENV{CACHE_DIR} && $ENV{CACHE_DIR} ne '';
}

# Log cache operations to JSON log file
sub cache_log {
  my ($operation, $data) = @_;

  return unless cache_enabled();

  my $cache_dir = $ENV{CACHE_DIR};
  my $log_file = "$cache_dir/cache.log";

  # Build log entry
  my ($sec, $usec) = gettimeofday();
  my @t = localtime($sec);
  my $timestamp =
    sprintf("%04d-%02d-%02dT%02d:%02d:%02d.%06dZ", $t[5] + 1900, $t[4] + 1, $t[3], $t[2], $t[1], $t[0], $usec);

  # If path is present, make it relative to cache_dir
  my %log_data = %{$data // {}};

  if (exists $log_data{path} && defined $log_data{path} && $log_data{path} ne 'undef') {
    my $path = $log_data{path};

    # Strip cache_dir prefix to make path relative
    if ($path =~ /^\Q$cache_dir\E\/?(.*)$/) {
      $log_data{path} = $1;
    }
  }

  my $entry = {
    timestamp => $timestamp,
    operation => $operation,
    pid => $$,
    cache_dir => $cache_dir,
    %log_data,
  };

  my $json = encode_json($entry);

  # Append to log file with locking
  if (open my $fh, '>>', $log_file) {
    flock($fh, LOCK_EX);
    print $fh "$json\n";
    flock($fh, LOCK_UN);
    close $fh;
  } else {
    warn "Cache: Failed to write to log file $log_file: $!";
  }
}

# Check if serving from cache is enabled
sub serve_from_cache_enabled {
  return
       cache_enabled()
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
  my ($cache_key, $type, $params) = @_;
  $type ||= 'general';

  if (!serve_from_cache_enabled()) {
    cache_log(
      'skip', {
        key => $cache_key,
        type => $type,
        reason => 'serve_from_cache disabled',
        params => $params,
      },
    );
    return;
  }

  my ($dir, $path) = _get_cache_path($cache_key, $type);

  if (!$path || !-f $path) {
    cache_log(
      'miss', {
        key => $cache_key,
        type => $type,
        path => $path // 'undef',
        params => $params,
      },
    );
    return;
  }

  # Read and return the cached content (raw bytes - already UTF-8 encoded)
  open my $fh, '<:raw', $path or do {
    cache_log(
      'miss', {
        key => $cache_key,
        type => $type,
        path => $path,
        error => "open failed: $!",
        params => $params,
      },
    );
    return;
  };
  local $/;
  my $content = <$fh>;
  close $fh;

  my $size = length($content // '');
  cache_log(
    'hit', {
      key => $cache_key,
      type => $type,
      path => $path,
      size => $size,
      params => $params,
    },
  );

  return $content;
}

# Store content in the cache
# Returns 1 on success, 0 on failure
sub store_cached_content {
  my ($cache_key, $content, $type, $params) = @_;
  $type ||= 'general';

  my $content_len = length($content // '');

  if (!cache_enabled()) {
    cache_log(
      'store_skip', {
        key => $cache_key,
        type => $type,
        reason => 'cache disabled',
        params => $params,
      },
    );
    return 0;
  }

  if (!defined $content || $content eq '') {
    cache_log(
      'store_skip', {
        key => $cache_key,
        type => $type,
        reason => 'empty content',
        params => $params,
      },
    );
    return 0;
  }

  my ($dir, $path) = _get_cache_path($cache_key, $type);
  return 0 unless $path;

  # Create directory structure if it doesn't exist
  unless (-d $dir) {
    eval { make_path($dir) };

    if ($@) {
      cache_log(
        'store_error', {
          key => $cache_key,
          type => $type,
          path => $path,
          error => "mkdir failed: $@",
          params => $params,
        },
      );
      return 0;
    }
  }

  # Write content to cache file (raw bytes - already UTF-8 encoded)
  open my $fh, '>:raw', $path or do {
    cache_log(
      'store_error', {
        key => $cache_key,
        type => $type,
        path => $path,
        error => "open failed: $!",
        params => $params,
      },
    );
    return 0;
  };
  print $fh $content;
  close $fh;

  cache_log(
    'store', {
      key => $cache_key,
      type => $type,
      path => $path,
      size => $content_len,
      params => $params,
    },
  );

  return 1;
}

# Build cache parameters from arbitrary key-value pairs
# Normalizes undefined values to empty strings for consistent hashing
# Usage: build_cache_params(type => 'horas', date1 => $date1, version => $version, ...)
sub build_cache_params {
  my (%args) = @_;

  # Normalize all values - convert undef to empty string
  my %normalized;

  for my $key (keys %args) {
    $normalized{$key} = $args{$key} // '';
  }

  return %normalized;
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

  # Save original STDOUT
  open $original_stdout, '>&', STDOUT or do {
    cache_log('capture_error', {error => "Failed to duplicate STDOUT: $!"});
    return 0;
  };

  # Redirect STDOUT to in-memory scalar (no encoding layer - causes issues)
  close STDOUT;
  open STDOUT, '>:utf8', \$captured_output or do {

    # Restore original STDOUT on failure
    open STDOUT, '>&', $original_stdout;
    cache_log('capture_error', {error => "Failed to redirect STDOUT: $!"});

    return 0;
  };

  $capture_active = 1;
  cache_log('capture_start', {pid => $$});
  return 1;
}

# End output capture and return captured content
# Also restores STDOUT and prints the captured content
sub end_output_capture {
  return '' unless $capture_active;

  # Flush and close capture
  STDOUT->flush();
  close STDOUT;

  # Restore original STDOUT
  open STDOUT, '>&', $original_stdout or die "Cache: Failed to restore STDOUT: $!";
  binmode(STDOUT, ':raw');    # Output raw bytes - already UTF-8 encoded
  close $original_stdout;

  $capture_active = 0;

  my $size = length($captured_output // '');
  cache_log('capture_end', {pid => $$, captured_size => $size});

  # Print X-Cache header (miss = freshly generated, not from cache)
  print "X-Cache: miss\n";

  # Print the captured content to the actual STDOUT (raw bytes)
  print $captured_output;

  return $captured_output;
}

# Get the captured output without ending capture (for inspection)
sub get_captured_output {
  return $captured_output;
}

1;
