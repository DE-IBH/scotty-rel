Scotty RELOADED Network Monitoring Tool
=======================================

About
-----

Scotty RELOADED retrieves status information about network components
using sensor plugins (e.g. rtt, snmp). The data is presented to the user by
a browser based user interface. The backend is implemented in Perl using
the Mojolicious framework. The user interfaces uses HTML5 and JavaScript
technologies based on jQuery and some additional jQuery plugins.

Install
-------

Read [INSTALL.md](INSTALL.md).


History
-------

The Scotty RELOADED Network Monitoring Tool is a complete rewrite of
the ancient Scotty and Tkined Network Management Tools.

The Scotty and Tkined Network Management Tools were developed by
Juergen Schoenwaelder and many contributors.

I did some improvements on the graphical frontend in the year 2008.

I'd tried to rewrite it the first time using Ruby till the beginning of
the year 2010. Although it had an advanced featureset (client/server
design using Ruby Tuble Spaces, Linux/Win32 GUI clients, ...) it had
some performance/bandwidth issues and no designer gui.

In the meantime, due the development of websockets and other advanced web
techniques Scotty RELOADED is born - another complete rewrite in Perl
using a 3 Tier design and advanced web techniques.
