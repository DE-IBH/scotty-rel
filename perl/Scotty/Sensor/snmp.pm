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

    get_config($self, $config);

    bless $self, $class;
    return $self;
}

sub get_config($$) {
    my ($self, $config) = @_;

    foreach my $node ($config->get_nodelist()) {
	my %config = (
	    oid => undef,
	    label => undef,
	    color => 'black',
	    unit => '',
	    min => 0,
	    max => undef,
	    monitor => undef,
	);

	foreach my $key (keys %config) {
	    my $value = $node->findvalue($key);
	    $config{$key} = $value if(defined($value));
	
	    push(@{$self->{query}->{$key}}, (defined($value) ? $value : $config{$key}));
	}

	die "Config value 'oid' not defined!\n"
	    unless(defined($config{oid}));

    }
}

sub register {
    my ($self, $idmap, $host, $params) = @_;

    $self->{idmap} = $idmap;
    $self->{hosts}->{$host} = $params;
    $main::logger->info("register $self->{service}: $host (".join(', ', @{$params}).')');
}

sub series() {
    my ($self) = @_;

    return {
	label => $self->{query}->{label},
	interval => 5,
	unit => $self->{query}->{unit},
	color => $self->{query}->{color},
	min => $self->{query}->{min},
	max => $self->{query}->{max},
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
	    sleep(60);
	    #print $wh encode_json()."\n";
	}
    }
}

1;
