#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = GitInternals -> new(['Alice']);

$gi -> exec('Alice', 'git init --template=""');

$gi -> exec('Alice', "printf 'one foo\ntwo bar\n' > some-blob");

$gi -> exec('Alice', "git hash-object -w some-blob",
             text_pre => 'git hash-object with -w takes a file, computes the object id, and stores it in the .git/object directory');

$gi -> exec('Alice', "git cat-file -p 9363c4e4606084a3c1fca83a3c535f65582ac834",
             text_pre =>'Use git cat-file -p to show the content of an object');

$gi -> exec('Alice', "printf 'three baz\n' >> some-blob");

$gi -> exec('Alice', "git hash-object -w some-blob");

$gi -> exec('Alice', "git cat-file -p 8db444301e5246a004784c9c7f39ab89725c3d2b");

$gi -> exec('Alice', "git cat-file -t 8db444301e5246a004784c9c7f39ab89725c3d2b",
             text_pre=>"cat-file with -t shows the object type rather than the object's content");

$gi -> end;
