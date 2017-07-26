#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = GitInternals -> new(['Alice']);

$gi -> exec('Alice', 'git init', no_cmp => 1);
$gi -> exec('Alice', "printf 'one foo\ntwo bar\n' > some-blob");
$gi -> exec('Alice', "git hash-object -w some-blob");
$gi -> exec('Alice', "git cat-file -p 9363c4e4606084a3c1fca83a3c535f65582ac834");
$gi -> exec('Alice', "printf 'three baz\n' >> some-blob");
$gi -> exec('Alice', "git hash-object -w some-blob");
$gi -> exec('Alice', "git cat-file -p 8db444301e5246a004784c9c7f39ab89725c3d2b");
$gi -> exec('Alice', "git cat-file -t 8db444301e5246a004784c9c7f39ab89725c3d2b");

$gi -> end;
