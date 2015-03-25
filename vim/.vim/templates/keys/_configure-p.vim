" apply patches
:append
(for patch in ~/downloads/build/_sources/celestia-*.patch ; do
	rejfile="$(mktemp -t 'patch.XXXXXX')"
	patch -p1 -N -r "$rejfile" <"$patch" |cat
	rm -f "$rejfile"
	true
done) &&
.
