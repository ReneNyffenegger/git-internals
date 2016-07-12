#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = new GitInternals ( ['Alice', 'Bob' ]);

$gi -> exec('Alice', 'git init', no_cmp => 1);

$gi -> exec('Alice', 'printf "noe\ntwo\nthree" > numbers.txt',
   text_pre => 'Alice adds a file. Note the typo (noe instead of one).',
   no_cmp => 1);

$gi -> exec('Alice', 'git add numbers.txt',
   no_cmp => 1);

$gi -> exec('Alice', 'git commit numbers.txt -m "add numbers.txt"',
   no_cmp => 1);

$gi -> exec('Bob', 'git clone ' . $gi->repo_dir_full_path('Alice') .  ' .',
   text_pre  => 'Bob clones Alice\'s repository',
   no_cmp => 0);

$gi -> exec('Bob', 'diff -rq .git ' . $gi->repo_dir_full_path('Alice') .  '/.git',
   text_pre  => 'Comparing Alice\'s and Bob\'s repositories:',
   no_cmp => 0);

$gi -> exec('Bob', 'cat .git/refs/remotes/origin/HEAD',
   text_pre  => 'What does .git/refs/origin/HEAD contain?',
   no_cmp => 0);

$gi -> exec('Bob', 'sed s/noe/one/ -i numbers.txt',
   text_pre  => 'Bob fixes the typo ... ',
   no_cmp => 0);

$gi -> exec('Bob', 'git commit numbers.txt -m "Fixed typo" ',
   text_pre  => '... and commits the changes.',
   no_cmp => 0);

$gi -> exec('Alice', 'git pull ' . $gi->repo_dir_full_path('Bob'),
   text_pre  => 'Alice fetches the changes from bob',
   no_cmp => 0);

$gi -> exec('Alice', 'git status', 
#  text_pre  => 'Alice fetches the changes from bob',
   no_cmp => 0);

$gi -> exec('Alice', 'cat numbers.txt', 
   text_pre  => 'The typo is fixed.',
   no_cmp => 0);

$gi -> exec('Alice', 'git log', 
#  text_pre  => 'The typo is fixed.',
   no_cmp => 0);

$gi -> end;
