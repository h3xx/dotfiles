#!/usr/bin/env bash

HELP_MESSAGE() {
	local EXIT_CODE="${1:-0}"
	cat <<EOF
Usage: $(basename -- "$0") [OPTIONS] [--]
Open a web browser to create a new Gitlab pull request.

  -h		Show this help message.
  -s BRANCH	Set source branch (defaults to current branch).
  -t BRANCH	Set target branch (defaults to master).
  -T TEXT	Set merge request title (not working).
  -D TEXT	Set merge request description.
  -A REF_RANGE	Like -D, but copy description from commit messages in
		  REF_RANGE.
  -L REF	Like -A, but use only one REF.
  --		Terminate options list.

Copyright (C) 2015 Dan Church.
License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.
EOF
	exit "$EXIT_CODE"

}

url_encode() {
    perl -MURI::Escape -e 'print &uri_escape($_), "\n" foreach @ARGV' "$@"
}

TARGET_BRANCH='master'
SOURCE_BRANCH=''
MR_TITLE=''
MR_DESC=''
MR_DESC_FROM_REF=''

while getopts 'ht:s:T:D:A:L:' flag; do
	case "$flag" in
		't')
			TARGET_BRANCH="$OPTARG"
			;;
		's')
			SOURCE_BRANCH="$OPTARG"
			;;
		'T')
			MR_TITLE="$OPTARG"
			;;
		'D')
			MR_DESC="$OPTARG"
			MR_DESC_FROM_REF=''
			;;
		'A')
			MR_DESC_FROM_REF="$OPTARG"
			;;
		'L')
			MR_DESC_FROM_REF="${OPTARG}~1..${OPTARG}"
			;;
		'h')
			HELP_MESSAGE 0
			;;
		*)
			HELP_MESSAGE 1
			;;
	esac
done

shift "$((OPTIND-1))"

if [[ -z $SOURCE_BRANCH ]]; then
	SOURCE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
	if [ -z "$SOURCE_BRANCH" ]; then
		echo "Unable to determine current branch (are you in a git directory?)"
		exit 2
	fi
fi

# support -A argument
if [[ -n $MR_DESC_FROM_REF ]]; then
	# %b: only commit message (no title [%s])
	MR_DESC="$(git log --pretty=format:'%b' --no-notes "$MR_DESC_FROM_REF")"
    # TODO : gitlab doesn't use this
	#MR_TITLE="$(git log --pretty=format:'%s' --no-notes "$MR_DESC_FROM_REF")"
fi

# construct http args
http_args=(
	"merge_request[source_branch]=$SOURCE_BRANCH"
	"merge_request[target_branch]=$TARGET_BRANCH"
)

if [[ -n $MR_TITLE ]]; then
    http_args+=("merge_request[title]=$(url_encode "$MR_TITLE")")
fi

if [[ -n $MR_DESC ]]; then
    http_args+=("merge_request[description]=$(url_encode "$MR_DESC")")
fi

# concatenate all args, URL encoding '&' to %26
http_params="$(IFS='&';echo "${http_args[*]//&/%26}")"

# construct URL
push_url="$(git remote -v |sed -e 's#^'"$(git config "branch.$SOURCE_BRANCH.remote")"'\s*\(.*\)\s*(push)$#\1# p;d')"
# not working:
#push_url="$(git config "remote.$(git config "branch.$SOURCE_BRANCH.remote").url")"

if [[ -z $push_url ]]; then
	echo "Unable to determine push URL (are you in a git directory?)"
	exit 2
fi

http_url="$(echo $push_url |perl -p -e ' s#^ssh://##; s#:\d+/#/#; if (m#^\w*@#) { s#:#/#g; s#^\w*@#https://#; } s#\.git$##;')"
pull_request_url="$http_url/merge_requests/new?$http_params"

# (debugging)
#echo "$pull_request_url"
#for param in "${http_args[@]}"; do
#	echo ": $param"
#done
google-chrome "$pull_request_url"
