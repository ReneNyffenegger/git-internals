#!/usr/bin/perl
use warnings;
#!/usr/bin/perl
use warnings;
use strict;

use utf8;

use GitInternals;

my $gi = GitInternals -> new(['Alice']);

$gi -> exec('Alice', 'git init --template=""');
$gi -> exec('Alice', 'echo one > a.file');
$gi -> exec('Alice', 'git add a.file');
$gi -> exec('Alice', 'git commit . -m "1st commit"');

$gi -> exec('Alice', 'echo two > a.file');
$gi -> exec('Alice', 'git commit . -m "2nd commit"');

$gi -> exec('Alice', 'echo three > a.file');
$gi -> exec('Alice', 'git commit . -m "3rd commit"');

$gi -> exec('Alice', 'echo four > a.file');
$gi -> exec('Alice', 'git commit . -m "4th commit"');

$gi -> exec('Alice', 'git rev-parse HEAD');
$gi -> exec('Alice', 'git rev-parse @',
  text_pre => '@ alone is a shortcut for HEAD');
$gi -> exec('Alice', 'git rev-parse master');

$gi -> exec('Alice', 'git rev-parse HEAD^',
  text_pre => "A revision (parameter) can be suffixed with a caret: it refers to the revision's commit parent commit");

$gi -> exec('Alice', 'git rev-parse HEAD^^');

$gi -> exec('Alice', 'git rev-parse HEAD^^^');
$gi -> exec('Alice', 'git rev-parse HEAD^3');
$gi -> exec('Alice', 'git rev-parse HEAD~3');
$gi -> exec('Alice', 'git rev-parse @{3}');
$gi -> exec('Alice', 'git rev-parse master@{3}');

$gi -> exec('Alice', 'git rev-parse HEAD^^^^');

$gi -> exec('Alice', 'git rev-parse :/2nd',
  text_pre => 'find most recent commit object that matches a string');

$gi -> exec('Alice', 'git rev-parse HEAD^{/2nd}');


$gi -> end;
