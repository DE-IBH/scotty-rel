/*
scotty-rel - Scotty RELOADED Network Management Tool

Authors:
  Thomas Liske <thomas@fiasko-nw.net>

Copyright Holder:
  2012 (C) Thomas Liske [http://fiasko-nw.net/~thomas/]

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
*/

$(function () {
    var tabDivs = $('div.tabs > div');

    $('div.tabs ul.nav a').click(function () {
        tabDivs.hide().filter(this.hash).show();

        $('div.tabs ul.tabNavigation a').removeClass('selected');
        $(this).addClass('selected');

        window.CURRENT_VIEW = this.hash;
        log('Viewing '  + this.hash.substr(1) + '...');

        return false;
    }).filter(':first').click();
});

function log(msg) {
    $('#log').append(new Date().toTimeString() + " " + msg + "\n");
    $('#log').scrollTop($('#log')[0].scrollHeight - $('#log').height());
}

var ws;
var viewstoload = new Array();
var viewsloaded = new Array();

function scotty_init() {
    var wsurl = window.location + "/ws";
    wsurl.replace(/^http/i, "ws");
    log("[WS] URL = " + wsurl);
    ws = new WebSocket("ws://localhost:3000/ws");

    ws.onopen = function() {
        log("[WS] open");
    };
    ws.onmessage = function(e) {
        var m = JSON.parse(e.data);
        switch(m.op) {
	    case "map":
		log("[WS] map:");
		for(var key in m.pl) {
		    log(key + " = " + m.pl[key]);
		}
		break;
	    case "res":
		log("[WS] res:");
		for(var key in m.pl) {
		    log(key + " = " + m.pl[key]);
		}
		break;
	    default:
		log("[WS] unsupported op '" + m.op + "'");
		break;
        }
    };
    ws.onclose = function() {
        log("[WS] closed");
    };
    ws.onerror = function() {
        log("[WS] failed");
    };
}

function scotty_loadView(id, view) {
    viewstoload.push(id);
    $('#' + id).svg({loadURL: view, onLoad: scotty_loadViewDone});
}

function scotty_loadViewDone(svg, error) {
    if(error) {
	log('Failed: ' + error);
	svg.text(10, 20, error, {fill: 'red'});
	return;
    }

    log('Searching charts...');
    var charts = new Array();
    $('rect[id^="so_"]', svg.root()).each(function() {
	charts.push(this.id);
    });
    log(' ' + charts.join(', '));

    viewsloaded.push(this.id);
    if(viewstoload.length == viewsloaded.length) {
	log("[WS] Request map...");
	ws.send("connect");
    }
}
