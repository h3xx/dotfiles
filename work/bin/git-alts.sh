#!/bin/bash
GIT_ROOT=$(git rev-parse --show-toplevel)
cd "$GIT_ROOT" || exit

GD=''
if [[ -d .git ]]; then
	GD='.git'
fi

if [[ -f .git ]]; then
	GD="$(grep '^gitdir:' .git |cut -f 2- -d ' ')"
fi

if [[ ! -d $GD ]]; then
	echo "No git dir available" >&2
	exit 2
fi

REMOTE_URL="$(git remote -v |head -1 |tr '\t' ' ' |cut -f 2 -d ' ')"
ALT=''

case "$REMOTE_URL" in
	*/eclib.git)
		ALT=~/.gitrepos/eclib.git/objects
		;;
	*/emaxlib.git)
		ALT=~/.gitrepos/emaxlib.git/objects
		;;
	*/eventlib.git)
		ALT=~/.gitrepos/eventlib.git/objects
		;;
	*/autolib.git)
		ALT=~/.gitrepos/autolib.git/objects
		;;
	*/stylelib.git)
		ALT=~/.gitrepos/stylelib.git/objects
		;;
	*/jquery.git)
		ALT=~/.gitrepos/jquery.git/objects
		;;
	*/jqplot.git)
		ALT=~/.gitrepos/jqplot.git/objects
		;;
	*/phppowerpoint.git)
		ALT=~/.gitrepos/phppowerpoint.git/objects
		;;
	*/phpexcel.git)
		ALT=~/.gitrepos/phpexcel.git/objects
		;;
	*/ckeditor.git)
		ALT=~/.gitrepos/ckeditor.git/objects
		;;
	*/htmlpurifier.git)
		ALT=~/.gitrepos/htmlpurifier.git/objects
		;;
	*/odtphp.git)
		ALT=~/.gitrepos/odtphp.git/objects
		;;
	*/pchart.git)
		ALT=~/.gitrepos/pchart.git/objects
		;;
	*/smarty3.git)
		ALT=~/.gitrepos/smarty3.git/objects
		;;
	*/anet_php_sdk.git)
		ALT=~/.gitrepos/anet_php_sdk.git/objects
		;;
	*/apnsphp.git)
		ALT=~/.gitrepos/apnsphp.git/objects
		;;
	*/oxygen-icons.git)
		ALT=~/.gitrepos/oxygen-icons.git/objects
		;;
	*/google-api-php-client.git)
		ALT=~/.gitrepos/google-api-php-client.git/objects
		;;
    */*.git)
        if [[ -d ~/.gitrepos/"$(basename "$REMOTE_URL")" ]]; then
            ALT=~/.gitrepos/"$(basename "$REMOTE_URL")"/objects
        fi
        ;;
esac

if [[ ! -d $ALT ]]; then
	echo "No alt possible for this remote ($REMOTE_URL)" >&2
	exit 1
fi

if [[ -d $GD/objects/info ]]; then
	echo "$ALT" |tee "$GD/objects/info/alternates"
fi
