#!/bin/bash
arg="$1"
shift
upload_to_base="shlomif@iglu.org.il:/iglu/cgi-bin/jobs/"
upload_to="${upload_to_base}new/"
if [ "$arg" = "--stable" ] ; then
    upload_to="$upload_to_base"
fi
rsync -v --progress --rsh=ssh --relative \
    *.pl MyConfig.pm style.css Shlomif/MiniReporter.pm WWW/Form.pm \
    "$upload_to"
