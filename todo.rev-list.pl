#!/usr/bin/perl
use warnings;
use strict;


use utf8;

use GitInternals;

my $gi = GitInternals -> new(['Alice']);

$gi -> exec('Alice', 'git init --template=""');
$gi -> exec('Alice', 'echo one > a.file');
$gi -> exec('Alice', 'git add a.file');
$gi -> exec('Alice', 'git commit . -m "1st commit"');

$gi -> exec('Alice', 'echo two > a.file');
$gi -> exec('Alice', 'git commit . -m "2nd commit"');

$gi -> exec('Alice', 'echo three > a.file');
$gi -> exec('Alice', 'git commit . -m "3rd commit"');

$gi -> exec('Alice', 'echo four > a.file');
$gi -> exec('Alice', 'git commit . -m "4th commit"');

$gi -> exec('Alice', 'git rev-list --objects --all',
  text_pre => 'Show all objects from refs');

$gi -> exec('Alice', 'git rev-list --objects -g --no-walk --all',
  text_pre => 'Show all objects from the reflogs');

$gi -> exec('Alice', 'git rev-list --objects --no-walk $( git fsck --unreachable | grep \'^unreachable commit\' | cut -d\' \' -f3 )',
  text_pre => 'all unreachable objects');

$gi -> end;
