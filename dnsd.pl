#!/usr/bin/perl
use FindBin;
chdir "${FindBin::Bin}";
use lib "${FindBin::Bin}/lib";

use strict;
use warnings;

while (1) {
    eval {
        use Net::DNS::Server;

        my $daemon = Net::DNS::Server->new(DNSTXT => '/etc/dns.txt');
        $daemon->run();
    };
    warn $@ if $@;
    sleep 6;
}
