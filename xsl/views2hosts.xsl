<?xml version="1.0"?>

<!--
scotty-rel - Scotty RELOADED Network Management Tool

Authors:
  Thomas Liske <thomas@fiasko-nw.net>

Copyright Holder:
  2012 - 2014 (C) Thomas Liske [http://fiasko-nw.net/~thomas/]

License:
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this package; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml" indent="yes"/>

  <xsl:key name="hosts" match="host" use="@name" />

  <xsl:template match="/">
    <hosts>
      <snmp>
	<version>2c</version>
	<community>public</community>
      </snmp>

      <xsl:for-each select="//host[generate-id(.)=generate-id(key('hosts', @name)[1])]">
	<xsl:sort select="@name" />
	<host>
	  <xsl:attribute name="name"><xsl:value-of select="@name"/></xsl:attribute>
	  <ip><xsl:text>##</xsl:text><xsl:value-of select="@name"/><xsl:text>##</xsl:text></ip>
	</host>
      </xsl:for-each>
    </hosts>
  </xsl:template>
</xsl:stylesheet>
