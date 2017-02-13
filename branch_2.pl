#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = new GitInternals ( [ 'Alice', 'Bob']);

$gi -> exec('Alice', 'git init');

$gi -> exec('Alice', 'printf "one\ntwo\nthree\nfour\nfive\nsix\n" > numbers.txt');

$gi -> exec('Alice', 'git add . ');
$gi -> exec('Alice', 'git commit -m "+ numbers.txt"');

$gi -> exec('Bob'  , 'git clone ' . $gi->repo_dir_full_path('Alice') . ' .');
$gi -> exec('Bob'  , 'git checkout -b tq84');

$gi -> exec('Bob'  , "sed -i '/three/aTQ84-inserted-line' numbers.txt");
$gi -> exec('Bob'  , 'cat numbers.txt');

$gi -> exec('Bob'  , 'git commit . -m "Added TQ84 line"');
# $gi -> exec('Bob'  , 'git push ' . $gi->repo_dir_full_path('Alice'));
$gi -> exec('Bob'  , 'git push origin');

$gi -> exec('Alice', 'git branch');

$gi -> exec('Bob'  , 'git push -u origin tq84');
$gi -> exec('Alice', 'git branch');

$gi -> exec('Alice', 'git checkout tq84');
$gi -> exec('Alice', 'cat numbers.txt');

$gi -> exec('Alice', 'git checkout master');

$gi -> exec('Alice', 'printf "seven\n" >> numbers.txt');
$gi -> exec('Alice', 'cat numbers.txt');
$gi -> exec('Alice', 'git commit . -m "+ seven"');

$gi -> exec('Bob'  , 'git branch');
$gi -> exec('Bob'  , 'git pull origin master');
$gi -> exec('Bob'  , 'git merge master');
$gi -> exec('Bob'  , 'cat numbers.txt');
