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
  ['lbfmt',  'yellow', 'list files with bad audio format, which can\'t be used by taffy'],
  ['convbf', 'red',    'convert files of bad format, see lbfmt'],
  ['lmeta',  'green',  'show meta data of all files'],
  ['wmeta',  'red',    'write metadata to the files with taffy'],
  ['walb',   'red',    'write an album to the metadata of the files']
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

# functions for music editing
sub list {
  system 'ls -w 1';
}

sub lbvt {
  for (`ls`) {
    chomp;
    print "'$_'" if /\(Official Video\)|\(Official HD Video\)/;
  }
}

sub rnbvt {
  for (`ls`) {
    chomp;
    if (/\(Official Video\)|\(Official HD Video\)/) {
      my $old = $_;
      s/\s*(\(Official Video\)|\(Official HD Video\))//;
      system "mv -v \"$old\" \"$_\"";
    }
  }
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
    /^[^-]* - [^-]* - [^-]*\.[^.]{3,4}$/ || print;
  }
}

sub lfeat {
  for (`ls`) {
    chomp;
    print "'$_'" if /^(\d+ - )?[^-]* - [^-]*([( \[][Ff]([Ee][Aa])?[Tt]\.? )[^-]*\.[^.]{3,4}$/;
  }
}

sub rnfeat {
  for (`ls`) {
    chomp;
    my @r = (
      '((\d+ - )?[^-]* )',
      '(- [^-]*\S)',
      '([( \[][Ff]([Ee][Aa])?[Tt]\.? [^\])]*[\])])',
      '( [^-]*)?',
      '(\.[^.]{3,4})'
    );
    if (/^$r[0]$r[1]\s*$r[2]\s*$r[3]$r[4]$/) {
      my $bp = $6 || '';
      system "mv -v \"$_\" \"$1$4 $3$bp$7\"";
    }
  }
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
  print "$moved files moved";
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
    my @to = `taffy \"$_\"`;
    map chomp, @to;
    my $name = $to[0];

    my @info = ();
    my $track; my $artist; my $title; my $album;
    for (@to) {
      /^track:\s*(.*)/  and $track  = $1;
      /^artist:\s*(.*)/ and $artist = $1;
      /^title:\s*(.*)/  and $title  = $1;
      /^album:\s*(.*)/  and $album  = $1;
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
  my $n;
  my $artist;
  my $title;
  my $written = 0;
  for (`ls`) {
    chomp;
    /^\d+ - [^-]* - [^-]*\.[^.]{3,4}$/ || (print "excluding '$_'") && next;
    /^(\d+)/ and $n = $1 + 0;
    /^\d+ - ([^-]*) - .*/ and $artist = $1;
    /^\d+ - [^-]* - (.*)\.[^.]{3,4}$/ and $title = $1;
    system "taffy \"$_\" -n \"$n\" -r \"$artist\" -t \"$title\"";
    $written += 1;
  }
  print "meta data of $written files written";
}

sub walb {
  printf "give album name:\n> ";
  my $album = <STDIN>;
  chomp $album;
  for (`ls`) {
    chomp;
    system "taffy \"$_\" -l \"$album\"";
  }
}

