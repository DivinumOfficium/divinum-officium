#!/usr/bin/perl
use utf8;
use strict;
use warnings;

# Cache API - Simple REST-like API for cache management
# Endpoints:
#   ?action=status           - Get cache status and statistics
#   ?action=get&key=<hash>   - Get specific cached content
#   ?action=list&type=<type> - List cached entries (optional type filter)
#   ?action=clear&key=<hash> - Clear specific cache entry
#   ?action=clear_all        - Clear all cache (requires confirm=yes)
#   ?action=keys&type=<type> - List all cache keys

use FindBin qw($Bin);
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use JSON::PP;
use File::Find;
use File::Path qw(remove_tree);
use File::Basename;

use lib "$Bin/..";
use DivinumOfficium::Cache qw(cache_enabled serve_from_cache_enabled);

my $q = CGI->new;

# Token authentication
my $required_token = $ENV{CACHE_ADMIN_TOKEN} || '';
my $provided_token = $q->param('token') || '';

if ($required_token eq '') {
  print "Content-type: application/json; charset=utf-8\n\n";
  print '{"error":"CACHE_ADMIN_TOKEN environment variable not configured"}';
  exit;
}

if ($provided_token ne $required_token) {
  print "Content-type: application/json; charset=utf-8\n\n";
  print '{"error":"Invalid or missing token parameter"}';
  exit;
}

my $action = $q->param('action') || 'status';
my $key = $q->param('key') || '';
my $type = $q->param('type') || '';
my $confirm = $q->param('confirm') || '';
my $format = $q->param('format') || 'json';

# Handle raw log output early (before content-type)
if ($action eq 'log' && $format eq 'raw') {
  print "Content-type: text/plain; charset=utf-8\n\n";
  my $lines = $q->param('lines') || 100;
  my $log_file = ($ENV{CACHE_DIR} || '') . "/cache.log";

  if (-f $log_file) {
    open my $fh, '<', $log_file;
    my @all_lines = <$fh>;
    close $fh;
    my $start = @all_lines > $lines ? @all_lines - $lines : 0;
    print @all_lines[$start .. $#all_lines];
  } else {
    print "Log file not found\n";
  }
  exit;
}

# Output content type
if ($format eq 'html') {
  print "Content-type: text/html; charset=utf-8\n\n";
} else {
  print "Content-type: application/json; charset=utf-8\n\n";
}

my $cache_dir = $ENV{CACHE_DIR} || '';

# Validate cache key format (SHA256 hex)
sub is_valid_key {
  my $k = shift;
  return $k =~ /^[a-f0-9]{64}$/;
}

# Get cache file path for a key
sub get_cache_path {
  my ($cache_key, $cache_type) = @_;
  return unless $cache_dir && $cache_key;

  my $subdir = substr($cache_key, 0, 2);
  my $subsubdir = substr($cache_key, 2, 2);

  if ($cache_type) {
    return "$cache_dir/$cache_type/$subdir/$subsubdir/$cache_key.html";
  }

  # Search all types if type not specified
  for my $t (qw(horas missa cmissa general)) {
    my $path = "$cache_dir/$t/$subdir/$subsubdir/$cache_key.html";
    return $path if -f $path;
  }
  return;
}

# Get cache statistics
sub get_cache_stats {
  my %stats = (
    enabled => cache_enabled() ? JSON::PP::true : JSON::PP::false,
    serve_from_cache => serve_from_cache_enabled() ? JSON::PP::true : JSON::PP::false,
    cache_dir => $cache_dir,
    types => {},
    total_files => 0,
    total_size => 0,
  );

  return \%stats unless $cache_dir && -d $cache_dir;

  for my $type_dir (glob("$cache_dir/*")) {
    next unless -d $type_dir;
    my $type_name = basename($type_dir);

    my $count = 0;
    my $size = 0;

    find(
      sub {
        return unless -f && /\.html$/;
        $count++;
        $size += -s $_;
      },
      $type_dir,
    );

    $stats{types}{$type_name} = {
      files => $count,
      size_bytes => $size,
      size_human => format_size($size),
    };
    $stats{total_files} += $count;
    $stats{total_size} += $size;
  }

  $stats{total_size_human} = format_size($stats{total_size});
  return \%stats;
}

# Format bytes to human readable
sub format_size {
  my $bytes = shift;
  return '0 B' unless $bytes;

  my @units = ('B', 'KB', 'MB', 'GB');
  my $unit = 0;

  while ($bytes >= 1024 && $unit < $#units) {
    $bytes /= 1024;
    $unit++;
  }
  return sprintf("%.2f %s", $bytes, $units[$unit]);
}

# List cache keys
sub list_cache_keys {
  my ($filter_type, $limit) = @_;
  $limit ||= 100;

  my @keys;
  return \@keys unless $cache_dir && -d $cache_dir;

  my @type_dirs = $filter_type ? ("$cache_dir/$filter_type") : glob("$cache_dir/*");

  for my $type_dir (@type_dirs) {
    next unless -d $type_dir;
    my $type_name = basename($type_dir);

    find(
      sub {
        return unless -f && /^([a-f0-9]{64})\.html$/;
        return if @keys >= $limit;

        my $key = $1;
        my $path = $File::Find::name;
        my @stat = stat($path);

        push @keys, {
            key => $key,
            type => $type_name,
            size => $stat[7],
            mtime => $stat[9],
            mtime_human => scalar(localtime($stat[9])),
          };
      },
      $type_dir,
    );

    last if @keys >= $limit;
  }

  # Sort by mtime descending (most recent first)
  @keys = sort { $b->{mtime} <=> $a->{mtime} } @keys;

  return \@keys;
}

# Get cached content
sub get_cached_content {
  my $cache_key = shift;

  return {error => 'Invalid cache key format'} unless is_valid_key($cache_key);

  my $path = get_cache_path($cache_key, $type);
  return {error => 'Cache entry not found'} unless $path && -f $path;

  my @stat = stat($path);

  open my $fh, '<:encoding(utf-8)', $path or return {error => "Failed to read cache: $!"};
  local $/;
  my $content = <$fh>;
  close $fh;

  return {
    key => $cache_key,
    type => $type || 'unknown',
    size => $stat[7],
    mtime => $stat[9],
    mtime_human => scalar(localtime($stat[9])),
    content => $content,
  };
}

# Clear specific cache entry
sub clear_cache_entry {
  my $cache_key = shift;

  return {error => 'Invalid cache key format'} unless is_valid_key($cache_key);

  my $path = get_cache_path($cache_key, $type);
  return {error => 'Cache entry not found'} unless $path && -f $path;

  unlink $path or return {error => "Failed to delete cache: $!"};

  return {
    success => JSON::PP::true,
    key => $cache_key,
    message => 'Cache entry deleted',
  };
}

# Clear all cache
sub clear_all_cache {
  my $confirm_flag = shift;

  return {error => 'Confirmation required. Add confirm=yes to clear all cache.'} unless $confirm_flag eq 'yes';

  return {error => 'Cache directory not configured'} unless $cache_dir && -d $cache_dir;

  my $count = 0;

  for my $type_dir (glob("$cache_dir/*")) {
    next unless -d $type_dir;

    find(
      sub {
        return unless -f && /\.html$/;
        unlink $_ and $count++;
      },
      $type_dir,
    );
  }

  return {
    success => JSON::PP::true,
    deleted => $count,
    message => "Cleared $count cache entries",
  };
}

# Get cache entry count
sub get_cache_count {
  my %counts = (
    total => 0,
    by_type => {},
  );

  return \%counts unless $cache_dir && -d $cache_dir;

  for my $type_dir (glob("$cache_dir/*")) {
    next unless -d $type_dir;
    my $type_name = basename($type_dir);

    my $count = 0;
    find(
      sub {
        return unless -f && /\.html$/;
        $count++;
      },
      $type_dir,
    );

    $counts{by_type}{$type_name} = $count;
    $counts{total} += $count;
  }

  return \%counts;
}

# Get cache log
sub get_cache_log {
  my ($tail_lines, $raw) = @_;
  $tail_lines ||= 100;

  my $log_file = "$cache_dir/cache.log";

  return {error => 'Log file not found'} unless -f $log_file;

  my @lines;

  # Read last N lines
  open my $fh, '<', $log_file or return {error => "Failed to open log: $!"};
  my @all_lines = <$fh>;
  close $fh;

  # Get last N lines
  my $start = @all_lines > $tail_lines ? @all_lines - $tail_lines : 0;
  @lines = @all_lines[$start .. $#all_lines];

  if ($raw) {
    return join('', @lines);
  }

  # Parse JSON lines
  my @entries;

  for my $line (@lines) {
    chomp $line;
    next unless $line;
    eval {
      my $entry = decode_json($line);
      push @entries, $entry;
    };

    if ($@) {
      push @entries, {
          raw => $line,
          parse_error => $@,
        };
    }
  }

  return {
    total_lines => scalar(@all_lines),
    returned_lines => scalar(@entries),
    entries => \@entries,
  };
}

# Clear cache log
sub clear_cache_log {
  my $log_file = "$cache_dir/cache.log";

  return {error => 'Log file not found'} unless -f $log_file;

  open my $fh, '>', $log_file or return {error => "Failed to clear log: $!"};
  close $fh;

  return {
    success => JSON::PP::true,
    message => 'Log cleared',
  };
}

# Main dispatch
my $result;

if ($action eq 'status') {
  $result = get_cache_stats();
} elsif ($action eq 'count') {
  $result = get_cache_count();
} elsif ($action eq 'keys' || $action eq 'list') {
  my $limit = $q->param('limit') || 100;
  $result = {keys => list_cache_keys($type, $limit)};
} elsif ($action eq 'get') {
  if (!$key) {
    $result = {error => 'Missing key parameter'};
  } else {
    $result = get_cached_content($key);

    # If format is html and we have content, return raw HTML
    if ($format eq 'html' && $result->{content}) {
      print $result->{content};
      exit;
    }
  }
} elsif ($action eq 'log') {
  my $lines = $q->param('lines') || 100;
  $result = get_cache_log($lines, 0);
} elsif ($action eq 'clear_log') {
  $result = clear_cache_log();
} elsif ($action eq 'clear') {
  if (!$key) {
    $result = {error => 'Missing key parameter'};
  } else {
    $result = clear_cache_entry($key);
  }
} elsif ($action eq 'clear_all') {
  $result = clear_all_cache($confirm);
} else {
  $result = {
    error => 'Unknown action',
    available_actions => ['status', 'count', 'keys', 'list', 'get', 'log', 'clear', 'clear_log', 'clear_all'],
  };
}

# Output JSON
print encode_json($result);
