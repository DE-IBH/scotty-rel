<?xml version="1.0"?>

<!--
scotty-rel - Scotty RELOADED Network Management Tool

Authors:
  Thomas Liske <thomas@fiasko-nw.net>

Copyright Holder:
  2012 - 2013 (C) Thomas Liske [https://fiasko-nw.net/~thomas/tag/scotty]
  2014        (C) IBH IT-Service GmbH [http://www.ibh.de/OSS/Scotty]

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

  <xsl:template match="/">
    <xsl:for-each select="*">
	<xsl:copy>
	    <xsl:attribute name="viewBox"><xsl:text>0 0 </xsl:text><xsl:value-of select="@width"/><xsl:text> </xsl:text><xsl:value-of select="@height"/></xsl:attribute>
	    <xsl:copy-of select="@*"/>
	    <xsl:copy-of select="*"/>
	</xsl:copy>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
