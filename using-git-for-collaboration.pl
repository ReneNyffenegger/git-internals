#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use GitInternals;

my $gi = new GitInternals ( ['Alice', 'Bob' ]);

$gi -> exec('Alice', 'git init --template=""');

$gi -> exec('Alice', 'printf "noe\ntwo\nthree\n" > numbers.txt',
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

$gi -> exec('Bob', 'ls .git/refs/remotes/origin/master',
   text_pre  => 'It contains <code>refs/remotes/origin/master</code>. However, such a file des not exist.',
   no_cmp => 0);

$gi -> exec('Bob', 'sed s/noe/one/ -i numbers.txt',
   text_pre  => 'Bob fixes the typo ... ',
   no_cmp => 0);

$gi -> exec('Bob', 'git commit numbers.txt -m "Fixed typo" ',
   text_pre  => '... and commits the changes.',
   no_cmp => 0);

$gi -> exec('Alice', 'echo four >> numbers.txt',
   text_pre  => 'In the mean time, Alice adds another number to numbers.txt ...',
   no_cmp => 0);

$gi -> exec('Alice', 'git commit numbers.txt -m "add fourth number."',
   text_pre  => '... and commits the change.',
   no_cmp => 0);

$gi -> exec('Alice', 'cat numbers.txt',
   text_pre  => 'numbers.txt now contains four numbers, still with the typo.',
   no_cmp => 0);

$gi -> exec('Alice', 'git remote add bob ' . $gi->repo_dir_full_path('Bob'),
   text_pre  => 'Alice defines a remote repository to make it easier to work with Bob\'s repository.',
   no_cmp => 0);

# $gi -> exec('Alice', 'git fetch ' . $gi->repo_dir_full_path('Bob'),
  $gi -> exec('Alice', 'git fetch bob', #  . $gi->repo_dir_full_path('Bob'),
  text_pre => 'Using the fetch command, Alice can peek at what Bob changed, without merging it',
  no_cmp => 0);

$gi -> text('Such a peek can be done with the log command. It comes in at least three variants. Without dots, with two dots and with three dots.');

$gi -> exec('Alice', 'git log HEAD FETCH_HEAD',
  text_pre => 'First, Alice shows the log without dots, so every commit is shown.',
  no_cmp => 0);

$gi -> exec('Alice', 'git log HEAD...FETCH_HEAD',
  text_pre => 'Then, she uses three dots to show the changes since Bob has cloned Alice\'s reposiotory.',
  no_cmp => 0);

$gi -> exec('Alice', 'git log -p HEAD..FETCH_HEAD',
  text_pre => 'Finally, she uses two dots, which shows only what Bob has commited. She also uses the -p flag for more information on the commits.',
  no_cmp => 0);

$gi -> exec('Alice', 'git merge bob/master ', #  . $gi->repo_dir_full_path('Bob'),
   text_pre  => 'Alice likes Bob\'s change and merges them. Instead of using git fetch followed by git merge, she could also have used git pull which would have executed those two operations in one go.',
   no_cmp => 0);

$gi -> exec('Alice', 'git status', 
#  text_pre  => 'Alice fetches the changes from bob',
   no_cmp => 0);

$gi -> exec('Alice', 'cat numbers.txt', 
   text_pre  => 'The typo is fixed.',
   no_cmp => 0);

$gi -> exec('Bob', 'git pull', 
   text_pre  => 'Bob wants to fetch Alice\'s latest changes.',
   no_cmp => 0);

$gi -> exec('Bob', 'git config --get remote.origin.url', 
   text_pre  => 'In the prior pull command, git »knew« what repository to pull it from since it stored it in »remote.origin.url« which was set in git clone.',
   no_cmp => 0);

$gi -> exec('Bob', 'cat numbers.txt', 
   text_pre  => 'Finally, a demonstration that Bob has received the added number »four« from Alice.',
   no_cmp => 0);

$gi -> end;
