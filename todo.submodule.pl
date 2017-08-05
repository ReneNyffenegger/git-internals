#!/usr/bin/perl
use warnings;
use strict;
use utf8;

use GitInternals;

my $gi = GitInternals -> new(['Alice', 'Bob']);

$gi->exec('Bob', 'git init --template=""');

$gi->exec('Bob', 'printf "Bob\'s Library\nVersion 1\n" > README');

$gi->exec('Bob', 'git add README');

$gi->exec('Bob', 'git commit README -m "add README"');


# ----

$gi->exec('Alice', 'git init --template=""');
$gi->exec('Alice', 'printf "Alice\'s Program\n" > README');
$gi->exec('Alice', 'git add README');
$gi->exec('Alice', 'git commit README -m "Add README"');

$gi->exec('Alice', 'git submodule add ' . $gi->repo_dir_full_path('Bob'));

$gi->end();
