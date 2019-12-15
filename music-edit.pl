#! /bin/perl

use strict;
no strict 'refs';
use warnings;

use Term::ANSIColor;

$\ = "\n";

my @opinfo = (
  ['list',   'green',  'lists files in the current directory'],
  ['lbvt',   'yellow', 'lists all files that have a title not referring to audio'],
  ['rnbvt',  'red',    'rename all files that have a title not referring to audio'],
  ['ldbl',   'yellow', 'find doubled files, i.e. one normal version and one with video'],
  ['lbdash', 'yellow', 'list all files that have a bad format, i.e. wrong number of dashes'],
  ['lfeat',  'yellow', 'list all files that have a feat. in title instead of artist'],
  ['rnfeat', 'red',    'rename all files that have a feat. in title instead of artist'],
  ['lgaps',  'yellow', 'list numeric gaps, names have to be preceded with numbers'],
  ['mvdown', 'red',    'close all numeric gaps by appropriate moving, see lgaps'],
  ['lbfmt',  'yellow', 'list files with bad audio format, which can\'t be used by taggo'],
  ['convbf', 'red',    'convert files of bad format, see lbfmt'],
  ['lmeta',  'green',  'show meta data of all files'],
  ['wmeta',  'red',    'write metadata to the files with taggo'],
  ['want',   'red',    'write an album and track numbers to the metadata']
);

# main routine
my $ARGC = $#ARGV + 1;
my $op = '';
if ($ARGC == 0) {
  $op = showInteractive();

} elsif ($ARGC == 1) {
  $op = $ARGV[0];

} else {
  print "too many arguments";
  exit 1
}

my %quitops = ('' => 1, 'q' => 1, 'quit' => 1, 'exit' => 1);
if (exists $quitops{$op}) {
  exit 0;
}

my %names = map(($_->[0], 1), @opinfo);
unless (exists $names{$op}) {
  print "unknown operation '$op'";
  exit 1;
}
"$op"->();

# functions
sub showInteractive {
  print 'Choose an Operation';
  print 'available operations:';
  my $sep = '---------------------';
  print $sep;

  foreach my $data (@opinfo) {
    printf "- %-16s (%s)\n", color($data->[1]) . $data->[0] . color("reset"), $data->[2];
  }

  print $sep;
  $\ = '';
  print '> ';
  $\ = "\n";
  my $line = <>;
  unless ($line) {
    print "input closed";
    exit 0;
  }
  chomp $line;
  return $line;
}

sub files {
  return ($_[0] != 1) && 'files' || 'file';
}

# functions for music editing
sub list {
  system 'ls -w 1';
}

sub lbvt {
  for (`ls`) {
    chomp;
    print "'$_'" if /\(Official Video\)|\(Official HD Video\)|\(Music Video\)/;
  }
}

sub rnbvt {
  my $moved = 0;
  for (`ls`) {
    chomp;
    if (/\(Official Video\)|\(Official HD Video\)|\(Music Video\)/) {
      my $old = $_;
      s/\s*(\(Official Video\)|\(Official HD Video\)|\(Music Video\))//;
      system "mv \"$old\" \"$_\"";
      $moved += 1;
    }
  }
  print "$moved " . files($moved) . ' renamed';
}

sub ldbl {
  my @ls = `ls`;
  map chomp, @ls;
  my @names = @ls;
  map s/^\d+ - (.*)\.[^.]{3,4}$/$1/, @names;
  for (my $i = 0; $i < @names; $i++) {
    my $cur = $names[$i];
    my @matches = ();
    for (my $j = 0; $j < @names; $j++) {
      if ($names[$j] eq $cur) {
        push @matches, ($j);
      }
    }
    if (@matches > 1 && $i == $matches[0]) {
      print "found double(s) of '$cur' at numbers (" . (join(', ', map sub { $ls[$_] =~ /^(\d+)/; return $1; }->(), @matches)) . ")";
    }
  }
}

sub lbdash {
  for (`ls`) {
    chomp;
    /^\d+ - ([^-]|\S-\S)+ - ([^-]|\S-\S)+\.[^.]{3,4}$/ || print;
  }
}

sub lfeat {
  for (`ls`) {
    chomp;
    print "'$_'" if /^\d+ - ([^-]|\S-\S)+ - ([^-]|\S-\S)+[( \[][Ff]([Ee][Aa])?[Tt]\.? ([^-]|\S-\S)*\.[^.]{3,4}$/;
  }
}

sub rnfeat {
  my $moved = 0;
  for (`ls`) {
    chomp;
    my @r = (
      '\d+',
      '(?:[^-]|\S-\S)',
      '[Ff](?:[Ee][Aa])?[Tt]\.?',
      '[^.]{3,4}'
    );

    if (/^($r[0]) - ($r[1]+) - ($r[1]+-?\S)\s*(?:(\($r[2] $r[1]+?\))\s*($r[1]*)| ($r[2] [^(]+)| ($r[2] [^(]+\S)\s*(\(.*\)))\.($r[3])$/) {
      my $feat = $4 || $6 || $7;
      my $appendix = $5 || $8 || '';
      $appendix = " $appendix" if $appendix ne '';
      system "mv \"$_\" \"$1 - $2 $feat - $3$appendix.$9\"";
      $moved += 1;
    }
  }
  print "$moved " . files($moved) . ' moved';
}

sub lgaps {
  my $pn = 0;
  my $prev = '';
  my $n;
  for (`ls`) {
    chomp;
    $n = sub {/^(\d+)/; return $1}->();
    if ($pn != $n-1) {
      print "gap between:\n  '$prev'\n  '$_'";
    }
    $prev = $_;
    $pn = $n;
  }
}

sub mvdown {
  my @lines = `ls`;
  map chomp, @lines;
  my $w = $lines[0] =~ /^(\d+)/ && length $1;

  my $c = 1;
  my $n;
  my $moved = 0;
  for (my $i = 0; $i < @lines; $i++) {
    $_ = $lines[$i];
    $n = /^(\d+)(.*)/ && $1;
    if ($n != $c) {
      system "mv \"$_\" \"" . (sprintf "%0${w}d", "$c") . "$2\"";
      $moved += 1;
    }
    $c += 1;
  }
  print "$moved " . files($moved) . ' moved';
}

sub lbfmt {
  for (`ls`) {
    chomp;
    /\.ogg$/ && print;
  }
}

sub convbf {
  for (`ls`) {
    chomp;
    my $head = /^(.*)\.{3,4}$/ && $1;
    /\.ogg$/ && `ffmpeg -i \"$_\" -f opus \"$head.opus\"`;
    system "rm \"$_\"";
  }
}

sub lmeta {
  for (`ls`) {
    chomp;
    my $file = $_;
    $file =~ s/\$/\\\$/g;
    my @to = `taggo \"$file\"`;
    map chomp, @to;
    my $name = $to[0];

    my @info = ();
    my $track; my $artist; my $title; my $album;
    for (@to) {
      /^\s*Track: (.*)/  and $track  = $1;
      /^\s*Artist: (.*)/ and $artist = $1;
      /^\s*Title: (.*)/  and $title  = $1;
      /^\s*Album: (.*)/  and $album  = $1;
    }
    $track  && push @info, "'$track'";
    $artist && push @info, "'$artist'";
    $title  && push @info, "'$title'";
    $album  && push @info, "'$album'";

    print "'$_'";
    if (@info > 0) {
      print '  ', join ' - ', @info;
    } else {
      print '  empty tags';
    }
  }
}

sub wmeta {
  my $artist;
  my $title;
  my $written = 0;
  for (`ls`) {
    chomp;
    /^\d+ - ([^-]|\S-\S)+ - ([^-]|\S-\S)+\.[^.]{3,4}$/ || (print "excluding '$_'") && next;
    /^\d+ - ((?:[^-]|\S-\S)+) - .*/ and $artist = $1;
    /^\d+ - (?:[^-]|\S-\S)+ - (.*)\.[^.]{3,4}$/ and $title = $1;
    my $file = $_;
    $file =~ s/\$/\\\$/g;
    system "taggo \"$file\" -r \"$artist\" -t \"$title\"";
    $written += 1;
  }
  print "meta data of $written " . files($written) . ' written';
}

sub want {
  printf "give album name:\n> ";
  my $album = <STDIN>;
  chomp $album;
  my $n;
  my $written = 0;
  for (`ls`) {
    chomp;
    /^(\d+) - / and $n = $1 + 0;
    my $file = $_;
    $file =~ s/\$/\\\$/g;
    system "taggo \"$file\" -l \"$album\" -k \"$n\"";
    $written += 1;
  }
  print "meta data of $written " . files($written) . ' written';
}

