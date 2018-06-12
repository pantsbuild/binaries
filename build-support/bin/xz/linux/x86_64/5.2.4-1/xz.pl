#!/usr/bin/perl

use strict;
use warnings;

use Cwd 'abs_path';
use File::Basename 'dirname';
use File::Spec::Functions 'catfile';
use POSIX 'uname';

my $this_file_dir = dirname(__FILE__);
my $xz_executable = abs_path(catfile($this_file_dir, 'xz-real'));
my $xz_lib_dir = abs_path(catfile($this_file_dir, '..', 'lib'));

my ($platform) = uname();

my $env_var;
if ($platform eq 'Darwin') {
  $env_var = 'DYLD_LIBRARY_PATH';
} elsif ($platform eq 'Linux') {
  $env_var = 'LD_LIBRARY_PATH';
} else {
  die sprintf("Unrecognized platform: {}", $platform);
}

my $prev_lib_path = $ENV{$env_var};
$prev_lib_path = '' unless defined $prev_lib_path;

my @lib_path_entries = grep(!/^$/m, split(/:/, $prev_lib_path));

my @lib_path_ours_first = ($xz_lib_dir, @lib_path_entries);

$ENV->{$env_var} = join(':', @lib_path_ours_first);

exec { $xz_executable } ($0, @ARGV);
