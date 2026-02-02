use strict;
use warnings;
use utf8;

use File::Temp qw(tempdir);
use File::Path qw(remove_tree);

use DivinumOfficium::Cache qw(
  get_cache_key
  get_cached_content
  store_cached_content
  cache_enabled
  serve_from_cache_enabled
  build_cache_params
);

use Test::Simple tests => 14;

# Create a temporary directory for testing
my $temp_dir = tempdir(CLEANUP => 1);

# Test 1: Cache disabled when CACHE_DIR not set
delete $ENV{CACHE_DIR};
delete $ENV{SERVE_FROM_CACHE};
ok(!cache_enabled(), 'Cache disabled when CACHE_DIR not set');

# Test 2: Cache enabled when CACHE_DIR is set
$ENV{CACHE_DIR} = $temp_dir;
ok(cache_enabled(), 'Cache enabled when CACHE_DIR is set');

# Test 3: Serve from cache disabled by default
ok(!serve_from_cache_enabled(), 'Serve from cache disabled by default');

# Test 4: Serve from cache enabled when SERVE_FROM_CACHE=1
$ENV{SERVE_FROM_CACHE} = '1';
ok(serve_from_cache_enabled(), 'Serve from cache enabled when SERVE_FROM_CACHE=1');

# Test 5: Serve from cache enabled when SERVE_FROM_CACHE=true
$ENV{SERVE_FROM_CACHE} = 'true';
ok(serve_from_cache_enabled(), 'Serve from cache enabled when SERVE_FROM_CACHE=true');

# Test 6: Cache key generation is deterministic
my %params = (date1 => '02-01-2026', version => 'Rubrics 1960', lang1 => 'Latin');
my $key1 = get_cache_key(%params);
my $key2 = get_cache_key(%params);
ok($key1 eq $key2, 'Cache key generation is deterministic');

# Test 7: Cache key is a valid SHA256 hash (64 hex characters)
ok($key1 =~ /^[a-f0-9]{64}$/, 'Cache key is valid SHA256 hash');

# Test 8: Different params produce different keys
my %params2 = (date1 => '02-02-2026', version => 'Rubrics 1960', lang1 => 'Latin');
my $key3 = get_cache_key(%params2);
ok($key1 ne $key3, 'Different params produce different keys');

# Test 9: Store and retrieve content
my $test_content = "<html>Test content for caching</html>";
my $store_result = store_cached_content($key1, $test_content, 'test');
ok($store_result == 1, 'Store cached content returns success');

# Test 10: Retrieved content matches stored content
my $retrieved = get_cached_content($key1, 'test');
ok($retrieved eq $test_content, 'Retrieved content matches stored content');

# Test 11: Non-existent cache returns undef
my $nonexistent = get_cached_content('nonexistent_key', 'test');
ok(!defined $nonexistent, 'Non-existent cache returns undef');

# Test 12: build_cache_params returns expected keys
my %horas_params = build_cache_params(type => 'horas', date1 => '02-01-2026', hora => 'Laudes');
ok(exists $horas_params{date1} && $horas_params{date1} eq '02-01-2026', 'Cache params include date1');

# Test 13: build_cache_params normalizes undef to empty string
my %missa_params = build_cache_params(type => 'missa', date1 => '02-01-2026', Propers => undef);
ok(exists $missa_params{Propers} && $missa_params{Propers} eq '', 'Cache params normalize undef to empty string');

# Test 14: Empty content not stored
my $empty_result = store_cached_content($key1, '', 'test');
ok($empty_result == 0, 'Empty content is not stored');

# Cleanup
remove_tree($temp_dir);
