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
use EV;
use IO::Pipe;

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
    }

    $services{$service}->register($idmap, \%series, $host, $params);
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

sub targets() {
    my ($self) = @_;

    die(${$self}{_class} . " did not override targets method!\n");
}

sub worker() {
    my ($self) = @_;

    my $pipe = IO::Pipe->new();
    my $pid = fork();
    die "Cannot fork!\n" unless(defined($pid));
    if($pid == 0) {
	$0 = "scotty-backend_$self->{service}";
	main::close_fds();
	$pipe->writer();
	$pipe->autoflush(1);
	return $pipe;
    }
    $pipe->reader();
    main::register_fd($pipe);

    $self->{wpipe} = EV::io $pipe, EV::READ, \&main::sensor_data;

    return undef;
}

sub push_hashref($$) {
    my ($self, $wh, $ref) = @_;

    print $wh $main::json->encode($ref)."\n" if(scalar keys %$ref > 0);
}

1;
