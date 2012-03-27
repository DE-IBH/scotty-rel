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

package Scotty::POSIX;

use Scotty::Logging::Syslog;
use Proc::Daemon;
use IO::File;
use POSIX qw(mkfifo);
use strict;
use warnings;
our @ISA = qw(main);

$main::logger = Scotty::Logging::Syslog->new();
$main::logger->info("starting...");

#Proc::Daemon::Init;

my $FIFO_NAME = "/tmp/scotty-rel";
my $FIFO_PERM = 0700;
unless(-e $FIFO_NAME) {
	unless(mkfifo($FIFO_NAME, $FIFO_PERM)) {
		$main::logger->warning("mkfifo($FIFO_NAME) failed: $!");
	}
}
if(-r $FIFO_NAME) {
	my $fifo;
	if($fifo = new IO::File($FIFO_NAME, O_RDWR)) {
		$fifo->blocking(0);
		Event->io(
			desc => 'FIFO handler',
			fd => $fifo,
			poll => 'r',
			cb => \&main::cmd_handler,
			repeat => '1',
		);

		$main::logger->info("listening on $FIFO_NAME");
	}
	else {
		$main::logger->warning("open($FIFO_NAME) failed: $!");
	}
} else {
	$main::logger->warning("$FIFO_NAME not readable - ignoring");
}

1;
