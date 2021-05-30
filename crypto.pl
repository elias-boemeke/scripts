#! /bin/perl

use strict;
use warnings;

my @chart = `curl -s \"rate.sx/?qTF&n=50\"`;
my $portfolio = `curl -s \"rate.sx/0.03207947ETH+1.84249794LINK+0.00221127BTC\"`;
chomp $portfolio;

my $reg = 'Market Cap|BTC Dominance|\sCoin\s|\sBTC\s|\sETH\s|\sLINK\s';

for (@chart) {
  if (/$reg/) {
    print "$_";
  }
}

my $buy = `qalc -t \"200€ to \$\"`;
$buy =~ /^\$(.*?)0*$/;
my $full = $1;
my $percent = ($portfolio - $full) / $full * 100;

# formatting
$percent = sprintf("%.2f", $percent);
$percent > 0 and $percent = "+" . $percent;
$portfolio = sprintf("%.2f", $portfolio);

print "\nHolding: \$$portfolio ($percent%)\n";

