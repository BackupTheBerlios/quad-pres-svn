#!/bin/bash
rsync -v --progress --rsh=ssh --relative \
    *.pl MyConfig.pm style.css Shlomif/MiniReporter.pm WWW/Form.pm \
    shlomif@iglu.org.il:/iglu/cgi-bin/jobs/new/
