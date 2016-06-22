package GitInternals;

use warnings;
use strict;

use File::Path qw(rmtree);
use File::Basename;
use File::Copy::Recursive 'dircopy';
use File::DirCompare;
use File::Find;
use HTML::Escape;
use Cwd;
use utf8;

use open ':utf8';

sub new {

  my $self = {};
  bless $self, shift;

  my $repos_ref = shift;

  my @repos = @{$repos_ref};

  $self -> {working_dirs } = [ map { "repos/$_"} @repos ];
  $self -> {snapshot_dirs} = [ map { "snaps/$_"} @repos ];
  $self -> {cur_dirs     } = [ map { "$_/"     } @repos ];

  $self -> {top_dir      } = cwd();

  my $repo_no = 0;
  for my $repo_name (@repos) {
    $self -> {repo_name_to_no} -> { $repo_name } = $repo_no;
    $self -> {snapshot_no} -> [$repo_no] = -1;
    $repo_no ++;
  }

# Assign script name (without .pl) to self->{name}
  ($self -> {name}) = fileparse ($0, '.pl');

  $self -> init_directories;

  $self->make_snapshot($_) for 0 .. @repos-1;

  $self -> open_html;

  return $self;
}

sub end {

  my $self = shift;

  print {$self->{html_out}} "</table></body></html>\n";
  close $self->{html_out};
}

sub exec {
  my $self = shift;

  my $repo_name = shift;

  my $repo_no = $self->{repo_name_to_no}{$repo_name};
  die "Unknown repo with name $repo_name" unless defined $repo_no;

  my $command   = shift;

  my %options   = @_;

  $self->html("<div class='out$repo_no'>");

  if ($options{text_pre}) {
    $self->html("<p class='txt'>" . text2html($options{text_pre}) . "</p>\n");
  }

  $self->html("<code class='shell'><pre>");

  $self -> print_command($repo_no, $command);

  chdir $self->{top_dir} . '/repos/' . $self->{cur_dirs}->[$repo_no];

  my $command_out = readpipe ($command);
  $self->html (escape_html($command_out));

  $self->html("</pre></code>\n");

  $self -> make_snapshot($repo_no);

  if (not $options{no_cmp}) {
    $self -> compare_snapshots($repo_no);
  }

  if ($options{text_post}) {
    $self->html("<p class='txt'>" . text2html($options{text_post}) . "</p>\n");
  }

  $self->html("</div>\n");

}

sub print_command {

  my $self    = shift;
  my $repo_no = shift;
  my $command = shift;

  my $command_html = escape_html($command);

  $command_html =~ s!^git +(\w+)!<a href='http://renenyffenegger.ch/notes/development/version-control-systems/git/commands/$1'>git $1</a>!;

  my $cur_dir = $self->{cur_dirs}->[$repo_no];

  print {$self->{html_out}} "<span class='cur-dir'>$cur_dir</span>&gt; <b>$command_html</b>\n";
}

sub html {

  my $self      = shift;
  my $html_text = shift;

  print {$self->{html_out}} $html_text;
}

sub init_directories {

  my $self = shift;

  for my $dir (@{$self->{working_dirs}}, @{$self->{snapshot_dirs}}) {

      if (-d $dir) {
        rmtree $dir or die "Could not remove $dir";
      }
      mkdir  $dir or die;
  }
}

sub make_snapshot {

  my $self    = shift;
  my $repo_no = shift;

  $self->{snapshot_no}->[$repo_no]++;

  chdir $self->{top_dir};

 dircopy ("$self->{working_dirs}->[$repo_no]/", "$self->{snapshot_dirs}->[$repo_no]/$self->{snapshot_no}->[$repo_no]");
}

sub compare_snapshots {

  my $self = shift;
  my $repo_no = shift;

  my @new_files;
  my @changed_files;
# File::DirCompare->compare("$snapshot_dirs[$working_dir_no]/snapshot.$last_snapshot_command_numbers[$working_dir_no]", "$snapshot_dirs[$working_dir_no]/snapshot.$command_counter", sub 

  chdir $self->{top_dir};

  my $curr_snap_no = $self->{snapshot_no}->[$repo_no];
  my $prev_snap_no = $curr_snap_no - 1;

  File::DirCompare->compare(
     "$self->{snapshot_dirs}->[$repo_no]/$prev_snap_no",
     "$self->{snapshot_dirs}->[$repo_no]/$curr_snap_no",
  sub {
 
     my ($prev, $new) = @_;
 
     my $type  = -d ($new || $prev) ? "directory" : "file";
     if (! $prev) {
 
       if (-f $new) {
         push @new_files, $new;
       }
       else {
         find( {no_chdir => 1, wanted => sub {
 
              my $file = $_;
 
              return if -d $file;
              push @new_files, $file;
 
           }
         }, $new);
       }
     } elsif (! $new) {
         die;
     } else {
 
       push @changed_files, $new;
     }
   });
 
  my $counter = 0;
  if (@new_files) {
    $self->html("<div class='files-title'>New files</div><div class='new-files'>");
    for my $new_file (@new_files) {
       $new_file = File::Spec -> abs2rel($new_file, "$self->{snapshot_dirs}->[$repo_no]/$curr_snap_no");
       $self->html("<code class='filename'>$new_file</code>");
 
       $self->html("<br>") if (++$counter < @new_files);
    }
    $self->html("</div>");
  }
 
  $counter = 0;
  if (@changed_files) {
    $self->html("<div class='files-title'>Changed files</div><div class='changed-files'>");
 
    for my $changed_file (@changed_files) {
       $changed_file = File::Spec -> abs2rel($changed_file, "$self->{snapshot_dirs}->[$repo_no]/$curr_snap_no");
       $self->html("<code class='filename'>$changed_file</code>");
 
       $self->html("<br>") if (++$counter < @changed_files);
    }
 
    $self->html("</div>");
  }


}

sub text2html {

  my $text = shift;

  $text =~ s{

    →\ *(
           [^[]+
        )
       \[
        (
           [^\]]+
        )
       \]
  }{

   "<a href='http://renenyffenegger.ch/notes/development/version-control-systems/$1'>$2</a>"

  }gex;

  $text;

}

sub open_html {

  my $self = shift;

  open ($self->{html_out}, '>:encoding(utf-8)', "$self->{name}.html") or die;


  my $title = "git $self->{name}";

  print {$self->{html_out}} "<!DOCTYPE html>\n";
  print {$self->{html_out}} "<html><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'><title>$title</title></head>\n";
 
 
  print {$self->{html_out}} q{<style type="text/css">
* { font-family: Liberation Sans ; }

div.out0, div.out1, div.out2 {padding-left: 20px}

div.out0 {border-left: 5px solid red  }
div.out1 {border-left: 5px solid blue }
div.out2 {border-left: 5px solid green}


code.shell {width: 100%; display: block; background-color: #f2f4fe; spacing: 2px;}
pre, pre * { font-family: Courier New; font-size:14px}
code.filename { font-family: Courier New; }

.files-title { font-size: 16px; margin-top: 9px}

.new-files > *, .changed-files > * {
  font-size: 12px;
}

.cur-dir {
  color:#a38;
}

p.txt { color: #114 }

h1.title {
  color:blue;
} 
table {
 border:collapse;
}
</style>
};

  print {$self->{html_out}} "</head><body><h1 class='title'>$title</h1>";

  print {$self->{html_out}} "<table>";
}


1;

