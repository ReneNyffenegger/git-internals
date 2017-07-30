#!/usr/bin/perl
use warnings;
use strict;

use utf8;

use GitInternals;

my $gi = GitInternals -> new ( [ 'Alice', 'Bob'], {title=>'Git branching, pulling and pushing etc.'});

$gi -> exec('Alice', 'git init --template=""');

$gi -> exec('Alice', 'printf "one\ntow\nthree\nfour\nfife\nsix\nseven\neigth\nnine\n" > numbers.txt',
             text_pre => 'Alice creates a file to store numbers …');


$gi -> exec('Alice', 'git add numbers.txt',
       text_pre=>'… adds it to the repository …');

$gi -> exec('Alice', 'git commit numbers.txt -m "+ numbers.txt"',
       text_pre=>'… and commits it.');

$gi -> exec('Alice', 'cat numbers.txt',
       text_pre => 'Unfortunately, Alice has made a few typos (tow instead of two, fife instead of five and eigth instead of eight)');

$gi -> exec('Alice', 'git checkout -b fixTypo',
       text_pre=>'So, she creates a new branch to start fixing the typos');

$gi -> exec('Alice', 'sed -i s/tow/two/ numbers.txt',
       text_pre=>'Fix the first typo:');

$gi -> exec('Alice', 'git commit numbers.txt -m "Fix typo: tow->two"',
       text_pre=>'Commit the fix:');

$gi -> exec('Alice', 'sed -i s/fife/five/ numbers.txt',
       text_pre=>'Immediately, Alice starts to fix the second typo:');

$gi -> exec('Bob'  , 'git clone --template="" ' . $gi->repo_dir_full_path('Alice') . ' .',
       text_pre=>'In the mean time, Bob clones Alice\'s repository.',
       text_post=>'After cloning, he has received all objects that already are in Alice\'s repository.');

$gi -> exec('Bob'  , 'git branch',
       text_pre=>'Bob wants to inquire about available branches:',
       text_post=>'A little surprising, there is only the fixTypo branch and no master branch. This is because he cloned from Alice\'s repository when it was in the fixTypo branch.');

$gi -> exec('Bob'  , 'git branch -r',
       text_pre=>'So, in order to see the remote tracking branches, he uses the<code>-r</code> option:');

$gi -> exec('Bob'  , 'git branch -a',
       text_pre=>'With the <code>-a</code> option, he sees <i>all</i> branches, remote tracking and local ones:');

$gi -> exec('Bob'  , 'cat numbers.txt',
       text_pre=>'Examine the content of numbers.txt',
       text_post=>'Bob sees the commited fix (two instead of tow) of Alice at the time of his cloning the repository');

# $gi -> exec('Bob'  , 'git branch master origin/master');
$gi -> exec('Bob'  , 'git checkout origin/master');
$gi -> exec('Bob'  , 'cat numbers.txt');
 
# $gi -> exec('Bob'  , "sed -i '/three/aTQ84-inserted-line' numbers.txt");
# 
# $gi -> exec('Bob'  , 'git commit . -m "Added TQ84 line"');
# # $gi -> exec('Bob'  , 'git push ' . $gi->repo_dir_full_path('Alice'));
# $gi -> exec('Bob'  , 'git push origin');
# 
# $gi -> exec('Alice', 'git branch');
# 
# $gi -> exec('Bob'  , 'git push -u origin tq84');
# $gi -> exec('Alice', 'git branch');
# 
# $gi -> exec('Alice', 'git checkout tq84');
# $gi -> exec('Alice', 'cat numbers.txt');
# 
# $gi -> exec('Alice', 'git checkout master');
# 
# $gi -> exec('Alice', 'printf "seven\n" >> numbers.txt');
# $gi -> exec('Alice', 'cat numbers.txt');
# $gi -> exec('Alice', 'git commit . -m "+ seven"');
# 
# $gi -> exec('Bob'  , 'git branch');
# $gi -> exec('Bob'  , 'git pull origin master');
# $gi -> exec('Bob'  , 'git merge master');
# $gi -> exec('Bob'  , 'cat numbers.txt');

$gi -> end();
