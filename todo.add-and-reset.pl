#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = GitInternals -> new(['Alice']);

$gi -> exec('Alice', 'git init --template=""');
$gi -> exec('Alice', 'echo foo > a.file');
$gi -> exec('Alice', 'git add a.file');

$gi -> exec('Alice', 'echo bar >> a.file');

$gi -> exec('Alice', 'git commit -m "+ a.file"',
       text_pre  => 'Alice commits the newly added file',
       text_post => 'Note: this commits the content of the file that was added, not the content of the file as it is in the working directory. Note also that the content of the working directory would be commited if
                     Alice executed the commit with a dot: <code>git commit . -m …</code>');

$gi -> exec('Alice', 'git status',
       text_pre  => 'Because the commit didn\'t commit the file in the working directory, the file\'s status is modified:');

$gi -> exec('Alice', 'git show HEAD:a.file',
       text_pre  => 'The content of a.file in the repository can also be whown like so:');

$gi -> exec('Alice', 'git reset --hard');

$gi -> exec('Alice', 'cat a.file');

$gi -> end;
