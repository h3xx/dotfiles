#!/usr/bin/perl -w
use strict;

# parses ${INFOCOM_PATH}/*.z* and generates a fluxbox-compatible menu in ./infocom

open MENU, '>infocom';
print MENU "[submenu] (infocom)\n";

opendir INFOCOM, "$ENV{INFOCOM_PATH}";

foreach (readdir INFOCOM) {
s/(\s+.)(\S*)/\U$1\L$2/g
}
closedir INFOCOM;

print MENU "[end]\n";
close MENU;
