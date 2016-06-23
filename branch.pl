#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = new GitInternals ( [ 'Alice']);

$gi -> exec('Alice', 'git init');

$gi -> exec('Alice', 'printf "one\ntow\nthree\nfour\n" > numbers.txt',
   text_pre => 'Creating a file with numbers. Note the typo (tow instead of two)');

$gi -> exec('Alice', 'git add . ');
$gi -> exec('Alice', 'git commit -m "Numbers 1 through 4"');

$gi -> exec('Alice', 'git branch fixTypoBranch',
    text_pre => 'Creating a branch');

$gi -> exec('Alice', 'git branch',
    text_pre => 'Show "available" branches',
    text_post=> 'The star indicates the "current" branch');

$gi -> exec('Alice', 'git checkout fixTypoBranch',
    text_pre => 'Change to the newly created branch');

$gi -> exec('Alice', 'sed -i s/tow/two/ numbers.txt',
    text_pre => 'Fix the typo');

$gi -> exec('Alice', 'cat numbers.txt',
    text_pre => 'Make sure that the sed command did its job');

$gi -> exec('Alice', 'git commit -a -m "Fix typo"',
    text_pre => 'Commit the fix');

$gi -> exec('Alice', 'git checkout master',
    text_pre => 'go back to the original master branch');

$gi -> exec('Alice', 'cat numbers.txt',
    text_pre => 'The typo is still here');

$gi -> exec('Alice', 'git log --stat --summary',
    text_pre => 'Also, the "Fix typo" commit is not present in the master branch');

$gi -> exec('Alice', 'printf "five\nsix\n" >> numbers.txt',
    text_pre => 'Add a few numbers');

$gi -> exec('Alice', 'git commit -a -m "Added 5 and 6"',
    text_pre => 'Commit changes');

$gi -> exec('Alice', 'git checkout fixTypoBranch',
    text_pre => 'Going to fixTypoBranch again');

$gi -> exec('Alice', 'cat numbers.txt',
    text_pre => 'Numbers 5 and 6 don\'t exist');

$gi -> exec('Alice', 'git checkout master',
    text_pre => 'Going back to master');

$gi -> exec('Alice', 'cat numbers.txt',
    text_pre => 'Numbers 5 and 6 exist. So does the typo.');

$gi -> exec('Alice', 'git merge fixTypoBranch',
    text_pre => 'Merge the typo fix from fixTypoBranch');

$gi -> exec('Alice', 'cat numbers.txt',
    text_pre => 'Numbers 5 and 6 exist, but the typo has gone.');

$gi -> exec('Alice', 'git status',
    text_pre => 'A merge does not seem to be needed to be commited.');

$gi -> exec('Alice', 'git branch -d fixTypoBranch',
    text_pre => 'The fixTypoBranch is not needed anymore, we can delete it.');

$gi -> exec('Alice', 'git branch',
    text_pre => 'The branch is gone.');

$gi -> end;
