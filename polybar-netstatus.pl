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

unless (`cat \"/sys/class/net/$1/operstate\"` eq "up\n") {
  print $notconn;
  exit 0;
}

`ls /sys/class/net/$1/wireless 2>/dev/null`;
if ($? == 0) {
  print $wireless;
} else {
  print $ethernet;
}

