#!/bin/sh

prep() {
	local \
		in \
		out="$1"

	(for in; do
		cat "$in"
	done) | perl -p -e 's,(^\s+|\s+\n),,' |sort -u |grep -v '^$' >"$out"
}

tr_out=~/.vim/dict/php/TemplateRequest.php
tr=~/future/php/eventlib/page/TemplateRequest.php
prep "$tr_out" "$tr"

my_out=~/.vim/dict/php/menu.yaml
prep "$my_out" ~/future/php/eclib/data/menu*.yaml

ay_out=~/.vim/dict/php/access.yaml
ay=~/future/php/eclib/data/access.yaml
prep "$ay_out" "$ay"

cl_out=~/.vim/dict/php/class_list.txt
find \
	~/future/php/eclib/{page,shell,database,utility} \
	-type f \
	-name '*.php' \
	-exec basename {} .php \; |
sort -u >"$cl_out"
