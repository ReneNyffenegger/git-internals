#!/usr/bin/perl
use warnings;
use strict;

use utf8;

use GitInternals;

my $gi = new GitInternals ( [ 'Alice']);

$gi -> exec('Alice', 'git init --template=""');

$gi -> exec('Alice', 'touch numbers.txt',
       text_pre => 'Alice creates the (empty) file numbers.txt');

$gi -> exec('Alice', 'git add . ',
       text_pre => 'She adds the file to the index …');

$gi -> exec('Alice', 'git commit -m "Adding numbers.txt"',
       text_pre => '… and commits the addition of the file.');

$gi -> exec('Alice', 'printf "one\ntow\nthree\nfour\n" > numbers.txt',
   text_pre => 'Adding some numbers to the file. Note the typo (tow instead of two)');

# $gi -> exec('Alice', 'git add . ');
$gi -> exec('Alice', 'git commit numbers.txt -m "Numbers 1 through 4"');

$gi -> exec('Alice', 'git branch fixTypoBranch',
    text_pre => 'Create a branch to fix the typo:',
    text_post=> 'It creates the two files .git/logs/refs/heads/fixTypoBranch and .git/refs/heads/fixTypoBranch. These files will later be deleted again when the branch will be deleted.');

$gi -> exec('Alice', 'git branch',
    text_pre => 'Show "available" branches',
    text_post=> 'The star indicates the "current" branch');

$gi -> exec('Alice', 'git checkout fixTypoBranch',
    text_pre => 'Change to the newly created branch',
    text_post=> 'The content of .git/HEAD changes from refs/heads/master to refs/heads/fixTypoBranch');

$gi -> exec('Alice', 'sed -i s/tow/two/ numbers.txt',
    text_pre => 'Fix the typo');

$gi -> exec('Alice', 'cat numbers.txt',
    text_pre => 'Make sure that the sed command did its job');

$gi -> exec('Alice', 'git commit -a -m "Fix typo"',
    text_pre => 'Commit the fix');

$gi -> exec('Alice', 'git checkout master',
    text_pre  => 'Go back to the original master branch. Note, the fix is not yet commited.',
    text_post => 'The content of .git/HEAD changes back to <code>refs/heads/master</code>.');

$gi -> exec('Alice', 'cat numbers.txt',
    text_pre => 'The typo is fixed in the fixTypoBranch. Because it had not been merged into the master branch, the typo is still there:');

$gi -> exec('Alice', 'git log --pretty=format:"%h %ar%x09%s"',
    text_pre => 'Also, the "Fix typo" commit is not present in the master branch');

$gi -> exec('Alice', 'printf "five\nsix\n" >> numbers.txt',
    text_pre => 'Add a few numbers:');

$gi -> exec('Alice', 'git commit numbers.txt -m "Added 5 and 6"',
    text_pre => 'Commit the addition of 5 and 6:');

# $gi -> exec('Alice', 'git log --pretty=format:"%h : %s" --graph');
$gi -> exec('Alice', 'git log --branches --graph --oneline --decorate',
    text_pre=>'Showing the commit tree:',
    text_post=>'Read the log from bottom upwards. Asterisks signify commits.'  );

$gi -> exec('Alice', 'git checkout fixTypoBranch',
    text_pre => 'By switching to the fixTypoBranch-branch, it can be shown that the branches are truly independent from one another.');

$gi -> exec('Alice', 'cat numbers.txt',
    text_pre => 'In fixTypoBranch, the numbers 5 and 6 don\'t exist, but the typo is fixed.');

$gi -> exec('Alice', 'git checkout master',
    text_pre => 'Going back to master.');

$gi -> exec('Alice', 'cat numbers.txt',
    text_pre => 'Int the master branch, the numbers 5 and 6 exist, but also does the typo:');

$gi -> exec('Alice', 'git merge fixTypoBranch',
    text_pre => 'Merge the typo fix from fixTypoBranch');

$gi -> exec('Alice', 'cat numbers.txt',
    text_pre => 'Showing the effects of the merge: numbers 5 and 6 exist <i>and</i> the typo has gone.');

# $gi -> exec('Alice', 'git show --name-status',
$gi -> exec('Alice', 'git log --branches --graph --oneline --decorate',
    text_pre => 'A merge creates a seperate commit object (In this case: fcc8c66…). So (unlike Subversion(?), it needs not be commited).');

$gi -> exec('Alice', 'git cat-file -p fcc8c66',
    text_pre=>'Note: the commit object of a merge has two parents');

$gi -> exec('Alice', 'git branch -d fixTypoBranch',
    text_pre => 'The fixTypoBranch is not needed anymore, we can delete it.',
    text_post=> 'This deletes the two files ./git/logs/refs/heads/fixTypoBranch and ./git/refs/heads/fixTypoBranch that were previously created with the git branch command.
                 Note: the objects of the branch are not deleted.');

$gi -> exec('Alice', 'git branch',
    text_pre => 'The branch is gone.');

$gi -> end;
