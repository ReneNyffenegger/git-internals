#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use GitInternals;

my $gi = GitInternals -> new(['Alice', 'Bob']);

$gi -> exec('Alice', 'git init --template=""',
  text_pre => 'Alice creates a repository');

$gi -> exec('Alice', 'printf "one\ntwo\nthree\n"  > numbers.txt',
  text_pre => 'She adds a file with three lines (<code>one</code> through <code>three</code>), …');

$gi -> exec('Alice', 'git add numbers.txt',
  text_pre => '… add the file to the index … ');

$gi -> exec('Alice', 'git commit numbers.txt -m "+ numbers.txt"',
  text_pre => '… and commits it.');

$gi -> exec('Alice', 'echo TODO: fix me. >> numbers.txt',
  text_pre => 'Then she starts modifying <code>numbers.txt</code>.');

$gi -> exec('Alice', 'git stash',
  text_pre => 'She realizes that the started changes are not ready for a commit. Alice wants to work on it later, but for the moment, she stashes the changes away:',
  text_post => 'Note: git stash creates a commit object and the file .git/logs/refs/stash');

$gi -> exec('Alice', 'cat numbers.txt',
  text_pre => "The file doesn't have the TODO anymore:");

$gi -> exec('Alice', "sed -e '1 i Some Numbers:' -i numbers.txt",
  text_pre => 'Alice adds a header line to <code>numbers.txt</code> …');
 
$gi -> exec('Alice', "git commit numbers.txt -m 'Add header line'",
  text_pre => '… and commits the modification.');

$gi -> exec('Bob'  , 'git clone --template="" ' . $gi->repo_dir_full_path('Alice') . ' .',
       text_pre=>'In the mean time, Bob clones Alice\'s repository.');

$gi -> exec('Bob'  , 'git stash list',
       text_pre=>'TODO TODO');

$gi -> exec('Alice', 'git stash list',
  text_pre=>'After this modification, Alice is ready to work again on the stashed away changes. She checks which and if stashes are available …');

$gi -> exec('Alice', 'git stash pop',
  text_pre=>'… and pops the most recent one:');

$gi -> exec('Alice', 'cat numbers.txt',
  text_pre=>'After popping the stash, the TODO is in the file again:');

$gi -> end;
