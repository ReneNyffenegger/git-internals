package GitInternals;

use warnings;
use strict;

use Digest::MD5::File qw(file_md5_hex);
use File::Path qw(rmtree);
use File::Basename;
use File::Copy::Recursive 'dircopy';
use File::DirCompare;
use File::Find;
use File::Slurp;
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
  my $command_out = readpipe ("$faketime $command 2>&1");

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

  my $add_file = sub {
    my $array_ref = shift;
    my $filename  = shift;

    my $file = {};

    $filename = File::Spec -> abs2rel($filename, "$self->{snapshot_dirs}->[$repo_no]/$curr_snap_no");


    if ($filename =~ m!^.git/objects/([[:xdigit:]]{2})/([[:xdigit:]]+)$!) { #_{

       my $object_id = "$1$2";

       my $filename_obj = "obj_$object_id.html";

       $filename = ".git/objects/<a class='filename' href='$filename_obj'>$1/$2</a>";

       my $cwd_safe = cwd();
       chdir ($self->{working_dirs}->[$repo_no]);

          my $object_type = readpipe("git cat-file -t $object_id");
          chomp $object_type;

          my $object_content = readpipe("git cat-file -p $object_id");;
          $object_content =~ s!([[:xdigit:]]{40})!<a href='obj_$1.html'>$1</a>!mg;

       chdir $cwd_safe;

       my $title = "Git $object_type-object $object_id";
       $self -> write_html_linked_files($filename_obj, $title, <<CONTENT);
The content of this $object_type object is;
<code><pre class='$object_type'>$object_content</pre></code>
CONTENT


       $file->{object}->{id  } = $object_id;
       $file->{object}->{type} = $object_type;
    } #_}
    else { #_{

      if ($filename ne '.git/index') {
       my $cwd_safe = cwd();
       chdir ($self->{working_dirs}->[$repo_no]);

          my $filename_ = file_md5_hex($filename) . '.html';
          my $filecontent = read_file($filename, binmode => ':utf8');
          $filecontent =~ s!([[:xdigit:]]{40})!<a href='obj_$1.html'>$1</a>!mg;

       chdir $cwd_safe;

       $self->write_html_linked_files($filename_, $filename, <<CONTENT);
The content of $filename is:
<code><pre>$filecontent</pre></code>
CONTENT

       $filename = "<a class='filename' href='$filename_'>$filename</a>";

       }

    } #_}

    $file->{filename} = $filename;


    push @$array_ref, $file;


  };

  File::DirCompare->compare(
     "$self->{snapshot_dirs}->[$repo_no]/$prev_snap_no",
     "$self->{snapshot_dirs}->[$repo_no]/$curr_snap_no",
  sub { #_{

     my ($prev, $new) = @_;

     my $type  = -d ($new || $prev) ? "directory" : "file";
     if (! $prev) {     #_{ New file or directory

#      print "Compare, new = $new\n";

       if (-f $new) { #_{
       # A new file, add it:
         &$add_file(\@new_files, $new);
#        push @new_files, $new;
       } #_}
       else { #_{
       # A new directory, add each file under the new directory:
         find( {no_chdir => 1, wanted => sub {

              my $file = $_;

              return if -d $file;
              &$add_file(\@new_files, $file);
#             push @new_files, $file;

           }
         }, $new); #_}
       } #_}
     } elsif (! $new) { #_{ deleted file

         if (-f $prev) {
         # A file was deleted. Add it to the list of deleted files
#          push @deleted_files, $prev;
           &$add_file(\@deleted_files, $prev);
         }
         else {
           die;
         }

 #_}
     } else {           #_{ changed file

     # A file has changed
#      push @changed_files, $new;
       &$add_file(\@changed_files, $new);
     } #_}
   }); #_}

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
  my $title        = shift;  # TODO currently not used anymore
  my $css_class    = shift;
  my $repo_no      = shift;
  my $curr_snap_no = shift;
  my $files_ref    = shift;

  my $counter = 0;
  if (@$files_ref) {
#   $self->html("<div class='files-title'>$title</div><div class='$css_class'>");
    $self->html(                                     "<div class='$css_class'>");

    for my $file (@$files_ref) {

       my $file_name = $file->{filename};
#      my $file_name = File::Spec -> abs2rel($file->{filename}, "$self->{snapshot_dirs}->[$repo_no]/$curr_snap_no");

       my $object_type='';
       if (my $object = $file->{object}) {
         $object_type = " <span class='obj-type'>[$object->{type}]</span>";
       }

       $self->html("<code class='filename'>$file_name</code>$object_type");

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

  unless (-d $self->{name}) {
    mkdir $self->{name} or die;
  }

  unlink glob "$self->{name}/*.html";

  open ($self->{html_out}, '>:encoding(utf-8)', "$self->{name}/index.html") or die;


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
.filename { font-family: Courier New; }

.files-title { font-size: 16px; margin-top: 9px}

.new-files > *, .changed-files > *, .deleted-files > * {
  font-size: 12px;
}

.cur-dir {
  color:#a38;
}

p.txt { color: #114 }

span.obj-type {
  color: gray;
}

h1.title {
  color:blue;
}
table {
 border:collapse;
}
td {
  vertical-align: top;
  border-right: 1px solid #f93;
  padding: 10px;
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

  print {$self->{html_out}} "<table border=0>";

  $self->html("<tr><td>Command</td><td>New files</td><td>Changed files</td><td>Deleted files</td></tr>\n");
} #_}

sub write_html_linked_files { #_{

  my $self     = shift;
  my $filename = shift;
  my $title    = shift;
  my $content  = shift;


  open (my $f, '>', $self->{name} . "/$filename") or die "$!\n" . cwd() . "\n$filename";

  print $f "<!DOCTYPE html>\n";
  print $f "<html><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'><title>$title</title>\n";
  print $f '<style type="text/css">

     pre {border: 1px solid black; margin: 3px; padding: 4px}

     pre.blob   {background-color: #e5f50f;}
     pre.commit {background-color: #f3c248;}
     pre.tree   {background-color: #ecc4ff;}
     pre.tag    {background-color: #f4c95f;}

  </style></head><body>
  ';


  print $f "<h1>$title</h1>";

  print $f $content;

  print $f "<p><hr><a href='index.html'>Return to example</a></body></html>";


} #_}


1;
