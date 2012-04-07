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
var idmap;
var ridmap = new Object();
var series = new Object();
var svgviews = new Object();
var svgdirty = new Object();
var svgcharts = new Object();
var viewstoload = new Array();
var viewsloaded = new Array();

function scotty_init() {
    var wsurl = window.location.toString().replace(/^http/i, "ws");
    if(wsurl.charAt(wsurl.length-1) != '/') {
	wsurl += '/';
    }
    wsurl += 'ws';
    log("[WS] URL = '" + wsurl + "'");
    ws = new WebSocket(wsurl);

    ws.onopen = function() {
        log("[WS] open");
    };
    ws.onmessage = function(e) {
        var m = JSON.parse(e.data);
        switch(m[0]) {
	    case "map":
		log("[WS] map:");
		idmap = m[1];
		for(var key in m[1]) {
		    log(key + " = " + m[1][key]);
		    ridmap[m[1][key]] = key;
		}
		break;
	    case "res":
		log("[WS] res:");
		for(var key in m[1]) {
		    scotty_adddata(key, m[1][key]);
		    log(key + " = " + series[key].join(','));
		}
		scotty_updatesvg(window.CURRENT_VIEW);
		break;
	    default:
		log("[WS] '" + m[0] + "' unkown");
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

function scotty_adddata(key, value) {
    if(typeof series[key] == "undefined") {
	series[key] = new Array(60);
    }

    series[key].push(value);
    if(series[key].length > 60) {
	series[key].shift();
    }

    svgdirty[key.split('#')[0]] = 1;
}

function scotty_updatesvg(view) {
    var svg = svgviews[view];

    for(var service in svgdirty) {
	if(!(typeof svgcharts[view][ridmap[service]] == "undefined")) {
	    var chart = svgcharts[view][ridmap[service]];

	    var points = new Array();
	    var dx = chart.width / 60;
	    var ox = chart.x;
	    var oy = chart.y + chart.height;
	    for(var i=0; i < series[service + "#0"].length; i++) {
		var v = series[service + "#0"][i];
		if(typeof v != "undefined") {
		    points.push([ox, oy - v]);
		}
		ox += dx;
	    }

	    if(typeof chart.line != "undefined") {
		svg.remove(chart.line);
	    }
	    chart.line = svg.polyline(points, {stroke: 'red', strokeWidth: 2});
	}
    }

    svgdirty = new Object();
}

function scotty_createChart(svg, chart) {
    svg.rect(chart.x, chart.y, chart.width, chart.height, {stroke: 'black', fill: 'none'});
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
    var view = this.id;
    svgviews["#" + view] = svg;
    svgcharts["#" + view] = new Object();
    $('rect[id^="so_"]', svg.root()).each(function() {
	log(' ' + this.id.substring(3));
	var chart = {
	    x: parseInt(this.getAttribute("x")),
	    y: parseInt(this.getAttribute("y")),
	    width: parseInt(this.getAttribute("width")),
	    height: parseInt(this.getAttribute("height")),
	};
	svg.remove(this);
	scotty_createChart(svg, chart);
	svgcharts["#" + view][this.id.substring(3)] = chart;
    });

    viewsloaded.push(this.id);
    if(viewstoload.length == viewsloaded.length) {
	log("[WS] Request map...");
	ws.send("connect");
    }
}
