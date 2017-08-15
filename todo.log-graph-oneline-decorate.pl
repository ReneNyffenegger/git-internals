#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = GitInternals -> new(['Alice']);

$gi -> exec('Alice', 'git init --template=""');
$gi -> exec('Alice', 'printf "one\ntwo\nthree\nfour\nfive\nsix\nseven\n"  > numbers.txt');
$gi -> exec('Alice', 'git add numbers.txt');
$gi -> exec('Alice', 'git commit numbers.txt -m "+ numbers.txt"');

$gi -> exec('Alice', 'git checkout -b A');
$gi -> exec('Alice', 'sed -i "s/four/& branch A/" numbers.txt');
$gi -> exec('Alice', 'git commit . -m "Changed line four"');

$gi -> exec('Alice', 'git checkout -b A1');
$gi -> exec('Alice', 'sed -i "s/six/& branch A1/" numbers.txt');
$gi -> exec('Alice', 'git commit . -m "Changed line six"');

$gi -> exec('Alice', 'git checkout -b B master');
$gi -> exec('Alice', 'sed -i "s/two/& branch B/" numbers.txt');
$gi -> exec('Alice', 'git commit . -m "Changed line two"');


$gi -> exec('Alice', 'git checkout master');
$gi -> exec('Alice', 'echo eight >> numbers.txt');
$gi -> exec('Alice', 'git commit . -m "Added eight"');

$gi -> exec('Alice', 'git merge B');
$gi -> exec('Alice', 'git merge A');

$gi -> exec('Alice', 'git merge A1');

$gi -> exec('Alice', 'git log --graph --oneline --decorate',
  text_post=>'Remember, logs need to be read from bottom up');

$gi -> end;
