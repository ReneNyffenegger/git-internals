#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = new GitInternals ( [ 'Alice']);

$gi -> exec('Alice', 'git init', no_cmp => 1);
$gi -> exec('Alice', 'printf "foo\nbar\nbaz"   > foo-bar-baz.txt'  );
$gi -> exec('Alice', 'printf "one\ntwo\nthree" > one-two-three.txt');
$gi -> exec('Alice', 'git add foo-bar-baz.txt'                     );
$gi -> exec('Alice', 'git add one-two-three.txt'                   );

$gi -> end;