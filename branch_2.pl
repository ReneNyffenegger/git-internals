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
       text_post=>'A little surprising, there is only the fixTypo branch and no master branch. This is (probably?) because he cloned from Alice\'s repository when it was in the fixTypo branch.');

$gi -> exec('Bob'  , 'git branch -r',
       text_pre=>'So, in order to see the remote tracking branches, he uses the<code>-r</code> option:');

$gi -> exec('Bob'  , 'git branch -a',
       text_pre=>'With the <code>-a</code> option, he sees <i>all</i> branches: remote tracking and local ones:');

$gi -> exec('Bob'  , 'cat numbers.txt',
       text_pre=>'Examine the content of numbers.txt',
       text_post=>'Bob sees the commited fix (two instead of tow) of Alice at the time of his cloning the repository.');

$gi -> exec('Bob'  , 'git branch master origin/master',
       text_pre=>'Bob wants to work on the master branch. Therefore, he creates it like so …');

$gi -> exec('Bob'  , 'git checkout master',
       text_pre=>'… and switches to it:',
       text_post=>'Note: Bob could have done the creation and switch to the new branch in one step: <code>git checkout -b master origin/master</code>.');
        

# $gi -> exec('Bob'  , 'git checkout -b master origin/master');

$gi -> exec('Bob'  , 'cat numbers.txt',
       text_pre=>'The content of numbers.txt now has all three typos:');

$gi -> exec('Alice', 'git commit numbers.txt -m "Fix typo fife->five"',
       text_pre=>'In the mean time, Alice commits her second typo fix.');
 
$gi -> exec('Bob'  , 'printf "eleven\ntwelve\n" >> numbers.txt',
       text_pre=>'Bob, being on the master branch, adds 11 and 12 to numbers.txt:');

$gi -> exec('Bob'  , 'git commit numbers.txt -m "add 11 and 12"',
       text_pre=>'Commit the changes:');

$gi -> exec('Bob'  , 'git push origin master');

# TODO: This is certainly possible more elegantly...
$gi -> exec('Alice', '', no_separate_command=>1, another_diff=>1, text_pre=>"Bob's push also changes Alice's repository");

$gi -> exec('Bob'  , 'git pull',
       text_pre=>"He now pulls from Alice's repository:",
       text_post=>"Note: it pulls the commit object of Alice's latest typo fix, but it <i>does not</i> update <code>.git/refs/heads/fixTypo</code>!" );

  $gi -> exec('Bob'  , 'git checkout fixTypo',
       text_pre=>'Bob checks out the fixTypo branch.',
       text_post=>"He would be mistaken if he believed that he now has Alice's latest fix. Note git's warning <i>Your branch is behind 'origin/fixTypo' by 1 commit…</i>");

$gi -> exec('Bob'  , 'cat numbers.txt',
       text_pre=>"Bob does not according to git's recommendation to execute <code>git pull</code> again…",
       text_post=>"… so he still sees <i>fife</i> instead of the corrected <i>five</i>.");

$gi -> exec('Bob'  , 'git pull',
       text_pre=>"He now <i>does</i> execute <code>git pull</code> …",
       text_post=>"… which updates <code>.git/refs/heads/fixTypo</code>. Note, that the command does not pull new objects into Bob's repository.");

$gi -> exec('Bob'  , 'cat numbers.txt',
       text_pre=>"Showing the content of the file:",
       text_post=>"This time, the file does contain Alice's correction.");

$gi -> exec('Alice', 'git checkout master',
       text_pre=>"In the mean time, Alice checks out the master branch.",
       text_post=>"Note, git does not say anything about the branch being behind.");
$gi -> exec('Alice', 'cat numbers.txt',
       text_pre=>"So, she sees Bob's addition of eleven and twelve.");

$gi -> end();
