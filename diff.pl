#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = new GitInternals ( [ 'Alice']);

$gi -> exec('Alice', 'git init --template=""');

$gi -> exec('Alice', 'printf "foo\nabr\nbaz\n" > foo.txt'          , no_cmp => 1);
$gi -> exec('Alice', 'printf "one\ntwo\nthree\n" > 123.txt'        , no_cmp => 1);

$gi -> exec('Alice', 'git add .'                                   , no_cmp => 1);
$gi -> exec('Alice', 'git commit . -m "first revision"'            , no_cmp => 1);

$gi -> exec('Alice', 'sed -i s/abr/bar/ foo.txt'                   , no_cmp => 1);

$gi -> exec('Alice', 'echo hello > world.txt'                      , no_cmp => 1);

$gi -> exec('Alice', 'git status'                                  , no_cmp => 1);
$gi -> exec('Alice', 'git diff --cached'                           , no_cmp => 1);
$gi -> exec('Alice', 'git diff'                                    , no_cmp => 1);

$gi -> exec('Alice', 'git add world.txt'                           , no_cmp => 1);

$gi -> exec('Alice', 'git diff --cached'                           , no_cmp => 1);
$gi -> exec('Alice', 'git diff'                                    , no_cmp => 1);



$gi -> end;
