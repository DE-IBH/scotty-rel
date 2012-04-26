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

package Scotty::Sensor::snmp;

use Scotty::Sensor;
use strict;
use warnings;
use Data::Dumper;
use JSON;
use SNMP;
our @ISA = qw(Scotty::Sensor);

sub new {
    my ($class, $service, $config) = @_;
    my $self = Scotty::Sensor->new($class, $service);

    my @copts = qw(oid label color unit sminx smax state);
    my $len;
    foreach my $copt (@copts) {
	die "Config option $copt not set!\n"
	    unless(defined($config->{$copt}));

	$self->{query}->{$copt} = split(/!/, $config->{$copt});
	unless(defined($len)) {
	    $len = $#{ $self->{query}->{$copt} };
	}
	elsif ( $#{ $self->{query}->{$copt} } != $len ) {
	    die "Config option value $copt is invalid!\n";
	}
    }

    bless $self, $class;
    return $self;
}

sub register {
    my ($self, $idmap, $host, $params) = @_;

    $self->{idmap} = $idmap;
    $self->{hosts}->{$host} = $params;
    $main::logger->info("register $self->{service}: $host ".join(', ', %{$params}));
}

sub series() {
    my ($self) = @_;

    return {
	label => $self->{query}->{label},
	interval => 5,
	unit => $self->{query}->{unit},
	color => $self->{query}->{color},
	min => $self->{query}->{smin},
	max => $self->{query}->{smax},
    };
}

sub targets {
    my ($self) = @_;

    return keys %{$self->{idmap}};
}

sub worker {
    my ($self) = @_;

    foreach my $host (keys %{$self->{hosts}}) {
	$self->{idmap}->getID("${host}_$self->{service}");
    }

    my $wh = $self->SUPER::worker();
    if(defined($wh)) {
	while(1) {
	    print $wh encode_json()."\n";
	}
    }
}

1;
