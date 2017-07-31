#!/usr/bin/perl
use warnings;
use strict;

use utf8;

use GitInternals;

my $gi = GitInternals -> new(['Alice'], {title => 'Git objects: tree'});

$gi -> exec('Alice', 'git init --template=""');

$gi -> exec('Alice', 'printf "foo\nbar\nbaz\n"   > same.txt');

$gi -> exec('Alice', 'mkdir dir; cp same.txt dir');

$gi -> exec('Alice', 'mkdir dir/subdir; cp same.txt dir/subdir');

$gi -> exec('Alice', 'echo foo > abc.txt; echo root > root.txt');

$gi -> exec('Alice', 'echo bar > dir/abc.txt; echo dir > dir/dir.txt');

$gi -> exec('Alice', 'echo baz > dir/subdir/abc.txt; echo subdir > dir/subdir/subdir.txt');

$gi -> exec('Alice', 'git add *');

$gi -> exec('Alice', 'git commit -m "Add directories"');

$gi -> exec('Alice', 'git cat-file -p master^{tree}',
       text_pre => 'Show the tree object of the last commit using the <code>master^{tree}</code> syntax.',
       text_post=> 'A (sub-)directory is referenced by another tree object (e7412b3…)');

$gi -> exec('Alice', 'git cat-file -p e7412b3',
       text_pre => 'Showing the content of this tree object (dir)',
       text_post=> 'Again, the tree object contains another tree object (subdir, 24c8aea…)');

$gi -> exec('Alice', 'git cat-file -p 24c8aea',
       text_pre => 'Showing the content of dir/subdir');

$gi -> end;
