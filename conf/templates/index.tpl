<html>
<head>
<style type="text/css">
@import "res/tabs.css";
@import "lib/svg.js/jquery.svg.css";
@import "lib/qTip2/jquery.qtip.min.css";
</style>
<script type="text/javascript" src="lib/jquery/jquery-1.8.0.min.js"></script>
<script type="text/javascript" src="lib/jquery.spin.js/jquery.spin.js"></script>
<script type="text/javascript" src="lib/svg.js/jquery.svg.js"></script>
<script type="text/javascript" src="lib/svg.js/jquery.svggraph.js"></script>
<script type="text/javascript" src="lib/qTip2/jquery.qtip.min.js"></script>
<script type="text/javascript" src="lib/spin.js/spin.min.js"></script>
<script type="text/javascript" src="lib/web-socket-js/swfobject.js"></script>
<script type="text/javascript" src="lib/web-socket-js/web_socket.js"></script>
</head>
<body>
<div id="scotty_about_popup">
<span style="float: right"><a href="javascript:scotty_about();" style="text-decoration: none">x</a></span>
<h1>Scotty RELOADED</h1>
<pre style="text-align: left">
Author:
  Thomas Liske &lt;<a href="mailto:thomas@fiasko-nw.net">thomas@fiasko-nw.net</a>&gt;

Copyright Holder:
  2012 - 2013 (C) Thomas Liske [<a href="http://fiasko-nw.net/~thomas/">http://fiasko-nw.net/~thomas/</a>]

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
</pre>
</div>
<div id="scotty_chart">
<table>
    <tr>
	<td class="scotty_chart_title">Host:</th>
	<td class="scotty_chart_value" id="sc_host"></td>
    </tr>
    <tr>
	<td class="scotty_chart_title">Data:</th>
	<td class="scotty_chart_value" id="sc_data"></td>
    </tr>
</table>
</div>
<div id="scotty_hb"></div>
<div id="scotty_about"><small><a href="javascript:scotty_about();" style="text-decoration: none">Scotty RELOADED</a></small></div>
<div class="tabs">
    <ul class="nav">
{
    foreach my $id (sort keys %views) {
	$OUT .= "<li><a href=\"#$id\"><span>$id</span></a></li>\n";
    }
}
    </ul>
{
    foreach my $id (sort keys %views) {
	$OUT .= "<div class=\"svgview\" id=\"$id\"></div>\n";
    }
}
</div>
<div id="scotty_logd"><textarea id="log" readonly="1"></textarea></div>
<script type="text/javascript" src="res/index.js"></script>
<script type="text/javascript">

WEB_SOCKET_SWF_LOCATION = "web-socket-js/WebSocketMain.swf";
WEB_SOCKET_DEBUG = true;

scotty_init();

{
    my $first = 0;
    foreach my $id (sort keys %views) {
	$OUT .= "window.CURRENT_VIEW = \"$id\";\n" unless($first++);

	my $view = $views{$id};
	$OUT .= "scotty_loadView('$id', 'views/$view');\n";
    }
}

</script>
</html>
