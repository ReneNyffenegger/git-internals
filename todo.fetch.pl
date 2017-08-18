#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = GitInternals -> new(['Alice', 'Bob']);

$gi -> exec('Alice', 'git init --template=""');
$gi -> exec('Alice', 'echo master > master.txt');
$gi -> exec('Alice', 'git add master.txt');
$gi -> exec('Alice', 'git commit . -m "+ master.txt"');

$gi -> exec('Alice', 'git checkout -b B1');
$gi -> exec('Alice', 'echo B1 > B1.txt');
$gi -> exec('Alice', 'git add B1.txt');
$gi -> exec('Alice', 'git commit . -m "+ B1.txt"');

$gi -> exec('Alice', 'git checkout -b B2 master',
       text_pre=>'Alice creates another branch, B2, from master');
$gi -> exec('Alice', 'ls',
       text_post=>'Because B2 was created from master rather from B1, the file <code>B1.txt</code> is not present in the repositoriy (<span style="background-color:red">TODO: is this the right word?</span>).');
$gi -> exec('Alice', 'echo B2 > B2.txt');
$gi -> exec('Alice', 'git add B2.txt');
$gi -> exec('Alice', 'git commit . -m "+ B2.txt"');

# TODO_LOG_GRAPH
# $gi -> exec('Alice', 'git log --graph --oneline --decorate master');

$gi -> exec('Alice', 'git checkout master',
       text_pre => 'Alice goes back to the master branch');

$gi -> exec('Bob'  , 'git clone --template="" ' . $gi->repo_dir_full_path('Alice') . ' .',
       text_pre=>'Bob clones Alice\'s repository');

$gi -> exec('Alice', 'git checkout B1');
$gi -> exec('Alice', 'echo foo >> B1.txt');
$gi -> exec('Alice', 'git commit . -m "foo -> B1.txt"');

$gi -> exec('Alice', 'git checkout B2');
$gi -> exec('Alice', 'echo bar >> B2.txt');
$gi -> exec('Alice', 'git commit . -m "bar -> B2.txt"');

$gi -> exec('Alice', 'git checkout -b B3 master');
$gi -> exec('Alice', 'echo B3 > B3.txt');
$gi -> exec('Alice', 'git add B3.txt');
$gi -> exec('Alice', 'git commit B3.txt -m "+ B3.txt"');

# $gi -> exec('Alice', 'git checkout -b R1');
# $gi -> exec('Alice', 'echo R1 > R1.txt');
# $gi -> exec('Alice', 'git add R1.txt');
# $gi -> exec('Alice', 'git commit . -m "+ R1.txt"');

# TODO_BRANCH_A_R
$gi -> exec('Bob'  , 'git branch -a');
$gi -> exec('Bob'  , 'git branch -r');

$gi -> exec('Bob'  , 'git checkout B1');

$gi -> exec('Bob'  , 'git fetch');

$gi -> exec('Bob'  , 'git log 7a0918c',
       text_pre => 'Bob has received the 7a0918c object (adding foo to B1)');

$gi -> exec('Bob'  , 'cat B1.txt',
       text_pre =>  'Although Bob has received the 7a0918c commit object, it is not yet in his working tree.');

$gi -> exec('Bob'  , 'git merge',
       text_pre => 'Only after merging ....');

$gi -> exec('Bob'  , 'cat B1.txt',
       text_pre => '.... is the line reading <code>foo</code> visible:');

$gi -> exec('Bob'  , 'git checkout B2',
       text_pre => '...');

$gi->end;
