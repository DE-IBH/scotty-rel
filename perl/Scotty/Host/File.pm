# scotty-rel - Scotty RELOADED Network Management Tool
#
# Authors:
#   Thomas Liske <thomas@fiasko-nw.net>
#
# Copyright Holder:
#   2012 - 2013 (C) Thomas Liske [https://fiasko-nw.net/~thomas/tag/scotty]
#   2014        (C) IBH IT-Service GmbH [http://www.ibh.de/OSS/Scotty]
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

package Scotty::Host::File;

use Scotty::Host::Generic;
use strict;
use warnings;
our @ISA = qw(Scotty::Host::Generic);

sub new {
    my ($class, @p) = @_;
    my $self = Scotty::Host::Generic->new($class, @p);

	$main::logger->info("host source:");
	$main::logger->info(" filename = " . ${$self}{'filename'});

    die("$class requires filename option!\n") unless (${$self}{'filename'});
    die('Could not read file '.${$self}{'filename'}."!\n") unless (-r ${$self}{'filename'});

    return $self;
}

sub getXMLhosts {
    my ($self) = @_;

	open(HOSTS, ${$self}{'filename'});
	my @ret = <HOSTS>;
	close(HOSTS);
    
    return join("\n", @ret);
}

1;
