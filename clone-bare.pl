#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use GitInternals;

my $gi = new GitInternals ( [ 'Alice', 'Bob', 'Depot' ]);

$gi -> exec('Alice', 'mkdir foo');
$gi -> exec('Alice', 'echo one > foo/one.txt', no_cmp => 1);
$gi -> exec('Alice', 'echo two > foo/two.txt', no_cmp => 1);

$gi -> exec('Alice', 'git init --template=""');

$gi -> exec('Alice', 'git add .', no_cmp => 1);
$gi -> exec('Alice', 'git commit -m "add foo/one.txt, foo/two.txt"', no_cmp => 1);

$gi -> exec('Depot', 'git clone --bare ' . $gi->repo_dir_full_path('Alice') . ' .');

$gi -> exec('Bob'  , 'git clone '        . $gi->repo_dir_full_path('Depot') . ' .');

$gi -> end;
