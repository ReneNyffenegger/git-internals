#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = GitInternals -> new(['Alice'], {title=>'Git: Adding files and resetting'} );

$gi -> exec('Alice', 'git init --template=""',
       text_pre => 'Alice creates a new repository.');

$gi -> exec('Alice', 'echo foo > a.file',
       text_pre => 'She creates a file whose content is simply: <code>foo</code>');

$gi -> exec('Alice', 'git add a.file',
       text_pre  => 'Then, she adds the file to the index.',
       text_post => 'This creates a blob object.');

$gi -> exec('Alice', 'echo bar >> a.file',
       text_pre  => 'She adds another line (<code>bar</code>) to the file:');

$gi -> exec('Alice', 'git commit -m "+ a.file"',
       text_pre  => 'Alice commits the newly added file',
       text_post => 'Note: this commits the content of the file that was added (blob object 257cc56…), not the content of the file as it is in the working directory.
                     Note also that the content of the working directory would be commited if
                     Alice executed the commit with a dot: <code>git commit . -m …</code>');

$gi -> exec('Alice', 'git status',
       text_pre  => 'Because the commit didn\'t commit the file in the working directory, the file\'s status is modified:');

$gi -> exec('Alice', 'git show HEAD:a.file',
       text_pre  => 'Showing the content of the file as stored in the repository:');

$gi -> exec('Alice', 'git reset --hard',
       text_pre => 'Alice resets the working tree so that it matches HEAD:',
       text_post=> 'Note: it creates .git/ORIG_HEAD');

$gi -> exec('Alice', 'cat a.file',
       text_pre => 'Thus, the content of <code>a.file</code> is <code>foo</code> again:');

$gi -> end;
