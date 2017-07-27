#!/usr/bin/perl
use warnings;
use strict;

use utf8;

use GitInternals;

my $gi = GitInternals -> new(['Alice']);

$gi -> exec('Alice', 'git init', no_cmp => 1);

$gi -> exec('Alice', 'printf "foo\nbar\nbaz"   > foo-bar-baz.txt'  ,
       text_pre=>'First, Alice creates two files: foo-bar-baz.txt and …');

$gi -> exec('Alice', 'printf "one\ntwo\nthree" > one-two-three.txt',
       text_pre=>'… one-two-three.txt.');

$gi -> exec('Alice', 'git update-index --add *.txt'      ,
       text_pre =>'She adds both files to the index:');

$gi -> exec('Alice', 'printf "eggs\nwhy\nz.\n" > xyz.txt',
       text_pre=>'She also creates a third file …',
       text_post=>'… that is not added to the index.');

$gi -> exec('Alice', 'git write-tree'    ,
       text_pre=>'Alice creates a tree object from the files on the index.');

$gi -> exec('Alice', 'git cat-file -t 582a0898'    ,
       text_pre=>'Verify if it is a tree object');

$gi -> exec('Alice', 'git cat-file -p 582a0898'    ,
       text_pre=>'Show the content of the new tree object');

$gi -> end;
