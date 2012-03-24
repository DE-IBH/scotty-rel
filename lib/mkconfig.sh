#!/bin/bash

XSLDIR=${2:-/usr/share/scotty-rel/xsl}
CFGDIR=${1:-/etc/scotty-rel}
WWWDIR=${3:-/var/www/scotty-rel}
VIEWSDIR="$WWWDIR/views"

function err {
    logger -s -t scotty-rel -- "Configuration error: $@"
    exit 1
}

SRVFN=`tempfile -p srv -s xml`
V2SFN=`tempfile -p v2s -s xml`
for fn in "$VIEWSDIR/"*.svg; do
    if [ ! -e "$fn" ]; then
	rm "$SRVFN"
	rm "$V2SFN"
	err no views found "($VIEWSDIR/*.svg)"
    fi

    xsltproc -o "$V2SFN" "$XSLDIR/view2services.xsl" "$fn" || err xsltproc processing failed on $fn
    tail -n +2 "$V2SFN" >> "$SRVFN"
done
rm "$V2SFN"

cat "$SRVFN"

rm "$SRVFN"
