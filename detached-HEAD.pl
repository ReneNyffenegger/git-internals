#!/usr/bin/perl
use warnings;
use strict;

use utf8;

use GitInternals;

my $gi = GitInternals -> new ( [ 'Alice'], {title=>'Git: Detached HEAD'});

$gi->exec('Alice', 'git init --template=""');

$gi->exec('Alice', 'touch foo');
$gi->exec('Alice', 'git add foo');
$gi->exec('Alice', 'git commit foo -m "add foo" ');

$gi->exec('Alice', 'touch bar');
$gi->exec('Alice', 'git add bar');
$gi->exec('Alice', 'git commit bar -m "add bar" ');

$gi->exec('Alice', 'git checkout 3fd0cb8');
$gi->exec('Alice', 'ls -l');
$gi->exec('Alice', 'git branch');

$gi->exec('Alice', 'touch baz');
$gi->exec('Alice', 'git add baz');
$gi->exec('Alice', 'git commit baz -m "add baz" ');

# $gi->exec('Alice', 'git log --oneline --graph --decorate --branches --decorate');

$gi->exec('Alice', 'git checkout master');
$gi->exec('Alice', 'ls -l');

$gi->exec('Alice', 'git merge 35855da');
$gi->exec('Alice', 'ls -l');


$gi -> end();
