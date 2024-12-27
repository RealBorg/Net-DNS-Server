package Net::DNS::Server;

use File::Slurp;
use IO::Socket::IP;
use List::Util;
use Net::DNS;

use strict;
use warnings;

sub new {
	my ($class, @args) = @_;

    my $self = {
        DNSTXT => '/etc/dns.txt',
        LocalAddr => '::',
        LocalPort => 53,
        Proto => 'udp',
        @args,
    };
    $self = bless($self);
    my $socket = IO::Socket::IP->new(%{$self});
    die $@ unless $socket;
    $self->{socket} = $socket;
	return $self;
}
 
sub run {
	my ($self) = @_;

    PACKET: while (1) {
        my $packet;
        $self->{socket}->recv($packet, 15000);
        next unless $packet;
        my $time = time();
        $packet = Net::DNS::Packet->new(\$packet);
        next unless $packet;
        my $header = $packet->header;
        next PACKET unless $header->opcode eq 'QUERY';
        next PACKET unless $header->qr == 0;
        my $peerhost = $self->{socket}->peerhost();
        my $reply = $packet->reply;
        $reply->header->ra(0);
        my $records = $self->get_records;
        for my $question ($packet->question) {
            my $qname = $question->qname;
            my $qclass = $question->qclass;
            my $qtype = $question->qtype;

            my $host = $records->{lc($qname)};

            if ($host) {
                $reply->header->rcode('NOERROR');
                $reply->header->aa(1);
                my $rrs = $host->{$qclass.' '.$qtype};
                for my $rr (List::Util::shuffle(@{$rrs})) {
                    $reply->push(answer => $rr);
                }
                if ($qtype eq 'NS' || $qtype eq 'MX') {
                    $rrs = $host->{'IN A'};
                    $reply->push(additional => List::Util::shuffle(@{$rrs})) if $rrs;
                }
            } else {
                $reply->header->rcode('REFUSED');
            }
            STDOUT->printf("%s %s %-15s %-5s %s %s %s %s\n",
                __PACKAGE__,
                POSIX::strftime("%Y-%m-%dT%H:%M:%S", gmtime($time)),
                $peerhost,
                $reply->header->id,
                $qname,
                $qclass,
                $qtype,
                $reply->header->rcode,
            );
        }
        $self->{socket}->send($reply->data);
    }
}

sub get_records {
    my ($self) = @_;

    my $stat = [ stat($self->{DNSTXT}) ];
    die sprintf("stat: %s: %s", $self->{DNSTXT}, $@) unless $stat;
    my $records;
    my $mtime = $stat->[9];
    unless ($self->{MTIME} && $mtime > $self->{MTIME}) {
        my $data = read_file($self->{DNSTXT});
        die sprintf("read_file: %s: %s", $self->{DNSTXT}, $@) unless $data;
        for my $line (split(/\n/, $data)) {
            next if $line =~ /^$/;
            next if $line =~ /^#/;
            my $rr = Net::DNS::RR->new($line);
            if ($rr->type eq 'MX') {
                $rr->preference(10) unless $rr->preference;
                $rr->exchange($rr->owner) unless $rr->exchange;
            } elsif ($rr->type eq 'NS') {
                $rr->nsdname($rr->owner) unless $rr->nsdname;
            } elsif ($rr->type eq 'SOA') {
                $rr->mname($rr->owner) unless $rr->mname;
                $rr->rname('hostmaster.'.$rr->owner) unless $rr->rname;
                $rr->serial($mtime) unless $rr->serial;
                $rr->refresh(24*60*60) unless $rr->refresh;
                $rr->retry(60*60) unless $rr->retry;
                $rr->expire(365*24*60*60) unless $rr->expire;
                $rr->minimum(60*60) unless $rr->minimum;
            }
            $rr->ttl(60*60) unless $rr->ttl;
            push @{$records->{$rr->owner}->{$rr->class.' '.$rr->type}}, $rr;
            push @{$records->{$rr->owner}->{$rr->class.' ANY'}}, $rr;
            #STDOUT->print($rr->plain, "\n");
        }
        $self->{RECORDS} = $records;
        $self->{MTIME} = $mtime;
    }
    return $self->{RECORDS};
}

1;
