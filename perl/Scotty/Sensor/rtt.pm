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

package Scotty::Sensor::rtt;

use Scotty::Sensor;
use strict;
use warnings;
use IPC::Open3;
use Symbol 'gensym';
use Statistics::Basic qw(:all);
use JSON;
our @ISA = qw(Scotty::Sensor);

sub new {
    my ($class) = @_;
    my $self = Scotty::Sensor->new($class);

    bless $self, $class;
    return $self;
}

sub register {
    my ($self, $id, $host, $params) = @_;

    $self->{hostmap}->{$host} = $id;

    $main::logger->info("register: $host ($id)");
}

sub series() {
    my ($self) = @_;

    return (
	series => ['rtt', 'pl'],
	interval => [5, 5],
	units => ['ms', '%'],
    );
}

sub targets {
    my ($self) = @_;

    return keys %{$self->{hostmap}};
}

sub worker {
    my ($self) = @_;

    my $wh = $self->SUPER::worker();
    if(defined($wh)) {
	my $targets = join("\n", keys %{$self->{hostmap}}, '');

	while(1) {
	    my ($out, $in, $err);
	    $err = gensym;
	    my $pid = open3($out, $in, $err, qw(fping -q -p 1000 -C 5));
	    close($in);

	    print $out $targets;
	    close($out);

	    my %res;
	    while(defined(my $l = <$err>)) {
		chomp($l);

		if($l =~ m@^(\S+)\s*: ([\d. -]+)$@) {
		    my $id = $self->{hostmap}->{$1};
		    my @mea = split(/ /, $2);
		    my @rtt = grep {/[^-]/} @mea;

		    $res{"${id}_$self->{service}|pl"} = 100 - 100*($#rtt + 1)/($#mea + 1);
		    $res{"${id}_$self->{service}|rtt"} = ($#rtt > -1 ? median(@rtt)*1.0 : undef);
		}
		else {
		    warn "Unhandled fping output '$l'!\n";
		}
	    }

	    print $wh encode_json({op => 'res', pl => \%res})."\n";
	}
    }
}

1;
