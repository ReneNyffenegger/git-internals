#!/usr/bin/perl
use warnings;
use strict;

use utf8;
use GitInternals;

my $gi = GitInternals -> new(['Alice']);

$gi -> exec('Alice', 'git init --template=""');

$gi -> exec('Alice', 'echo one > one.txt');
$gi -> exec('Alice', 'mkdir dir; echo two > dir/two.txt');
$gi -> exec('Alice', 'mkdir dir/subdir; echo three > dir/subdir/three.txt');

$gi -> exec('Alice', 'git add *');
$gi -> exec('Alice', 'git commit . -m "added a few files"');

# $gi -> exec('Alice', 'git rm one.txt');
$gi -> exec('Alice', 'git rm -r dir');

$gi -> exec('Alice', 'git commit . -m "deleted a few files"');

$gi -> exec('Alice', 'git status');

$gi -> exec('Alice', 'git read-tree b475e40',
       text_pre => 'git read-tree changes the index/stating area (it adds <code>dir/two.txt</code> and <code>dir/subdir/three.txt</code> again) but does not add this files to the working directory');

$gi -> exec('Alice', 'git status');

$gi -> end;
