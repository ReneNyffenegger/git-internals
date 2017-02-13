package GitInternals;

use warnings;
use strict;

use File::Path qw(rmtree);
use File::Basename;
use File::Copy::Recursive 'dircopy';
use File::DirCompare;
use File::Find;
use Time::Piece;
use HTML::Escape;
use Cwd;
use utf8;

use open ':utf8';

sub new { #_{

  my $self = {};
  bless $self, shift;

  my $repos_ref = shift;

  my @repos = @{$repos_ref};

  $self -> {working_dirs } = [ map { "repos/$_"} @repos ];
  $self -> {snapshot_dirs} = [ map { "snaps/$_"} @repos ];
  $self -> {cur_dirs     } = [ map { "$_/"     } @repos ];

  $self -> {top_dir      } = cwd() . '/';

  $self -> {t}             = Time::Piece -> strptime('2016-01-01 00:00:00', '%Y-%m-%d %H:%M:%S');

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
} #_}

sub end { #_{

  my $self = shift;

  $self->html("</table>\n");

  $self->html("<div id='repolink'>This page was created using <a href='https://github.com/ReneNyffenegger/git-internals'>GitInternals.pm</a>.
    <br>See also <a href='http://renenyffenegger.ch/development/git-internals/index.html'>list of other html pages</a> created with GitInternals.pm.</div>\n");
  
  $self->html("</body></html>\n");

  close $self->{html_out};
} #_}

sub exec { #_{
  my $self = shift;

  my $repo_name = shift;

  my $repo_no = $self->repo_no($repo_name);
  die "Unknown repo with name $repo_name" unless defined $repo_no;

  my $command   = shift;

  my %options   = @_;

  $self->html("<tr><td>");

  $self->html("<div class='out$repo_no'>");

  if ($options{text_pre}) {
    $self->html("<p class='txt'>" . text2html($options{text_pre}) . "</p>\n");
  }

  $self->html("<code class='shell'><pre>");

  $self -> print_command($repo_no, $command);

  chdir $self->{top_dir} . '/repos/' . $self->{cur_dirs}->[$repo_no];

# http://renenyffenegger.ch/notes/Linux/shell/commands/faketime
  my $faketime = $self->{t}->strftime('faketime -f "@%Y-%m-%d %H:%M:%S" '); $self->{t} += 60;
  my $command_out = readpipe ("$command 2>&1");

  $self->html (escape_html($command_out));

  $self->html("</pre></code>\n");

  $self->html("</div>\n");
  $self->html("</td>");

  $self -> make_snapshot($repo_no);

  if (not $options{no_cmp}) {
    $self -> compare_snapshots($repo_no);
  }
  else {
    $self->html("<td></td><td></td><td></td>\n");
  }
  $self->html("</tr>");


  if ($options{text_post}) {
    $self->html("<tr><td colspan='4'>");
    $self->html("<p class='txt'>" . text2html($options{text_post}) . "</p>\n");
    $self->html("</td></tr>");
  }


} #_}

sub text { #_{
  my $self = shift;
  my $text = shift;

  $self->html("<div class='outNeutral'>");

  $self->html("<p class='txt'>" . text2html($text) . "</p>\n");

  $self->html("</div>\n");


} #_}

sub repo_no { #_{
  my $self      = shift;
  my $repo_name = shift;
  return $self->{repo_name_to_no}{$repo_name};
} #_}

sub print_command { #_{

  my $self    = shift;
  my $repo_no = shift;
  my $command = shift;

  my $command_html = escape_html($command);

  $command_html =~ s!^git +(\w+)!<a href='http://renenyffenegger.ch/notes/development/version-control-systems/git/commands/$1'>git $1</a>!;

  my $cur_dir = $self->{cur_dirs}->[$repo_no];

  $self->html("<span class='cur-dir'>$cur_dir</span>&gt; <b>$command_html</b>\n");
} #_}

sub html { #_{

  my $self      = shift;
  my $html_text = shift;

  print {$self->{html_out}} $html_text;
} #_}

sub init_directories { #_{

  my $self = shift;

  for my $dir (@{$self->{working_dirs}}, @{$self->{snapshot_dirs}}) {

      if (-d $dir) {
        rmtree $dir or die "Could not remove $dir";
      }
      mkdir  $dir or die;
  }
} #_}

sub make_snapshot { #_{

  my $self    = shift;
  my $repo_no = shift;

  $self->{snapshot_no}->[$repo_no]++;

  chdir $self->{top_dir};

 dircopy ("$self->{working_dirs}->[$repo_no]/", "$self->{snapshot_dirs}->[$repo_no]/$self->{snapshot_no}->[$repo_no]");
} #_}

sub repo_dir_full_path { #_{

  my $self      = shift;
  my $repo_name = shift;

  my $repo_no   = $self->repo_no($repo_name);

  return $self->{top_dir} . $self->{working_dirs}->[$repo_no];

} #_}

sub compare_snapshots { #_{

  my $self = shift;
  my $repo_no = shift;

  my @new_files;
  my @deleted_files;
  my @changed_files;

  chdir $self->{top_dir};

  my $curr_snap_no = $self->{snapshot_no}->[$repo_no];
  my $prev_snap_no = $curr_snap_no - 1;

  File::DirCompare->compare(
     "$self->{snapshot_dirs}->[$repo_no]/$prev_snap_no",
     "$self->{snapshot_dirs}->[$repo_no]/$curr_snap_no",
  sub {
 
     my ($prev, $new) = @_;
 
     my $type  = -d ($new || $prev) ? "directory" : "file";
     if (! $prev) {     #_{ New file or directory
 
       if (-f $new) {
       # A new file, add it:
         push @new_files, $new;
       }
       else {
       # A new directory, add each file under the new directory:
         find( {no_chdir => 1, wanted => sub {
 
              my $file = $_;
 
              return if -d $file;
              push @new_files, $file;
 
           }
         }, $new);
       } #_}
     } elsif (! $new) { #_{ deleted file
 
         if (-f $prev) {
         # A file was deleted. Add it to the list of deleted files
           push @deleted_files, $prev;
         }
         else {
           die;
         }

 #_}
     } else {           #_{ changed file

     # A file has changed
       push @changed_files, $new;
     } #_}
   });

  $self->html("<td>");
  $self -> print_file_list('New files'    , 'new-files'    , $repo_no, $curr_snap_no  , \@new_files    );   
  $self->html("</td><td>");
  $self -> print_file_list('Changed files', 'changed-files', $repo_no, $curr_snap_no  , \@changed_files);   
  $self->html("</td><td>");
  $self -> print_file_list('Deleted files', 'deleted-files', $repo_no, $curr_snap_no-1, \@deleted_files);   
  $self->html("</td>");

} #_}

sub print_file_list { #_{
  my $self         = shift;
  my $title        = shift;
  my $css_class    = shift;
  my $repo_no      = shift;
  my $curr_snap_no = shift;
  my $files_ref    = shift;
 
  my $counter = 0;
  if (@$files_ref) {
    $self->html("<div class='files-title'>$title</div><div class='$css_class'>");
 
    for my $file_name (@$files_ref) {
       $file_name = File::Spec -> abs2rel($file_name, "$self->{snapshot_dirs}->[$repo_no]/$curr_snap_no");
       $self->html("<code class='filename'>$file_name</code>");
 
       $self->html("<br>") if (++$counter < @$files_ref);
    }
 
    $self->html("</div>");
  }
} #_}

sub text2html { #_{

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

} #_}

sub open_html { #_{

  my $self = shift;

  open ($self->{html_out}, '>:encoding(utf-8)', "$self->{name}.html") or die;


  my $title = "git $self->{name}";

  print {$self->{html_out}} "<!DOCTYPE html>\n";
  print {$self->{html_out}} "<html><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'><title>$title</title></head>\n";
 
 
  print {$self->{html_out}} q{<style type="text/css">
* { font-family: Liberation Sans ; }


div.out0, div.out1, div.out2, div.outNeutral {padding-left: 20px}

div.out0 {border-left: 5px solid red  }
div.out1 {border-left: 5px solid blue }
div.out2 {border-left: 5px solid green}
div.outNeutral {border-left: 5px solid white}


code.shell {width: 100%; display: block; background-color: #f2f4fe; spacing: 2px;}
pre, pre * { font-family: Courier New; font-size:14px}
code.filename { font-family: Courier New; }

.files-title { font-size: 16px; margin-top: 9px}

.new-files > *, .changed-files > *, .deleted-files > * {
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
td {
  vertical-align: top
}

#repolink {
  background-color: #ccffbb;

  padding-top:    20px;
  padding-bottom: 20px;
  padding-left:   20px;

  margin-top: 100px;
  border-top: 3px solid #00a000;

}
</style>
};

  print {$self->{html_out}} "</head><body><h1 class='title'>$title</h1>";

  print {$self->{html_out}} "<table border=1>";
} #_}

1;
