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

package Scotty::HostMap;

use strict;
use warnings;

sub new {
    my ($class) = @_;

    my $self = {
	hostmap => { },
	nextid => 0,
    };

    bless $self, $class;
    return $self;
}

sub getHost {
    my ($self, $hostname) = @_;

    unless(exists($self->{hostmap}->{$hostname})) {
	$self->{hostmap}->{$hostname} = hex($self->{nextid});
	$self->{nextid}++;
    }

    return $self->{hostmap}->{$hostname};
}

sub getMap {
    my ($self) = @_;

    return $self->{hostmap};
}

1;