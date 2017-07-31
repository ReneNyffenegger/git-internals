#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use GitInternals;

my $gi = new GitInternals ( [ 'Alice']);

$gi -> exec('Alice', 'mkdir foo bar baz');
$gi -> exec('Alice', 'echo one > foo/one.txt');
$gi -> exec('Alice', 'echo two > foo/two.txt');
$gi -> exec('Alice', 'echo three > bar/three.txt');
$gi -> exec('Alice', 'echo four > baz/four.txt');

$gi -> exec('Alice', 'git init --template=""');


$gi -> exec('Alice', 'git add .',
     text_pre  => 'Tell git to take a snapshot of the contents of all files under the working directory:',
     text_post => 'The snapshot is now stored in a temporary staging area which Git calls the → git/_git/index_[index].'
  );

$gi -> exec('Alice', 'git commit -m "First version"',
     text_pre => 'Permanently store the »first version« of the project in Git:'
  );

$gi -> end;
