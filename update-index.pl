#!/usr/bin/perl
use warnings;
use strict;

use utf8;

use GitInternals;

my $gi = GitInternals -> new(['Alice']);

$gi -> exec('Alice', 'git init', no_cmp => 1);

$gi -> exec('Alice', 'printf "foo\nbar\nbaz\n"   > foo-bar-baz.txt'  ,
       text_pre=>'First, Alice creates two files: foo-bar-baz.txt and …');

$gi -> exec('Alice', 'printf "one\ntwo\nthree\n" > one-two-three.txt',
       text_pre=>'… one-two-three.txt.');

$gi -> exec('Alice', 'git update-index --add foo-bar-baz.txt'      ,
       text_pre =>'She adds foo-bar-baz.txt to the index:',
       text_post=>'The name of the file is added to .git/index and an according blob-object is created under ./git/objects');

$gi -> exec('Alice', 'git update-index --add one-two-three.txt'    ,
       text_pre=>'She also addes one-two-three.txt to the index');

$gi -> exec('Alice', 'git update-index --remove foo-bar-baz.txt'   ,
       text_pre=>'Trying to remove a file from the index does not change the repository …',
       text_post=>'… because the file foo-bar-baz.txt is still existant.');

$gi -> exec('Alice', 'rm foo-bar-baz.txt'                          ,
       text_pre=>'So, the file is removed …');

$gi -> exec('Alice', 'git update-index --remove foo-bar-baz.txt'   ,
       text_pre=>'… and then the index is updated',
       text_post=>'foo-bar-baz.txt is removed from the index, however, the object file is still in the ./git/objects directory.');

$gi -> exec('Alice', 'Echo "Appended line" >> one-two-three.txt',
       text_pre => 'Modify one-two-three.txt (append a line)');

$gi -> exec('Alice', 'git update-index one-two-three.txt',
       text_pre => 'Updating the index with the newer version of one-two-three.txt (Appended line). Note: no -add option is used this time because the file is already known.',
       text_post=> 'The index now tracks one-two-three.txt with the new object id 5325806….');

$gi -> end;
