" apply patches
insert
(build_script=$(readlink -f -- "$BASH_SOURCE")
patch_dir=$(dirname -- "$build_script")/patches
for patch in "$patch_dir"/FILE-*.patch ; do
.
s/FILE/\=expand("%:t:r")/
append
    rejfile=$(mktemp -t 'patch.XXXXXX')
    patch -p1 -N -r "$rejfile" <"$patch" |cat
    rm -f "$rejfile"
    true
done) &&
.
