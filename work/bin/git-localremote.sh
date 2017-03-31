#!/bin/bash
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
REMOTE_NAME="$(git remote |head -1)"
LR=''
ALT=''

case "$REMOTE_URL" in
	*/eclib.git)
		LR=~/.gitrepos/eclib.git
        ALT=~/public_html/code/future-ec/.git/modules/php/eclib/objects
		;;
	*/emaxlib.git)
		LR=~/.gitrepos/emaxlib.git
        ALT=~/public_html/code/future-ec/.git/modules/php/emaxlib/objects
		;;
	*/eventlib.git)
		LR=~/.gitrepos/eventlib.git
        ALT=~/public_html/code/future-ec/.git/modules/php/eventlib/objects
		;;
	*/autolib.git)
		LR=~/.gitrepos/autolib.git
        ALT=~/public_html/code/future-ec/.git/modules/php/autolib/objects
		;;
	*/stylelib.git)
		LR=~/.gitrepos/stylelib.git
        ALT=~/public_html/code/future-ec/.git/modules/php/stylelib/objects
		;;
	*/jquery.git)
		LR=~/.gitrepos/jquery.git
        ALT=~/public_html/code/future-ec/.git/modules/php/jquery/objects
		;;
	*/jqplot.git)
		LR=~/.gitrepos/jqplot.git
        ALT=~/public_html/code/future-ec/.git/modules/php/jqplot/objects
		;;
	*/phppowerpoint.git)
		LR=~/.gitrepos/phppowerpoint.git
        ALT=~/public_html/code/future-ec/.git/modules/php/phppowerpoint/objects
		;;
	*/phpexcel.git)
		LR=~/.gitrepos/phpexcel.git
		;;
	*/ckeditor.git)
		LR=~/.gitrepos/ckeditor.git
        ALT=~/public_html/code/future-ec/.git/modules/php/ckeditor/objects
		;;
	*/htmlpurifier.git)
		LR=~/.gitrepos/htmlpurifier.git
        ALT=~/public_html/code/future-ec/.git/modules/php/htmlpurifier/objects
		;;
	*/odtphp.git)
		LR=~/.gitrepos/odtphp.git
        ALT=~/public_html/code/future-ec/.git/modules/php/odtphp/objects
		;;
	*/pchart.git)
		LR=~/.gitrepos/pchart.git
        ALT=~/public_html/code/future-ec/.git/modules/php/pchart/objects
		;;
	*/smarty3.git)
		LR=~/.gitrepos/smarty3.git
        ALT=~/public_html/code/future-ec/.git/modules/php/smarty3/objects
		;;
	*/anet_php_sdk.git)
		LR=~/.gitrepos/anet_php_sdk.git
        ALT=~/public_html/code/future-ec/.git/modules/php/anet_php_sdk/objects
		;;
	*/apnsphp.git)
		LR=~/.gitrepos/apnsphp.git
        ALT=~/public_html/code/future-ec/.git/modules/php/apnsphp/objects
		;;
	*/oxygen-icons.git)
		LR=~/.gitrepos/oxygen-icons.git
        ALT=~/public_html/code/future-ec/.git/modules/php/oxygen-icons/objects
		;;
	*/google-api-php-client.git)
		LR=~/.gitrepos/google-api-php-client.git
		;;
esac

if [[ ! -d $LR ]]; then
	echo "No alt possible for this remote ($REMOTE_URL)" >&2
	exit 1
fi

echo "$LR"
git remote set-url "$REMOTE_NAME" "$LR"

if [[ -d $ALT && -d $GD/objects/info ]]; then
    echo "$ALT" > $GD/objects/info/alternates
fi
