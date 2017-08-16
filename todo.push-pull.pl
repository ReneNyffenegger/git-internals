#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;
use utf8;

my $gi = new GitInternals ( ['Alice', 'Bob', 'Charlie']);

$gi -> exec('Alice', 'git init --template=""');

$gi -> exec('Alice', 'echo FOO BAR BAZ > README');
$gi -> exec('Alice', 'git add README');
$gi -> exec('Alice', 'git commit README -m "+ README"');

$gi -> exec('Alice', 'git checkout -b develop');
$gi -> exec('Alice', 'echo "V0.01: adding foo" >> README');
$gi -> exec('Alice', 'git commit . -m "Version 0.01 (foo)"');
$gi -> exec('Alice', 'git checkout master');
$gi -> exec('Alice', 'git merge develop');

$gi -> exec('Alice', 'git checkout develop;');
$gi -> exec('Alice', 'echo "V0.02: adding bar" >> README');
$gi -> exec('Alice', 'git commit . -m "Version 0.02 (bar)"');

$gi -> exec('Bob'  , 'git clone --template="" ' . $gi->repo_dir_full_path('Alice') . ' .');
$gi -> exec('Bob'  , 'git branch',
       text_pre => 'After cloning, Bob is in the develop branch, apparently because Alice was on this branch when Bob cloned the repository');

$gi -> exec('Alice', 'git checkout master',
       text_pre => 'In the mean time, Alice is going to merge V0.02, developed in the develop branch, into master');
$gi -> exec('Alice', 'git merge develop');

$gi -> exec('Bob'  , 'git pull');

$gi -> end;
