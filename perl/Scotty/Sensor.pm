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

package Scotty::Sensor;

use strict;
use warnings;
use Scotty::IDMapper;
use Event;

my %services;
my %series;
my %pipes;
my $idmap = Scotty::IDMapper->new();

sub new {
    my ($class, $oclass, $service) = @_;

    $oclass =~ /::([^:]+)$/;

    my $self = {
	_class => $oclass,
	service => $service,
    };

    bless $self, $class;
    return $self;
}

sub add {
    my ($srvfile, $service, $host, $xml_parser, $params) = @_;

    unless(exists($services{$service})) {
	die "Service config file '$srvfile' not found!\n" unless(-r $srvfile);
	my $sdom = $xml_parser->parse_file($srvfile);

	my $sensor = $sdom->findvalue("/service/sensor/\@name");
	die "Service $service did not have a sensor name!\n" unless(defined($sensor));

	my $config = $sdom->findnodes("/service/sensor/config/*");

	eval("require $sensor;");
	die($@) if $@;

	eval("\$services{\$service} = ${sensor}->new(\$service, \$config);");
	die($@) if $@;

	$series{$service} = $services{$service}->series();
    }

    $services{$service}->register($idmap, $host, $params);
}

sub start_worker() {
    $main::logger->info("Forking working processes...");
    foreach my $service (keys %services) {
	$services{$service}->worker();
    }
}

sub getMap() {
    return $idmap->getMap();
}

sub getSeries() {
    return \%series;
}


sub register {
    my ($self) = @_;

    die(${$self}{_class} . " did not override register method!\n");
}

sub series() {
    my ($self) = @_;

    die(${$self}{_class} . " did not override series method!\n");
}

sub targets() {
    my ($self) = @_;

    die(${$self}{_class} . " did not override targets method!\n");
}

sub worker() {
    my ($self) = @_;

    my ($RH, $WH);
    pipe $RH, $WH;
    my $pid = fork();
    die "Cannot fork!\n" unless(defined($pid));
    if($pid == 0) {
	close($RH);
	return *$WH;
    }
    close($WH);
    Event->io(
	desc => "$self",
	fd => *$RH,
	poll => 'r',
	cb => \&main::sensor_data,
	repeat => '1',
    );

    return undef;
}

1;
