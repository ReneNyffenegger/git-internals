#!/usr/bin/perl
use warnings;
use strict;

use GitInternals;

my $gi = new GitInternals ( [ 'Alice']);

$gi -> exec('Alice', 'git init --template=',
  text_pre=>'Initialize a new git repository. Use the <code>--template=</code> parameter to indicate that git should not copy (sample) hook files into the new repository.',
  text_post=>'The content of .git/HEAD is refs/heads/master although this file does not yet exist.');

$gi -> end;
