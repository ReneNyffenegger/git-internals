#!/usr/bin/perl
use warnings;
use strict;

use utf8;

use GitInternals;

my $gi = GitInternals -> new(['Alice']);

$gi -> exec('Alice', 'git init --template=""');

$gi -> exec('Alice', 'printf "foo\nbar\nbaz\n"   > foo-bar-baz.txt'  ,
       text_pre=>'First, Alice creates two files: foo-bar-baz.txt and …');

$gi -> exec('Alice', 'printf "one\ntwo\nthree\n" > one-two-three.txt',
       text_pre=>'… one-two-three.txt.',
#      no_separate_command=>1
     );

$gi -> exec('Alice', 'git update-index --add *.txt'      ,
       text_pre =>'She adds both files to the index:');

$gi -> exec('Alice', 'printf "eggs\nwhy\nz.\n" > xyz.txt',
       text_pre=>'She also creates a third file …',
       text_post=>'… that is not added to the index.');

$gi -> exec('Alice', 'echo "Another line" >> foo-bar-baz.txt',
       text_pre => 'Appending another line to foo-bar-baz.txt');

$gi -> exec('Alice', 'git write-tree'    ,
       text_pre=>'Alice creates a tree object from the files on the index.');

$gi -> exec('Alice', 'git cat-file -t fe362c96'    ,
       text_pre=>'Verify if it is a tree object');

$gi -> exec('Alice', 'git cat-file -p fe362c96'    ,
       text_pre=>'Show the content of the new tree object');

$gi -> exec('Alice', 'git cat-file -p 86e041da'    ,
       text_pre=>'Note: the foo-bar-baz.txt file in the tree object does not have the appended line:');

$gi -> end;
