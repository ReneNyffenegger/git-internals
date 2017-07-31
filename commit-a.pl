#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = new GitInternals ( [ 'Alice']);

$gi -> exec('Alice', 'git init --template=""');

$gi -> exec('Alice', 'echo foo > foo.txt'                          , no_cmp => 1);
$gi -> exec('Alice', 'git add .'                                   , no_cmp => 1);

$gi -> exec('Alice', 'git commit -m "foo"'                         , no_cmp => 1);

$gi -> exec('Alice', 'echo foo foo > foo.txt'                      , no_cmp => 1);

$gi -> exec('Alice', 'git commit -m "foo foo ?"'                   , no_cmp => 1,
     text_pre => 'Commiting without specifying -a will only commit files that were explicitely added');

$gi -> exec('Alice', 'git status'                                  , no_cmp => 1,
     text_post => 'Nothing was commited');

$gi -> exec('Alice', 'git commit -a -m "foo foo"'                  , no_cmp => 1,
     text_pre => 'This time, the commit goes along with the -a flag, the file will be commited');

$gi -> exec('Alice', 'git status'                                  , no_cmp => 1);



$gi -> end;
