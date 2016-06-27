#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = new GitInternals ( [ 'Alice']);

$gi -> exec('Alice', 'git init');

$gi -> exec('Alice', 'echo one > one.txt');
$gi -> exec('Alice', 'git add . ');
$gi -> exec('Alice', 'git commit -m "First commit"');

$gi -> exec('Alice', 'echo two > two.txt');
$gi -> exec('Alice', 'git add . ');
$gi -> exec('Alice', 'echo two >> one.txt');
$gi -> exec('Alice', 'git commit -m "Second commit"');

$gi -> exec('Alice', 'echo three > three.txt');
$gi -> exec('Alice', 'echo three >> one.txt');
$gi -> exec('Alice', 'git add . ');
$gi -> exec('Alice', 'git commit -m "Third commit"');

$gi -> exec('Alice', 'git log');
$gi -> exec('Alice', 'git log -p');
$gi -> exec('Alice', 'git log --stat --summary');


$gi -> end;
