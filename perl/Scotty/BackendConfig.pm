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
use Scotty::Host::Generic;
use strict;

sub parse_config() {
	my ($xml_cfgfile) = @_;
	die "Usage: $0 <views.xml>\n" unless (defined($xml_cfgfile));
	die "Could not read views XML file!\n" unless (-r $xml_cfgfile);

	my $xml_parser = XML::LibXML->new();
	my $xml_dom = $xml_parser->parse_file($xml_cfgfile);

	&parse_services($xml_dom, '//service');
}

sub parse_services() {
	my ($ctx, $xpath) = @_;

	my $res = $ctx->findnodes($xpath);
	die "config file: empty XPath node list: $xpath\n" unless ($res->isa('XML::LibXML::NodeList'));

	foreach my $nctx ($res->get_nodelist) {
		my $host = $nctx->findvalue("../\@name");
		my $service = lc($nctx->findvalue("\@name"));
		my $params = $nctx->findvalue("\@params");
		
		eval("require Scotty::Service::$service;");
		die($@) if $@;

		eval("Scotty::Service::$service::add($host, $params);");
		die($@) if $@;
	}
}

1;
