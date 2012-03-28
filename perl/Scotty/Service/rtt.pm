# scotty-rel - Scotty RELOADED Network Management Tool
#
# Authors:
#   Thomas Liske <thomas@fiasko-nw.net>
#
# Copyright Holder:
#   2012 (C) Thomas Liske [http://fiasko-nw.net/~thomas/]
#
# License:
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this package; if not, write to the Free Software
#   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
#

package Scotty::Service::rtt;

use Scotty::Service;
use strict;
use warnings;
use IPC::Open3;
use Symbol 'gensym';
our @ISA = qw(Scotty::Service);
my %hosts;
my %loss;
my %rtt;

sub new {
    my ($class) = @_;
    my $self = Scotty::Service->new($class);

    bless $self, $class;
    return $self;
}

sub register {
    my ($self, $host, $params) = @_;

    $hosts{$host} = $params;

    $main::logger->info("register: $host");
}

sub fping_handler() {
    my $event = shift;
    my $h = $event->w->fd;
    return if eof($h);

    my $l = <$h>;
    chomp($l);

    # new period
    if($l =~ /^\[[:\d]+\]$/) {
	%loss = ();
	%rtt = ();
	return;
    }

    if($l =~ m@^(.+)\s*: xmt/rcv/\%loss = \d+/\d+/(\d+)%, min/avg/max = [\d.]+/([\d.]+)/[\d.]+@) {
	$loss{$1} = $2;
	$rtt{$1} = $3;
	return
    }

    warn "Unhandled fping output '$l'!\n";
}

sub worker {
    my ($self) = @_;

    my ($out, $in, $err);
    $err = gensym;
    my $pid = open3($out, $in, $err, qw(fping -Q 5 -p 1250 -l));
    close($in);

    print $out join("\n", keys %hosts, '');
    close($out);

    Event->io(
	desc => 'fping',
	fd => $err,
	poll => 'r',
	cb => \&fping_handler,
	repeat => '1',
    );
}

1;
