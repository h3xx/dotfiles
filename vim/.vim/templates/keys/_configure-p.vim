" apply patches
append
(build_script="$(readlink -f -- "$BASH_SOURCE")"
patch_dir="$(dirname -- "$build_script")/patches"
for patch in "$patch_dir"/celestia-*.patch ; do
	rejfile="$(mktemp -t 'patch.XXXXXX')"
	patch -p1 -N -r "$rejfile" <"$patch" |cat
	rm -f "$rejfile"
	true
done) &&
.
