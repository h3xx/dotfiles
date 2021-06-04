#!/bin/sh
# vi: et sts=4 sw=4 ts=4

# Sometimes a remote branch reflog can contain a commit that doesn't exist
# ...which makes fsck fail
# ...which causes repack to fail
# ...which leads to thousands of unpacked objects lying around
# ...which leads to gc always auto-triggering because it thinks it will help
#    speed up graph traversal
# ...which leads to gc failing over and over again, generating error logs,
#    eating away at your hard disk lifetime
# ...which leads to decreased hard drive lifetime
# ...which causes catastrophic data loss
# ...which leads to getting fired
# ...which leads to financial ruin and destitution
#
# ...all because some joker force-pushed a branch or deleted a tag, or
#    something else out of your control.
#
# Use this command to get your life back on track.

git reflog expire \
    --stale-fix \
    --expire-unreachable=now \
    --all \
    --rewrite &&
for remote in $(git remote); do
    git remote set-head "$remote" --delete
done
