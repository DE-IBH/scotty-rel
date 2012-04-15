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

package Scotty::BackendConfig;

use XML::LibXML;
use Scotty::Sensor;
use strict;
use warnings;

sub parse_config() {
	my ($confdir) = @_;
	die "Usage: $0 <config directory>\n" unless (defined($confdir));
	die "Config directory invalid: $confdir\n" unless (-d $confdir);
	die "Could not read views XML file ($confdir/views.xml)!\n" unless (-r "$confdir/views.xml");

	my $xml_parser = XML::LibXML->new();
	my $xml_dom = $xml_parser->parse_file("$confdir/views.xml");

	&parse_services($confdir, $xml_dom, '//service');
}

sub parse_services() {
	my ($confdir, $ctx, $xpath) = @_;

	my $res = $ctx->findnodes($xpath);
	die "config file: empty XPath node list: $xpath\n" unless ($res->isa('XML::LibXML::NodeList'));

	foreach my $nctx ($res->get_nodelist) {
		my $host = $nctx->findvalue("../\@name");
		my $service = lc($nctx->findvalue("\@name"));
		my $params = $nctx->findvalue("\@params");

		Scotty::Sensor::add($service, $host, $params);
	}
}

1;
