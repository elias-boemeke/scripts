#! /bin/perl


my $notconn = '';
my $wireless = '';
my $ethernet = '';
#  
#  
#  
#   

`ip r` =~ /^default via \S+ dev (\S+)/;
unless ($1) {
  print $notconn;
  exit 0;
}

unless (`cat \"/sys/class/net/$1/operstate\"` == 'up') {
  print $notconn;
  exit 0;
}

system "ls /sys/class/net/$1/wireless &> /dev/null";
if ($? == 0) {
  print $wireless;
} else {
  print $ethernet;
}

