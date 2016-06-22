#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = new GitInternals ( [ 'Alice']);

$gi -> exec('Alice', 'git init');

$gi -> exec('Alice', 'echo one > one.txt');
$gi -> exec('Alice', 'git add . ');
$gi -> exec('Alice', 'git commit -m "First commit"');

$gi -> exec('Alice', 'git branch fooBranch');

$gi -> exec('Alice', 'git branch');

$gi -> exec('Alice', 'git checkout fooBranch');

$gi -> exec('Alice', 'echo two >> one.txt');
$gi -> exec('Alice', 'git commit -a -m "Second commit"');

$gi -> exec('Alice', 'git checkout master');
$gi -> exec('Alice', 'cat one.txt');
$gi -> exec('Alice', 'git log --stat --summary');

$gi -> exec('Alice', 'git checkout fooBranch');
$gi -> exec('Alice', 'cat one.txt');
$gi -> exec('Alice', 'git log --stat --summary');


$gi -> end;
