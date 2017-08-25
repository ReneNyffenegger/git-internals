#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use GitInternals;

my $gi = GitInternals -> new(['Alice']);

$gi -> exec('Alice', 'git init --template=""');
$gi -> exec('Alice', 'echo foo bar baz > a.file');
$gi -> exec('Alice', 'git add a.file');
$gi -> exec('Alice', 'git commit . -m "foo bar baz"');

$gi -> exec('Alice', 'git checkout -b B');
$gi -> exec('Alice', 'echo B >> a.file ');
$gi -> exec('Alice', 'git commit . -m "B"');

$gi -> exec('Alice', 'git checkout master');
$gi -> exec('Alice', 'cat a.file');

# $gi -> exec('Alice', 'git merge B');
# $gi -> exec('Alice', 'cat a.file');

$gi -> exec('Alice', 'git branch -d B');
$gi -> exec('Alice', 'git branch -D B');
$gi -> exec('Alice', 'git fsck --unreachable');
$gi -> exec('Alice', 'git fsck --dangling');
$gi -> exec('Alice', 'git fsck --lost-found');
$gi -> exec('Alice', 'git fsck --full --no-reflogs --unreachable --lost-found');


$gi -> end;
