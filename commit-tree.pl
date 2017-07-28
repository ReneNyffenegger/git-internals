#!/usr/bin/perl
use warnings;
use strict;

use utf8;
use GitInternals;

my $gi = GitInternals -> new(['Alice']);

$gi -> exec('Alice', 'git init', no_cmp => 1);

$gi -> exec('Alice', 'echo one > one.txt');
$gi -> exec('Alice', 'mkdir dir; echo two > dir/two.txt');
$gi -> exec('Alice', 'mkdir dir/subdir; echo three > dir/subdir/three.txt');

$gi -> exec('Alice', 'git update-index --add one.txt dir/two.txt dir/subdir/three.txt');

$gi -> exec('Alice', 'git write-tree');

$gi -> exec('Alice', 'git commit-tree f572124 -m "First commit"');

$gi -> exec('Alice', 'echo ONE >> one.txt');
$gi -> exec('Alice', 'git update-index one.txt');
$gi -> exec('Alice', 'git write-tree');

$gi -> exec('Alice', 'git commit-tree da93050 -m "Second commit" -p 68e902c',
            text_pre => 'Create another commit object, reference the first commit object as parent (<code>-p</code>)');

$gi -> exec('Alice', 'git log a06ce91');

$gi -> end;
