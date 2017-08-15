#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = GitInternals -> new(['Alice']);

$gi -> exec('Alice', 'git init --template=""');
$gi -> exec('Alice', 'printf "one\ntwo\nthree\n"  > numbers.txt');
$gi -> exec('Alice', 'git add numbers.txt');
$gi -> exec('Alice', 'git commit numbers.txt -m "+ numbers.txt"');

$gi -> exec('Alice', 'echo four >> numbers.txt');

$gi -> exec('Alice', 'git stash',
  text_post => 'Note: git stash creates a commit object and the file .git/logs/refs/stash');

$gi -> exec('Alice', 'cat numbers.txt');

$gi -> exec('Alice', 'git stash list');

$gi -> exec('Alice', 'git stash pop');

$gi -> exec('Alice', 'cat numbers.txt');

$gi -> end;
