#! /bin/perl


my $notconn = '';
my $wireless = '';
my $ethernet = '';
my $vpn = '';
#  
#  
#  
#   
#    

sub connstate {
  `ip r | grep '^default via'` =~ /^default via \S+ dev (\S+)/;
  unless ($1) {
    print $notconn;
    return;
  }

  unless (`cat \"/sys/class/net/$1/operstate\"` eq "up\n") {
    print $notconn;
    return;
  }

  `ls /sys/class/net/$1/wireless 2>/dev/null`;
  if ($? == 0) {
    print $wireless;
  } else {
    print $ethernet;
  }
}

sub vpnstate {
  `pgrep openvpn` and print " $vpn";
}

connstate;
vpnstate;

